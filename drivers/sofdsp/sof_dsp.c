// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * sof_dsp.c -- Intel SOF DSP boot for Windows (ASUS Chromebook CX15 "Telith")
 *
 * Boot flow ported from Linux sound/soc/sof/intel/hda-loader.c, hda-dsp.c
 * and cnl.c, Copyright(c) 2018 Intel Corporation (dual BSD-3-Clause /
 * GPL-2.0). Authors: Liam Girdwood, Ranjani Sridharan, Rander Wang,
 * Keyon Jie.
 */

#include "sof_dsp.h"

//
// Register helpers
//

static ULONG dsp_read(PSOF_DSP Dsp, ULONG off)
{
	return READ_REGISTER_ULONG((volatile ULONG*)(Dsp->DspBar + off));
}

static void dsp_write(PSOF_DSP Dsp, ULONG off, ULONG val)
{
	WRITE_REGISTER_ULONG((volatile ULONG*)(Dsp->DspBar + off), val);
}

static void dsp_update_bits(PSOF_DSP Dsp, ULONG off, ULONG mask, ULONG val)
{
	ULONG tmp = dsp_read(Dsp, off);
	tmp = (tmp & ~mask) | (val & mask);
	dsp_write(Dsp, off, tmp);
}

static void pp_update_bits(PSOF_DSP Dsp, ULONG off, ULONG mask, ULONG val)
{
	volatile ULONG* reg = (volatile ULONG*)(Dsp->PpCap + off);
	ULONG tmp = READ_REGISTER_ULONG(reg);
	tmp = (tmp & ~mask) | (val & mask);
	WRITE_REGISTER_ULONG(reg, tmp);
}

static void sof_sleep_us(ULONG us)
{
	LARGE_INTEGER interval;
	interval.QuadPart = -10 * (LONGLONG)us;
	KeDelayExecutionThread(KernelMode, FALSE, &interval);
}

static ULONGLONG sof_now_us(void)
{
	return KeQueryInterruptTime() / 10;
}

// Polls (reg & mask) == value. Returns STATUS_IO_TIMEOUT on timeout.
static NTSTATUS dsp_poll(PSOF_DSP Dsp, ULONG off, ULONG mask, ULONG value, ULONG timeout_us, ULONG* last)
{
	ULONGLONG end = sof_now_us() + timeout_us;
	ULONG val;

	for (;;) {
		val = dsp_read(Dsp, off);
		if ((val & mask) == value) {
			if (last)
				*last = val;
			return STATUS_SUCCESS;
		}
		if (sof_now_us() > end)
			break;
		sof_sleep_us(HDA_DSP_REG_POLL_INTERVAL_US);
	}
	if (last)
		*last = val;
	return STATUS_IO_TIMEOUT;
}

static NTSTATUS dsp_poll_rom_state(PSOF_DSP Dsp, ULONG state, ULONG timeout_us)
{
	ULONG last = 0;
	NTSTATUS status = dsp_poll(Dsp, HDA_DSP_SRAM_REG_ROM_STATUS, FSR_STATE_MASK, state, timeout_us, &last);
	Dsp->Diag.RomStatus = last;
	Dsp->Diag.RomError = dsp_read(Dsp, HDA_DSP_SRAM_REG_ROM_ERROR);
	return status;
}

//
// DSP core control (hda-dsp.c)
//

static NTSTATUS hda_dsp_core_reset_enter(PSOF_DSP Dsp, ULONG core_mask)
{
	ULONG reset = HDA_DSP_ADSPCS_CRST_MASK(core_mask);

	dsp_update_bits(Dsp, HDA_DSP_REG_ADSPCS, reset, reset);
	return dsp_poll(Dsp, HDA_DSP_REG_ADSPCS, reset, reset, HDA_DSP_RESET_TIMEOUT_US, NULL);
}

