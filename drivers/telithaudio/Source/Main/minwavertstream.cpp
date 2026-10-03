/*++

Copyright (c) Microsoft Corporation All Rights Reserved
Copyright (c) Telith Audio Project

Module Name:

    minwavertstream.cpp

Abstract:

    WaveRT stream on top of the Intel SOF DSP. The audio buffer is the HDA
    host DMA buffer of a SOF PCM; the position is the DMA position (DPIB).
    Based on the Microsoft SimpleAudioSample (MS-PL).
--*/

#include "definitions.h"
#include <limits.h>
#include <ks.h>
#include "endpoints.h"
#include "minwavert.h"
#include "minwavertstream.h"
#define MINWAVERTSTREAM_POOLTAG 'SRWM'

#pragma warning (disable : 4127)

// Number of host DMA periods (BDL entries) used when the engine does not ask
// for notifications.
#define DEFAULT_PERIODS     2
// HDA BDL entries must start on 128-byte boundaries.
#define PERIOD_ALIGN        128

//=============================================================================
#pragma code_seg("PAGE")
CMiniportWaveRTStream::~CMiniportWaveRTStream
(
    void
)
{
    PAGED_CODE();

    StopHardware();

    if (m_pNotificationTimer)
    {
        ExDeleteTimer(m_pNotificationTimer, TRUE, TRUE, NULL);
        m_pNotificationTimer = NULL;
    }
    KeFlushQueuedDpcs();

    if (NULL != m_pMiniport)
    {
        if (m_bUnregisterStream)
        {
            m_pMiniport->StreamClosed(m_ulPin, this);
            m_bUnregisterStream = FALSE;
        }

        m_pMiniport->Release();
        m_pMiniport = NULL;
    }

    if (m_pWfExt)
    {
        ExFreePoolWithTag( m_pWfExt, MINWAVERTSTREAM_POOLTAG );
        m_pWfExt = NULL;
    }

    DPF_ENTER(("[CMiniportWaveRTStream::~CMiniportWaveRTStream]"));
} // ~CMiniportWaveRTStream

//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS
CMiniportWaveRTStream::Init
(
    _In_ PCMiniportWaveRT           Miniport_,
    _In_ PPORTWAVERTSTREAM          PortStream_,
    _In_ ULONG                      Pin_,
    _In_ BOOLEAN                    Capture_,
    _In_ PKSDATAFORMAT              DataFormat_,
    _In_ GUID                       SignalProcessingMode
)
{
    PAGED_CODE();

    PWAVEFORMATEX pWfEx = NULL;
    NTSTATUS ntStatus = STATUS_SUCCESS;

    m_pMiniport = NULL;
    m_ulPin = 0;
    m_bUnregisterStream = FALSE;
    m_bCapture = FALSE;
    m_KsState = KSSTATE_STOP;
    m_pWfExt = NULL;
    m_ulContentId = 0;
    m_SignalProcessingMode = SignalProcessingMode;
    m_pMdl = NULL;
    m_pDmaBuffer = NULL;
    m_ulDmaBufferSize = 0;
    m_ulNotificationsPerBuffer = 0;
    m_ulNotificationIntervalMs = 0;
    m_ulLastDmaPosition = 0;
    m_ullLinearPosition = 0;
    m_CodecOn = FALSE;
    m_SofGeneration = 0;
    RtlZeroMemory(&m_SofStream, sizeof(m_SofStream));

    m_pPortStream = PortStream_;
    InitializeListHead(&m_NotificationList);
    KeInitializeSpinLock(&m_PositionSpinLock);
    KeInitializeSpinLock(&m_NotificationLock);

    m_pNotificationTimer = ExAllocateTimer(TimerNotifyRT, this, EX_TIMER_HIGH_RESOLUTION);
    if (!m_pNotificationTimer)
    {
        return STATUS_INSUFFICIENT_RESOURCES;
    }

    pWfEx = GetWaveFormatEx(DataFormat_);
    if (NULL == pWfEx)
    {
        return STATUS_UNSUCCESSFUL;
    }

    m_pMiniport = reinterpret_cast<CMiniportWaveRT*>(Miniport_);
    if (m_pMiniport == NULL)
    {
        return STATUS_INVALID_PARAMETER;
    }
    m_pMiniport->AddRef();

    m_ulPin = Pin_;
    m_bCapture = Capture_;

    switch (m_pMiniport->m_DeviceType)
    {
    case eHeadphoneDevice:
        m_PcmId = TELITH_PCM_HEADSET;
        m_CodecStart = TelithCodecHeadphoneStart;
        m_CodecStop = TelithCodecHeadphoneStop;
        break;
    case eHeadsetMicDevice:
        m_PcmId = TELITH_PCM_HEADSET;
        m_CodecStart = TelithCodecHeadsetMicStart;
        m_CodecStop = TelithCodecHeadsetMicStop;
        break;
    case eMicArrayDevice1:
        // DMIC straight into the DSP, the codec is not involved
        m_PcmId = TELITH_PCM_DMIC;
        m_CodecStart = 0;
        m_CodecStop = 0;
        break;
    case eSpeakerDevice:
    default:
        m_PcmId = TELITH_PCM_SPEAKERS;
        m_CodecStart = TelithCodecSpeakerStart;
        m_CodecStop = TelithCodecSpeakerStop;
        break;
    }

    m_pWfExt = (PWAVEFORMATEXTENSIBLE)ExAllocatePool2(POOL_FLAG_NON_PAGED, sizeof(WAVEFORMATEX) + pWfEx->cbSize, MINWAVERTSTREAM_POOLTAG);
    if (m_pWfExt == NULL)
    {
        return STATUS_INSUFFICIENT_RESOURCES;
    }
    RtlCopyMemory(m_pWfExt, pWfEx, sizeof(WAVEFORMATEX) + pWfEx->cbSize);

    //
    // Register this stream.
    //
    ntStatus = m_pMiniport->StreamCreated(m_ulPin, this);
    if (NT_SUCCESS(ntStatus))
    {
        m_bUnregisterStream = TRUE;
    }

    return ntStatus;
} // Init

