// SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
/*
 * telith_hw.h -- real hardware behind the audio endpoints (Telith):
 * Intel SOF DSP on sklhdaudbus + Realtek RT5650 codec driver.
 */

#ifndef _TELITH_HW_H_
#define _TELITH_HW_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "..\..\..\sofdsp\sof_dsp.h"
#include "..\..\..\common\telith_codec_api.h"

// SOF PCM ids from the topology (sof-adl-rt5650)
#define TELITH_PCM_SPEAKERS     0
#define TELITH_PCM_HEADSET      1
#define TELITH_PCM_DMIC         99

// Jack change listeners (one per topology filter)
#define TELITH_JACK_SLOT_HEADPHONE  0
#define TELITH_JACK_SLOT_HEADSETMIC 1
#define TELITH_JACK_SLOTS           2

typedef VOID (*PTELITH_JACK_NOTIFY)(PVOID Context);

NTSTATUS TelithHwStart(_In_ PDEVICE_OBJECT Fdo, _In_ PDEVICE_OBJECT Pdo);
VOID TelithHwStop(VOID);

// D0 <-> D3 (standby, hibernation, fast startup): the DSP is booted again
VOID TelithHwSuspend(VOID);
NTSTATUS TelithHwResume(VOID);

PSOF_DSP TelithHwDsp(VOID);          // NULL while the DSP is not running
ULONG TelithHwGeneration(VOID);      // changes on every DSP boot
PADSP_BUS_INTERFACE TelithHwBus(VOID);
NTSTATUS TelithHwCodecRequest(_In_ ULONG Command);

BOOLEAN TelithHwHeadphoneConnected(VOID);
BOOLEAN TelithHwHeadsetMicConnected(VOID);
VOID TelithHwSetJackNotify(_In_ ULONG Slot, _In_opt_ PTELITH_JACK_NOTIFY Notify, _In_opt_ PVOID Context);

#ifdef __cplusplus
}
#endif

#endif
