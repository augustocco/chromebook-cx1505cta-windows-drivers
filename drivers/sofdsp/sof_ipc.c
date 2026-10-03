// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * sof_ipc.c -- SOF IPC3 transport for Intel cAVS 2.5 (ASUS Chromebook CX15 "Telith")
 *
 * Ported from Linux sound/soc/sof/ipc3.c, sound/soc/sof/intel/cnl.c and
 * hda-ipc.c, Copyright(c) 2018 Intel Corporation (dual BSD-3-Clause /
 * GPL-2.0).
 */

#include "sof_dsp.h"

static void mbox_read(PSOF_DSP Dsp, ULONG off, void* buf, ULONG size)
{
	READ_REGISTER_BUFFER_UCHAR(Dsp->DspBar + off, (PUCHAR)buf, size);
}

static void mbox_write(PSOF_DSP Dsp, ULONG off, const void* buf, ULONG size)
{
	WRITE_REGISTER_BUFFER_UCHAR(Dsp->DspBar + off, (PUCHAR)buf, size);
}

static void sof_ipc_set_windows(PSOF_DSP Dsp, const struct sof_ipc_window* window)
{
	ULONG i;

	for (i = 0; i < window->num_windows && i < SOF_IPC_MAX_ELEMS; i++) {
		const struct sof_ipc_window_elem* elem = &window->window[i];
		ULONG elemOffset = SRAM_WINDOW_OFFSET(elem->id) + elem->offset;

		switch (elem->type) {
		case SOF_IPC_REGION_UPBOX:      /* DSP -> host */
			Dsp->DspBoxOffset = elemOffset;
			Dsp->DspBoxSize = elem->size;
			break;
		case SOF_IPC_REGION_DOWNBOX:    /* host -> DSP */
			Dsp->HostBoxOffset = elemOffset;
			Dsp->HostBoxSize = elem->size;
			break;
		case SOF_IPC_REGION_STREAM:
			Dsp->StreamBoxOffset = elemOffset;
			Dsp->StreamBoxSize = elem->size;
			break;
		default:
			break;
		}
	}
}

//
// Extended manifest of the firmware file (ipc3_fw_ext_man_get_windows).
// Firmware built without runtime ext data publishes its windows only here.
//

void SofIpcParseExtManifest(_Inout_ PSOF_DSP Dsp, _In_reads_bytes_(FwSize) const UCHAR* Fw, _In_ ULONG FwSize)
{
	const struct sof_ext_man_header* hdr = (const struct sof_ext_man_header*)Fw;
	ULONG offset, end;

	if (FwSize < sizeof(*hdr) || hdr->magic != SOF_EXT_MAN_MAGIC_NUMBER)
		return;

	end = min(hdr->full_size, FwSize);
	offset = hdr->header_size;

	while (offset + sizeof(struct sof_ext_man_elem_header) <= end) {
		const struct sof_ext_man_elem_header* elem = (const struct sof_ext_man_elem_header*)(Fw + offset);

		if (elem->size < sizeof(*elem) || offset + elem->size > end)
			break;

		if (elem->type == SOF_EXT_MAN_ELEM_WINDOW &&
			elem->size >= sizeof(*elem) + FIELD_OFFSET(struct sof_ipc_window, window)) {
			struct sof_ipc_window window;
			ULONG size = min(elem->size - (ULONG)sizeof(*elem), (ULONG)sizeof(window));

			RtlZeroMemory(&window, sizeof(window));
			RtlCopyMemory(&window, Fw + offset + sizeof(*elem), size);
			sof_ipc_set_windows(Dsp, &window);
		}

		offset += elem->size;
	}
}

//
// FW_READY extended data (ipc3_fw_parse_ext_data / ipc3_get_windows)
//

NTSTATUS SofIpcParseFwReady(_Inout_ PSOF_DSP Dsp)
{
	ULONG offset = HDA_DSP_MBOX_UPLINK_OFFSET + sizeof(struct sof_ipc_fw_ready);
	struct sof_ipc_ext_data_hdr ext;
	struct sof_ipc_window window;
	ULONG guard;

	for (guard = 0; guard < 16; guard++) {
		mbox_read(Dsp, offset, &ext, sizeof(ext));
		if (ext.hdr.cmd != SOF_IPC_FW_READY || ext.hdr.size < sizeof(ext))
			break;

		if (ext.type == SOF_IPC_EXT_WINDOW) {
			ULONG size = min(ext.hdr.size, (ULONG)sizeof(window));

			RtlZeroMemory(&window, sizeof(window));
			mbox_read(Dsp, offset, &window, size);
			sof_ipc_set_windows(Dsp, &window);
		}

		offset += ext.hdr.size;
	}

	Dsp->Diag.HostBoxOffset = Dsp->HostBoxOffset;
	Dsp->Diag.HostBoxSize = Dsp->HostBoxSize;
	Dsp->Diag.DspBoxOffset = Dsp->DspBoxOffset;
	Dsp->Diag.DspBoxSize = Dsp->DspBoxSize;
	Dsp->Diag.StreamBoxOffset = Dsp->StreamBoxOffset;

	if (!Dsp->HostBoxSize || !Dsp->DspBoxSize)
		return STATUS_DEVICE_CONFIGURATION_ERROR;

	return STATUS_SUCCESS;
}

