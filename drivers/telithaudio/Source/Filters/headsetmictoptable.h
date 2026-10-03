/*++

Copyright (c) Microsoft Corporation All Rights Reserved
Copyright (c) Telith Audio Project

Module Name:

    headsetmictoptable.h

Abstract:

    Topology tables for the headset microphone (CTIA/OMTP plug on the 3.5 mm
    combo jack, detected by the RT5650). Derived from micarray1toptable.h of
    the SimpleAudioSample.
--*/

#ifndef _TELITH_HEADSETMICTOPTABLE_H_
#define _TELITH_HEADSETMICTOPTABLE_H_

#include "headphonetopo.h"

//=============================================================================
static
KSDATARANGE HeadsetMicTopoPinDataRangesBridge[] =
{
 {
   sizeof(KSDATARANGE),
   0,
   0,
   0,
   STATICGUIDOF(KSDATAFORMAT_TYPE_AUDIO),
   STATICGUIDOF(KSDATAFORMAT_SUBTYPE_ANALOG),
   STATICGUIDOF(KSDATAFORMAT_SPECIFIER_NONE)
 }
};

static
PKSDATARANGE HeadsetMicTopoPinDataRangePointersBridge[] =
{
  &HeadsetMicTopoPinDataRangesBridge[0]
};

//=============================================================================
static
PCPIN_DESCRIPTOR HeadsetMicTopoMiniportPins[] =
{
  // KSPIN_TOPO_MIC_ELEMENTS
  {
    0,
    0,
    0,                                                  // InstanceCount
    NULL,                                               // AutomationTable
    {                                                   // KsPinDescriptor
      0,                                                // InterfacesCount
      NULL,                                             // Interfaces
      0,                                                // MediumsCount
      NULL,                                             // Mediums
      SIZEOF_ARRAY(HeadsetMicTopoPinDataRangePointersBridge),
      HeadsetMicTopoPinDataRangePointersBridge,
      KSPIN_DATAFLOW_IN,                                // DataFlow
      KSPIN_COMMUNICATION_NONE,                         // Communication
      &KSNODETYPE_HEADSET_MICROPHONE,                   // Category
      NULL,                                             // Name
      0                                                 // Reserved
    }
  },
  // KSPIN_TOPO_BRIDGE
  {
    0,
    0,
    0,                                                  // InstanceCount
    NULL,                                               // AutomationTable
    {                                                   // KsPinDescriptor
      0,                                                // InterfacesCount
      NULL,                                             // Interfaces
      0,                                                // MediumsCount
      NULL,                                             // Mediums
      SIZEOF_ARRAY(HeadsetMicTopoPinDataRangePointersBridge),
      HeadsetMicTopoPinDataRangePointersBridge,
      KSPIN_DATAFLOW_OUT,                               // DataFlow
      KSPIN_COMMUNICATION_NONE,                         // Communication
      &KSCATEGORY_AUDIO,                                // Category
      NULL,                                             // Name
      0                                                 // Reserved
    }
  }
};

//=============================================================================
// IsConnected is filled at runtime from the RT5650 jack detection.
static
KSJACK_DESCRIPTION HeadsetMicJackDesc =
{
    KSAUDIO_SPEAKER_MONO,
    JACKDESC_RGB(0x00, 0x00, 0x00),
    eConnType3Point5mm,
    eGeoLocLeft,
    eGenLocPrimaryBox,
    ePortConnJack,
    FALSE
};

// Only return a KSJACK_DESCRIPTION for the physical mic pin.
static
PKSJACK_DESCRIPTION HeadsetMicJackDescriptions[] =
{
    &HeadsetMicJackDesc,
    NULL
};

//=============================================================================
static
PCCONNECTION_DESCRIPTOR HeadsetMicTopoMiniportConnections[] =
{
    //  FromNode,                 FromPin,                    ToNode,                 ToPin
    {   PCFILTER_NODE,            KSPIN_TOPO_MIC_ELEMENTS,    PCFILTER_NODE,          KSPIN_TOPO_BRIDGE }
};

//=============================================================================
static
PCPROPERTY_ITEM PropertiesHeadsetMicTopoFilter[] =
{
    {
        &KSPROPSETID_Jack,
        KSPROPERTY_JACK_DESCRIPTION,
        KSPROPERTY_TYPE_GET |
        KSPROPERTY_TYPE_BASICSUPPORT,
        PropertyHandler_HeadsetMicTopoFilter
    },
    {
        &KSPROPSETID_Jack,
        KSPROPERTY_JACK_DESCRIPTION2,
        KSPROPERTY_TYPE_GET |
        KSPROPERTY_TYPE_BASICSUPPORT,
        PropertyHandler_HeadsetMicTopoFilter
    }
};

static
PCEVENT_ITEM HeadsetMicJackEvents[] =
{
    {
        &KSEVENTSETID_PinCapsChange,
        KSEVENT_PINCAPS_JACKINFOCHANGE,
        KSEVENT_TYPE_ENABLE | KSEVENT_TYPE_BASICSUPPORT,
        EventHandler_HeadphoneJack
    }
};

DEFINE_PCAUTOMATION_TABLE_PROP_EVENT(AutomationHeadsetMicTopoFilter, PropertiesHeadsetMicTopoFilter, HeadsetMicJackEvents);

//=============================================================================
static
PCFILTER_DESCRIPTOR HeadsetMicTopoMiniportFilterDescriptor =
{
  0,                                              // Version
  &AutomationHeadsetMicTopoFilter,                // AutomationTable
  sizeof(PCPIN_DESCRIPTOR),                       // PinSize
  SIZEOF_ARRAY(HeadsetMicTopoMiniportPins),       // PinCount
  HeadsetMicTopoMiniportPins,                     // Pins
  sizeof(PCNODE_DESCRIPTOR),                      // NodeSize
  0,                                              // NodeCount
  NULL,                                           // Nodes
  SIZEOF_ARRAY(HeadsetMicTopoMiniportConnections),// ConnectionCount
  HeadsetMicTopoMiniportConnections,              // Connections
  0,                                              // CategoryCount
  NULL                                            // Categories
};

#endif // _TELITH_HEADSETMICTOPTABLE_H_
