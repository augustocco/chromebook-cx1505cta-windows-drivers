// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * sof_pcm.c -- SOF IPC3 PCM streams over HDA host DMA (ASUS Chromebook CX15 "Telith")
 *
 * Follows Linux sound/soc/sof/ipc3-pcm.c (hw_params, trigger, hw_free) and
 * sound/soc/sof/intel/hda-pcm.c / hda-stream.c for the host DMA side,
 * Copyright(c) 2018-2021 Intel Corporation (dual BSD-3-Clause / GPL-2.0).
 */

#include "sof_dsp.h"

static PSOF_PCM sof_find_pcm(PSOF_DSP Dsp, ULONG PcmId)
{
	for (ULONG i = 0; i < Dsp->NumPcms; i++) {
		if (Dsp->Pcms[i].PcmId == PcmId)
			return &Dsp->Pcms[i];
	}
	return NULL;
}

static NTSTATUS sof_stream_msg(PSOF_DSP Dsp, ULONG cmd, ULONG compId)
{
	struct sof_ipc_stream stream;

	stream.hdr.size = sizeof(stream);
	stream.hdr.cmd = SOF_IPC_GLB_STREAM_MSG | cmd;
	stream.comp_id = compId;
	return SofIpcTx(Dsp, &stream, sizeof(stream), NULL, 0);
}

NTSTATUS SofPcmOpen(_Inout_ PSOF_DSP Dsp, _Out_ PSOF_STREAM Stream,
	_In_ ULONG PcmId, _In_ ULONG Direction,
	_In_ ULONG Rate, _In_ ULONG Channels,
	_In_ ULONG PeriodBytes, _In_ ULONG Periods)
{
	PHYSICAL_ADDRESS highest;
	PUCHAR buffer;
	NTSTATUS status;

	if (Periods < 2 || Periods > 32 || !PeriodBytes)
		return STATUS_INVALID_PARAMETER;

	highest.QuadPart = 0xFFFFFFFF;
	buffer = (PUCHAR)MmAllocateContiguousMemory(ROUND_TO_PAGES(PeriodBytes * Periods), highest);
	if (!buffer)
		return STATUS_INSUFFICIENT_RESOURCES;
	RtlZeroMemory(buffer, ROUND_TO_PAGES(PeriodBytes * Periods));

	status = SofPcmOpenBuffer(Dsp, Stream, PcmId, Direction, Rate, Channels,
		buffer, MmGetPhysicalAddress(buffer), PeriodBytes * Periods, Periods);
	if (!NT_SUCCESS(status)) {
		MmFreeContiguousMemory(buffer);
		return status;
	}
	Stream->OwnsBuffer = TRUE;
	return STATUS_SUCCESS;
}