//=============================================================================
#pragma code_seg("PAGE")
STDMETHODIMP_(NTSTATUS)
CMiniportWaveRTStream::NonDelegatingQueryInterface
(
    _In_ REFIID  Interface,
    _COM_Outptr_ PVOID * Object
)
{
    PAGED_CODE();

    ASSERT(Object);

    if (IsEqualGUIDAligned(Interface, IID_IUnknown))
    {
        *Object = PVOID(PUNKNOWN(PMINIPORTWAVERTSTREAM(this)));
    }
    else if (IsEqualGUIDAligned(Interface, IID_IMiniportWaveRTStream))
    {
        *Object = PVOID(PMINIPORTWAVERTSTREAM(this));
    }
    else if (IsEqualGUIDAligned(Interface, IID_IMiniportWaveRTStreamNotification))
    {
        *Object = PVOID(PMINIPORTWAVERTSTREAMNOTIFICATION(this));
    }
    else if (IsEqualGUIDAligned(Interface, IID_IDrmAudioStream))
    {
        *Object = (PVOID)(IDrmAudioStream*)this;
    }
    else
    {
        *Object = NULL;
    }

    if (*Object)
    {
        PUNKNOWN(*Object)->AddRef();
        return STATUS_SUCCESS;
    }

    return STATUS_INVALID_PARAMETER;
} // NonDelegatingQueryInterface

//=============================================================================
// Buffer allocation: physically contiguous pages (one HDA BDL entry per period)
//=============================================================================
#pragma code_seg("PAGE")
static ULONG AlignBufferSize(ULONG Requested, ULONG Periods, ULONG BlockAlign)
{
    // each period: multiple of PERIOD_ALIGN and of the frame size
    ULONG unit = PERIOD_ALIGN;
    while (unit % BlockAlign)
        unit += PERIOD_ALIGN;

    ULONG period = Requested / Periods;
    period -= period % unit;
    if (period == 0)
        period = unit;
    return period * Periods;
}