//
// Interrupt handling. The bus calls SofIpcIsr from its ISR (DIRQL); the
// actual work runs in a DPC, like the Linux IRQ thread (cnl_ipc_irq_thread).
//

static BOOL SofIpcIsr(PVOID context)
{
	PSOF_DSP Dsp = (PSOF_DSP)context;
	ULONG status;

	if (!Dsp->IpcReady)
		return FALSE;

	status = SofDspRead(Dsp, HDA_DSP_REG_ADSPIS);
	if (status == 0xffffffff || !(status & HDA_DSP_ADSPIS_IPC))
		return FALSE;

	/* mask the IPC interrupt until the DPC has run */
	SofDspUpdateBits(Dsp, HDA_DSP_REG_ADSPIC, HDA_DSP_ADSPIC_IPC, 0);
	KeInsertQueueDpc(&Dsp->IpcDpc, NULL, NULL);
	return TRUE;
}

static void SofIpcDpc(PKDPC Dpc, PVOID context, PVOID arg1, PVOID arg2)
{
	PSOF_DSP Dsp = (PSOF_DSP)context;
	ULONG hipcida, hipctdr, hipctdd;

	UNREFERENCED_PARAMETER(Dpc);
	UNREFERENCED_PARAMETER(arg1);
	UNREFERENCED_PARAMETER(arg2);

	Dsp->Diag.IrqCount++;

	hipcida = SofDspRead(Dsp, CNL_DSP_REG_HIPCIDA);
	hipctdr = SofDspRead(Dsp, CNL_DSP_REG_HIPCTDR);
	hipctdd = SofDspRead(Dsp, CNL_DSP_REG_HIPCTDD);

	/* reply message from DSP */
	if (hipcida & CNL_DSP_REG_HIPCIDA_DONE) {
		/* mask Done interrupt */
		SofDspUpdateBits(Dsp, CNL_DSP_REG_HIPCCTL, CNL_DSP_REG_HIPCCTL_DONE, 0);

		/* IPC3 replies are written back into the host box */
		mbox_read(Dsp, Dsp->HostBoxOffset, Dsp->ReplyBuf, sizeof(Dsp->ReplyBuf));
		KeSetEvent(&Dsp->ReplyEvent, IO_NO_INCREMENT, FALSE);

		/* cnl_ipc_dsp_done */
		SofDspUpdateBits(Dsp, CNL_DSP_REG_HIPCIDA,
			CNL_DSP_REG_HIPCIDA_DONE, CNL_DSP_REG_HIPCIDA_DONE);
		SofDspUpdateBits(Dsp, CNL_DSP_REG_HIPCCTL,
			CNL_DSP_REG_HIPCCTL_DONE, CNL_DSP_REG_HIPCCTL_DONE);
	}

	/* new message from DSP */
	if (hipctdr & CNL_DSP_REG_HIPCTDR_BUSY) {
		struct sof_ipc_cmd_hdr hdr = { 0 };

		if ((hipctdr & SOF_IPC_PANIC_MAGIC_MASK) == SOF_IPC_PANIC_MAGIC) {
			Dsp->Diag.LastRxCmd = hipctdr;
		}
		else {
			mbox_read(Dsp, Dsp->DspBoxOffset, &hdr, sizeof(hdr));
			Dsp->Diag.LastRxCmd = hdr.cmd;
		}
		Dsp->Diag.RxCount++;
		UNREFERENCED_PARAMETER(hipctdd);

		/* cnl_ipc_host_done */
		SofDspUpdateBits(Dsp, CNL_DSP_REG_HIPCTDR,
			CNL_DSP_REG_HIPCTDR_BUSY, CNL_DSP_REG_HIPCTDR_BUSY);
		SofDspUpdateBits(Dsp, CNL_DSP_REG_HIPCTDA,
			CNL_DSP_REG_HIPCTDA_DONE, CNL_DSP_REG_HIPCTDA_DONE);
	}

	SofDspUpdateBits(Dsp, HDA_DSP_REG_ADSPIC, HDA_DSP_ADSPIC_IPC, HDA_DSP_ADSPIC_IPC);
}

