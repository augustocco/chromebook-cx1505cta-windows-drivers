/*++

Copyright (c) Microsoft Corporation All Rights Reserved
Copyright (c) Telith Audio Project

Module Name:

    headphonetoptable.h

Abstract:

    Topology tables for the headphone endpoint (3.5 mm jack with presence
    detection). Derived from speakertoptable.h of the SimpleAudioSample.
--*/

#ifndef _TELITH_HEADPHONETOPTABLE_H_
#define _TELITH_HEADPHONETOPTABLE_H_

#include "headphonetopo.h"

//=============================================================================
static
KSDATARANGE HeadphoneTopoPinDataRangesBridge[] =
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
PKSDATARANGE HeadphoneTopoPinDataRangePointersBridge[] =
{
  &HeadphoneTopoPinDataRangesBridge[0]
};

//=============================================================================
static
PCPIN_DESCRIPTOR HeadphoneTopoMiniportPins[] =
{
  // KSPIN_TOPO_WAVEOUT_SOURCE
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
      SIZEOF_ARRAY(HeadphoneTopoPinDataRangePointersBridge),
      HeadphoneTopoPinDataRangePointersBridge,
      KSPIN_DATAFLOW_IN,                                // DataFlow
      KSPIN_COMMUNICATION_NONE,                         // Communication
      &KSCATEGORY_AUDIO,                                // Category
      NULL,                                             // Name
      0                                                 // Reserved
    }
  },
  // KSPIN_TOPO_LINEOUT_DEST
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
      SIZEOF_ARRAY(HeadphoneTopoPinDataRangePointersBridge),
      HeadphoneTopoPinDataRangePointersBridge,
      KSPIN_DATAFLOW_OUT,                               // DataFlow
      KSPIN_COMMUNICATION_NONE,                         // Communication
      &KSNODETYPE_HEADPHONES,                           // Category
      NULL,                                             // Name
      0                                                 // Reserved
    }
  }
};

//=============================================================================
// IsConnected is filled at runtime from the RT5650 jack detection.
static
KSJACK_DESCRIPTION HeadphoneJackDescBridge =
{
    KSAUDIO_SPEAKER_STEREO,
    JACKDESC_RGB(0x00, 0x00, 0x00),
    eConnType3Point5mm,
    eGeoLocLeft,
    eGenLocPrimaryBox,
    ePortConnJack,
    FALSE
};

// Only return a KSJACK_DESCRIPTION for the physical bridge pin.
static
PKSJACK_DESCRIPTION HeadphoneJackDescriptions[] =
{
    NULL,
    &HeadphoneJackDescBridge
};

//=============================================================================
static
PCCONNECTION_DESCRIPTOR HeadphoneTopoMiniportConnections[] =
{
    //  FromNode,                 FromPin,                    ToNode,                 ToPin
    {   PCFILTER_NODE,            KSPIN_TOPO_WAVEOUT_SOURCE,  PCFILTER_NODE,          KSPIN_TOPO_LINEOUT_DEST }
};

//=============================================================================
static
PCPROPERTY_ITEM PropertiesHeadphoneTopoFilter[] =
{
    {
        &KSPROPSETID_Jack,
        KSPROPERTY_JACK_DESCRIPTION,
        KSPROPERTY_TYPE_GET |
        KSPROPERTY_TYPE_BASICSUPPORT,
        PropertyHandler_HeadphoneTopoFilter
    },
    {
        &KSPROPSETID_Jack,
        KSPROPERTY_JACK_DESCRIPTION2,
        KSPROPERTY_TYPE_GET |
        KSPROPERTY_TYPE_BASICSUPPORT,
        PropertyHandler_HeadphoneTopoFilter
    }
};

// Jack change event (KSE_PIN on the line out pin), as in SYSVAD
static
PCEVENT_ITEM HeadphoneJackEvents[] =
{
    {
        &KSEVENTSETID_PinCapsChange,
        KSEVENT_PINCAPS_JACKINFOCHANGE,
        KSEVENT_TYPE_ENABLE | KSEVENT_TYPE_BASICSUPPORT,
        EventHandler_HeadphoneJack
    }
};

DEFINE_PCAUTOMATION_TABLE_PROP_EVENT(AutomationHeadphoneTopoFilter, PropertiesHeadphoneTopoFilter, HeadphoneJackEvents);

//=============================================================================
static
PCFILTER_DESCRIPTOR HeadphoneTopoMiniportFilterDescriptor =
{
  0,                                              // Version
  &AutomationHeadphoneTopoFilter,                 // AutomationTable
  sizeof(PCPIN_DESCRIPTOR),                       // PinSize
  SIZEOF_ARRAY(HeadphoneTopoMiniportPins),        // PinCount
  HeadphoneTopoMiniportPins,                      // Pins
  sizeof(PCNODE_DESCRIPTOR),                      // NodeSize
  0,                                              // NodeCount
  NULL,                                           // Nodes
  SIZEOF_ARRAY(HeadphoneTopoMiniportConnections), // ConnectionCount
  HeadphoneTopoMiniportConnections,               // Connections
  0,                                              // CategoryCount
  NULL                                            // Categories
};

#endif // _TELITH_HEADPHONETOPTABLE_H_