static NTSTATUS hda_dsp_core_reset_leave(PSOF_DSP Dsp, ULONG core_mask)
{
	ULONG crst = HDA_DSP_ADSPCS_CRST_MASK(core_mask);

	dsp_update_bits(Dsp, HDA_DSP_REG_ADSPCS, crst, 0);
	return dsp_poll(Dsp, HDA_DSP_REG_ADSPCS, crst, 0, HDA_DSP_RESET_TIMEOUT_US, NULL);
}

static NTSTATUS hda_dsp_core_stall_reset(PSOF_DSP Dsp, ULONG core_mask)
{
	dsp_update_bits(Dsp, HDA_DSP_REG_ADSPCS,
		HDA_DSP_ADSPCS_CSTALL_MASK(core_mask),
		HDA_DSP_ADSPCS_CSTALL_MASK(core_mask));

	return hda_dsp_core_reset_enter(Dsp, core_mask);
}

static BOOLEAN hda_dsp_core_is_enabled(PSOF_DSP Dsp, ULONG core_mask)
{
	ULONG val = dsp_read(Dsp, HDA_DSP_REG_ADSPCS);

	return ((val & HDA_DSP_ADSPCS_CPA_MASK(core_mask)) == HDA_DSP_ADSPCS_CPA_MASK(core_mask)) &&
		((val & HDA_DSP_ADSPCS_SPA_MASK(core_mask)) == HDA_DSP_ADSPCS_SPA_MASK(core_mask)) &&
		!(val & HDA_DSP_ADSPCS_CRST_MASK(core_mask)) &&
		!(val & HDA_DSP_ADSPCS_CSTALL_MASK(core_mask));
}

static NTSTATUS hda_dsp_core_run(PSOF_DSP Dsp, ULONG core_mask)
{
	NTSTATUS status = hda_dsp_core_reset_leave(Dsp, core_mask);
	if (!NT_SUCCESS(status))
		return status;

	dsp_update_bits(Dsp, HDA_DSP_REG_ADSPCS,
		HDA_DSP_ADSPCS_CSTALL_MASK(core_mask), 0);

	if (!hda_dsp_core_is_enabled(Dsp, core_mask)) {
		hda_dsp_core_stall_reset(Dsp, core_mask);
		return STATUS_DEVICE_NOT_READY;
	}
	return STATUS_SUCCESS;
}

static NTSTATUS hda_dsp_core_power_up(PSOF_DSP Dsp, ULONG core_mask)
{
	ULONG cpa = HDA_DSP_ADSPCS_CPA_MASK(core_mask);

	core_mask &= TGL_HOST_MANAGED_CORES_MASK;
	if (!core_mask)
		return STATUS_SUCCESS;

	dsp_update_bits(Dsp, HDA_DSP_REG_ADSPCS,
		HDA_DSP_ADSPCS_SPA_MASK(core_mask),
		HDA_DSP_ADSPCS_SPA_MASK(core_mask));

	return dsp_poll(Dsp, HDA_DSP_REG_ADSPCS, cpa, cpa, HDA_DSP_RESET_TIMEOUT_US, NULL);
}

static NTSTATUS hda_dsp_core_power_down(PSOF_DSP Dsp, ULONG core_mask)
{
	dsp_update_bits(Dsp, HDA_DSP_REG_ADSPCS,
		HDA_DSP_ADSPCS_SPA_MASK(core_mask), 0);

	return dsp_poll(Dsp, HDA_DSP_REG_ADSPCS,
		HDA_DSP_ADSPCS_CPA_MASK(core_mask), 0, 50 * 1000, NULL);
}

static NTSTATUS hda_dsp_core_reset_power_down(PSOF_DSP Dsp, ULONG core_mask)
{
	NTSTATUS status;

	core_mask &= TGL_HOST_MANAGED_CORES_MASK;
	if (!core_mask)
		return STATUS_SUCCESS;

	status = hda_dsp_core_stall_reset(Dsp, core_mask);
	if (!NT_SUCCESS(status))
		return status;

	status = hda_dsp_core_power_down(Dsp, core_mask);
	if (!NT_SUCCESS(status))
		return status;

	if (hda_dsp_core_is_enabled(Dsp, core_mask))
		return STATUS_DEVICE_BUSY;

	return STATUS_SUCCESS;
}