NTSTATUS SofIpcStart(_Inout_ PSOF_DSP Dsp)
{
	NTSTATUS status;
	volatile ULONG* ppctl = (volatile ULONG*)(Dsp->PpCap + SOF_HDA_REG_PP_PPCTL);

	KeInitializeDpc(&Dsp->IpcDpc, SofIpcDpc, Dsp);

	status = Dsp->Bus.RegisterInterrupt(Dsp->Bus.Context, SofIpcIsr, Dsp);
	if (!NT_SUCCESS(status))
		return status;
	Dsp->IrqRegistered = TRUE;
	Dsp->IpcReady = TRUE;

	/* hda_dsp_ipc_int_enable + hda_dsp_ctrl_ppcap_int_enable */
	SofDspUpdateBits(Dsp, CNL_DSP_REG_HIPCCTL,
		CNL_DSP_REG_HIPCCTL_DONE | CNL_DSP_REG_HIPCCTL_BUSY,
		CNL_DSP_REG_HIPCCTL_DONE | CNL_DSP_REG_HIPCCTL_BUSY);
	SofDspUpdateBits(Dsp, HDA_DSP_REG_ADSPIC, HDA_DSP_ADSPIC_IPC, HDA_DSP_ADSPIC_IPC);
	WRITE_REGISTER_ULONG(ppctl, READ_REGISTER_ULONG(ppctl) | SOF_HDA_PPCTL_PIE);

	return STATUS_SUCCESS;
}

void SofIpcStop(_Inout_ PSOF_DSP Dsp)
{
	volatile ULONG* ppctl;

	if (!Dsp->IrqRegistered)
		return;

	Dsp->IpcReady = FALSE;

	ppctl = (volatile ULONG*)(Dsp->PpCap + SOF_HDA_REG_PP_PPCTL);
	WRITE_REGISTER_ULONG(ppctl, READ_REGISTER_ULONG(ppctl) & ~SOF_HDA_PPCTL_PIE);
	SofDspUpdateBits(Dsp, HDA_DSP_REG_ADSPIC, HDA_DSP_ADSPIC_IPC, 0);

	Dsp->Bus.UnregisterInterrupt(Dsp->Bus.Context);
	KeFlushQueuedDpcs();
	Dsp->IrqRegistered = FALSE;
}

//
// Send a message and wait for the reply (sof_ipc_tx_message / cnl_ipc_send_msg)
//

NTSTATUS SofIpcTx(_Inout_ PSOF_DSP Dsp,
	_In_reads_bytes_(MsgSize) const void* Msg, _In_ ULONG MsgSize,
	_Out_writes_bytes_opt_(ReplySize) void* Reply, _In_ ULONG ReplySize)
{
	const struct sof_ipc_cmd_hdr* hdr = (const struct sof_ipc_cmd_hdr*)Msg;
	struct sof_ipc_reply* reply = (struct sof_ipc_reply*)Dsp->ReplyBuf;
	LARGE_INTEGER timeout;
	NTSTATUS status;

	if (!Dsp->IpcReady)
		return STATUS_DEVICE_NOT_READY;
	if (MsgSize > Dsp->HostBoxSize || MsgSize > SOF_IPC_MSG_MAX_SIZE)
		return STATUS_INVALID_PARAMETER;

	ExAcquireFastMutex(&Dsp->TxLock);

	KeClearEvent(&Dsp->ReplyEvent);

	mbox_write(Dsp, Dsp->HostBoxOffset, Msg, MsgSize);
	SofDspWrite(Dsp, CNL_DSP_REG_HIPCIDR, CNL_DSP_REG_HIPCIDR_BUSY);

	Dsp->Diag.TxCount++;
	Dsp->Diag.LastTxCmd = hdr->cmd;

	timeout.QuadPart = -10 * 1000 * (LONGLONG)SOF_IPC_TIMEOUT_MS;
	status = KeWaitForSingleObject(&Dsp->ReplyEvent, Executive, KernelMode, FALSE, &timeout);
	if (status == STATUS_TIMEOUT) {
		status = STATUS_IO_TIMEOUT;
	}
	else {
		Dsp->Diag.LastReplyError = reply->error;
		if (reply->error < 0)
			status = STATUS_DEVICE_PROTOCOL_ERROR;
		else
			status = STATUS_SUCCESS;

		if (Reply && ReplySize)
			RtlCopyMemory(Reply, Dsp->ReplyBuf, min(ReplySize, (ULONG)sizeof(Dsp->ReplyBuf)));
	}

	Dsp->Diag.LastTxStatus = status;
	ExReleaseFastMutex(&Dsp->TxLock);
	return status;
}