#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::AllocateBufferWithNotification
(
    _In_    ULONG               NotificationCount_,
    _In_    ULONG               RequestedSize_,
    _Out_   PMDL                *AudioBufferMdl_,
    _Out_   ULONG               *ActualSize_,
    _Out_   ULONG               *OffsetFromFirstPage_,
    _Out_   MEMORY_CACHING_TYPE *CacheType_
)
{
    PAGED_CODE();

    PHYSICAL_ADDRESS low, high, skip;
    ULONG periods, size;

    if ((0 == RequestedSize_) || (RequestedSize_ < m_pWfExt->Format.nBlockAlign))
    {
        return STATUS_UNSUCCESSFUL;
    }
    if ((NotificationCount_ == 0) || (RequestedSize_ % NotificationCount_ != 0))
    {
        return STATUS_INVALID_PARAMETER;
    }

    periods = (NotificationCount_ >= 2) ? NotificationCount_ : DEFAULT_PERIODS;
    size = AlignBufferSize(RequestedSize_, periods, m_pWfExt->Format.nBlockAlign);

    low.QuadPart = 0;
    high.QuadPart = MAXULONG;
    skip.QuadPart = 0;
    UNREFERENCED_PARAMETER(skip);

    PMDL pBufferMdl = m_pPortStream->AllocateContiguousPagesForMdl(low, high, size);
    if (NULL == pBufferMdl)
    {
        return STATUS_INSUFFICIENT_RESOURCES;
    }

    m_pDmaBuffer = (PUCHAR)m_pPortStream->MapAllocatedPages(pBufferMdl, MmCached);
    if (!m_pDmaBuffer)
    {
        m_pPortStream->FreePagesFromMdl(pBufferMdl);
        return STATUS_INSUFFICIENT_RESOURCES;
    }

    m_pMdl = pBufferMdl;
    m_ulNotificationsPerBuffer = NotificationCount_;
    m_ulDmaBufferSize = size;
    m_ulNotificationIntervalMs = (ULONG)(((ULONGLONG)size * 1000) /
        m_pWfExt->Format.nAvgBytesPerSec / NotificationCount_);

    *AudioBufferMdl_ = pBufferMdl;
    *ActualSize_ = size;
    *OffsetFromFirstPage_ = 0;
    *CacheType_ = MmCached;

    return STATUS_SUCCESS;
}

//=============================================================================
#pragma code_seg("PAGE")
VOID CMiniportWaveRTStream::FreeBufferWithNotification
(
    _In_        PMDL    Mdl_,
    _In_        ULONG   Size_
)
{
    FreeAudioBuffer(Mdl_, Size_);
}

//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::AllocateAudioBuffer
(
_In_    ULONG                   RequestedSize_,
_Out_   PMDL                   *AudioBufferMdl_,
_Out_   ULONG                  *ActualSize_,
_Out_   ULONG                  *OffsetFromFirstPage_,
_Out_   MEMORY_CACHING_TYPE    *CacheType_
)
{
    PAGED_CODE();

    NTSTATUS status = AllocateBufferWithNotification(DEFAULT_PERIODS,
        RequestedSize_ - (RequestedSize_ % DEFAULT_PERIODS),
        AudioBufferMdl_, ActualSize_, OffsetFromFirstPage_, CacheType_);
    if (NT_SUCCESS(status))
    {
        m_ulNotificationsPerBuffer = 0;
        m_ulNotificationIntervalMs = 0;
    }
    return status;
}

//=============================================================================
#pragma code_seg("PAGE")
VOID CMiniportWaveRTStream::FreeAudioBuffer
(
_In_opt_    PMDL        Mdl_,
_In_        ULONG       Size_
)
{
    UNREFERENCED_PARAMETER(Size_);

    PAGED_CODE();

    // The DSP must not touch the buffer any more.
    StopHardware();

    if (Mdl_ != NULL)
    {
        if (m_pDmaBuffer != NULL)
        {
            m_pPortStream->UnmapAllocatedPages(m_pDmaBuffer, Mdl_);
            m_pDmaBuffer = NULL;
        }

        m_pPortStream->FreePagesFromMdl(Mdl_);
    }

    m_pMdl = NULL;
    m_ulDmaBufferSize = 0;
    m_ulNotificationsPerBuffer = 0;
}