NTSTATUS SofPcmOpenBuffer(_Inout_ PSOF_DSP Dsp, _Out_ PSOF_STREAM Stream,
	_In_ ULONG PcmId, _In_ ULONG Direction,
	_In_ ULONG Rate, _In_ ULONG Channels,
	_In_ PUCHAR Buffer, _In_ PHYSICAL_ADDRESS BufferPhys,
	_In_ ULONG BufferSize, _In_ ULONG Periods)
{
	struct sof_ipc_pcm_params pcm;
	struct sof_ipc_pcm_params_reply reply;
	HDAUDIO_STREAM_FORMAT format = { 0 };
	PHYSICAL_ADDRESS phys;
	PHDAC_BDLENTRY bdl;
	PSOF_PCM spcm;
	NTSTATUS status;
	ULONG i, PeriodBytes;

	RtlZeroMemory(Stream, sizeof(*Stream));

	if (Direction > 1 || Periods < 2 || Periods > 32 || !BufferSize ||
		(BufferSize % Periods) || ((BufferSize / Periods) % 128))
		return STATUS_INVALID_PARAMETER;
	PeriodBytes = BufferSize / Periods;

	spcm = sof_find_pcm(Dsp, PcmId);
	if (!spcm || spcm->HostCompId[Direction] == 0xFFFFFFFF)
		return STATUS_NOT_FOUND;

	Stream->HostCompId = spcm->HostCompId[Direction];
	Stream->Direction = Direction;
	Stream->PeriodBytes = PeriodBytes;
	Stream->Periods = Periods;
	Stream->BufferSize = PeriodBytes * Periods;

	/* host DMA stream (hda_dsp_pcm_hw_params): S32_LE container */
	format.SampleRate = Rate;
	format.ValidBitsPerSample = 32;
	format.ContainerSize = 32;
	format.NumberOfChannels = (USHORT)Channels;

	if (Direction == 0)
		status = Dsp->Bus.GetRenderStream(Dsp->Bus.Context, format, &Stream->BusStream, &Stream->StreamTag);
	else
		status = Dsp->Bus.GetCaptureStream(Dsp->Bus.Context, format, &Stream->BusStream, &Stream->StreamTag);
	if (!NT_SUCCESS(status))
		return status;

	Stream->Buffer = Buffer;

	status = Dsp->Bus.PrepareDSP(Dsp->Bus.Context, Stream->BusStream,
		Stream->BufferSize, Periods, &Stream->Bdl);
	if (!NT_SUCCESS(status))
		goto err_stream;

	/* one BDL entry per period (the buffer is physically contiguous) */
	bdl = (PHDAC_BDLENTRY)Stream->Bdl;
	for (i = 0; i < Periods; i++) {
		phys.QuadPart = BufferPhys.QuadPart + (LONGLONG)i * PeriodBytes;
		bdl[i].addr_lo = phys.LowPart;
		bdl[i].addr_hi = phys.HighPart;
		bdl[i].size = PeriodBytes;
		bdl[i].ioc = 0;
	}

	/* sof_ipc3_pcm_hw_params */
	RtlZeroMemory(&pcm, sizeof(pcm));
	pcm.hdr.size = sizeof(pcm);
	pcm.hdr.cmd = SOF_IPC_GLB_STREAM_MSG | SOF_IPC_STREAM_PCM_PARAMS;
	pcm.comp_id = Stream->HostCompId;
	pcm.params.hdr.size = sizeof(pcm.params);
	pcm.params.buffer.phy_addr = MmGetPhysicalAddress(Stream->Bdl).LowPart;  /* use_phy_address */
	pcm.params.buffer.pages = (Stream->BufferSize + PAGE_SIZE - 1) / PAGE_SIZE;
	pcm.params.buffer.size = Stream->BufferSize;
	pcm.params.direction = Direction;
	pcm.params.frame_fmt = SOF_IPC_FRAME_S32_LE;
	pcm.params.buffer_fmt = SOF_IPC_BUFFER_INTERLEAVED;
	pcm.params.rate = Rate;
	pcm.params.stream_tag = Stream->StreamTag;
	pcm.params.channels = (UINT16)Channels;
	pcm.params.sample_valid_bytes = 4;
	pcm.params.sample_container_bytes = 4;
	pcm.params.host_period_bytes = PeriodBytes;
	pcm.params.no_stream_position = 1;   /* position comes from the DMA (DPIB) */

	status = SofIpcTx(Dsp, &pcm, sizeof(pcm), &reply, sizeof(reply));
	if (!NT_SUCCESS(status))
		goto err_cleanup;

	Stream->PosnOffset = reply.posn_offset;
	Stream->Open = TRUE;
	return STATUS_SUCCESS;

err_cleanup:
	Dsp->Bus.CleanupDSP(Dsp->Bus.Context, Stream->BusStream);
err_stream:
	Stream->Buffer = NULL;
	Dsp->Bus.FreeStream(Dsp->Bus.Context, Stream->BusStream);
	Stream->BusStream = NULL;
	return status;
}

