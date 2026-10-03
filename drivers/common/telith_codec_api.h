// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * telith_codec_api.h -- requests from the DSP driver to the codec driver.
 *
 * Both drivers open the kernel callback object TELITH_CODEC_CALLBACK_NAME.
 * The DSP driver calls ExNotifyCallback(obj, &request, NULL) at PASSIVE_LEVEL;
 * the codec driver handles the request synchronously and fills Status.
 */

#ifndef __TELITH_CODEC_API_H
#define __TELITH_CODEC_API_H

#define TELITH_CODEC_CALLBACK_NAME L"\\Callback\\TelithAudioCodecApi"

/*
 * Jack changes: the codec driver calls
 *   ExNotifyCallback(obj, (PVOID)(ULONG_PTR)JackType, NULL)
 * at PASSIVE_LEVEL whenever the jack state changes.
 */
#define TELITH_JACK_CALLBACK_NAME  L"\\Callback\\TelithAudioJackState"

#define TELITH_JACK_HEADPHONE   0x1
#define TELITH_JACK_MICROPHONE  0x2

typedef enum _TELITH_CODEC_COMMAND {
	TelithCodecHeadphoneStart = 1,   // AIF1 (SSP0) playback to HPOL/HPOR
	TelithCodecHeadphoneStop,
	TelithCodecSpeakerStart,         // AIF2 (SSP1) playback to SPOL/SPOR
	TelithCodecSpeakerStop,
	TelithCodecGetJackState,         // fills JackType
	TelithCodecHeadsetMicStart,      // IN1 (CBJ) -> ADC -> AIF1 (SSP0) capture
	TelithCodecHeadsetMicStop,
} TELITH_CODEC_COMMAND;

typedef struct _TELITH_CODEC_REQUEST {
	ULONG Size;          // sizeof(TELITH_CODEC_REQUEST)
	ULONG Command;       // TELITH_CODEC_COMMAND
	ULONG Rate;          // Hz
	ULONG ValidBits;     // sample bits on the I2S link
	ULONG SlotWidth;     // bits per slot
	ULONG Channels;
	ULONG MclkRate;      // Hz
	ULONG JackType;      // TELITH_JACK_* (TelithCodecGetJackState)
	NTSTATUS Status;     // set by the codec driver
} TELITH_CODEC_REQUEST, * PTELITH_CODEC_REQUEST;

#endif