//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::RegisterNotificationEvent
(
    _In_ PKEVENT NotificationEvent_
)
{
    PAGED_CODE();

    KIRQL irql;
    NotificationListEntry *nleNew = (NotificationListEntry*)ExAllocatePool2(
        POOL_FLAG_NON_PAGED,
        sizeof(NotificationListEntry),
        MINWAVERTSTREAM_POOLTAG);
    if (NULL == nleNew)
    {
        return STATUS_INSUFFICIENT_RESOURCES;
    }

    nleNew->NotificationEvent = NotificationEvent_;

    KeAcquireSpinLock(&m_NotificationLock, &irql);
    PLIST_ENTRY leCurrent = m_NotificationList.Flink;
    while (leCurrent != &m_NotificationList)
    {
        NotificationListEntry* nleCurrent = CONTAINING_RECORD(leCurrent, NotificationListEntry, ListEntry);
        if (nleCurrent->NotificationEvent == NotificationEvent_)
        {
            KeReleaseSpinLock(&m_NotificationLock, irql);
            ExFreePoolWithTag(nleNew, MINWAVERTSTREAM_POOLTAG);
            return STATUS_UNSUCCESSFUL;
        }
        leCurrent = leCurrent->Flink;
    }
    InsertTailList(&m_NotificationList, &(nleNew->ListEntry));
    KeReleaseSpinLock(&m_NotificationLock, irql);

    return STATUS_SUCCESS;
}

//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::UnregisterNotificationEvent
(
    _In_ PKEVENT NotificationEvent_
)
{
    PAGED_CODE();

    KIRQL irql;

    KeAcquireSpinLock(&m_NotificationLock, &irql);
    PLIST_ENTRY leCurrent = m_NotificationList.Flink;
    while (leCurrent != &m_NotificationList)
    {
        NotificationListEntry* nleCurrent = CONTAINING_RECORD(leCurrent, NotificationListEntry, ListEntry);
        if (nleCurrent->NotificationEvent == NotificationEvent_)
        {
            RemoveEntryList(leCurrent);
            KeReleaseSpinLock(&m_NotificationLock, irql);
            ExFreePoolWithTag(nleCurrent, MINWAVERTSTREAM_POOLTAG);
            return STATUS_SUCCESS;
        }
        leCurrent = leCurrent->Flink;
    }
    KeReleaseSpinLock(&m_NotificationLock, irql);

    return STATUS_NOT_FOUND;
}

//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::GetClockRegister
(
    _Out_ PKSRTAUDIO_HWREGISTER Register_
)
{
    UNREFERENCED_PARAMETER(Register_);
    PAGED_CODE();
    return STATUS_NOT_IMPLEMENTED;
}

//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::GetPositionRegister
(
    _Out_ PKSRTAUDIO_HWREGISTER Register_
)
{
    UNREFERENCED_PARAMETER(Register_);
    PAGED_CODE();
    return STATUS_NOT_IMPLEMENTED;
}

//=============================================================================
#pragma code_seg("PAGE")
VOID CMiniportWaveRTStream::GetHWLatency
(
    _Out_ PKSRTAUDIO_HWLATENCY  Latency_
)
{
    PAGED_CODE();

    ASSERT(Latency_);

    // host DMA FIFO plus the DSP pipeline buffers (~1-10 ms period)
    Latency_->ChipsetDelay = 0;
    Latency_->CodecDelay = 0;
    Latency_->FifoSize = 256;
}

//=============================================================================
// Hardware: SOF PCM + codec path
//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::StartHardware()
{
    PAGED_CODE();

    PSOF_DSP dsp = TelithHwDsp();
    PHYSICAL_ADDRESS phys;
    ULONG periods;
    NTSTATUS status;

    if (m_SofStream.Open)
        return STATUS_SUCCESS;
    if (!dsp)
        return STATUS_DEVICE_NOT_READY;
    if (!m_pMdl || !m_pDmaBuffer || !m_ulDmaBufferSize)
        return STATUS_INVALID_DEVICE_STATE;

    if (m_CodecStart)
    {
        status = TelithHwCodecRequest(m_CodecStart);
        if (!NT_SUCCESS(status))
            return status;
        m_CodecOn = TRUE;
    }

    periods = (m_ulNotificationsPerBuffer >= 2) ? m_ulNotificationsPerBuffer : DEFAULT_PERIODS;
    phys = m_pPortStream->GetPhysicalPageAddress(m_pMdl, 0);

    status = SofPcmOpenBuffer(dsp, &m_SofStream, m_PcmId, m_bCapture ? 1 : 0,
        m_pWfExt->Format.nSamplesPerSec, m_pWfExt->Format.nChannels,
        m_pDmaBuffer, phys, m_ulDmaBufferSize, periods);
    if (NT_SUCCESS(status))
    {
        m_SofGeneration = TelithHwGeneration();
    }
    if (!NT_SUCCESS(status) && m_CodecOn)
    {
        TelithHwCodecRequest(m_CodecStop);
        m_CodecOn = FALSE;
    }
    return status;
}