NTSTATUS SofPcmStart(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream)
{
	NTSTATUS status;

	if (!Stream->Open || Stream->Running)
		return STATUS_INVALID_DEVICE_STATE;

	KeFlushIoBuffers(NULL, FALSE, TRUE);

	/* sof_pcm_trigger(START): host DMA first, then the IPC */
	Dsp->Bus.TriggerDSP(Dsp->Bus.Context, Stream->BusStream, TRUE);
	status = sof_stream_msg(Dsp, SOF_IPC_STREAM_TRIG_START, Stream->HostCompId);
	if (!NT_SUCCESS(status)) {
		Dsp->Bus.TriggerDSP(Dsp->Bus.Context, Stream->BusStream, FALSE);
		return status;
	}
	Stream->Running = TRUE;
	return STATUS_SUCCESS;
}

NTSTATUS SofPcmStop(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream)
{
	NTSTATUS status = STATUS_SUCCESS;

	if (!Stream->Running)
		return STATUS_SUCCESS;

	/* sof_pcm_trigger(STOP): IPC first, then host DMA */
	status = sof_stream_msg(Dsp, SOF_IPC_STREAM_TRIG_STOP, Stream->HostCompId);
	Dsp->Bus.TriggerDSP(Dsp->Bus.Context, Stream->BusStream, FALSE);
	Stream->Running = FALSE;
	Stream->Paused = FALSE;
	return status;
}

NTSTATUS SofPcmPause(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream)
{
	NTSTATUS status;

	if (!Stream->Running || Stream->Paused)
		return STATUS_SUCCESS;

	/* sof_pcm_trigger(PAUSE_PUSH): IPC first, then host DMA */
	status = sof_stream_msg(Dsp, SOF_IPC_STREAM_TRIG_PAUSE, Stream->HostCompId);
	Dsp->Bus.TriggerDSP(Dsp->Bus.Context, Stream->BusStream, FALSE);
	Stream->Paused = TRUE;
	return status;
}

NTSTATUS SofPcmRelease(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream)
{
	NTSTATUS status;

	if (!Stream->Running || !Stream->Paused)
		return STATUS_SUCCESS;

	/* sof_pcm_trigger(PAUSE_RELEASE): host DMA first, then the IPC */
	Dsp->Bus.TriggerDSP(Dsp->Bus.Context, Stream->BusStream, TRUE);
	status = sof_stream_msg(Dsp, SOF_IPC_STREAM_TRIG_RELEASE, Stream->HostCompId);
	if (NT_SUCCESS(status))
		Stream->Paused = FALSE;
	return status;
}

ULONG SofPcmPosition(_In_ PSOF_DSP Dsp, _In_ PSOF_STREAM Stream)
{
	if (!Stream->Open)
		return 0;
	return Dsp->Bus.StreamPosition(Dsp->Bus.Context, Stream->BusStream);
}

/*
 * Release the host DMA side of a stream whose DSP has been powered down (or
 * rebooted) in the meantime: the firmware no longer knows the PCM, so no IPC.
 */
void SofPcmAbandon(_In_ PADSP_BUS_INTERFACE Bus, _Inout_ PSOF_STREAM Stream)
{
	if (!Stream->Open)
		return;

	Bus->TriggerDSP(Bus->Context, Stream->BusStream, FALSE);
	Bus->CleanupDSP(Bus->Context, Stream->BusStream);
	Bus->FreeStream(Bus->Context, Stream->BusStream);
	if (Stream->OwnsBuffer)
		MmFreeContiguousMemory(Stream->Buffer);

	RtlZeroMemory(Stream, sizeof(*Stream));
}

void SofPcmClose(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream)
{
	if (!Stream->Open)
		return;

	SofPcmStop(Dsp, Stream);

	/* sof_ipc3_pcm_hw_free */
	sof_stream_msg(Dsp, SOF_IPC_STREAM_PCM_FREE, Stream->HostCompId);

	Dsp->Bus.CleanupDSP(Dsp->Bus.Context, Stream->BusStream);
	Dsp->Bus.FreeStream(Dsp->Bus.Context, Stream->BusStream);
	if (Stream->OwnsBuffer)
		MmFreeContiguousMemory(Stream->Buffer);

	RtlZeroMemory(Stream, sizeof(*Stream));
}