static void hda_dsp_ipc_int_enable(PSOF_DSP Dsp)
{
	dsp_update_bits(Dsp, CNL_DSP_REG_HIPCCTL,
		CNL_DSP_REG_HIPCCTL_DONE | CNL_DSP_REG_HIPCCTL_BUSY,
		CNL_DSP_REG_HIPCCTL_DONE | CNL_DSP_REG_HIPCCTL_BUSY);

	dsp_update_bits(Dsp, HDA_DSP_REG_ADSPIC,
		HDA_DSP_ADSPIC_IPC, HDA_DSP_ADSPIC_IPC);
}

static void hda_ssp_set_cbp_cfp(PSOF_DSP Dsp)
{
	/* DSP is powered up, set all SSPs to clock consumer/codec provider mode */
	for (ULONG i = 0; i < TGL_SSP_COUNT; i++) {
		dsp_update_bits(Dsp,
			CNL_SSP_BASE_OFFSET + i * SSP_DEV_MEM_SIZE + SSP_SSC1_OFFSET,
			SSP_SET_CBP_CFP, SSP_SET_CBP_CFP);
	}
}

//
// Code loader (hda-loader.c)
//

static NTSTATUS cl_dsp_init(PSOF_DSP Dsp, ULONG stream_tag)
{
	ULONG ipc_hdr;
	NTSTATUS status;

	/* step 1: power up corex */
	Dsp->Diag.Step = SOF_STEP_CORE_POWER_UP;
	status = hda_dsp_core_power_up(Dsp, TGL_HOST_MANAGED_CORES_MASK);
	if (!NT_SUCCESS(status))
		goto err;

	hda_ssp_set_cbp_cfp(Dsp);

	/* step 2: Send ROM_CONTROL command */
	Dsp->Diag.Step = SOF_STEP_ROM_IPC;
	ipc_hdr = CNL_DSP_REG_HIPCIDR_BUSY | HDA_DSP_ROM_IPC_CONTROL |
		HDA_DSP_ROM_IPC_PURGE_FW | ((stream_tag - 1) << 9);
	dsp_write(Dsp, CNL_DSP_REG_HIPCIDR, ipc_hdr);

	/* step 3: unset core 0 reset state & unstall/run core 0 */
	Dsp->Diag.Step = SOF_STEP_CORE_RUN;
	status = hda_dsp_core_run(Dsp, TGL_INIT_CORE_MASK);
	if (!NT_SUCCESS(status))
		goto err;

	/* step 4: wait for IPC DONE bit from ROM */
	Dsp->Diag.Step = SOF_STEP_ROM_ACK;
	status = dsp_poll(Dsp, CNL_DSP_REG_HIPCIDA,
		CNL_DSP_REG_HIPCIDA_DONE, CNL_DSP_REG_HIPCIDA_DONE,
		HDA_DSP_INIT_TIMEOUT_US, NULL);
	if (!NT_SUCCESS(status))
		goto err;

	/* set DONE bit to clear the reply IPC message */
	dsp_update_bits(Dsp, CNL_DSP_REG_HIPCIDA,
		CNL_DSP_REG_HIPCIDA_DONE, CNL_DSP_REG_HIPCIDA_DONE);

	/* step 5: no other host managed cores on ADL */

	/* step 6: enable IPC interrupts */
	hda_dsp_ipc_int_enable(Dsp);

	/* step 7: wait for ROM init to proceed to download the firmware */
	Dsp->Diag.Step = SOF_STEP_ROM_INIT_DONE;
	status = dsp_poll_rom_state(Dsp, FSR_STATE_INIT_DONE, HDA_DSP_ROM_INIT_TIMEOUT_US);
	if (NT_SUCCESS(status))
		return status;

err:
	Dsp->Diag.Adspcs = dsp_read(Dsp, HDA_DSP_REG_ADSPCS);
	Dsp->Diag.RomStatus = dsp_read(Dsp, HDA_DSP_SRAM_REG_ROM_STATUS);
	Dsp->Diag.RomError = dsp_read(Dsp, HDA_DSP_SRAM_REG_ROM_ERROR);
	hda_dsp_core_reset_power_down(Dsp, TGL_HOST_MANAGED_CORES_MASK);
	return status;
}

