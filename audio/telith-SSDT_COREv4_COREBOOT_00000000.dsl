/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (32-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of telith-SSDT_COREv4_COREBOOT_00000000.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x000033B9 (13241)
 *     Revision         0x02
 *     Checksum         0x62
 *     OEM ID           "COREv4"
 *     OEM Table ID     "COREBOOT"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "CORE"
 *     Compiler Version 0x20250807 (539297799)
 */
DefinitionBlock ("", "SSDT", 2, "COREv4", "COREBOOT", 0x00000000)
{
    /*
     * iASL Warning: There were 18 external control methods found during
     * disassembly, but only 15 were resolved (3 unresolved). Additional
     * ACPI tables may be required to properly disassemble the code. This
     * resulting disassembler output file may not compile because the
     * disassembler did not know how many arguments to assign to the
     * unresolved methods. Note: SSDTs can be dynamically loaded at
     * runtime and may or may not be available via the host OS.
     *
     * In addition, the -fe option can be used to specify a file containing
     * control method external declarations with the associated method
     * argument counts. Each line of the file must be of the form:
     *     External (<method pathname>, MethodObj, <argument count>)
     * Invocation:
     *     iasl -fe refs.txt -d dsdt.aml
     *
     * The following methods were unresolved and many not compile properly
     * because the disassembler had to guess at the number of arguments
     * required for each:
     */
    External (_SB_.CREC, DeviceObj)
    External (_SB_.CREC.CKSC, DeviceObj)
    External (_SB_.MDSX, MethodObj)    // Warning: Unknown method, guessing 1 arguments
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.CTXS, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.EGPM, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.FSPI, UnknownObj)
    External (_SB_.PCI0.GFX0, DeviceObj)
    External (_SB_.PCI0.GFX0.XBCL, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.GFX0.XBCM, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.GFX0.XBQC, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.GNA_, UnknownObj)
    External (_SB_.PCI0.GTXS, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.HDAS, DeviceObj)
    External (_SB_.PCI0.HECI, UnknownObj)
    External (_SB_.PCI0.I2C0, DeviceObj)
    External (_SB_.PCI0.I2C1, DeviceObj)
    External (_SB_.PCI0.I2C2, DeviceObj)
    External (_SB_.PCI0.I2C3, DeviceObj)
    External (_SB_.PCI0.I2C4, DeviceObj)
    External (_SB_.PCI0.I2C5, DeviceObj)
    External (_SB_.PCI0.IPU0, UnknownObj)
    External (_SB_.PCI0.LPCB, UnknownObj)
    External (_SB_.PCI0.LPCB.EC0_.ACEX, FieldUnitObj)
    External (_SB_.PCI0.LPCB.EC0_.CHGD, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.LPCB.EC0_.CHGS, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.LPCB.EC0_.EDSX, MethodObj)    // Warning: Unknown method, guessing 1 arguments
    External (_SB_.PCI0.LPCB.EC0_.FAN0, FieldUnitObj)
    External (_SB_.PCI0.LPCB.EC0_.FAND, FieldUnitObj)
    External (_SB_.PCI0.LPCB.EC0_.PAT0, MethodObj)    // 2 Arguments
    External (_SB_.PCI0.LPCB.EC0_.PAT1, MethodObj)    // 2 Arguments
    External (_SB_.PCI0.LPCB.EC0_.PATD, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.LPCB.EC0_.S0IX, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.LPCB.EC0_.TSRD, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.LPCB.EC__.S0IX, MethodObj)    // Warning: Unknown method, guessing 1 arguments
    External (_SB_.PCI0.MCHC, UnknownObj)
    External (_SB_.PCI0.PS2K, DeviceObj)
    External (_SB_.PCI0.RGPM, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.RP01, UnknownObj)
    External (_SB_.PCI0.SRAM, UnknownObj)
    External (_SB_.PCI0.STXS, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.TELM, UnknownObj)
    External (_SB_.PCI0.TXHC, UnknownObj)
    External (_SB_.PCI0.TXHC.RHUB.SS01, DeviceObj)
    External (_SB_.PCI0.TXHC.RHUB.SS02, DeviceObj)
    External (_SB_.PCI0.UAR0, UnknownObj)
    External (_SB_.PCI0.XHCI, UnknownObj)
    External (_SB_.PCI0.XHCI.RHUB.HS01, DeviceObj)
    External (_SB_.PCI0.XHCI.RHUB.HS02, DeviceObj)
    External (_SB_.PCI0.XHCI.RHUB.HS03, DeviceObj)
    External (_SB_.PCI0.XHCI.RHUB.HS06, DeviceObj)
    External (_SB_.PCI0.XHCI.RHUB.HS08, DeviceObj)
    External (_SB_.PCI0.XHCI.RHUB.SS01, DeviceObj)
    External (_SB_.PCI0.XHCI.RHUB.SS04, DeviceObj)
    External (PICM, IntObj)
    External (PRRS, IntObj)
    External (RSTT, IntObj)
    External (WFDL, UnknownObj)

    Device (CTBL)
    {
        Name (_HID, "BOOT0000")  // _HID: Hardware ID
        Name (_UID, Zero)  // _UID: Unique ID
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            Return (0x0F)
        }

        Name (_CRS, Buffer (0x001C)  // _CRS: Current Resource Settings
        {
            /* 0000 */  0x87, 0x17, 0x00, 0x00, 0x1C, 0x02, 0x00, 0x00,  // ........
            /* 0008 */  0x00, 0x00, 0x00, 0x70, 0x89, 0x76, 0xFF, 0xEF,  // ...p.v..
            /* 0010 */  0x89, 0x76, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,  // .v......
            /* 0018 */  0x00, 0x00, 0x79, 0x00                           // ..y.
        })
    }

    Scope (\_SB)
    {
        Method (MPTS, 1, Serialized)
        {
        }
    }

    Scope (\_SB)
    {
        Method (MS0X, 1, Serialized)
        {
            If ((Arg0 == One)){}
            Else
            {
            }
        }
    }

    Scope (\_SB.PCI0)
    {
        Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
        {
            If (PICM)
            {
                Return (Package (0x3C)
                {
                    Package (0x04)
                    {
                        0x0001FFFF, 
                        0x00, 
                        0x00, 
                        0x00000010
                    }, 

                    Package (0x04)
                    {
                        0x0002FFFF, 
                        0x00, 
                        0x00, 
                        0x00000011
                    }, 

                    Package (0x04)
                    {
                        0x0004FFFF, 
                        0x00, 
                        0x00, 
                        0x00000012
                    }, 

                    Package (0x04)
                    {
                        0x0005FFFF, 
                        0x00, 
                        0x00, 
                        0x00000010
                    }, 

                    Package (0x04)
                    {
                        0x0006FFFF, 
                        0x03, 
                        0x00, 
                        0x00000010
                    }, 

                    Package (0x04)
                    {
                        0x0006FFFF, 
                        0x01, 
                        0x00, 
                        0x00000012
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x00, 
                        0x00, 
                        0x00000013
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x01, 
                        0x00, 
                        0x00000014
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x02, 
                        0x00, 
                        0x00000015
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x03, 
                        0x00, 
                        0x00000016
                    }, 

                    Package (0x04)
                    {
                        0x0008FFFF, 
                        0x00, 
                        0x00, 
                        0x00000017
                    }, 

                    Package (0x04)
                    {
                        0x000DFFFF, 
                        0x00, 
                        0x00, 
                        0x00000011
                    }, 

                    Package (0x04)
                    {
                        0x000DFFFF, 
                        0x01, 
                        0x00, 
                        0x00000013
                    }, 

                    Package (0x04)
                    {
                        0x0010FFFF, 
                        0x00, 
                        0x00, 
                        0x00000018
                    }, 

                    Package (0x04)
                    {
                        0x0010FFFF, 
                        0x01, 
                        0x00, 
                        0x00000019
                    }, 

                    Package (0x04)
                    {
                        0x0010FFFF, 
                        0x02, 
                        0x00, 
                        0x00000014
                    }, 

                    Package (0x04)
                    {
                        0x0010FFFF, 
                        0x03, 
                        0x00, 
                        0x00000015
                    }, 

                    Package (0x04)
                    {
                        0x0011FFFF, 
                        0x00, 
                        0x00, 
                        0x0000001A
                    }, 

                    Package (0x04)
                    {
                        0x0011FFFF, 
                        0x01, 
                        0x00, 
                        0x0000001B
                    }, 

                    Package (0x04)
                    {
                        0x0011FFFF, 
                        0x02, 
                        0x00, 
                        0x0000001C
                    }, 

                    Package (0x04)
                    {
                        0x0011FFFF, 
                        0x03, 
                        0x00, 
                        0x0000001D
                    }, 

                    Package (0x04)
                    {
                        0x0012FFFF, 
                        0x00, 
                        0x00, 
                        0x0000001E
                    }, 

                    Package (0x04)
                    {
                        0x0012FFFF, 
                        0x01, 
                        0x00, 
                        0x0000001F
                    }, 

                    Package (0x04)
                    {
                        0x0012FFFF, 
                        0x02, 
                        0x00, 
                        0x00000016
                    }, 

                    Package (0x04)
                    {
                        0x0013FFFF, 
                        0x00, 
                        0x00, 
                        0x00000020
                    }, 

                    Package (0x04)
                    {
                        0x0013FFFF, 
                        0x01, 
                        0x00, 
                        0x00000021
                    }, 

                    Package (0x04)
                    {
                        0x0013FFFF, 
                        0x02, 
                        0x00, 
                        0x00000022
                    }, 

                    Package (0x04)
                    {
                        0x0013FFFF, 
                        0x03, 
                        0x00, 
                        0x00000023
                    }, 

                    Package (0x04)
                    {
                        0x0014FFFF, 
                        0x01, 
                        0x00, 
                        0x00000017
                    }, 

                    Package (0x04)
                    {
                        0x0014FFFF, 
                        0x00, 
                        0x00, 
                        0x00000024
                    }, 

                    Package (0x04)
                    {
                        0x0014FFFF, 
                        0x02, 
                        0x00, 
                        0x00000011
                    }, 

                    Package (0x04)
                    {
                        0x0015FFFF, 
                        0x00, 
                        0x00, 
                        0x00000025
                    }, 

                    Package (0x04)
                    {
                        0x0015FFFF, 
                        0x01, 
                        0x00, 
                        0x00000026
                    }, 

                    Package (0x04)
                    {
                        0x0015FFFF, 
                        0x02, 
                        0x00, 
                        0x00000027
                    }, 

                    Package (0x04)
                    {
                        0x0015FFFF, 
                        0x03, 
                        0x00, 
                        0x00000028
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x00, 
                        0x00, 
                        0x00000012
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x01, 
                        0x00, 
                        0x00000013
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x02, 
                        0x00, 
                        0x00000014
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x03, 
                        0x00, 
                        0x00000015
                    }, 

                    Package (0x04)
                    {
                        0x0017FFFF, 
                        0x00, 
                        0x00, 
                        0x00000016
                    }, 

                    Package (0x04)
                    {
                        0x0019FFFF, 
                        0x00, 
                        0x00, 
                        0x00000029
                    }, 

                    Package (0x04)
                    {
                        0x0019FFFF, 
                        0x01, 
                        0x00, 
                        0x0000002A
                    }, 

                    Package (0x04)
                    {
                        0x0019FFFF, 
                        0x02, 
                        0x00, 
                        0x0000002B
                    }, 

                    Package (0x04)
                    {
                        0x001AFFFF, 
                        0x00, 
                        0x00, 
                        0x00000017
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x00, 
                        0x00, 
                        0x00000010
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x01, 
                        0x00, 
                        0x00000011
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x02, 
                        0x00, 
                        0x00000012
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x03, 
                        0x00, 
                        0x00000013
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x00, 
                        0x00, 
                        0x00000010
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x01, 
                        0x00, 
                        0x00000011
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x02, 
                        0x00, 
                        0x00000012
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x03, 
                        0x00, 
                        0x00000013
                    }, 

                    Package (0x04)
                    {
                        0x001EFFFF, 
                        0x00, 
                        0x00, 
                        0x00000014
                    }, 

                    Package (0x04)
                    {
                        0x001EFFFF, 
                        0x01, 
                        0x00, 
                        0x00000015
                    }, 

                    Package (0x04)
                    {
                        0x001EFFFF, 
                        0x02, 
                        0x00, 
                        0x0000002C
                    }, 

                    Package (0x04)
                    {
                        0x001EFFFF, 
                        0x03, 
                        0x00, 
                        0x0000002D
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x01, 
                        0x00, 
                        0x00000017
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x02, 
                        0x00, 
                        0x00000014
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x03, 
                        0x00, 
                        0x00000015
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x00, 
                        0x00, 
                        0x00000016
                    }
                })
            }
            Else
            {
                Return (Package (0x3C)
                {
                    Package (0x04)
                    {
                        0x0001FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0002FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000A
                    }, 

                    Package (0x04)
                    {
                        0x0004FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0005FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0006FFFF, 
                        0x03, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0006FFFF, 
                        0x01, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x01, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x02, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0007FFFF, 
                        0x03, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0008FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x000DFFFF, 
                        0x00, 
                        0x00, 
                        0x0000000A
                    }, 

                    Package (0x04)
                    {
                        0x000DFFFF, 
                        0x01, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0010FFFF, 
                        0x02, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0010FFFF, 
                        0x03, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0012FFFF, 
                        0x02, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0014FFFF, 
                        0x01, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0014FFFF, 
                        0x02, 
                        0x00, 
                        0x0000000A
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x01, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x02, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0016FFFF, 
                        0x03, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x0017FFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001AFFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x01, 
                        0x00, 
                        0x0000000A
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x02, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001CFFFF, 
                        0x03, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x01, 
                        0x00, 
                        0x0000000A
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x02, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001DFFFF, 
                        0x03, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001EFFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001EFFFF, 
                        0x01, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x01, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x02, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x03, 
                        0x00, 
                        0x0000000B
                    }, 

                    Package (0x04)
                    {
                        0x001FFFFF, 
                        0x00, 
                        0x00, 
                        0x0000000B
                    }
                })
            }
        }
    }

    Device (\_SB.CP00)
    {
        Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
        Name (_UID, Zero)  // _UID: Unique ID
        Name (_CST, Package (0x04)  // _CST: C-States
        {
            0x03, 
            Package (0x04)
            {
                Buffer (0x0011)
                {
                    /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x02, 0x01, 0x00,  // ........
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                    /* 0010 */  0x00                                             // .
                }, 

                0x01, 
                0x0001, 
                0x000003E8
            }, 

            Package (0x04)
            {
                Buffer (0x0011)
                {
                    /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x02, 0x01, 0x21,  // .......!
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                    /* 0010 */  0x00                                             // .
                }, 

                0x02, 
                0x007F, 
                0x0000015E
            }, 

            Package (0x04)
            {
                Buffer (0x0011)
                {
                    /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x02, 0x01, 0x60,  // .......`
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                    /* 0010 */  0x00                                             // .
                }, 

                0x03, 
                0x0418, 
                0x000000C8
            }
        })
        Name (GCPC, Package (0x17)
        {
            0x00000017, 
            0x03, 
            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x00, 0x04, 0x71,  // .......q
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x08, 0x04, 0xCE,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x10, 0x04, 0x71,  // .......q
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x18, 0x04, 0x71,  // .......q
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x08, 0x04, 0x71,  // .......q
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x10, 0x04, 0x74,  // .......t
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x00, 0x04, 0x74,  // .......t
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x08, 0x04, 0x74,  // .......t
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x40, 0x00, 0x04, 0xE7,  // ....@...
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x40, 0x00, 0x04, 0xE8,  // ....@...
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x02, 0x04, 0x77,  // .......w
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x00, 0x04, 0x70,  // .......p
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            0x00000001, 
            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x0A, 0x20, 0x04, 0x74,  // ..... .t
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x08, 0x18, 0x04, 0x74,  // .......t
                /* 0008 */  0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }, 

            Buffer (0x0011)
            {
                /* 0000 */  0x82, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                /* 0010 */  0x00                                             // .
            }
        })
        Method (_CPC, 0, NotSerialized)  // _CPC: Continuous Performance Control
        {
            GCPC [0x03] = 0x0A
            GCPC [0x16] = 0x03E8
            Return (GCPC) /* \_SB_.CP00.GCPC */
        }
    }

    Device (\_SB.CP01)
    {
        Name (_HID, "ACPI0007" /* Processor Device */)  // _HID: Hardware ID
        Name (_UID, One)  // _UID: Unique ID
        Name (_CST, Package (0x04)  // _CST: C-States
        {
            0x03, 
            Package (0x04)
            {
                Buffer (0x0011)
                {
                    /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x02, 0x01, 0x00,  // ........
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                    /* 0010 */  0x00                                             // .
                }, 

                0x01, 
                0x0001, 
                0x000003E8
            }, 

            Package (0x04)
            {
                Buffer (0x0011)
                {
                    /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x02, 0x01, 0x21,  // .......!
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                    /* 0010 */  0x00                                             // .
                }, 

                0x02, 
                0x007F, 
                0x0000015E
            }, 

            Package (0x04)
            {
                Buffer (0x0011)
                {
                    /* 0000 */  0x82, 0x0C, 0x00, 0x7F, 0x01, 0x02, 0x01, 0x60,  // .......`
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79,  // .......y
                    /* 0010 */  0x00                                             // .
                }, 

                0x03, 
                0x0418, 
                0x000000C8
            }
        })
        Method (_CPC, 0, NotSerialized)  // _CPC: Continuous Performance Control
        {
            \_SB.CP00.GCPC [0x03] = 0x0A
            \_SB.CP00.GCPC [0x16] = 0x03E8
            Return (\_SB.CP00.GCPC)
        }
    }

    Name (PPKG, Package (0x02)
    {
        \_SB.CP00, , 
        \_SB.CP01, 
    })
    Method (\_SB.CNOT, 1, NotSerialized)
    {
        Notify (\_SB.CP00, Arg0)
        Notify (\_SB.CP01, Arg0)
    }

    Scope (\_SB.PCI0)
    {
        Name (A4GB, 0x000000017FC00000)
        Name (A4GS, 0x0000007E80400000)
    }

    Scope (\_SB.PCI0.I2C0)
    {
        Name (FPCN, Package (0x03)
        {
            0x001E, 
            0x0037, 
            0x00000007
        })
    }

    Scope (\_SB.PCI0.I2C1)
    {
        Name (FMCN, Package (0x03)
        {
            0x004F, 
            0x00A0, 
            0x00000007
        })
    }

    Scope (\_SB.PCI0.I2C2)
    {
        Name (FMCN, Package (0x03)
        {
            0x004F, 
            0x009D, 
            0x00000007
        })
    }

    Scope (\_SB.PCI0.I2C3)
    {
        Name (FMCN, Package (0x03)
        {
            0x004F, 
            0x009D, 
            0x00000007
        })
    }

    Scope (\_SB.PCI0.I2C4)
    {
        Name (FMCN, Package (0x03)
        {
            0x006A, 
            0x00D5, 
            0x00000028
        })
    }

    Scope (\_SB.PCI0.I2C5)
    {
        Name (FMCN, Package (0x03)
        {
            0x004F, 
            0x0098, 
            0x00000007
        })
    }

    Scope (\_SB.PCI0)
    {
        Device (PMC)
        {
            Name (_HID, "INTC1026")  // _HID: Hardware ID
            Name (_DDN, "Intel(R) Alder Lake IPC Controller")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0B)
            }

            Name (_CRS, Buffer (0x000E)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0xFE,  // ........
                /* 0008 */  0x00, 0x00, 0x01, 0x00, 0x79, 0x00               // ....y.
            })
            Name (RVAL, Package (0x05)
            {
                Zero, 
                Zero, 
                Zero, 
                Zero, 
                Zero
            })
            Method (IPCS, 7, Serialized)
            {
                OperationRegion (IPCM, SystemMemory, 0xFE000000, 0xFF)
                Field (IPCM, DWordAcc, NoLock, Preserve)
                {
                    Offset (0x00), 
                    ICMD,   32, 
                    Offset (0x04), 
                    IBSY,   1, 
                    IERR,   1, 
                    Offset (0x06), 
                    IERC,   8, 
                    Offset (0x80), 
                    IWB0,   32, 
                    IWB1,   32, 
                    IWB2,   32, 
                    IWB3,   32, 
                    Offset (0x90), 
                    IRB0,   32, 
                    IRB1,   32, 
                    IRB2,   32, 
                    IRB3,   32
                }

                IWB0 = Arg3
                IWB1 = Arg4
                IWB2 = Arg5
                IWB3 = Arg6
                Local0 = Zero
                Local0 += (Arg0 << Zero)
                Local0 += (Arg1 << 0x0C)
                Local1 = Zero
                Local0 += (Local1 << 0x08)
                Local0 += (Arg2 << 0x10)
                ICMD = Local0
                Local1 = 0x03E8
                While ((Local1 > Zero))
                {
                    If ((IBSY == Zero))
                    {
                        RVAL [Zero] = Zero
                        RVAL [One] = IRB0 /* \_SB_.PCI0.PMC_.IPCS.IRB0 */
                        RVAL [0x02] = IRB1 /* \_SB_.PCI0.PMC_.IPCS.IRB1 */
                        RVAL [0x03] = IRB2 /* \_SB_.PCI0.PMC_.IPCS.IRB2 */
                        RVAL [0x04] = IRB3 /* \_SB_.PCI0.PMC_.IPCS.IRB3 */
                        Return (RVAL) /* \_SB_.PCI0.PMC_.RVAL */
                    }

                    If ((IERR == One))
                    {
                        Debug = "IPCS ERROR"
                        Debug = IERC /* \_SB_.PCI0.PMC_.IPCS.IERC */
                        RVAL [Zero] = One
                        Return (RVAL) /* \_SB_.PCI0.PMC_.RVAL */
                    }

                    Sleep (One)
                    Local1--
                }

                Debug = "IPCS TIMEOUT"
                RVAL [Zero] = 0x02
                Return (RVAL) /* \_SB_.PCI0.PMC_.RVAL */
            }
        }
    }

    Scope (\_SB.PCI0)
    {
        Device (PEPD)
        {
            Name (_HID, "INT33A1" /* Intel Power Engine */)  // _HID: Hardware ID
            Name (_CID, EisaId ("PNP0D80") /* Windows-compatible System Power Management Controller */)  // _CID: Compatible ID
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                ToBuffer (Arg0, Local0)
                If ((Local0 == ToUUID ("c4eb40a0-6cd2-11e2-bcfd-0800200c9a66") /* Modern Standby Intel */))
                {
                    ToInteger (Arg2, Local1)
                    If ((Local1 == Zero))
                    {
                        Return (Buffer (One)
                        {
                             0x7B                                             // {
                        })
                    }

                    If ((Local1 == One))
                    {
                        Return (Package (0x17)
                        {
                            Package (0x03)
                            {
                                \_SB.PCI0.MCHC, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.GFX0, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.TCPU, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.IPU0, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.GNA, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.TELM, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.TXHC, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.XHCI, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.SRAM, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.I2C0, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.I2C1, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.I2C2, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.I2C3, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.HECI, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        Zero
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.I2C4, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.I2C5, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.RP01, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        Zero
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.UAR0, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.LPCB, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        Zero
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.HDAS, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        Zero
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.PCI0.FSPI, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        0x03
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.CP00, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        Zero
                                    }
                                }
                            }, 

                            Package (0x03)
                            {
                                \_SB.CP01, , 
                                One, 
                                Package (0x02)
                                {
                                    Zero, 
                                    Package (0x02)
                                    {
                                        0xFF, 
                                        Zero
                                    }
                                }
                            }
                        })
                    }

                    If ((Local1 == 0x02)){}
                    If ((Local1 == 0x03))
                    {
                        If (CondRefOf (\_SB.PCI0.LPCB.EC0.EDSX))
                        {
                            \_SB.PCI0.LPCB.EC0.EDSX (Zero)
                        }

                        If (CondRefOf (\_SB.MDSX))
                        {
                            \_SB.MDSX (Zero)
                        }
                    }

                    If ((Local1 == 0x04))
                    {
                        If (CondRefOf (\_SB.PCI0.LPCB.EC0.EDSX))
                        {
                            \_SB.PCI0.LPCB.EC0.EDSX (One)
                        }

                        If (CondRefOf (\_SB.MDSX))
                        {
                            \_SB.MDSX (One)
                        }
                    }

                    If ((Local1 == 0x05))
                    {
                        If (CondRefOf (\_SB.PCI0.LPCB.EC.S0IX))
                        {
                            \_SB.PCI0.LPCB.EC.S0IX (One)
                        }

                        If (CondRefOf (\_SB.PCI0.LPCB.EC0.S0IX))
                        {
                            \_SB.PCI0.LPCB.EC0.S0IX (One)
                        }

                        If (CondRefOf (\_SB.MS0X))
                        {
                            \_SB.MS0X (One)
                        }

                        If (CondRefOf (\_SB.PCI0.EGPM))
                        {
                            \_SB.PCI0.EGPM ()
                        }
                    }

                    If ((Local1 == 0x06))
                    {
                        If (CondRefOf (\_SB.PCI0.LPCB.EC.S0IX))
                        {
                            \_SB.PCI0.LPCB.EC.S0IX (Zero)
                        }

                        If (CondRefOf (\_SB.PCI0.LPCB.EC0.S0IX))
                        {
                            \_SB.PCI0.LPCB.EC0.S0IX (Zero)
                        }

                        If (CondRefOf (\_SB.MS0X))
                        {
                            \_SB.MS0X (Zero)
                        }

                        If (CondRefOf (\_SB.PCI0.RGPM))
                        {
                            \_SB.PCI0.RGPM ()
                        }
                    }

                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }

                If ((Local0 == ToUUID ("57a6512e-3979-4e9d-9708-ff13b2508972") /* Unknown UUID */))
                {
                    ToInteger (Arg2, Local1)
                    If ((Local1 == Zero))
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }

                    If ((Local1 == One))
                    {
                        Return (Buffer (0xC0)
                        {
                            /* 0000 */  0x36, 0x02, 0x7C, 0x75, 0xEF, 0x01, 0x7C, 0x80,  // 6.|u..|.
                            /* 0008 */  0xAC, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0010 */  0x05, 0xE8, 0x3F, 0x18, 0x00, 0x00, 0xA0, 0xAA,  // ..?.....
                            /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0030 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0038 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0040 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0048 */  0x7E, 0x02, 0xFE, 0xF7, 0xEF, 0x01, 0x7C, 0xE8,  // ~.....|.
                            /* 0050 */  0xAD, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0058 */  0xC5, 0xE8, 0x3F, 0x38, 0x00, 0x00, 0xA0, 0xAA,  // ..?8....
                            /* 0060 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0068 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0070 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0078 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0080 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0088 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0090 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 0098 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 00A0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 00A8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 00B0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                            /* 00B8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // ........
                        })
                    }

                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }
        }
    }

    Scope (\_SB.PCI0.GFX0)
    {
        Method (_DOD, 0, NotSerialized)  // _DOD: Display Output Devices
        {
            Return (Package (0x04)
            {
                0x80010400, 
                0x80010000, 
                0x80010000, 
                0x80010000
            })
        }

        Device (LCD0)
        {
            Name (_ADR, 0x0400)  // _ADR: Address
            Name (_STA, 0x0F)  // _STA: Status
            Method (_BCL, 0, NotSerialized)  // _BCL: Brightness Control Levels
            {
                Return (^^XBCL ())
            }

            Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
            {
                ^^XBCM (Arg0)
            }

            Method (_BQC, 0, NotSerialized)  // _BQC: Brightness Query Current
            {
                Return (^^XBQC ())
            }
        }

        Device (DD01)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_STA, 0x0F)  // _STA: Status
        }

        Device (DD02)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_STA, 0x0F)  // _STA: Status
            Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
            {
                ToPLD (
                    PLD_Revision           = 0x2,
                    PLD_IgnoreColor        = 0x0,
                    PLD_Red                = 0x0,
                    PLD_Green              = 0x0,
                    PLD_Blue               = 0x0,
                    PLD_Width              = 0x0,
                    PLD_Height             = 0x0,
                    PLD_UserVisible        = 0x1,
                    PLD_Dock               = 0x0,
                    PLD_Lid                = 0x0,
                    PLD_Panel              = "LEFT",
                    PLD_VerticalPosition   = "UPPER",
                    PLD_HorizontalPosition = "LEFT",
                    PLD_Shape              = "OVAL",
                    PLD_GroupOrientation   = 0x0,
                    PLD_GroupToken         = 0x1,
                    PLD_GroupPosition      = 0x1,
                    PLD_Bay                = 0x0,
                    PLD_Ejectable          = 0x0,
                    PLD_EjectRequired      = 0x0,
                    PLD_CabinetNumber      = 0x0,
                    PLD_CardCageNumber     = 0x0,
                    PLD_Reference          = 0x0,
                    PLD_Rotation           = 0x0,
                    PLD_Order              = 0x0,
                    PLD_VerticalOffset     = 0x0,
                    PLD_HorizontalOffset   = 0x0)

            })
        }

        Device (DD03)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_STA, 0x0F)  // _STA: Status
            Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
            {
                ToPLD (
                    PLD_Revision           = 0x2,
                    PLD_IgnoreColor        = 0x0,
                    PLD_Red                = 0x0,
                    PLD_Green              = 0x0,
                    PLD_Blue               = 0x0,
                    PLD_Width              = 0x0,
                    PLD_Height             = 0x0,
                    PLD_UserVisible        = 0x1,
                    PLD_Dock               = 0x0,
                    PLD_Lid                = 0x0,
                    PLD_Panel              = "LEFT",
                    PLD_VerticalPosition   = "UPPER",
                    PLD_HorizontalPosition = "RIGHT",
                    PLD_Shape              = "OVAL",
                    PLD_GroupOrientation   = 0x0,
                    PLD_GroupToken         = 0x2,
                    PLD_GroupPosition      = 0x1,
                    PLD_Bay                = 0x0,
                    PLD_Ejectable          = 0x0,
                    PLD_EjectRequired      = 0x0,
                    PLD_CabinetNumber      = 0x0,
                    PLD_CardCageNumber     = 0x0,
                    PLD_Reference          = 0x0,
                    PLD_Rotation           = 0x0,
                    PLD_Order              = 0x0,
                    PLD_VerticalOffset     = 0x0,
                    PLD_HorizontalOffset   = 0x0)

            })
        }
    }

    Scope (\_SB.PCI0)
    {
        Device (TCPU)
        {
            Name (_ADR, 0x0000000000040000)  // _ADR: Address
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }
    }

    Scope (\_SB)
    {
        Device (DPTF)
        {
            Name (_HID, "INTC1041")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Device (TFN1)
            {
                Name (_HID, "INTC1048")  // _HID: Hardware ID
                Name (_UID, Zero)  // _UID: Unique ID
                Name (_STR, Unicode ("Fan Participant"))  // _STR: Description String
                Name (PTYP, 0x04)
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x00)
                }
            }

            Name (DCFG, Zero)
            Name (ODVX, Package (0x06)
            {
                0x00000000, 
                0x00000000, 
                0x00000000, 
                0x00000000, 
                0x00000000, 
                0x00000000
            })
            Method (ODUP, 2, Serialized)
            {
                ODVX [Arg0] = Arg1
            }

            Method (ODGT, 1, Serialized)
            {
                Return (DerefOf (ODVX [Arg0]))
            }

            Method (ODVP, 0, Serialized)
            {
                Return (ODVX) /* \_SB_.DPTF.ODVX */
            }

            Method (IMOK, 1, NotSerialized)
            {
                Return (Arg0)
            }

            Device (TCHG)
            {
                Name (_HID, "INTC1046")  // _HID: Hardware ID
                Name (_UID, Zero)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (_STR, Unicode ("Battery Charger"))  // _STR: Description String
                Name (PTYP, 0x0B)
            }

            Device (TSR0)
            {
                Name (_HID, "INTC1046")  // _HID: Hardware ID
                Name (_UID, One)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (PTYP, 0x03)
            }

            Device (TSR1)
            {
                Name (_HID, "INTC1046")  // _HID: Hardware ID
                Name (_UID, 0x02)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (PTYP, 0x03)
            }

            Device (TSR2)
            {
                Name (_HID, "INTC1046")  // _HID: Hardware ID
                Name (_UID, 0x03)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (PTYP, 0x03)
            }

            Device (TSR3)
            {
                Name (_HID, "INTC1046")  // _HID: Hardware ID
                Name (_UID, 0x04)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (PTYP, 0x03)
            }

            Device (TSR4)
            {
                Name (_HID, "INTC1046")  // _HID: Hardware ID
                Name (_UID, 0x05)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x00)
                }

                Name (PTYP, 0x03)
            }

            Device (TPCH)
            {
                Name (_HID, "INTC1049")  // _HID: Hardware ID
                Name (_STR, Unicode ("Intel PCH FIVR Participant"))  // _STR: Description String
                Name (PTYP, 0x05)
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Method (PKGC, 1, Serialized)
                {
                    Name (PPKG, Package (0x02)
                    {
                        Zero, 
                        Zero
                    })
                    PPKG [Zero] = DerefOf (Arg0 [Zero])
                    PPKG [One] = DerefOf (Arg0 [One])
                    Return (PPKG) /* \_SB_.DPTF.TPCH.PKGC.PPKG */
                }

                Method (RFC0, 1, Serialized)
                {
                    \_SB.PCI0.PMC.IPCS (0xA3, One, 0x08, Zero, Arg0, Zero, Zero)
                    Return (Package (0x01)
                    {
                        Zero
                    })
                }

                Method (RFC1, 1, Serialized)
                {
                    \_SB.PCI0.PMC.IPCS (0xA3, One, 0x08, One, Arg0, Zero, Zero)
                    Return (Package (0x01)
                    {
                        Zero
                    })
                }

                Method (GFC0, 0, Serialized)
                {
                    Local0 = \_SB.PCI0.PMC.IPCS (0xA3, Zero, 0x08, Zero, Zero, Zero, Zero)
                    Local1 = PKGC (Local0)
                    Return (Local1)
                }

                Method (GFC1, 0, Serialized)
                {
                    Local0 = \_SB.PCI0.PMC.IPCS (0xA3, Zero, 0x08, One, Zero, Zero, Zero)
                    Local1 = PKGC (Local0)
                    Return (Local1)
                }

                Method (GEMI, 0, Serialized)
                {
                    Local0 = \_SB.PCI0.PMC.IPCS (0xA3, Zero, 0x08, 0x02, Zero, Zero, Zero)
                    Local1 = PKGC (Local0)
                    Return (Local1)
                }

                Method (GFFS, 0, Serialized)
                {
                    Local0 = \_SB.PCI0.PMC.IPCS (0xA3, Zero, 0x08, 0x03, Zero, Zero, Zero)
                    Local1 = PKGC (Local0)
                    Return (Local1)
                }

                Method (GFCS, 0, Serialized)
                {
                    Local0 = \_SB.PCI0.PMC.IPCS (0xA3, Zero, 0x08, 0x04, Zero, Zero, Zero)
                    Local1 = PKGC (Local0)
                    Return (Local1)
                }
            }
        }
    }

    Scope (\_SB.DPTF)
    {
        Name (IDSP, Package (0x02)
        {
            ToUUID ("42a441d6-ae6a-462b-a84b-4a8ce79027d3") /* Unknown UUID */, 
            ToUUID ("97c68ae7-15fa-499c-b8c9-5da81d606e0a") /* Unknown UUID */
        })
    }

    Scope (\_SB.DPTF)
    {
        Name (TRTR, One)
        Method (_TRT, 0, NotSerialized)  // _TRT: Thermal Relationship Table
        {
            Return (Package (0x05)
            {
                Package (0x08)
                {
                    \_SB.PCI0.TCPU, , 
                    \_SB.PCI0.TCPU, , 
                    0x64, 
                    0x3C, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero
                }, 

                Package (0x08)
                {
                    \_SB.PCI0.TCPU, , 
                    TSR0, , 
                    0x64, 
                    0x3C, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero
                }, 

                Package (0x08)
                {
                    \_SB.PCI0.TCPU, , 
                    TSR1, , 
                    0x64, 
                    0x3C, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero
                }, 

                Package (0x08)
                {
                    \_SB.PCI0.TCPU, , 
                    TSR2, , 
                    0x64, 
                    0x32, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero
                }, 

                Package (0x08)
                {
                    TCHG, , 
                    TSR3, , 
                    0x64, 
                    0x3C, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero
                }
            })
        }
    }

    Scope (\_SB.PCI0.TCPU)
    {
        Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
        {
            Return (0x0DFE)
        }
    }

    Scope (\_SB.DPTF.TSR0)
    {
        Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
        {
            Return (0x0DFE)
        }
    }

    Scope (\_SB.DPTF.TSR1)
    {
        Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
        {
            Return (0x0DFE)
        }
    }

    Scope (\_SB.DPTF.TSR2)
    {
        Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
        {
            Return (0x0DFE)
        }
    }

    Scope (\_SB.DPTF.TSR3)
    {
        Method (_PSV, 0, NotSerialized)  // _PSV: Passive Temperature
        {
            Return (0x0DFE)
        }
    }

    Scope (\_SB.DPTF.TSR1)
    {
        Method (_CRT, 0, NotSerialized)  // _CRT: Critical Temperature
        {
            Return (0x0E30)
        }
    }

    Scope (\_SB.DPTF.TSR2)
    {
        Method (_CRT, 0, NotSerialized)  // _CRT: Critical Temperature
        {
            Return (0x0E30)
        }
    }

    Scope (\_SB.DPTF.TCHG)
    {
        Method (PPSS, 0, NotSerialized)
        {
            Return (Package (0x04)
            {
                Package (0x08)
                {
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero, 
                    0xFF, 
                    0x0BB8, 
                    "ma", 
                    Zero
                }, 

                Package (0x08)
                {
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero, 
                    0x18, 
                    0x05DC, 
                    "ma", 
                    Zero
                }, 

                Package (0x08)
                {
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero, 
                    0x10, 
                    0x03E8, 
                    "ma", 
                    Zero
                }, 

                Package (0x08)
                {
                    Zero, 
                    Zero, 
                    Zero, 
                    Zero, 
                    0x08, 
                    0x01F4, 
                    "ma", 
                    Zero
                }
            })
        }
    }

    Scope (\_SB.PCI0.TCPU)
    {
        Method (PPCC, 0, NotSerialized)
        {
            Return (Package (0x03)
            {
                0x02, 
                Package (0x06)
                {
                    Zero, 
                    0x1770, 
                    0x3A98, 
                    0x6D60, 
                    0x7D00, 
                    0xC8
                }, 

                Package (0x06)
                {
                    One, 
                    0x61A8, 
                    0x61A8, 
                    0x6D60, 
                    0x7D00, 
                    0x03E8
                }
            })
        }
    }

    Scope (\_SB.DPTF.TFN1)
    {
        Name (_FIF, Package (0x04)  // _FIF: Fan Information
        {
            Zero, 
            Zero, 
            Zero, 
            Zero
        })
    }

    Scope (\_SB.DPTF.TSR0)
    {
        Name (_STR, Unicode ("CPU"))  // _STR: Description String
    }

    Scope (\_SB.DPTF.TSR1)
    {
        Name (_STR, Unicode ("5V Regulator"))  // _STR: Description String
    }

    Scope (\_SB.DPTF.TSR2)
    {
        Name (_STR, Unicode ("Ambient"))  // _STR: Description String
    }

    Scope (\_SB.DPTF.TSR3)
    {
        Name (_STR, Unicode ("Charger"))  // _STR: Description String
    }

    Scope (\_SB.PCI0.I2C0)
    {
        Device (TPMI)
        {
            Name (_HID, "GOOG0005")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_DDN, "I2C TPM")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Name (_CRS, Buffer (0x002C)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x8E, 0x1E, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                /* 0010 */  0x50, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x50,  // P.\_SB.P
                /* 0018 */  0x43, 0x49, 0x30, 0x2E, 0x49, 0x32, 0x43, 0x30,  // CI0.I2C0
                /* 0020 */  0x00, 0x89, 0x06, 0x00, 0x07, 0x01, 0x4D, 0x00,  // ......M.
                /* 0028 */  0x00, 0x00, 0x79, 0x00                           // ..y.
            })
        }
    }

    Scope (\_SB.PCI0.I2C3)
    {
        Device (RT58)
        {
            Name (_HID, "10EC5650")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_DDN, "Realtek RT5650")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0B)
            }

            Name (_CRS, Buffer (0x0073)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x8E, 0x1E, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                /* 0010 */  0x1A, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x50,  // ..\_SB.P
                /* 0018 */  0x43, 0x49, 0x30, 0x2E, 0x49, 0x32, 0x43, 0x33,  // CI0.I2C3
                /* 0020 */  0x00, 0x8C, 0x25, 0x00, 0x01, 0x00, 0x01, 0x00,  // ..%.....
                /* 0028 */  0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x17,  // ........
                /* 0030 */  0x00, 0x00, 0x19, 0x00, 0x28, 0x00, 0x00, 0x00,  // ....(...
                /* 0038 */  0x57, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x50,  // W.\_SB.P
                /* 0040 */  0x43, 0x49, 0x30, 0x2E, 0x47, 0x50, 0x49, 0x4F,  // CI0.GPIO
                /* 0048 */  0x00, 0x8C, 0x25, 0x00, 0x01, 0x01, 0x01, 0x00,  // ..%.....
                /* 0050 */  0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x17,  // ........
                /* 0058 */  0x00, 0x00, 0x19, 0x00, 0x28, 0x00, 0x00, 0x00,  // ....(...
                /* 0060 */  0x4B, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x50,  // K.\_SB.P
                /* 0068 */  0x43, 0x49, 0x30, 0x2E, 0x47, 0x50, 0x49, 0x4F,  // CI0.GPIO
                /* 0070 */  0x00, 0x79, 0x00                                 // .y.
            })
            Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
            {
                ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                Package (0x03)
                {
                    Package (0x02)
                    {
                        "irq-gpios", 
                        Package (0x04)
                        {
                            \_SB.PCI0.I2C3.RT58, , 
                            Zero, 
                            Zero, 
                            Zero
                        }
                    }, 

                    Package (0x02)
                    {
                        "cbj-sleeve-gpios", 
                        Package (0x04)
                        {
                            \_SB.PCI0.I2C3.RT58, , 
                            One, 
                            Zero, 
                            Zero
                        }
                    }, 

                    Package (0x02)
                    {
                        "realtek,jd-mode", 
                        0x02
                    }
                }
            })
        }
    }

    Scope (\_SB.PCI0.I2C5)
    {
        Device (H015)
        {
            Name (_HID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _HID: Hardware ID
            Name (_CID, "PNP0C50" /* HID Protocol Device (I2C bus) */)  // _CID: Compatible ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_DDN, "PRIMAX Touchpad")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Name (_CRS, Buffer (0x002C)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x8E, 0x1E, 0x00, 0x01, 0x00, 0x01, 0x02, 0x00,  // ........
                /* 0008 */  0x00, 0x01, 0x06, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                /* 0010 */  0x15, 0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x50,  // ..\_SB.P
                /* 0018 */  0x43, 0x49, 0x30, 0x2E, 0x49, 0x32, 0x43, 0x35,  // CI0.I2C5
                /* 0020 */  0x00, 0x89, 0x06, 0x00, 0x1D, 0x01, 0x64, 0x00,  // ......d.
                /* 0028 */  0x00, 0x00, 0x79, 0x00                           // ..y.
            })
            Name (_S0W, 0x03)  // _S0W: S0 Device Wake State
            Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
            {
                0x4E, 
                0x03
            })
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                ToBuffer (Arg0, Local0)
                If ((Local0 == ToUUID ("3cdff6f7-4267-4555-ad05-b30a3d8938de") /* HID I2C Device */))
                {
                    ToInteger (Arg2, Local1)
                    If ((Local1 == Zero))
                    {
                        ToInteger (Arg1, Local2)
                        If ((Local2 == One))
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Else
                        {
                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }
                    }

                    If ((Local1 == One))
                    {
                        Return (0x01)
                    }

                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }
        }
    }

    Device (\_SB.PCI0.RP01.WF00)
    {
        Name (_UID, 0x923ACF1C)  // _UID: Unique ID
        Name (_DDN, "WIFI Device")  // _DDN: DOS Device Name
        Name (_ADR, 0x0000000000000000)  // _ADR: Address
    }

    Scope (\_SB.PCI0.RP01.WF00)
    {
        Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
        {
            0x23, 
            0x03
        })
        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("70d24161-6dd5-4c9e-8070-705531292865") /* Unknown UUID */, 
            Package (0x01)
            {
                Package (0x02)
                {
                    "DmaProperty", 
                    One
                }
            }
        })
        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            ToBuffer (Arg0, Local0)
            If ((Local0 == ToUUID ("7266172c-220b-4b29-814f-75e4dd26b5fd") /* Unknown UUID */))
            {
                ToInteger (Arg2, Local1)
                If ((Local1 == Zero))
                {
                    Return (Buffer (One)
                    {
                         0x2D                                             // -
                    })
                }

                If ((Local1 == One)){}
                If ((Local1 == 0x02))
                {
                    CreateWordField (Arg3, Zero, CMDT)
                    CreateWordField (Arg3, 0x02, CMDP)
                    If ((CMDT == One))
                    {
                        If (CondRefOf (RSTT))
                        {
                            Return (RSTT) /* External reference */
                        }

                        Return (Zero)
                    }

                    If ((CMDT == 0x02))
                    {
                        If (CondRefOf (RSTT))
                        {
                            RSTT = CMDP /* \_SB_.PCI0.RP01.WF00._DSM.CMDP */
                        }

                        Return (Zero)
                    }

                    If ((CMDT == 0x03))
                    {
                        If (CondRefOf (PRRS))
                        {
                            Return (PRRS) /* External reference */
                        }

                        Return (Zero)
                    }

                    Return (Zero)
                }

                If ((Local1 == 0x03))
                {
                    Return (One)
                }

                If ((Local1 == 0x04)){}
                If ((Local1 == 0x05))
                {
                    If (CondRefOf (WFDL))
                    {
                        WFDL = Arg3
                    }
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }
    }

    Scope (\_SB.DPTF)
    {
        Method (_OSC, 4, Serialized)  // _OSC: Operating System Capabilities
        {
            Local0 = SizeOf (IDSP)
            Local1 = Zero
            Local2 = Zero
            While ((Local1 < Local0))
            {
                If (((DerefOf (IDSP [Local1]) == Arg0) && (Arg1 == One)))
                {
                    Local2 = One
                }

                Local1++
            }

            If ((Local2 == One))
            {
                ^TSR0.PATD ()
                ^TSR1.PATD ()
                ^TSR2.PATD ()
                ^TSR3.PATD ()
                ^TSR4.PATD ()
                \_SB.PCI0.LPCB.EC0.CHGD ()
            }

            Local0 = SizeOf (IDSP)
            Local1 = Zero
            Local2 = Zero
            While ((Local1 < Local0))
            {
                If (((DerefOf (IDSP [Local1]) == Arg0) && (Arg1 == Zero)))
                {
                    Local2 = One
                }

                Local1++
            }

            If ((Local2 == One))
            {
                \_SB.PCI0.LPCB.EC0.FAND = 0xFF
            }

            Return (Arg3)
        }

        Method (TEVT, 1, NotSerialized)
        {
            ToInteger (Arg0, Local0)
            If ((Local0 == Zero))
            {
                Notify (^TSR0, 0x90) // Device-Specific
            }

            If ((Local0 == One))
            {
                Notify (^TSR1, 0x90) // Device-Specific
            }

            If ((Local0 == 0x02))
            {
                Notify (^TSR2, 0x90) // Device-Specific
            }

            If ((Local0 == 0x03))
            {
                Notify (^TSR3, 0x90) // Device-Specific
            }

            If ((Local0 == 0x04))
            {
                Notify (^TSR4, 0x90) // Device-Specific
            }
        }

        Method (TPET, 0, NotSerialized)
        {
            Notify (^TSR0, 0x81) // Information Change
            Notify (^TSR1, 0x81) // Information Change
            Notify (^TSR2, 0x81) // Information Change
            Notify (^TSR3, 0x81) // Information Change
            Notify (^TSR4, 0x81) // Information Change
        }
    }

    Scope (\_SB.DPTF.TCHG)
    {
        Method (PPPC, 0, Serialized)
        {
            Local0 = SizeOf (PPSS ())
            Local0--
            If ((\_SB.PCI0.LPCB.EC0.ACEX == Zero))
            {
                Return (Local0)
            }

            Return (Zero)
        }

        Method (SPPC, 1, Serialized)
        {
            Local0 = DerefOf (DerefOf (PPSS () [ToInteger (Arg0)]) [0x04]
                )
            \_SB.PCI0.LPCB.EC0.CHGS (Local0)
        }
    }

    Scope (\_SB.DPTF.TFN1)
    {
        Method (_FSL, 1, Serialized)  // _FSL: Fan Set Level
        {
            \_SB.PCI0.LPCB.EC0.FAND = Arg0
        }

        Name (TFST, Package (0x03)
        {
            Zero, 
            Zero, 
            Zero
        })
        Method (_FST, 0, Serialized)  // _FST: Fan Status
        {
            TFST [One] = \_SB.PCI0.LPCB.EC0.FAND /* External reference */
            TFST [0x02] = \_SB.PCI0.LPCB.EC0.FAN0 /* External reference */
            Return (TFST) /* \_SB_.DPTF.TFN1.TFST */
        }
    }

    Scope (\_SB.DPTF.TSR0)
    {
        Name (GTSH, 0x14)
        Method (_TMP, 0, Serialized)  // _TMP: Temperature
        {
            Return (\_SB.PCI0.LPCB.EC0.TSRD (Zero))
        }

        Name (PATC, 0x02)
        Method (PAT0, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT0 (Zero, Arg0)
        }

        Method (PAT1, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT1 (Zero, Arg0)
        }

        Method (PATD, 0, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PATD (Zero)
        }
    }

    Scope (\_SB.DPTF.TSR1)
    {
        Name (GTSH, 0x14)
        Method (_TMP, 0, Serialized)  // _TMP: Temperature
        {
            Return (\_SB.PCI0.LPCB.EC0.TSRD (One))
        }

        Name (PATC, 0x02)
        Method (PAT0, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT0 (One, Arg0)
        }

        Method (PAT1, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT1 (One, Arg0)
        }

        Method (PATD, 0, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PATD (One)
        }
    }

    Scope (\_SB.DPTF.TSR2)
    {
        Name (GTSH, 0x14)
        Method (_TMP, 0, Serialized)  // _TMP: Temperature
        {
            Return (\_SB.PCI0.LPCB.EC0.TSRD (0x02))
        }

        Name (PATC, 0x02)
        Method (PAT0, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT0 (0x02, Arg0)
        }

        Method (PAT1, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT1 (0x02, Arg0)
        }

        Method (PATD, 0, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PATD (0x02)
        }
    }

    Scope (\_SB.DPTF.TSR3)
    {
        Name (GTSH, 0x14)
        Method (_TMP, 0, Serialized)  // _TMP: Temperature
        {
            Return (\_SB.PCI0.LPCB.EC0.TSRD (0x03))
        }

        Name (PATC, 0x02)
        Method (PAT0, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT0 (0x03, Arg0)
        }

        Method (PAT1, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT1 (0x03, Arg0)
        }

        Method (PATD, 0, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PATD (0x03)
        }
    }

    Scope (\_SB.DPTF.TSR4)
    {
        Name (GTSH, 0x14)
        Method (_TMP, 0, Serialized)  // _TMP: Temperature
        {
            Return (\_SB.PCI0.LPCB.EC0.TSRD (0x04))
        }

        Name (PATC, 0x02)
        Method (PAT0, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT0 (0x04, Arg0)
        }

        Method (PAT1, 1, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PAT1 (0x04, Arg0)
        }

        Method (PATD, 0, Serialized)
        {
            \_SB.PCI0.LPCB.EC0.PATD (0x04)
        }
    }

    Scope (\_SB.CREC)
    {
        Device (USBC)
        {
            Name (_HID, "GOOG0014")  // _HID: Hardware ID
            Name (_DDN, "ChromeOS EC Embedded Controller USB Type-C Control")  // _DDN: DOS Device Name
            Device (CON0)
            {
                Name (_ADR, Zero)  // _ADR: Address
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x0A)
                    {
                        Package (0x02)
                        {
                            "port-number", 
                            Zero
                        }, 

                        Package (0x02)
                        {
                            "power-role", 
                            "dual"
                        }, 

                        Package (0x02)
                        {
                            "data-role", 
                            "dual"
                        }, 

                        Package (0x02)
                        {
                            "try-power-role", 
                            "source"
                        }, 

                        Package (0x02)
                        {
                            "usb2-port", 
                            \_SB.PCI0.XHCI.RHUB.HS01, 
                        }, 

                        Package (0x02)
                        {
                            "usb3-port", 
                            \_SB.PCI0.TXHC.RHUB.SS02, 
                        }, 

                        Package (0x02)
                        {
                            "orientation-switch", 
                            \_SB.PCI0.PMC.MUX.CON0, 
                        }, 

                        Package (0x02)
                        {
                            "usb-role-switch", 
                            \_SB.PCI0.PMC.MUX.CON0, 
                        }, 

                        Package (0x02)
                        {
                            "mode-switch", 
                            \_SB.PCI0.PMC.MUX.CON0, 
                        }, 

                        Package (0x02)
                        {
                            "port-location", 
                            "UNKNOWN"
                        }
                    }
                })
                Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
                {
                    ToPLD (
                        PLD_Revision           = 0x2,
                        PLD_IgnoreColor        = 0x0,
                        PLD_Red                = 0x0,
                        PLD_Green              = 0x0,
                        PLD_Blue               = 0x0,
                        PLD_Width              = 0x0,
                        PLD_Height             = 0x0,
                        PLD_UserVisible        = 0x1,
                        PLD_Dock               = 0x0,
                        PLD_Lid                = 0x0,
                        PLD_Panel              = "LEFT",
                        PLD_VerticalPosition   = "UPPER",
                        PLD_HorizontalPosition = "LEFT",
                        PLD_Shape              = "OVAL",
                        PLD_GroupOrientation   = 0x0,
                        PLD_GroupToken         = 0x1,
                        PLD_GroupPosition      = 0x1,
                        PLD_Bay                = 0x0,
                        PLD_Ejectable          = 0x0,
                        PLD_EjectRequired      = 0x0,
                        PLD_CabinetNumber      = 0x0,
                        PLD_CardCageNumber     = 0x0,
                        PLD_Reference          = 0x0,
                        PLD_Rotation           = 0x0,
                        PLD_Order              = 0x0,
                        PLD_VerticalOffset     = 0x0,
                        PLD_HorizontalOffset   = 0x0)

                })
            }

            Device (CON1)
            {
                Name (_ADR, One)  // _ADR: Address
                Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                {
                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                    Package (0x0A)
                    {
                        Package (0x02)
                        {
                            "port-number", 
                            One
                        }, 

                        Package (0x02)
                        {
                            "power-role", 
                            "dual"
                        }, 

                        Package (0x02)
                        {
                            "data-role", 
                            "dual"
                        }, 

                        Package (0x02)
                        {
                            "try-power-role", 
                            "source"
                        }, 

                        Package (0x02)
                        {
                            "usb2-port", 
                            \_SB.PCI0.XHCI.RHUB.HS02, 
                        }, 

                        Package (0x02)
                        {
                            "usb3-port", 
                            \_SB.PCI0.TXHC.RHUB.SS01, 
                        }, 

                        Package (0x02)
                        {
                            "orientation-switch", 
                            \_SB.PCI0.PMC.MUX.CON1, 
                        }, 

                        Package (0x02)
                        {
                            "usb-role-switch", 
                            \_SB.PCI0.PMC.MUX.CON1, 
                        }, 

                        Package (0x02)
                        {
                            "mode-switch", 
                            \_SB.PCI0.PMC.MUX.CON1, 
                        }, 

                        Package (0x02)
                        {
                            "port-location", 
                            "UNKNOWN"
                        }
                    }
                })
                Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
                {
                    ToPLD (
                        PLD_Revision           = 0x2,
                        PLD_IgnoreColor        = 0x0,
                        PLD_Red                = 0x0,
                        PLD_Green              = 0x0,
                        PLD_Blue               = 0x0,
                        PLD_Width              = 0x0,
                        PLD_Height             = 0x0,
                        PLD_UserVisible        = 0x1,
                        PLD_Dock               = 0x0,
                        PLD_Lid                = 0x0,
                        PLD_Panel              = "LEFT",
                        PLD_VerticalPosition   = "UPPER",
                        PLD_HorizontalPosition = "RIGHT",
                        PLD_Shape              = "OVAL",
                        PLD_GroupOrientation   = 0x0,
                        PLD_GroupToken         = 0x2,
                        PLD_GroupPosition      = 0x1,
                        PLD_Bay                = 0x0,
                        PLD_Ejectable          = 0x0,
                        PLD_EjectRequired      = 0x0,
                        PLD_CabinetNumber      = 0x0,
                        PLD_CardCageNumber     = 0x0,
                        PLD_Reference          = 0x0,
                        PLD_Rotation           = 0x0,
                        PLD_Order              = 0x0,
                        PLD_VerticalOffset     = 0x0,
                        PLD_HorizontalOffset   = 0x0)

                })
            }
        }
    }

    Scope (_SB.PCI0.PS2K)
    {
        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
            Package (0x02)
            {
                Package (0x02)
                {
                    "function-row-physmap", 
                    Package (0x0F)
                    {
                        0xEA, 
                        0xE7, 
                        0x91, 
                        0x92, 
                        0x93, 
                        0x94, 
                        0x95, 
                        0xA7, 
                        0xA8, 
                        0xA9, 
                        0x9A, 
                        0x9B, 
                        0xA0, 
                        0xAE, 
                        0xB0
                    }
                }, 

                Package (0x02)
                {
                    "linux,keymap", 
                    Package (0x7F)
                    {
                        0x00EA009E, 
                        0x00E700AD, 
                        0x00910174, 
                        0x00920078, 
                        0x00930063, 
                        0x009400E0, 
                        0x009500E1, 
                        0x00A7024A, 
                        0x00A8024F, 
                        0x00A9024E, 
                        0x009A00A4, 
                        0x009B00F8, 
                        0x00A00071, 
                        0x00AE0072, 
                        0x00B00073, 
                        0x003B003B, 
                        0x003C003C, 
                        0x003D003D, 
                        0x003E003E, 
                        0x003F003F, 
                        0x00400040, 
                        0x00410041, 
                        0x00420042, 
                        0x00430043, 
                        0x00440044, 
                        0x00570057, 
                        0x00580058, 
                        0x005900B7, 
                        0x005A00B8, 
                        0x005B00B9, 
                        0x005E01D0, 
                        0x00B50062, 
                        0x00370037, 
                        0x004A004A, 
                        0x00470047, 
                        0x00480048, 
                        0x00490049, 
                        0x004E004E, 
                        0x004B004B, 
                        0x004C004C, 
                        0x004D004D, 
                        0x004F004F, 
                        0x00500050, 
                        0x00510051, 
                        0x009C0060, 
                        0x00520052, 
                        0x00530053, 
                        0x005D008E, 
                        0x005C0247, 
                        0x00010001, 
                        0x00D3006F, 
                        0x00290029, 
                        0x00020002, 
                        0x00030003, 
                        0x00040004, 
                        0x00050005, 
                        0x00060006, 
                        0x00070007, 
                        0x00080008, 
                        0x00090009, 
                        0x000A000A, 
                        0x000B000B, 
                        0x000C000C, 
                        0x000D000D, 
                        0x007D007C, 
                        0x000E000E, 
                        0x000F000F, 
                        0x00100010, 
                        0x00110011, 
                        0x00120012, 
                        0x00130013, 
                        0x00140014, 
                        0x00150015, 
                        0x00160016, 
                        0x00170017, 
                        0x00180018, 
                        0x00190019, 
                        0x001A001A, 
                        0x001B001B, 
                        0x002B002B, 
                        0x00DB007D, 
                        0x001E001E, 
                        0x001F001F, 
                        0x00200020, 
                        0x00210021, 
                        0x00220022, 
                        0x00230023, 
                        0x00240024, 
                        0x00250025, 
                        0x00260026, 
                        0x00270027, 
                        0x00280028, 
                        0x001C001C, 
                        0x002A002A, 
                        0x00560056, 
                        0x002C002C, 
                        0x002D002D, 
                        0x002E002E, 
                        0x002F002F, 
                        0x00300030, 
                        0x00310031, 
                        0x00320032, 
                        0x00330033, 
                        0x00340034, 
                        0x00350035, 
                        0x00730059, 
                        0x00360036, 
                        0x001D001D, 
                        0x00380038, 
                        0x007B005E, 
                        0x00390039, 
                        0x0079005C, 
                        0x00B80064, 
                        0x009D0061, 
                        0x00CB0069, 
                        0x00D0006C, 
                        0x00CD006A, 
                        0x00C80067, 
                        0x00DE0074, 
                        0x003A003A, 
                        0x00D2006E, 
                        0x00AB0098, 
                        0x00C90068, 
                        0x00D1006D, 
                        0x00C70066, 
                        0x00CF006B, 
                        0x00AC0255
                    }
                }
            }
        })
    }

    Scope (_SB.CREC.CKSC)
    {
        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
            Package (0x01)
            {
                Package (0x02)
                {
                    "function-row-physmap", 
                    Package (0x0F)
                    {
                        0xEA, 
                        0xE7, 
                        0x91, 
                        0x92, 
                        0x93, 
                        0x94, 
                        0x95, 
                        0xA7, 
                        0xA8, 
                        0xA9, 
                        0x9A, 
                        0x9B, 
                        0xA0, 
                        0xAE, 
                        0xB0
                    }
                }
            }
        })
    }

    Scope (\_SB.PCI0.PMC)
    {
        Device (MUX)
        {
            Name (_HID, "INTC105C")  // _HID: Hardware ID
            Name (_DDN, "Intel PMC MUX Driver")  // _DDN: DOS Device Name
        }
    }

    Scope (\_SB.PCI0.HDAS)
    {
        Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
        {
            ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
            Package (0x03)
            {
                Package (0x02)
                {
                    "speaker-tplg", 
                    "rt5650"
                }, 

                Package (0x02)
                {
                    "hp-tplg", 
                    "rt5650"
                }, 

                Package (0x02)
                {
                    "mic-tplg", 
                    "2ch-pdm0"
                }
            }
        })
    }

    Scope (\_SB.PCI0.TXHC.RHUB.SS01)
    {
        Name (_DDN, "USB3 Type-C Port C1 (MLB)")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0x09, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x0,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x1,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "LEFT",
                PLD_VerticalPosition   = "UPPER",
                PLD_HorizontalPosition = "RIGHT",
                PLD_Shape              = "OVAL",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x2,
                PLD_GroupPosition      = 0x1,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.TXHC.RHUB.SS02)
    {
        Name (_DDN, "USB3 Type-C Port C0 (MLB)")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0x09, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x0,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x1,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "LEFT",
                PLD_VerticalPosition   = "UPPER",
                PLD_HorizontalPosition = "LEFT",
                PLD_Shape              = "OVAL",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x1,
                PLD_GroupPosition      = 0x1,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.XHCI.RHUB.HS01)
    {
        Name (_DDN, "USB2 Type-C Port C0 (MLB)")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0x09, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x0,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x1,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "LEFT",
                PLD_VerticalPosition   = "UPPER",
                PLD_HorizontalPosition = "LEFT",
                PLD_Shape              = "OVAL",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x1,
                PLD_GroupPosition      = 0x1,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.XHCI.RHUB.HS02)
    {
        Name (_DDN, "USB2 Type-C Port C1 (MLB)")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0x09, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x0,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x1,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "LEFT",
                PLD_VerticalPosition   = "UPPER",
                PLD_HorizontalPosition = "RIGHT",
                PLD_Shape              = "OVAL",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x2,
                PLD_GroupPosition      = 0x1,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.XHCI.RHUB.HS03)
    {
        Name (_DDN, "USB2 Type-A Port A0 (MLB)")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0x00, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x0,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x1,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "LEFT",
                PLD_VerticalPosition   = "UPPER",
                PLD_HorizontalPosition = "CENTER",
                PLD_Shape              = "HORIZONTALRECTANGLE",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x3,
                PLD_GroupPosition      = 0x1,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.XHCI.RHUB.HS06)
    {
        Name (_DDN, "USB2 UFC")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0xFF, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x1,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x0,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "UNKNOWN",
                PLD_VerticalPosition   = "CENTER",
                PLD_HorizontalPosition = "CENTER",
                PLD_Shape              = "UNKNOWN",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x0,
                PLD_GroupPosition      = 0x0,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.XHCI.RHUB.HS08)
    {
        Name (_DDN, "PCIe Bluetooth")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0xFF, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x1,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x0,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "UNKNOWN",
                PLD_VerticalPosition   = "CENTER",
                PLD_HorizontalPosition = "CENTER",
                PLD_Shape              = "UNKNOWN",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x0,
                PLD_GroupPosition      = 0x0,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
        Name (_S0W, 0x02)  // _S0W: S0 Device Wake State
        Name (RDLY, 0xA0)
        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            ToBuffer (Arg0, Local0)
            If ((Local0 == ToUUID ("aa10f4e0-81ac-4233-abf6-3b2ac50e28d9") /* Unknown UUID */))
            {
                ToInteger (Arg2, Local1)
                If ((Local1 == Zero))
                {
                    If ((Arg1 == Zero))
                    {
                        Return (Buffer (One)
                        {
                             0x0B                                             // .
                        })
                    }
                    Else
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }
                }

                If ((Local1 == One))
                {
                    RDLY = Arg3
                }

                If ((Local1 == 0x02))
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }

                If ((Local1 == 0x03))
                {
                    Return (Buffer (One)
                    {
                         0x01                                             // .
                    })
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }

        PowerResource (BTRT, 0x05, 0x0000)
        {
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (One)
            }

            Method (_ON, 0, NotSerialized)  // _ON_: Power On
            {
            }

            Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
            {
            }

            Method (_RST, 0, NotSerialized)  // _RST: Device Reset
            {
                Local0 = Acquire (\_SB.PCI0.CNMT, 0x03E8)
                If ((Local0 == Zero))
                {
                    \_SB.PCI0.CTXS (0x8C)
                    \_SB.PCI0.CTXS (0x8E)
                    \_SB.PCI0.BTRK (Zero)
                    Sleep (RDLY)
                    \_SB.PCI0.STXS (0x8C)
                    \_SB.PCI0.STXS (0x8E)
                    \_SB.PCI0.BTRK (One)
                    Sleep (RDLY)
                    Release (\_SB.PCI0.CNMT)
                }
            }
        }

        Name (_PRR, Package (0x01)  // _PRR: Power Resource for Reset
        {
            BTRT, 
        })
        Name (_PR0, Package (0x01)  // _PR0: Power Resources for D0
        {
            BTRT, 
        })
        Name (_PR3, Package (0x01)  // _PR3: Power Resources for D3hot
        {
            BTRT, 
        })
        Method (AOLD, 0, NotSerialized)
        {
            Name (AODS, Package (0x03)
            {
                Zero, 
                0x12, 
                Zero
            })
            Return (AODS) /* \_SB_.PCI0.XHCI.RHUB.HS08.AOLD.AODS */
        }
    }

    Scope (\_SB.PCI0)
    {
        Mutex (CNMT, 0x00)
        Method (SBTE, 1, NotSerialized)
        {
        }

        Method (GBTE, 0, NotSerialized)
        {
            Return (Zero)
        }

        Method (BTRK, 1, NotSerialized)
        {
            If ((Arg0 == One))
            {
                \_SB.PCI0.STXS (0x7B)
            }
            Else
            {
                \_SB.PCI0.CTXS (0x7B)
            }
        }

        Method (GBTR, 0, NotSerialized)
        {
            Local0 = \_SB.PCI0.GTXS (0x7B)
            Local0 ^= One
            Local0 ^= One
            Return (Local0)
        }
    }

    Scope (\_SB.PCI0.XHCI.RHUB.SS01)
    {
        Name (_DDN, "USB3 Type-A Port A0 (MLB)")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0x03, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x0,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x1,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "LEFT",
                PLD_VerticalPosition   = "UPPER",
                PLD_HorizontalPosition = "CENTER",
                PLD_Shape              = "HORIZONTALRECTANGLE",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x3,
                PLD_GroupPosition      = 0x1,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.XHCI.RHUB.SS04)
    {
        Name (_DDN, "USB3 WLAN")  // _DDN: DOS Device Name
        Name (_UPC, Package (0x04)  // _UPC: USB Port Capabilities
        {
            0xFF, 
            0xFF, 
            Zero, 
            Zero
        })
        Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
        {
            ToPLD (
                PLD_Revision           = 0x2,
                PLD_IgnoreColor        = 0x1,
                PLD_Red                = 0x0,
                PLD_Green              = 0x0,
                PLD_Blue               = 0x0,
                PLD_Width              = 0x0,
                PLD_Height             = 0x0,
                PLD_UserVisible        = 0x0,
                PLD_Dock               = 0x0,
                PLD_Lid                = 0x0,
                PLD_Panel              = "UNKNOWN",
                PLD_VerticalPosition   = "CENTER",
                PLD_HorizontalPosition = "CENTER",
                PLD_Shape              = "UNKNOWN",
                PLD_GroupOrientation   = 0x0,
                PLD_GroupToken         = 0x0,
                PLD_GroupPosition      = 0x0,
                PLD_Bay                = 0x0,
                PLD_Ejectable          = 0x0,
                PLD_EjectRequired      = 0x0,
                PLD_CabinetNumber      = 0x0,
                PLD_CardCageNumber     = 0x0,
                PLD_Reference          = 0x0,
                PLD_Rotation           = 0x0,
                PLD_Order              = 0x0,
                PLD_VerticalOffset     = 0x0,
                PLD_HorizontalOffset   = 0x0)

        })
    }

    Scope (\_SB.PCI0.PMC.MUX)
    {
        Device (CON0)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
            {
                ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                Package (0x02)
                {
                    Package (0x02)
                    {
                        "usb2-port-number", 
                        One
                    }, 

                    Package (0x02)
                    {
                        "usb3-port-number", 
                        0x02
                    }
                }
            })
            Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
            {
                ToPLD (
                    PLD_Revision           = 0x2,
                    PLD_IgnoreColor        = 0x0,
                    PLD_Red                = 0x0,
                    PLD_Green              = 0x0,
                    PLD_Blue               = 0x0,
                    PLD_Width              = 0x0,
                    PLD_Height             = 0x0,
                    PLD_UserVisible        = 0x1,
                    PLD_Dock               = 0x0,
                    PLD_Lid                = 0x0,
                    PLD_Panel              = "LEFT",
                    PLD_VerticalPosition   = "UPPER",
                    PLD_HorizontalPosition = "LEFT",
                    PLD_Shape              = "OVAL",
                    PLD_GroupOrientation   = 0x0,
                    PLD_GroupToken         = 0x1,
                    PLD_GroupPosition      = 0x1,
                    PLD_Bay                = 0x0,
                    PLD_Ejectable          = 0x0,
                    PLD_EjectRequired      = 0x0,
                    PLD_CabinetNumber      = 0x0,
                    PLD_CardCageNumber     = 0x0,
                    PLD_Reference          = 0x0,
                    PLD_Rotation           = 0x0,
                    PLD_Order              = 0x0,
                    PLD_VerticalOffset     = 0x0,
                    PLD_HorizontalOffset   = 0x0)

            })
        }
    }

    Scope (\_SB.PCI0.PMC.MUX)
    {
        Device (CON1)
        {
            Name (_ADR, One)  // _ADR: Address
            Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
            {
                ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                Package (0x02)
                {
                    Package (0x02)
                    {
                        "usb2-port-number", 
                        0x02
                    }, 

                    Package (0x02)
                    {
                        "usb3-port-number", 
                        One
                    }
                }
            })
            Name (_PLD, Package (0x01)  // _PLD: Physical Location of Device
            {
                ToPLD (
                    PLD_Revision           = 0x2,
                    PLD_IgnoreColor        = 0x0,
                    PLD_Red                = 0x0,
                    PLD_Green              = 0x0,
                    PLD_Blue               = 0x0,
                    PLD_Width              = 0x0,
                    PLD_Height             = 0x0,
                    PLD_UserVisible        = 0x1,
                    PLD_Dock               = 0x0,
                    PLD_Lid                = 0x0,
                    PLD_Panel              = "LEFT",
                    PLD_VerticalPosition   = "UPPER",
                    PLD_HorizontalPosition = "RIGHT",
                    PLD_Shape              = "OVAL",
                    PLD_GroupOrientation   = 0x0,
                    PLD_GroupToken         = 0x2,
                    PLD_GroupPosition      = 0x1,
                    PLD_Bay                = 0x0,
                    PLD_Ejectable          = 0x0,
                    PLD_EjectRequired      = 0x0,
                    PLD_CabinetNumber      = 0x0,
                    PLD_CardCageNumber     = 0x0,
                    PLD_Reference          = 0x0,
                    PLD_Rotation           = 0x0,
                    PLD_Order              = 0x0,
                    PLD_VerticalOffset     = 0x0,
                    PLD_HorizontalOffset   = 0x0)

            })
        }
    }
}

