/*++

Copyright (c) Telith Audio Project

Module Name:

    headphonetopo.h

Abstract:

    Topology miniport handlers for the headphone jack (RT5650 jack detection).
--*/

#ifndef _TELITH_HEADPHONETOPO_H_
#define _TELITH_HEADPHONETOPO_H_

NTSTATUS PropertyHandler_HeadphoneTopoFilter(
    _In_ PPCPROPERTY_REQUEST PropertyRequest
);

NTSTATUS PropertyHandler_HeadsetMicTopoFilter(
    _In_ PPCPROPERTY_REQUEST PropertyRequest
);

// KSEVENT_PINCAPS_JACKINFOCHANGE for both jack endpoints
NTSTATUS EventHandler_HeadphoneJack(
    _In_ PPCEVENT_REQUEST EventRequest
);

#endif // _TELITH_HEADPHONETOPO_H_