static NTSTATUS sof_wait_fw_ready(PSOF_DSP Dsp)
{
	struct sof_ipc_fw_ready ready;
	NTSTATUS status;

	Dsp->Diag.Step = SOF_STEP_FW_READY;

	/* the first message from the firmware is FW_READY */
	status = dsp_poll(Dsp, CNL_DSP_REG_HIPCTDR,
		CNL_DSP_REG_HIPCTDR_BUSY, CNL_DSP_REG_HIPCTDR_BUSY,
		HDA_DSP_BASEFW_TIMEOUT_US, NULL);
	if (!NT_SUCCESS(status))
		return status;

	READ_REGISTER_BUFFER_UCHAR(Dsp->DspBar + HDA_DSP_MBOX_UPLINK_OFFSET,
		(PUCHAR)&ready, sizeof(ready));

	Dsp->Diag.FwReadyCmd = ready.hdr.cmd;
	Dsp->Diag.ReadyRaw[0] = ready.hdr.size;
	Dsp->Diag.ReadyRaw[1] = ready.dspbox_offset;
	Dsp->Diag.ReadyRaw[2] = ready.hostbox_offset;
	Dsp->Diag.ReadyRaw[3] = ready.dspbox_size;
	Dsp->Diag.FwVersion = ((ULONG)ready.version.major << 24) |
		((ULONG)ready.version.minor << 12) | ready.version.micro;
	Dsp->Diag.FwAbi = ready.version.abi_version;
	RtlCopyMemory(Dsp->Diag.FwTag, ready.version.tag, sizeof(ready.version.tag));
	Dsp->Diag.FwTag[sizeof(ready.version.tag)] = 0;

	/* ipc3_fw_ready: mailbox windows follow the fw_ready structure */
	if ((ready.hdr.cmd & SOF_GLB_TYPE_MASK) == SOF_IPC_FW_READY)
		status = SofIpcParseFwReady(Dsp);

	/* cnl_ipc_host_done: clear BUSY and tell the DSP the message was taken */
	dsp_update_bits(Dsp, CNL_DSP_REG_HIPCTDR,
		CNL_DSP_REG_HIPCTDR_BUSY, CNL_DSP_REG_HIPCTDR_BUSY);
	dsp_update_bits(Dsp, CNL_DSP_REG_HIPCTDA,
		CNL_DSP_REG_HIPCTDA_DONE, CNL_DSP_REG_HIPCTDA_DONE);

	if ((ready.hdr.cmd & SOF_GLB_TYPE_MASK) != SOF_IPC_FW_READY)
		return STATUS_DEVICE_PROTOCOL_ERROR;

	return status;
}

ULONG SofDspRead(PSOF_DSP Dsp, ULONG off)
{
	return dsp_read(Dsp, off);
}

void SofDspWrite(PSOF_DSP Dsp, ULONG off, ULONG val)
{
	dsp_write(Dsp, off, val);
}

void SofDspUpdateBits(PSOF_DSP Dsp, ULONG off, ULONG mask, ULONG val)
{
	dsp_update_bits(Dsp, off, mask, val);
}

//
// Public API
//

NTSTATUS SofDspInit(_Inout_ PSOF_DSP Dsp, _In_ PADSP_BUS_INTERFACE Bus)
{
	PCI_BAR hdaBar = { 0 }, dspBar = { 0 };
	PVOID ppcap = NULL;
	NTSTATUS status;

	RtlZeroMemory(Dsp, sizeof(*Dsp));
	Dsp->Bus = *Bus;

	Dsp->Diag.Step = SOF_STEP_RESOURCES;
	status = Dsp->Bus.GetResources(Dsp->Bus.Context, &hdaBar, &dspBar, &ppcap, NULL, NULL);
	if (!NT_SUCCESS(status))
		return status;

	if (!hdaBar.Base.Base || !dspBar.Base.Base || !ppcap)
		return STATUS_DEVICE_CONFIGURATION_ERROR;

	KeInitializeEvent(&Dsp->ReplyEvent, SynchronizationEvent, FALSE);
	ExInitializeFastMutex(&Dsp->TxLock);

	Dsp->HdaBar = hdaBar.Base.baseptr;
	Dsp->DspBar = dspBar.Base.baseptr;
	Dsp->DspBarLen = dspBar.Len;
	Dsp->PpCap = (PUCHAR)ppcap;
	return STATUS_SUCCESS;
}

