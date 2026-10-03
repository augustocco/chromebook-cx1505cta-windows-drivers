// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * sof_dsp.h -- Intel SOF DSP boot for Windows (ASUS Chromebook CX15 "Telith")
 */

#ifndef __SOF_DSP_H
#define __SOF_DSP_H

#include <ntddk.h>
#include "adsp_bus.h"
#include "sof_hw.h"

#define SOF_POOL_TAG                (ULONG) 'FOSc'

// Boot and IPC state, useful when debugging with a kernel debugger.
typedef struct _SOF_DSP_DIAG {
	ULONG Step;            // last step reached (SOF_STEP_*)
	NTSTATUS Status;
	ULONG BootIteration;
	ULONG Adspcs;
	ULONG RomStatus;
	ULONG RomError;
	ULONG StreamTag;
	ULONG PayloadSize;
	ULONG FwReadyCmd;
	ULONG FwVersion;       // major << 24 | minor << 12 | micro
	ULONG FwAbi;
	ULONG BootTimeMs;
	CHAR FwTag[8];

	// IPC
	ULONG HostBoxOffset;
	ULONG HostBoxSize;
	ULONG DspBoxOffset;
	ULONG DspBoxSize;
	ULONG StreamBoxOffset;
	ULONG IrqCount;
	ULONG RxCount;
	ULONG LastRxCmd;
	ULONG TxCount;
	ULONG LastTxCmd;
	NTSTATUS LastTxStatus;
	LONG LastReplyError;
	ULONG ReadyRaw[4];

	// Topology
	ULONG TplgMsgTotal;
	ULONG TplgMsgSent;
	ULONG TplgFailIndex;
	ULONG TplgFailCmd;
} SOF_DSP_DIAG, * PSOF_DSP_DIAG;

#define SOF_MAX_PCMS 8

typedef struct _SOF_PCM {
	ULONG PcmId;
	ULONG HostCompId[2];      // [playback, capture], 0xFFFFFFFF = none
	ULONG PipelineCompId[2];
	ULONG DaiCompId[2];
	CHAR Name[32];
} SOF_PCM, * PSOF_PCM;

typedef struct _SOF_STREAM {
	BOOLEAN Open;
	BOOLEAN Running;
	BOOLEAN OwnsBuffer;       // buffer allocated by SofPcmOpen
	BOOLEAN Paused;
	ULONG Direction;          // 0 playback, 1 capture
	ULONG HostCompId;
	HANDLE BusStream;
	UINT8 StreamTag;
	PUCHAR Buffer;            // contiguous, BufferSize bytes
	ULONG BufferSize;
	ULONG PeriodBytes;
	ULONG Periods;
	PVOID Bdl;
	ULONG PosnOffset;
} SOF_STREAM, * PSOF_STREAM;

enum {
	SOF_STEP_NONE = 0,
	SOF_STEP_RESOURCES,
	SOF_STEP_POWER,
	SOF_STEP_STREAM,
	SOF_STEP_CORE_POWER_UP,
	SOF_STEP_ROM_IPC,
	SOF_STEP_CORE_RUN,
	SOF_STEP_ROM_ACK,
	SOF_STEP_ROM_INIT_DONE,
	SOF_STEP_FW_ENTERED,
	SOF_STEP_FW_READY,
};

typedef struct _SOF_DSP {
	ADSP_BUS_INTERFACE Bus;

	PUCHAR HdaBar;
	PUCHAR DspBar;
	PUCHAR PpCap;
	ULONG DspBarLen;

	BOOLEAN Powered;
	BOOLEAN Booted;

	// IPC (sof_ipc.c)
	BOOLEAN IpcReady;
	BOOLEAN IrqRegistered;
	KDPC IpcDpc;
	KEVENT ReplyEvent;
	FAST_MUTEX TxLock;
	ULONG HostBoxOffset;
	ULONG HostBoxSize;
	ULONG DspBoxOffset;
	ULONG DspBoxSize;
	ULONG StreamBoxOffset;
	ULONG StreamBoxSize;
	UCHAR ReplyBuf[SOF_IPC_MSG_MAX_SIZE];

	// Topology (sof_tplg.c)
	BOOLEAN TplgLoaded;
	ULONG NumPcms;
	SOF_PCM Pcms[SOF_MAX_PCMS];

	SOF_DSP_DIAG Diag;
} SOF_DSP, * PSOF_DSP;

NTSTATUS SofDspInit(_Inout_ PSOF_DSP Dsp, _In_ PADSP_BUS_INTERFACE Bus);
NTSTATUS SofDspBoot(_Inout_ PSOF_DSP Dsp, _In_reads_bytes_(FwSize) const UCHAR* Fw, _In_ ULONG FwSize);
void SofDspShutdown(_Inout_ PSOF_DSP Dsp);

// sof_dsp.c helpers shared with sof_ipc.c
ULONG SofDspRead(PSOF_DSP Dsp, ULONG off);
void SofDspWrite(PSOF_DSP Dsp, ULONG off, ULONG val);
void SofDspUpdateBits(PSOF_DSP Dsp, ULONG off, ULONG mask, ULONG val);

// sof_ipc.c
void SofIpcParseExtManifest(_Inout_ PSOF_DSP Dsp, _In_reads_bytes_(FwSize) const UCHAR* Fw, _In_ ULONG FwSize);
NTSTATUS SofIpcParseFwReady(_Inout_ PSOF_DSP Dsp);
NTSTATUS SofIpcStart(_Inout_ PSOF_DSP Dsp);
void SofIpcStop(_Inout_ PSOF_DSP Dsp);
NTSTATUS SofIpcTx(_Inout_ PSOF_DSP Dsp,
	_In_reads_bytes_(MsgSize) const void* Msg, _In_ ULONG MsgSize,
	_Out_writes_bytes_opt_(ReplySize) void* Reply, _In_ ULONG ReplySize);

// sof_tplg.c
NTSTATUS SofTplgLoad(_Inout_ PSOF_DSP Dsp, _In_reads_bytes_(Size) const UCHAR* Blob, _In_ ULONG Size);

// sof_pcm.c
NTSTATUS SofPcmOpen(_Inout_ PSOF_DSP Dsp, _Out_ PSOF_STREAM Stream,
	_In_ ULONG PcmId, _In_ ULONG Direction,
	_In_ ULONG Rate, _In_ ULONG Channels,
	_In_ ULONG PeriodBytes, _In_ ULONG Periods);
NTSTATUS SofPcmOpenBuffer(_Inout_ PSOF_DSP Dsp, _Out_ PSOF_STREAM Stream,
	_In_ ULONG PcmId, _In_ ULONG Direction,
	_In_ ULONG Rate, _In_ ULONG Channels,
	_In_ PUCHAR Buffer, _In_ PHYSICAL_ADDRESS BufferPhys,
	_In_ ULONG BufferSize, _In_ ULONG Periods);
NTSTATUS SofPcmStart(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream);
NTSTATUS SofPcmStop(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream);
NTSTATUS SofPcmPause(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream);
NTSTATUS SofPcmRelease(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream);
ULONG SofPcmPosition(_In_ PSOF_DSP Dsp, _In_ PSOF_STREAM Stream);
void SofPcmClose(_Inout_ PSOF_DSP Dsp, _Inout_ PSOF_STREAM Stream);
void SofPcmAbandon(_In_ PADSP_BUS_INTERFACE Bus, _Inout_ PSOF_STREAM Stream);

#endif
