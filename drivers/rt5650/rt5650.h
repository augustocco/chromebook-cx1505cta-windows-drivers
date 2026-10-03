// SPDX-License-Identifier: GPL-2.0-only
/*
 * rt5650.h -- Realtek RT5650 codec driver for Windows (ASUS Chromebook CX15 "Telith")
 *
 * Register programming derived from the Linux rt5645 ALSA SoC driver,
 * Copyright 2013 Realtek Semiconductor Corp., Author: Bard Liao.
 */

#if !defined(_RT5650_H_)
#define _RT5650_H_

#include <initguid.h>
#include <ntddk.h>
#include <wdf.h>

#include "i2c.h"
#include "rt5645_regs.h"
#include "..\common\telith_codec_api.h"

// RT5650 keeps the I2S data length in bits [5:4] (rt5645_hw_params, dl_sft)
#define RT5650_I2S_DL_SFT   4
#define RT5650_I2S_DL_MASK  (0x3 << RT5650_I2S_DL_SFT)

#define RT5645_DEVICE_ID    0x6308
#define RT5650_DEVICE_ID    0x6419

// Private registers are reached through RT5645_PRIV_INDEX / RT5645_PRIV_DATA.
#define RT5645_PR_BASE      0x100

// Interval required between power on and the first register read.
#define TIME_TO_POWER_MS    400

// From the codec's _DSD ("realtek,jd-mode").
#define RT5650_JD_MODE      2

enum snd_jack_types {
	SND_JACK_HEADPHONE = 0x0001,
	SND_JACK_MICROPHONE = 0x0002,
	SND_JACK_HEADSET = SND_JACK_HEADPHONE | SND_JACK_MICROPHONE,
};

struct reg {
	UINT16 reg;
	UINT16 val;
};

/* errors go to the kernel debugger (DbgView: "Capture Kernel") */
#define RT_LOG(fmt, ...) \
	DbgPrintEx(DPFLTR_IHVAUDIO_ID, DPFLTR_ERROR_LEVEL, "rt5650: " fmt "\n", __VA_ARGS__)

typedef struct _RT5650_CONTEXT
{
	WDFDEVICE FxDevice;

	RT_I2C I2c;

	WDFINTERRUPT Interrupt;
	WDFWORKITEM JackWorkItem;
	WDFWAITLOCK RegLock;

	// cbj-sleeve output GPIO (resource hub connection)
	LARGE_INTEGER SleeveGpioId;
	WDFIOTARGET SleeveGpioTarget;

	ULONG GpioIoCount;
	ULONG InterruptCount;

	BOOLEAN ConnectInterrupt;

	UINT16 DeviceId;
	UINT8 VersionId;

	INT JackType;
	ULONG LastButton;

	// Requests from the DSP driver (telith_codec_api.h)
	PCALLBACK_OBJECT CodecCallback;
	PVOID CodecCallbackReg;
	PCALLBACK_OBJECT JackCallback;
	BOOLEAN HeadphoneActive;
	BOOLEAN SpeakerActive;
	BOOLEAN HeadsetMicActive;
	LONG HpAmpCount;
} RT5650_CONTEXT, *PRT5650_CONTEXT;

WDF_DECLARE_CONTEXT_TYPE_WITH_NAME(RT5650_CONTEXT, GetDeviceContext)

DRIVER_INITIALIZE DriverEntry;

#endif