#pragma code_seg("PAGE")
VOID CMiniportWaveRTStream::StopHardware()
{
    PAGED_CODE();

    PSOF_DSP dsp = TelithHwDsp();

    if (m_pNotificationTimer)
    {
        ExCancelTimer(m_pNotificationTimer, NULL);
    }

    if (m_SofStream.Open)
    {
        if (dsp && m_SofGeneration == TelithHwGeneration())
        {
            SofPcmClose(dsp, &m_SofStream);
        }
        else if (TelithHwBus())
        {
            // the DSP was powered down since the stream was opened
            SofPcmAbandon(TelithHwBus(), &m_SofStream);
        }
    }
    RtlZeroMemory(&m_SofStream, sizeof(m_SofStream));

    if (m_CodecOn)
    {
        TelithHwCodecRequest(m_CodecStop);
        m_CodecOn = FALSE;
    }
}

//=============================================================================
// Position
//=============================================================================
#pragma code_seg()
ULONG CMiniportWaveRTStream::ReadDmaPosition()
{
    PSOF_DSP dsp = TelithHwDsp();
    ULONG pos;

    if (!dsp || !m_SofStream.Open || !m_ulDmaBufferSize ||
        m_SofGeneration != TelithHwGeneration())
        return m_ulLastDmaPosition;

    pos = SofPcmPosition(dsp, &m_SofStream);
    if (pos >= m_ulDmaBufferSize)
        pos %= m_ulDmaBufferSize;
    return pos;
}

// Caller holds m_PositionSpinLock.
#pragma code_seg()
VOID CMiniportWaveRTStream::UpdateLinearPosition()
{
    ULONG pos = ReadDmaPosition();

    if (pos >= m_ulLastDmaPosition)
        m_ullLinearPosition += pos - m_ulLastDmaPosition;
    else
        m_ullLinearPosition += (m_ulDmaBufferSize - m_ulLastDmaPosition) + pos;
    m_ulLastDmaPosition = pos;
}

#pragma code_seg()
NTSTATUS CMiniportWaveRTStream::GetPosition
(
    _Out_   KSAUDIO_POSITION    *Position_
)
{
    KIRQL oldIrql;

    KeAcquireSpinLock(&m_PositionSpinLock, &oldIrql);

    if (m_KsState == KSSTATE_RUN)
    {
        UpdateLinearPosition();
    }

    Position_->PlayOffset = m_ulLastDmaPosition;
    Position_->WriteOffset = m_ulLastDmaPosition;

    KeReleaseSpinLock(&m_PositionSpinLock, oldIrql);

    return STATUS_SUCCESS;
}

//=============================================================================
// State
//=============================================================================
#pragma code_seg()
NTSTATUS CMiniportWaveRTStream::SetState
(
    _In_    KSSTATE State_
)
{
    NTSTATUS ntStatus = STATUS_SUCCESS;
    PSOF_DSP dsp = TelithHwDsp();
    KIRQL oldIrql;

    switch (State_)
    {
        case KSSTATE_STOP:
            if (m_KsState > KSSTATE_STOP)
            {
                StopHardware();
            }
            KeAcquireSpinLock(&m_PositionSpinLock, &oldIrql);
            m_ulLastDmaPosition = 0;
            m_ullLinearPosition = 0;
            KeReleaseSpinLock(&m_PositionSpinLock, oldIrql);
            break;

        case KSSTATE_ACQUIRE:
            if (m_KsState == KSSTATE_STOP)
            {
                // codec path + SOF PCM (PCM_PARAMS with this buffer)
                ntStatus = StartHardware();
            }
            break;

        case KSSTATE_PAUSE:
            if (m_KsState > KSSTATE_PAUSE)
            {
                // Run -> Pause
                ExCancelTimer(m_pNotificationTimer, NULL);
                KeFlushQueuedDpcs();
                if (dsp && m_SofStream.Running && m_SofGeneration == TelithHwGeneration())
                {
                    ntStatus = SofPcmPause(dsp, &m_SofStream);
                }
                KeAcquireSpinLock(&m_PositionSpinLock, &oldIrql);
                UpdateLinearPosition();
                KeReleaseSpinLock(&m_PositionSpinLock, oldIrql);
            }
            break;

        case KSSTATE_RUN:
            if (dsp && (!m_SofStream.Open || m_SofGeneration != TelithHwGeneration()))
            {
                // the DSP was rebooted (resume) after this stream was set up:
                // open the PCM and the codec path again on the new firmware
                StopHardware();
                ntStatus = StartHardware();
                if (!NT_SUCCESS(ntStatus))
                {
                    break;
                }
            }
            if (!dsp || !m_SofStream.Open)
            {
                ntStatus = STATUS_DEVICE_NOT_READY;
                break;
            }
            if (!m_SofStream.Running)
            {
                ntStatus = SofPcmStart(dsp, &m_SofStream);
            }
            else
            {
                ntStatus = SofPcmRelease(dsp, &m_SofStream);
            }
            if (NT_SUCCESS(ntStatus) && m_ulNotificationIntervalMs > 0)
            {
                // check the DMA position every millisecond and signal the
                // engine each time a notification boundary is crossed
                ExSetTimer(m_pNotificationTimer,
                    (-1) * HNSTIME_PER_MILLISECOND,
                    HNSTIME_PER_MILLISECOND,
                    NULL);
            }
            break;
    }

    if (NT_SUCCESS(ntStatus))
    {
        m_KsState = State_;
    }

    return ntStatus;
}

