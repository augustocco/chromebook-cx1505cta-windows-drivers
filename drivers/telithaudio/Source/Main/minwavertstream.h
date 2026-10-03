/*++

Copyright (c) Microsoft Corporation All Rights Reserved
Copyright (c) Telith Audio Project

Module Name:

    minwavertstream.h

Abstract:

    WaveRT stream on top of the Intel SOF DSP (HDA host DMA). Based on the
    Microsoft SimpleAudioSample (MS-PL); the simulated hardware was replaced
    by the real DMA buffer and position.
--*/

#ifndef _SIMPLEAUDIOSAMPLE_MINWAVERTSTREAM_H_
#define _SIMPLEAUDIOSAMPLE_MINWAVERTSTREAM_H_

#include "telith_hw.h"

//
// Structure to store notifications events in a protected list
//
typedef struct _NotificationListEntry
{
    LIST_ENTRY  ListEntry;
    PKEVENT     NotificationEvent;
} NotificationListEntry;

EXT_CALLBACK   TimerNotifyRT;

//=============================================================================
// Referenced Forward
//=============================================================================
class CMiniportWaveRT;
typedef CMiniportWaveRT *PCMiniportWaveRT;

//=============================================================================
// Classes
//=============================================================================
///////////////////////////////////////////////////////////////////////////////
// CMiniportWaveRTStream
//
class CMiniportWaveRTStream :
    public IDrmAudioStream,
    public IMiniportWaveRTStreamNotification,
    public CUnknown
{
protected:
    PPORTWAVERTSTREAM           m_pPortStream;
    LIST_ENTRY                  m_NotificationList;
    PEX_TIMER                   m_pNotificationTimer;
    ULONG                       m_ulNotificationIntervalMs;
    KSPIN_LOCK                  m_NotificationLock;

public:
    DECLARE_STD_UNKNOWN();
    DEFINE_STD_CONSTRUCTOR(CMiniportWaveRTStream);
    ~CMiniportWaveRTStream();

    IMP_IMiniportWaveRTStream;
    IMP_IMiniportWaveRTStreamNotification;
    IMP_IMiniportWaveRT;
    IMP_IDrmAudioStream;

    NTSTATUS                    Init
    (
        _In_  PCMiniportWaveRT    Miniport,
        _In_  PPORTWAVERTSTREAM   Stream,
        _In_  ULONG               Channel,
        _In_  BOOLEAN             Capture,
        _In_  PKSDATAFORMAT       DataFormat,
        _In_  GUID                SignalProcessingMode
    );

    // Friends
    friend class                CMiniportWaveRT;
    friend EXT_CALLBACK         TimerNotifyRT;
protected:
    CMiniportWaveRT*            m_pMiniport;
    ULONG                       m_ulPin;
    BOOLEAN                     m_bCapture;
    BOOLEAN                     m_bUnregisterStream;
    KSSTATE                     m_KsState;
    PWAVEFORMATEXTENSIBLE       m_pWfExt;
    ULONG                       m_ulContentId;
    GUID                        m_SignalProcessingMode;

    // SOF stream
    ULONG                       m_PcmId;
    ULONG                       m_SofGeneration;   // TelithHwGeneration() when m_SofStream was opened
    ULONG                       m_CodecStart;
    ULONG                       m_CodecStop;
    SOF_STREAM                  m_SofStream;
    BOOLEAN                     m_CodecOn;

    // DMA buffer (contiguous pages owned by the port stream)
    PMDL                        m_pMdl;
    PUCHAR                      m_pDmaBuffer;
    ULONG                       m_ulDmaBufferSize;
    ULONG                       m_ulNotificationsPerBuffer;

    // linear position: DMA position plus wraps
    ULONG                       m_ulLastDmaPosition;
    ULONGLONG                   m_ullLinearPosition;
    KSPIN_LOCK                  m_PositionSpinLock;

public:
    GUID GetSignalProcessingMode()
    {
        return m_SignalProcessingMode;
    }

private:
#pragma code_seg()
    ULONG ReadDmaPosition();
    VOID  UpdateLinearPosition();
    NTSTATUS StartHardware();
    VOID  StopHardware();
};
typedef CMiniportWaveRTStream *PCMiniportWaveRTStream;
#endif // _SIMPLEAUDIOSAMPLE_MINWAVERTSTREAM_H_