NTSTATUS SofDspBoot(_Inout_ PSOF_DSP Dsp, _In_reads_bytes_(FwSize) const UCHAR* Fw, _In_ ULONG FwSize)
{
	const struct sof_ext_man_header* extMan = (const struct sof_ext_man_header*)Fw;
	HDAUDIO_STREAM_FORMAT format = { 0 };
	PHYSICAL_ADDRESS highest, phys;
	HANDLE stream = NULL;
	UINT8 streamTag = 0;
	PVOID bdlBuf = NULL;
	PUCHAR dmaBuf = NULL;
	ULONG payloadOffset = 0, payloadSize, firstLen;
	ULONGLONG start = sof_now_us();
	NTSTATUS status, status2;
	ULONG i;

	/* strip the extended manifest (keeping the mailbox windows it describes) */
	if (FwSize >= sizeof(*extMan) && extMan->magic == SOF_EXT_MAN_MAGIC_NUMBER) {
		payloadOffset = extMan->full_size;
		SofIpcParseExtManifest(Dsp, Fw, FwSize);
	}
	if (payloadOffset >= FwSize)
		return STATUS_INVALID_IMAGE_FORMAT;
	payloadSize = FwSize - payloadOffset;
	Dsp->Diag.PayloadSize = payloadSize;

	Dsp->Diag.Step = SOF_STEP_POWER;
	status = Dsp->Bus.SetDSPPowerState(Dsp->Bus.Context, PowerDeviceD0);
	if (!NT_SUCCESS(status))
		return status;
	Dsp->Powered = TRUE;

	/* hda_dsp_ctrl_ppcap_enable */
	pp_update_bits(Dsp, SOF_HDA_REG_PP_PPCTL, SOF_HDA_PPCTL_GPROCEN, SOF_HDA_PPCTL_GPROCEN);

	/* start from a known state: core 0 in reset and powered down */
	hda_dsp_core_reset_power_down(Dsp, TGL_HOST_MANAGED_CORES_MASK);

	/* prepare DMA for code loader stream (HDA_CL_STREAM_FORMAT = 0x40) */
	Dsp->Diag.Step = SOF_STEP_STREAM;
	format.SampleRate = 48000;
	format.ValidBitsPerSample = 32;
	format.ContainerSize = 32;
	format.NumberOfChannels = 1;

	status = Dsp->Bus.GetRenderStream(Dsp->Bus.Context, format, &stream, &streamTag);
	if (!NT_SUCCESS(status))
		goto out;
	Dsp->Diag.StreamTag = streamTag;

	highest.QuadPart = 0xFFFFFFFF;
	dmaBuf = (PUCHAR)MmAllocateContiguousMemory(ROUND_TO_PAGES(payloadSize), highest);
	if (!dmaBuf) {
		status = STATUS_INSUFFICIENT_RESOURCES;
		goto out_stream;
	}
	RtlCopyMemory(dmaBuf, Fw + payloadOffset, payloadSize);

	status = Dsp->Bus.PrepareDSP(Dsp->Bus.Context, stream, payloadSize, 2, &bdlBuf);
	if (!NT_SUCCESS(status))
		goto out_buf;

	/* two BDL entries (HDA needs at least two), split on a page boundary */
	{
		PHDAC_BDLENTRY bdl = (PHDAC_BDLENTRY)bdlBuf;

		firstLen = (ULONG)ROUND_TO_PAGES(payloadSize / 2);
		if (firstLen >= payloadSize)
			firstLen = PAGE_SIZE;

		phys = MmGetPhysicalAddress(dmaBuf);
		bdl[0].addr_lo = phys.LowPart;
		bdl[0].addr_hi = phys.HighPart;
		bdl[0].size = firstLen;
		bdl[0].ioc = 0;

		phys = MmGetPhysicalAddress(dmaBuf + firstLen);
		bdl[1].addr_lo = phys.LowPart;
		bdl[1].addr_hi = phys.HighPart;
		bdl[1].size = payloadSize - firstLen;
		bdl[1].ioc = 0;
	}
	KeFlushIoBuffers(NULL, FALSE, TRUE);

	/* hda_data_stream_prepare: tell the DMA how much valid data the buffer holds */
	Dsp->Bus.DSPEnableSPIB(Dsp->Bus.Context, stream, payloadSize);

	/* try ROM init a few times before giving up */
	for (i = 0; i < HDA_FW_BOOT_ATTEMPTS; i++) {
		Dsp->Diag.BootIteration = i + 1;
		status = cl_dsp_init(Dsp, streamTag);
		if (NT_SUCCESS(status))
			break;
	}
	if (!NT_SUCCESS(status))
		goto out_cleanup;

	/* hda_cl_copy_fw */
	Dsp->Bus.TriggerDSP(Dsp->Bus.Context, stream, TRUE);

	Dsp->Diag.Step = SOF_STEP_FW_ENTERED;
	status = dsp_poll_rom_state(Dsp, FSR_STATE_FW_ENTERED, HDA_DSP_BASEFW_TIMEOUT_US);

	Dsp->Bus.TriggerDSP(Dsp->Bus.Context, stream, FALSE);

out_cleanup:
	Dsp->Bus.DSPDisableSPIB(Dsp->Bus.Context, stream);
	status2 = Dsp->Bus.CleanupDSP(Dsp->Bus.Context, stream);
	if (NT_SUCCESS(status) && !NT_SUCCESS(status2))
		status = status2;
out_buf:
	MmFreeContiguousMemory(dmaBuf);
out_stream:
	Dsp->Bus.FreeStream(Dsp->Bus.Context, stream);
out:
	if (NT_SUCCESS(status))
		status = sof_wait_fw_ready(Dsp);

	Dsp->Diag.Adspcs = dsp_read(Dsp, HDA_DSP_REG_ADSPCS);
	Dsp->Diag.BootTimeMs = (ULONG)((sof_now_us() - start) / 1000);
	Dsp->Diag.Status = status;

	if (NT_SUCCESS(status)) {
		Dsp->Booted = TRUE;
	}
	else {
		hda_dsp_core_reset_power_down(Dsp, TGL_HOST_MANAGED_CORES_MASK);
		pp_update_bits(Dsp, SOF_HDA_REG_PP_PPCTL, SOF_HDA_PPCTL_GPROCEN, 0);
	}
	return status;
}

void SofDspShutdown(_Inout_ PSOF_DSP Dsp)
{
	if (!Dsp->DspBar)
		return;

	SofIpcStop(Dsp);

	if (Dsp->Booted || Dsp->Powered) {
		dsp_update_bits(Dsp, HDA_DSP_REG_ADSPIC, HDA_DSP_ADSPIC_IPC, 0);
		dsp_update_bits(Dsp, CNL_DSP_REG_HIPCCTL,
			CNL_DSP_REG_HIPCCTL_DONE | CNL_DSP_REG_HIPCCTL_BUSY, 0);
		hda_dsp_core_reset_power_down(Dsp, TGL_HOST_MANAGED_CORES_MASK);
		pp_update_bits(Dsp, SOF_HDA_REG_PP_PPCTL, SOF_HDA_PPCTL_GPROCEN, 0);
	}
	Dsp->Booted = FALSE;

	if (Dsp->Powered) {
		Dsp->Bus.SetDSPPowerState(Dsp->Bus.Context, PowerDeviceD3);
		Dsp->Powered = FALSE;
	}
}
