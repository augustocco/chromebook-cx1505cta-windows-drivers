// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * sof_tplg.c -- replay of the IPC3 topology script produced by
 * tools/tplg/tplg2ipc.py (ASUS Chromebook CX15 "Telith").
 */

#include "sof_dsp.h"

#define SIPC_MAGIC 0x43504953 /* 'SIPC' */

#include <pshpack1.h>
typedef struct _SIPC_HEADER {
	UINT32 magic;
	UINT32 version;
	UINT32 num_pcms;
	UINT32 num_msgs;
} SIPC_HEADER;

typedef struct _SIPC_PCM {
	UINT32 pcm_id;
	UINT32 host_comp_id[2];
	UINT32 pipeline_comp_id[2];
	UINT32 dai_comp_id[2];
	CHAR name[32];
} SIPC_PCM;
#include <poppack.h>

NTSTATUS SofTplgLoad(_Inout_ PSOF_DSP Dsp, _In_reads_bytes_(Size) const UCHAR* Blob, _In_ ULONG Size)
{
	const SIPC_HEADER* hdr = (const SIPC_HEADER*)Blob;
	UCHAR reply[SOF_IPC_MSG_MAX_SIZE];
	ULONG offset, i;
	NTSTATUS status = STATUS_SUCCESS;

	if (Size < sizeof(*hdr) || hdr->magic != SIPC_MAGIC || hdr->version != 1)
		return STATUS_INVALID_IMAGE_FORMAT;

	offset = sizeof(*hdr);
	if (hdr->num_pcms > SOF_MAX_PCMS ||
		offset + hdr->num_pcms * sizeof(SIPC_PCM) > Size)
		return STATUS_INVALID_IMAGE_FORMAT;

	/* PCM table */
	Dsp->NumPcms = 0;
	for (i = 0; i < hdr->num_pcms; i++) {
		const SIPC_PCM* p = (const SIPC_PCM*)(Blob + offset);
		PSOF_PCM pcm = &Dsp->Pcms[Dsp->NumPcms++];

		pcm->PcmId = p->pcm_id;
		pcm->HostCompId[0] = p->host_comp_id[0];
		pcm->HostCompId[1] = p->host_comp_id[1];
		pcm->PipelineCompId[0] = p->pipeline_comp_id[0];
		pcm->PipelineCompId[1] = p->pipeline_comp_id[1];
		pcm->DaiCompId[0] = p->dai_comp_id[0];
		pcm->DaiCompId[1] = p->dai_comp_id[1];
		RtlCopyMemory(pcm->Name, p->name, sizeof(pcm->Name));
		pcm->Name[sizeof(pcm->Name) - 1] = 0;
		offset += sizeof(SIPC_PCM);
	}

	/* IPC messages, in order */
	Dsp->Diag.TplgMsgTotal = hdr->num_msgs;
	Dsp->Diag.TplgMsgSent = 0;
	Dsp->Diag.TplgFailIndex = 0xFFFFFFFF;

	for (i = 0; i < hdr->num_msgs; i++) {
		UINT32 msgSize;

		if (offset + sizeof(UINT32) > Size)
			return STATUS_INVALID_IMAGE_FORMAT;
		msgSize = *(const UINT32*)(Blob + offset);
		offset += sizeof(UINT32);
		if (msgSize < sizeof(struct sof_ipc_cmd_hdr) || offset + msgSize > Size)
			return STATUS_INVALID_IMAGE_FORMAT;

		status = SofIpcTx(Dsp, Blob + offset, msgSize, reply, sizeof(reply));
		if (!NT_SUCCESS(status)) {
			Dsp->Diag.TplgFailIndex = i;
			Dsp->Diag.TplgFailCmd = ((const struct sof_ipc_cmd_hdr*)(Blob + offset))->cmd;
			return status;
		}

		Dsp->Diag.TplgMsgSent++;
		offset += msgSize;
	}

	Dsp->TplgLoaded = TRUE;
	return STATUS_SUCCESS;
}
