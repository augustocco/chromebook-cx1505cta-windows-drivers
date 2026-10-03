/*++

Copyright (c) Microsoft Corporation All Rights Reserved
Copyright (c) Telith Audio Project

Module Name:

    headphonetopo.cpp

Abstract:

    Topology miniport handlers for the headphone endpoint. The jack state
    comes from the RT5650 codec driver (see Main\telith_hw.c).
--*/

#pragma warning (disable : 4127)

#include "definitions.h"
#include "endpoints.h"
#include "mintopo.h"
#include "headphonetopo.h"
#include "headphonetoptable.h"
#include "headsetmictoptable.h"
#include "Main\telith_hw.h"

#pragma code_seg("PAGE")
//=============================================================================
NTSTATUS
PropertyHandler_HeadphoneTopoFilter
(
    _In_ PPCPROPERTY_REQUEST      PropertyRequest
)
{
    PAGED_CODE();

    ASSERT(PropertyRequest);

    NTSTATUS            ntStatus = STATUS_INVALID_DEVICE_REQUEST;
    PCMiniportTopology  pMiniport = (PCMiniportTopology)PropertyRequest->MajorTarget;
    KSJACK_DESCRIPTION  jack = HeadphoneJackDescBridge;
    PKSJACK_DESCRIPTION jacks[] = { NULL, &jack };

    C_ASSERT(ARRAYSIZE(jacks) == ARRAYSIZE(HeadphoneJackDescriptions));

    jack.IsConnected = TelithHwHeadphoneConnected();

    if (IsEqualGUIDAligned(*PropertyRequest->PropertyItem->Set, KSPROPSETID_Jack))
    {
        if (PropertyRequest->PropertyItem->Id == KSPROPERTY_JACK_DESCRIPTION)
        {
            ntStatus = pMiniport->PropertyHandlerJackDescription(
                PropertyRequest,
                ARRAYSIZE(jacks),
                jacks
                );
        }
        else if (PropertyRequest->PropertyItem->Id == KSPROPERTY_JACK_DESCRIPTION2)
        {
            ntStatus = pMiniport->PropertyHandlerJackDescription2(
                PropertyRequest,
                ARRAYSIZE(jacks),
                jacks,
                JACKDESC2_PRESENCE_DETECT_CAPABILITY
                );
        }
    }

    return ntStatus;
} // PropertyHandler_HeadphoneTopoFilter

//=============================================================================
NTSTATUS
PropertyHandler_HeadsetMicTopoFilter
(
    _In_ PPCPROPERTY_REQUEST      PropertyRequest
)
{
    PAGED_CODE();

    ASSERT(PropertyRequest);

    NTSTATUS            ntStatus = STATUS_INVALID_DEVICE_REQUEST;
    PCMiniportTopology  pMiniport = (PCMiniportTopology)PropertyRequest->MajorTarget;
    KSJACK_DESCRIPTION  jack = HeadsetMicJackDesc;
    PKSJACK_DESCRIPTION jacks[] = { &jack, NULL };

    C_ASSERT(ARRAYSIZE(jacks) == ARRAYSIZE(HeadsetMicJackDescriptions));

    jack.IsConnected = TelithHwHeadsetMicConnected();

    if (IsEqualGUIDAligned(*PropertyRequest->PropertyItem->Set, KSPROPSETID_Jack))
    {
        if (PropertyRequest->PropertyItem->Id == KSPROPERTY_JACK_DESCRIPTION)
        {
            ntStatus = pMiniport->PropertyHandlerJackDescription(
                PropertyRequest,
                ARRAYSIZE(jacks),
                jacks
                );
        }
        else if (PropertyRequest->PropertyItem->Id == KSPROPERTY_JACK_DESCRIPTION2)
        {
            ntStatus = pMiniport->PropertyHandlerJackDescription2(
                PropertyRequest,
                ARRAYSIZE(jacks),
                jacks,
                JACKDESC2_PRESENCE_DETECT_CAPABILITY
                );
        }
    }

    return ntStatus;
} // PropertyHandler_HeadsetMicTopoFilter

//=============================================================================
NTSTATUS
EventHandler_HeadphoneJack
(
    _In_ PPCEVENT_REQUEST EventRequest
)
{
    PAGED_CODE();

    ASSERT(EventRequest);

    PCMiniportTopology pMiniport = (PCMiniportTopology)EventRequest->MajorTarget;

    switch (EventRequest->Verb)
    {
    case PCEVENT_VERB_ADD:
        pMiniport->AddEventToEventList(EventRequest->EventEntry);
        return STATUS_SUCCESS;
    case PCEVENT_VERB_REMOVE:
    case PCEVENT_VERB_SUPPORT:
        return STATUS_SUCCESS;
    default:
        return STATUS_INVALID_PARAMETER;
    }
} // EventHandler_HeadphoneJack

#pragma code_seg()