//=============================================================================
#pragma code_seg("PAGE")
NTSTATUS CMiniportWaveRTStream::SetFormat
(
    _In_    KSDATAFORMAT    *DataFormat_
)
{
    UNREFERENCED_PARAMETER(DataFormat_);
    PAGED_CODE();
    return STATUS_NOT_SUPPORTED;
}

//=============================================================================
#pragma code_seg("PAGE")
STDMETHODIMP_(NTSTATUS)
CMiniportWaveRTStream::SetContentId
(
    _In_  ULONG                   contentId,
    _In_  PCDRMRIGHTS             drmRights
)
{
    PAGED_CODE();

    UNREFERENCED_PARAMETER(drmRights);

    NTSTATUS    ntStatus;
    ULONG       ulOldContentId = m_ulContentId;

    m_ulContentId = contentId;
    ntStatus = m_pMiniport->UpdateDrmRights();
    if (!NT_SUCCESS(ntStatus))
    {
        m_ulContentId = ulOldContentId;
    }

    return ntStatus;
} // SetContentId

//=============================================================================
#pragma code_seg()
void
TimerNotifyRT
(
    _In_      PEX_TIMER    Timer,
    _In_opt_  PVOID        DeferredContext
)
{
    UNREFERENCED_PARAMETER(Timer);

    _IRQL_limited_to_(DISPATCH_LEVEL);

    CMiniportWaveRTStream* _this = (CMiniportWaveRTStream*)DeferredContext;
    ULONG segment, oldSegment, segmentSize;
    ULONGLONG oldLinear;
    BOOLEAN notify = FALSE;
    KIRQL oldIrql;

    if (NULL == _this || _this->m_KsState != KSSTATE_RUN ||
        !_this->m_ulNotificationsPerBuffer || !_this->m_ulDmaBufferSize)
    {
        return;
    }

    segmentSize = _this->m_ulDmaBufferSize / _this->m_ulNotificationsPerBuffer;

    KeAcquireSpinLock(&_this->m_PositionSpinLock, &oldIrql);
    oldLinear = _this->m_ullLinearPosition;
    _this->UpdateLinearPosition();
    oldSegment = (ULONG)(oldLinear / segmentSize);
    segment = (ULONG)(_this->m_ullLinearPosition / segmentSize);
    if (segment != oldSegment)
    {
        notify = TRUE;
    }
    KeReleaseSpinLock(&_this->m_PositionSpinLock, oldIrql);

    if (notify)
    {
        KeAcquireSpinLock(&_this->m_NotificationLock, &oldIrql);
        PLIST_ENTRY leCurrent = _this->m_NotificationList.Flink;
        while (leCurrent != &_this->m_NotificationList)
        {
            NotificationListEntry* nleCurrent = CONTAINING_RECORD(leCurrent, NotificationListEntry, ListEntry);
            KeSetEvent(nleCurrent->NotificationEvent, 0, 0);
            leCurrent = leCurrent->Flink;
        }
        KeReleaseSpinLock(&_this->m_NotificationLock, oldIrql);
    }
}
//=============================================================================
