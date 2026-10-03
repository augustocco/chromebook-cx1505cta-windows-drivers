/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (32-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of telith-DSDT.aml
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x000057A2 (22434)
 *     Revision         0x02
 *     Checksum         0xA1
 *     OEM ID           "COREv4"
 *     OEM Table ID     "COREBOOT"
 *     OEM Revision     0x20110725 (537986853)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20250807 (539297799)
 */
DefinitionBlock ("", "DSDT", 2, "COREv4", "COREBOOT", 0x20110725)
{
    External (_SB_.CNOT, MethodObj)    // 1 Arguments
    External (_SB_.DPTF.TPWR, DeviceObj)
    External (_SB_.MPTS, MethodObj)    // 1 Arguments
    External (_SB_.MWAK, MethodObj)    // 1 Arguments
    External (_SB_.NAPE, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.A4GB, IntObj)
    External (_SB_.PCI0.A4GS, IntObj)
    External (_SB_.PCI0.EGPM, MethodObj)    // 0 Arguments
    External (_SB_.PCI0.GFX0.LCD0, DeviceObj)
    External (_SB_.PCI0.LPCB.EC0_.PTS_, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.LPCB.EC0_.WAK_, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.RGPM, MethodObj)    // 0 Arguments
    External (A4GB, IntObj)
    External (A4GS, IntObj)
    External (DNVS, OpRegionObj)
    External (GNVS, OpRegionObj)
    External (OSFG, IntObj)

    Scope (\)
    {
        OperationRegion (GNVS, SystemMemory, 0x76FFE6E0, 0x3A)
    }

    Name (OSYS, Zero)
    Name (PICM, Zero)
    Name (PWRS, One)
    Method (_PIC, 1, NotSerialized)  // _PIC: Interrupt Model
    {
        PICM = Arg0
        If (CondRefOf (\_SB.NAPE))
        {
            \_SB.NAPE ()
        }
    }

    Scope (_SB)
    {
        Name (PCBA, 0xC0000000)
        Name (PCLN, 0x10000000)
        OperationRegion (PCFG, SystemMemory, PCBA, PCLN)
        Device (PERC)
        {
            Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
            Name (RBUF, Buffer (0x30)
            {
                /* 0000 */  0x8A, 0x2B, 0x00, 0x00, 0x0D, 0x01, 0x00, 0x00,  // .+......
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00,  // ........
                /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00,  // ........
                /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79, 0x00   // ......y.
            })
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                CreateQWordField (RBUF, 0x0E, MIN1)
                CreateQWordField (RBUF, 0x16, MAX1)
                CreateQWordField (RBUF, 0x26, LEN1)
                MIN1 = 0xC0000000
                MAX1 = ((MIN1 + 0x10000000) - One)
                LEN1 = 0x10000000
                Return (RBUF) /* \_SB_.PERC.RBUF */
            }
        }
    }

    Name (DBG0, Zero)
    Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
    {
        DBG0 = 0x96
        If (CondRefOf (\_SB.PCI0.LPCB.EC0.PTS))
        {
            \_SB.PCI0.LPCB.EC0.PTS (Arg0)
        }

        If (CondRefOf (\_SB.MPTS))
        {
            \_SB.MPTS (Arg0)
        }

        If (CondRefOf (\_SB.PCI0.EGPM))
        {
            \_SB.PCI0.EGPM ()
        }
    }

    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        DBG0 = 0x97
        If (CondRefOf (\_SB.PCI0.LPCB.EC0.WAK))
        {
            \_SB.PCI0.LPCB.EC0.WAK (Arg0)
        }

        If (CondRefOf (\_SB.MWAK))
        {
            \_SB.MWAK (Arg0)
        }

        If (CondRefOf (\_SB.PCI0.RGPM))
        {
            \_SB.PCI0.RGPM ()
        }

        Return (Package (0x02)
        {
            Zero, 
            Zero
        })
    }

    Field (GNVS, ByteAcc, NoLock, Preserve)
    {
        Offset (0x02), 
        SMIF,   8, 
        Offset (0x04), 
        PPCM,   8, 
        TLVL,   8, 
        LIDS,   8, 
        Offset (0x08), 
        Offset (0x0C), 
        PM1I,   64, 
        GPEI,   64, 
        DPTE,   8, 
        NHLA,   64, 
        NHLL,   32, 
        Offset (0x2B), 
        U2WE,   16, 
        U3WE,   16, 
        UIOR,   8, 
        Offset (0x38), 
        WATS,   8, 
        WATA,   8
    }

    Method (PNOT, 0, NotSerialized)
    {
        \_SB.CNOT (0x81)
    }

    Method (PPCN, 0, NotSerialized)
    {
        \_SB.CNOT (0x80)
    }

    Method (TNOT, 0, NotSerialized)
    {
        \_SB.CNOT (0x82)
    }

    Scope (_SB)
    {
        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A08") /* PCI Express Bus */)  // _HID: Hardware ID
            Name (_CID, EisaId ("PNP0A03") /* PCI Bus */)  // _CID: Compatible ID
            Name (_SEG, Zero)  // _SEG: PCI Segment
            Name (_UID, Zero)  // _UID: Unique ID
            Device (MCHC)
            {
                Name (_ADR, Zero)  // _ADR: Address
                OperationRegion (MCHP, PCI_Config, Zero, 0x0100)
                Field (MCHP, DWordAcc, NoLock, Preserve)
                {
                    Offset (0x40), 
                    EPEN,   1, 
                        ,   11, 
                    EPBR,   20, 
                    Offset (0x48), 
                    MHEN,   1, 
                        ,   14, 
                    MHBR,   27, 
                    Offset (0x60), 
                    PXEN,   1, 
                    PXSZ,   2, 
                        ,   23, 
                    PXBR,   6, 
                    Offset (0x68), 
                    DIEN,   1, 
                        ,   11, 
                    DIBR,   20, 
                    Offset (0xA0), 
                    TOM,    64, 
                    TUUD,   64, 
                    Offset (0xBC), 
                    TLUD,   32
                }
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (MCRS, Buffer (0x0236)
                {
                    /* 0000 */  0x88, 0x0D, 0x00, 0x02, 0x0C, 0x00, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x01,  // ........
                    /* 0010 */  0x87, 0x17, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                    /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF7, 0x0C,  // ........
                    /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8, 0x0C,  // ........
                    /* 0028 */  0x00, 0x00, 0x47, 0x01, 0xF8, 0x0C, 0xF8, 0x0C,  // ..G.....
                    /* 0030 */  0x01, 0x08, 0x87, 0x17, 0x00, 0x01, 0x0C, 0x03,  // ........
                    /* 0038 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x00, 0x00,  // ........
                    /* 0040 */  0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0048 */  0x00, 0xF3, 0x00, 0x00, 0x87, 0x17, 0x00, 0x00,  // ........
                    /* 0050 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0058 */  0x0A, 0x00, 0xFF, 0xFF, 0x0B, 0x00, 0x00, 0x00,  // ........
                    /* 0060 */  0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x87, 0x17,  // ........
                    /* 0068 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0070 */  0x00, 0x00, 0x0C, 0x00, 0xFF, 0x3F, 0x0C, 0x00,  // .....?..
                    /* 0078 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00,  // .....@..
                    /* 0080 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                    /* 0088 */  0x00, 0x00, 0x00, 0x40, 0x0C, 0x00, 0xFF, 0x7F,  // ...@....
                    /* 0090 */  0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40,  // .......@
                    /* 0098 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                    /* 00A0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x0C, 0x00,  // ........
                    /* 00A8 */  0xFF, 0xBF, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 00B0 */  0x00, 0x40, 0x00, 0x00, 0x87, 0x17, 0x00, 0x00,  // .@......
                    /* 00B8 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0,  // ........
                    /* 00C0 */  0x0C, 0x00, 0xFF, 0xFF, 0x0C, 0x00, 0x00, 0x00,  // ........
                    /* 00C8 */  0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x87, 0x17,  // ...@....
                    /* 00D0 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 00D8 */  0x00, 0x00, 0x0D, 0x00, 0xFF, 0x3F, 0x0D, 0x00,  // .....?..
                    /* 00E0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00,  // .....@..
                    /* 00E8 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                    /* 00F0 */  0x00, 0x00, 0x00, 0x40, 0x0D, 0x00, 0xFF, 0x7F,  // ...@....
                    /* 00F8 */  0x0D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40,  // .......@
                    /* 0100 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                    /* 0108 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x0D, 0x00,  // ........
                    /* 0110 */  0xFF, 0xBF, 0x0D, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0118 */  0x00, 0x40, 0x00, 0x00, 0x87, 0x17, 0x00, 0x00,  // .@......
                    /* 0120 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0,  // ........
                    /* 0128 */  0x0D, 0x00, 0xFF, 0xFF, 0x0D, 0x00, 0x00, 0x00,  // ........
                    /* 0130 */  0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x87, 0x17,  // ...@....
                    /* 0138 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0140 */  0x00, 0x00, 0x0E, 0x00, 0xFF, 0x3F, 0x0E, 0x00,  // .....?..
                    /* 0148 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00,  // .....@..
                    /* 0150 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                    /* 0158 */  0x00, 0x00, 0x00, 0x40, 0x0E, 0x00, 0xFF, 0x7F,  // ...@....
                    /* 0160 */  0x0E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40,  // .......@
                    /* 0168 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                    /* 0170 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x0E, 0x00,  // ........
                    /* 0178 */  0xFF, 0xBF, 0x0E, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0180 */  0x00, 0x40, 0x00, 0x00, 0x87, 0x17, 0x00, 0x00,  // .@......
                    /* 0188 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0,  // ........
                    /* 0190 */  0x0E, 0x00, 0xFF, 0xFF, 0x0E, 0x00, 0x00, 0x00,  // ........
                    /* 0198 */  0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x87, 0x17,  // ...@....
                    /* 01A0 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 01A8 */  0x00, 0x00, 0x0F, 0x00, 0xFF, 0xFF, 0x0F, 0x00,  // ........
                    /* 01B0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00,  // ........
                    /* 01B8 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x01, 0x00, 0x00,  // ........
                    /* 01C0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF,  // ........
                    /* 01C8 */  0xFF, 0xDF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 01D0 */  0x00, 0xE0, 0x8A, 0x2B, 0x00, 0x00, 0x0C, 0x01,  // ...+....
                    /* 01D8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 01E0 */  0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 01E8 */  0xFF, 0xFF, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 01F0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 01F8 */  0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0200 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                    /* 0208 */  0x00, 0x00, 0x00, 0x00, 0x80, 0xFC, 0xFF, 0xFF,  // ........
                    /* 0210 */  0x7F, 0xFE, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0218 */  0x00, 0x02, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                    /* 0220 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xD4, 0xFE,  // ........
                    /* 0228 */  0xFF, 0x7F, 0xD4, 0xFE, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0230 */  0x00, 0x80, 0x00, 0x00, 0x79, 0x00               // ....y.
                })
                CreateDWordField (MCRS, 0x01C2, PMIN)
                CreateDWordField (MCRS, 0x01C6, PMAX)
                CreateDWordField (MCRS, 0x01CE, PLEN)
                PMIN = (^MCHC.TLUD & 0xFFF00000)
                PLEN = ((PMAX - PMIN) + One)
                If ((A4GS == Zero))
                {
                    CreateQWordField (MCRS, 0x01F8, MSEN)
                    MSEN = Zero
                }
                Else
                {
                    CreateQWordField (MCRS, 0x01E0, MMIN)
                    CreateQWordField (MCRS, 0x01E8, MMAX)
                    CreateQWordField (MCRS, 0x01F8, MLEN)
                    MLEN = A4GS /* External reference */
                    MMIN = A4GB /* External reference */
                    MMAX = ((MMIN + MLEN) - One)
                }

                Return (MCRS) /* \_SB_.PCI0._CRS.MCRS */
            }

            Method (GMHB, 0, Serialized)
            {
                Local0 = (^MCHC.MHBR << 0x0F)
                Return (Local0)
            }

            Method (GEPB, 0, Serialized)
            {
                Local0 = (^MCHC.EPBR << 0x0C)
                Return (Local0)
            }

            Method (GPCB, 0, Serialized)
            {
                Local0 = (^MCHC.PXBR << 0x1A)
                Return (Local0)
            }

            Method (GPCL, 0, Serialized)
            {
                Local0 = (0x10000000 >> ^MCHC.PXSZ) /* \_SB_.PCI0.MCHC.PXSZ */
                Return (Local0)
            }

            Method (GDMB, 0, Serialized)
            {
                Local0 = (^MCHC.DIBR << 0x0C)
                Return (Local0)
            }

            Method (BASE, 1, NotSerialized)
            {
                Local0 = (Arg0 & 0x07)
                Local1 = ((Arg0 >> 0x10) & 0x1F)
                Local2 = ((Local0 << 0x0C) + (Local1 << 0x0F))
                Local3 = (GPCB () + Local2)
                Return (Local3)
            }

            Device (PDRC)
            {
                Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                Name (_UID, One)  // _UID: Unique ID
                Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
                {
                    Name (BUF0, Buffer (0x62)
                    {
                        /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                        /* 0008 */  0x00, 0x00, 0x02, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                        /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00,  // ........
                        /* 0018 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                        /* 0020 */  0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00, 0x00,  // ........
                        /* 0028 */  0x00, 0x00, 0xD9, 0xFE, 0x00, 0x40, 0x00, 0x00,  // .....@..
                        /* 0030 */  0x86, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                        /* 0038 */  0x00, 0x00, 0x00, 0x01, 0x86, 0x09, 0x00, 0x00,  // ........
                        /* 0040 */  0x00, 0x00, 0x00, 0xF8, 0x00, 0x00, 0x00, 0x02,  // ........
                        /* 0048 */  0x86, 0x09, 0x00, 0x00, 0x00, 0x00, 0xE0, 0xFE,  // ........
                        /* 0050 */  0x00, 0x00, 0x10, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                        /* 0058 */  0x00, 0x00, 0xD0, 0xFE, 0x00, 0x04, 0x00, 0x00,  // ........
                        /* 0060 */  0x79, 0x00                                       // y.
                    })
                    CreateDWordField (BUF0, 0x04, MBR0)
                    MBR0 = GMHB ()
                    CreateDWordField (BUF0, 0x10, DBR0)
                    DBR0 = GDMB ()
                    CreateDWordField (BUF0, 0x1C, EBR0)
                    EBR0 = GEPB ()
                    CreateDWordField (BUF0, 0x34, FBR0)
                    FBR0 = 0xFF000000
                    Return (BUF0) /* \_SB_.PCI0.PDRC._CRS.BUF0 */
                }
            }

            Device (GFX0)
            {
                Name (_ADR, 0x00020000)  // _ADR: Address
                Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
                {
                }

                Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
                {
                }

                Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                {
                    Return (0x03)
                }

                Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                {
                    Return (0x03)
                }
            }

            Method (GPCR, 2, NotSerialized)
            {
                If ((Arg0 == Zero))
                {
                    Local0 = 0xFD000000
                }
                ElseIf ((Arg0 == One))
                {
                    Local0 = Zero
                }
                Else
                {
                    Return (Zero)
                }

                Return ((Local0 + (Arg1 << 0x10)))
            }

            Method (RPCR, 3, Serialized)
            {
                OperationRegion (PCRD, SystemMemory, (GPCR (Arg0, Arg1) + Arg2), 0x04)
                Field (PCRD, DWordAcc, NoLock, Preserve)
                {
                    DATA,   32
                }

                Return (DATA) /* \_SB_.PCI0.RPCR.DATA */
            }

            Method (APCR, 4, Serialized)
            {
                OperationRegion (PCRD, SystemMemory, (GPCR (Arg0, Arg1) + Arg2), 0x04)
                Field (PCRD, DWordAcc, NoLock, Preserve)
                {
                    DATA,   32
                }

                DATA &= Arg3
                RPCR (Arg0, Arg1, Arg2)
            }

            Method (OPCR, 4, Serialized)
            {
                OperationRegion (PCRD, SystemMemory, (GPCR (Arg0, Arg1) + Arg2), 0x04)
                Field (PCRD, DWordAcc, NoLock, Preserve)
                {
                    DATA,   32
                }

                DATA |= Arg3
                RPCR (Arg0, Arg1, Arg2)
            }

            Method (WPCR, 4, Serialized)
            {
                OperationRegion (PCRD, SystemMemory, (GPCR (Arg0, Arg1) + Arg2), 0x04)
                Field (PCRD, DWordAcc, NoLock, Preserve)
                {
                    DATA,   32
                }

                DATA = Arg3
                RPCR (Arg0, Arg1, Arg2)
            }

            Method (PCRB, 1, NotSerialized)
            {
                Return (GPCR (Zero, Arg0))
            }

            Method (PCRR, 2, Serialized)
            {
                Return (RPCR (Zero, Arg0, Arg1))
            }

            Method (PCRA, 3, Serialized)
            {
                APCR (Zero, Arg0, Arg1, Arg2)
            }

            Method (PCRO, 3, Serialized)
            {
                OPCR (Zero, Arg0, Arg1, Arg2)
            }

            Method (PCRW, 3, Serialized)
            {
                WPCR (Zero, Arg0, Arg1, Arg2)
            }

            Scope (\_SB.PCI0)
            {
                Name (ICKB, Zero)
                ICKB = (PCRB (0xAD) + 0x8000)
                Method (RAOW, 3, Serialized)
                {
                    OperationRegion (ICLK, SystemMemory, (ICKB + (Arg0 * 0x0C)), 0x04)
                    Field (ICLK, AnyAcc, NoLock, Preserve)
                    {
                        VAL0,   32
                    }

                    Local0 = VAL0 /* \_SB_.PCI0.RAOW.VAL0 */
                    VAL0 = ((Local0 & Arg1) | Arg2)
                }

                Method (MCON, 2, NotSerialized)
                {
                    RAOW (Arg0, 0xFFFFFFFFFFFFFFFE, Arg1)
                    RAOW (Arg0, 0xFFFFFFFFFFFFFFFD, 0x02)
                }

                Method (MCOF, 1, NotSerialized)
                {
                    RAOW (Arg0, 0xFFFFFFFFFFFFFFFD, Zero)
                }
            }

            Method (CGPM, 2, Serialized)
            {
                Local0 = GPID (Arg0)
                If ((Local0 != Zero))
                {
                    PCRA (Local0, 0x10, 0xFFFFFFFFFFFFFF00)
                    PCRO (Local0, 0x10, (Arg1 & 0xFF))
                }
            }

            Method (GRXS, 1, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                        ,   1, 
                    RXST,   1
                }

                Return (RXST) /* \_SB_.PCI0.GRXS.RXST */
            }

            Method (GTXS, 1, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                    TXST,   1
                }

                Return (TXST) /* \_SB_.PCI0.GTXS.TXST */
            }

            Method (STXS, 1, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                    TXST,   1
                }

                TXST = One
            }

            Method (CTXS, 1, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                    TXST,   1
                }

                TXST = Zero
            }

            Method (GPMO, 2, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                        ,   10, 
                    MODE,   3
                }

                MODE = Arg1
            }

            Method (GTXE, 2, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x01), 
                    TXDI,   1
                }

                TXDI = !Arg1
            }

            Method (GRXE, 2, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                        ,   9, 
                    RXDI,   1
                }

                RXDI = !Arg1
            }

            Method (GSCI, 2, Serialized)
            {
                OperationRegion (PREG, SystemMemory, GADD (Arg0), 0x04)
                Field (PREG, AnyAcc, NoLock, Preserve)
                {
                        ,   19, 
                    SCIR,   1
                }

                SCIR = Arg1
            }

            Device (GPIO)
            {
                Name (_HID, "INTC1057")  // _HID: Hardware ID
                Name (_UID, Zero)  // _UID: Unique ID
                Name (_DDN, "GPIO Controller")  // _DDN: DOS Device Name
                Name (RBUF, Buffer (0x3B)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                    /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0018 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                    /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0030 */  0x89, 0x06, 0x00, 0x0D, 0x01, 0x0E, 0x00, 0x00,  // ........
                    /* 0038 */  0x00, 0x79, 0x00                                 // .y.
                })
                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    CreateDWordField (RBUF, 0x04, BAS0)
                    CreateDWordField (RBUF, 0x08, LEN0)
                    BAS0 = PCRB (0x6E)
                    LEN0 = 0x00010000
                    CreateDWordField (RBUF, 0x10, BAS1)
                    CreateDWordField (RBUF, 0x14, LEN1)
                    BAS1 = PCRB (0x6D)
                    LEN1 = 0x00010000
                    CreateDWordField (RBUF, 0x1C, BAS4)
                    CreateDWordField (RBUF, 0x20, LEN4)
                    BAS4 = PCRB (0x6A)
                    LEN4 = 0x00010000
                    CreateDWordField (RBUF, 0x28, BAS5)
                    CreateDWordField (RBUF, 0x2C, LEN5)
                    BAS5 = PCRB (0x69)
                    LEN5 = 0x00010000
                    Return (RBUF) /* \_SB_.PCI0.GPIO.RBUF */
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }
            }

            Method (GADD, 1, NotSerialized)
            {
                If (((Arg0 >= Zero) && (Arg0 <= 0x42)))
                {
                    Local0 = 0x6E
                    Local1 = (Arg0 - Zero)
                }

                If (((Arg0 >= 0x43) && (Arg0 <= 0xA8)))
                {
                    Local0 = 0x6D
                    Local1 = (Arg0 - 0x43)
                }

                If (((Arg0 >= 0xA9) && (Arg0 <= 0xB9)))
                {
                    Local0 = 0x6C
                    Local1 = (Arg0 - 0xA9)
                }

                If (((Arg0 >= 0xBA) && (Arg0 <= 0x0124)))
                {
                    Local0 = 0x6B
                    Local1 = (Arg0 - 0xBA)
                }

                If (((Arg0 >= 0x0125) && (Arg0 <= 0x0174)))
                {
                    Local0 = 0x6A
                    Local1 = (Arg0 - 0x0125)
                }

                If (((Arg0 >= 0x0175) && (Arg0 <= 0x0184)))
                {
                    Local0 = 0x69
                    Local1 = (Arg0 - 0x0175)
                }

                Local2 = ((PCRB (Local0) + 0x0700) + (Local1 * 0x10))
                Return (Local2)
            }

            Method (GPID, 1, Serialized)
            {
                Switch (ToInteger (Arg0))
                {
                    Case (Zero)
                    {
                        Local0 = 0x6E
                    }
                    Case (One)
                    {
                        Local0 = 0x6D
                    }
                    Case (0x02)
                    {
                        Local0 = 0x6C
                    }
                    Case (0x03)
                    {
                        Local0 = 0x6B
                    }
                    Case (0x04)
                    {
                        Local0 = 0x6A
                    }
                    Case (0x05)
                    {
                        Local0 = 0x69
                    }
                    Default
                    {
                        Return (Zero)
                    }

                }

                Return (Local0)
            }

            Name (GPMB, Package (0x06)
            {
                Zero, 
                Zero, 
                Zero, 
                Zero, 
                Zero, 
                Zero
            })
            Method (SGPM, 0, Serialized)
            {
                Local0 = Zero
                While ((Local0 < 0x06))
                {
                    Local1 = GPID (Local0)
                    GPMB [Local0] = PCRR (Local1, 0x10)
                    Local0++
                }
            }

            Method (RGPM, 0, Serialized)
            {
                Local0 = Zero
                While ((Local0 < 0x06))
                {
                    CGPM (Local0, DerefOf (GPMB [Local0]))
                    Local0++
                }
            }

            Method (EGPM, 0, Serialized)
            {
                SGPM ()
                Local0 = Zero
                While ((Local0 < 0x06))
                {
                    CGPM (Local0, 0xFF)
                    Local0++
                }
            }

            Device (LPCB)
            {
                Name (_ADR, 0x001F0000)  // _ADR: Address
                Name (_DDN, "LPC Bus Device")  // _DDN: DOS Device Name
                OperationRegion (LPCP, PCI_Config, Zero, 0x0100)
                Field (LPCP, DWordAcc, NoLock, Preserve)
                {
                    Offset (0x98), 
                    LGEN,   1, 
                    Offset (0x9A), 
                    LADR,   16
                }

                Method (GLGM, 0, Serialized)
                {
                    Local0 = (LADR << 0x10)
                    Return (Local0)
                }

                Device (DMAC)
                {
                    Name (_HID, EisaId ("PNP0200") /* PC-class DMA Controller */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x25)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x20,  // G...... 
                        /* 0008 */  0x47, 0x01, 0x81, 0x00, 0x81, 0x00, 0x01, 0x11,  // G.......
                        /* 0010 */  0x47, 0x01, 0x93, 0x00, 0x93, 0x00, 0x01, 0x0D,  // G.......
                        /* 0018 */  0x47, 0x01, 0xC0, 0x00, 0xC0, 0x00, 0x01, 0x20,  // G...... 
                        /* 0020 */  0x2A, 0x10, 0x01, 0x79, 0x00                     // *..y.
                    })
                }

                Device (FWH)
                {
                    Name (_HID, EisaId ("INT0800") /* Intel 82802 Firmware Hub Device */)  // _HID: Hardware ID
                    Name (_DDN, "Firmware Hub")  // _DDN: DOS Device Name
                    Name (_CRS, Buffer (0x0E)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x86, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF,  // ........
                        /* 0008 */  0x00, 0x00, 0x00, 0x01, 0x79, 0x00               // ....y.
                    })
                }

                Device (HPET)
                {
                    Name (_HID, EisaId ("PNP0103") /* HPET System Timer */)  // _HID: Hardware ID
                    Name (_CID, EisaId ("PNP0C01") /* System Board */)  // _CID: Compatible ID
                    Name (_DDN, "High Precision Event Timer")  // _DDN: DOS Device Name
                    Name (_CRS, Buffer (0x0E)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD0, 0xFE,  // ........
                        /* 0008 */  0x00, 0x04, 0x00, 0x00, 0x79, 0x00               // ....y.
                    })
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (0x0F)
                    }
                }

                Device (MATH)
                {
                    Name (_HID, EisaId ("PNP0C04") /* x87-compatible Floating Point Processing Unit */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x0D)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0xF0, 0x00, 0xF0, 0x00, 0x01, 0x01,  // G.......
                        /* 0008 */  0x22, 0x00, 0x20, 0x79, 0x00                     // ". y.
                    })
                }

                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000") /* 8259-compatible Programmable Interrupt Controller */)  // _HID: Hardware ID
                    Name (_DDN, "8259 Interrupt Controller")  // _DDN: DOS Device Name
                    Name (_CRS, Buffer (0x8D)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x20, 0x00, 0x20, 0x00, 0x01, 0x02,  // G. . ...
                        /* 0008 */  0x47, 0x01, 0x24, 0x00, 0x24, 0x00, 0x01, 0x02,  // G.$.$...
                        /* 0010 */  0x47, 0x01, 0x28, 0x00, 0x28, 0x00, 0x01, 0x02,  // G.(.(...
                        /* 0018 */  0x47, 0x01, 0x2C, 0x00, 0x2C, 0x00, 0x01, 0x02,  // G.,.,...
                        /* 0020 */  0x47, 0x01, 0x30, 0x00, 0x30, 0x00, 0x01, 0x02,  // G.0.0...
                        /* 0028 */  0x47, 0x01, 0x34, 0x00, 0x34, 0x00, 0x01, 0x02,  // G.4.4...
                        /* 0030 */  0x47, 0x01, 0x38, 0x00, 0x38, 0x00, 0x01, 0x02,  // G.8.8...
                        /* 0038 */  0x47, 0x01, 0x3C, 0x00, 0x3C, 0x00, 0x01, 0x02,  // G.<.<...
                        /* 0040 */  0x47, 0x01, 0xA0, 0x00, 0xA0, 0x00, 0x01, 0x02,  // G.......
                        /* 0048 */  0x47, 0x01, 0xA4, 0x00, 0xA4, 0x00, 0x01, 0x02,  // G.......
                        /* 0050 */  0x47, 0x01, 0xA8, 0x00, 0xA8, 0x00, 0x01, 0x02,  // G.......
                        /* 0058 */  0x47, 0x01, 0xAC, 0x00, 0xAC, 0x00, 0x01, 0x02,  // G.......
                        /* 0060 */  0x47, 0x01, 0xB0, 0x00, 0xB0, 0x00, 0x01, 0x02,  // G.......
                        /* 0068 */  0x47, 0x01, 0xB4, 0x00, 0xB4, 0x00, 0x01, 0x02,  // G.......
                        /* 0070 */  0x47, 0x01, 0xB8, 0x00, 0xB8, 0x00, 0x01, 0x02,  // G.......
                        /* 0078 */  0x47, 0x01, 0xBC, 0x00, 0xBC, 0x00, 0x01, 0x02,  // G.......
                        /* 0080 */  0x47, 0x01, 0xD0, 0x04, 0xD0, 0x04, 0x01, 0x02,  // G.......
                        /* 0088 */  0x22, 0x04, 0x00, 0x79, 0x00                     // "..y.
                    })
                }

                Device (LDRC)
                {
                    Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                    Name (_UID, 0x02)  // _UID: Unique ID
                    Name (_DDN, "Legacy Device Resources")  // _DDN: DOS Device Name
                    Name (_CRS, Buffer (0x52)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x2E, 0x00, 0x2E, 0x00, 0x01, 0x02,  // G.......
                        /* 0008 */  0x47, 0x01, 0x4E, 0x00, 0x4E, 0x00, 0x01, 0x02,  // G.N.N...
                        /* 0010 */  0x47, 0x01, 0x61, 0x00, 0x61, 0x00, 0x01, 0x01,  // G.a.a...
                        /* 0018 */  0x47, 0x01, 0x63, 0x00, 0x63, 0x00, 0x01, 0x01,  // G.c.c...
                        /* 0020 */  0x47, 0x01, 0x65, 0x00, 0x65, 0x00, 0x01, 0x01,  // G.e.e...
                        /* 0028 */  0x47, 0x01, 0x67, 0x00, 0x67, 0x00, 0x01, 0x01,  // G.g.g...
                        /* 0030 */  0x47, 0x01, 0x80, 0x00, 0x80, 0x00, 0x01, 0x01,  // G.......
                        /* 0038 */  0x47, 0x01, 0x92, 0x00, 0x92, 0x00, 0x01, 0x01,  // G.......
                        /* 0040 */  0x47, 0x01, 0xB2, 0x00, 0xB2, 0x00, 0x01, 0x02,  // G.......
                        /* 0048 */  0x47, 0x01, 0x00, 0x18, 0x00, 0x18, 0x01, 0xFF,  // G.......
                        /* 0050 */  0x79, 0x00                                       // y.
                    })
                }

                Device (RTC)
                {
                    Name (_HID, EisaId ("PNP0B00") /* AT Real-Time Clock */)  // _HID: Hardware ID
                    Name (_DDN, "Real Time Clock")  // _DDN: DOS Device Name
                    Name (_CRS, Buffer (0x0A)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x70, 0x00, 0x70, 0x00, 0x01, 0x08,  // G.p.p...
                        /* 0008 */  0x79, 0x00                                       // y.
                    })
                }

                Device (TIMR)
                {
                    Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
                    Name (_DDN, "8254 Timer")  // _DDN: DOS Device Name
                    Name (_CRS, Buffer (0x15)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x40, 0x00, 0x40, 0x00, 0x01, 0x04,  // G.@.@...
                        /* 0008 */  0x47, 0x01, 0x50, 0x00, 0x50, 0x00, 0x10, 0x04,  // G.P.P...
                        /* 0010 */  0x22, 0x01, 0x00, 0x79, 0x00                     // "..y.
                    })
                }
            }

            Device (HDAS)
            {
                Name (_ADR, 0x001F0003)  // _ADR: Address
                Name (_DDN, "Audio Controller")  // _DDN: DOS Device Name
                Name (UUID, ToUUID ("a69f886e-6ceb-4594-a41f-7b5dce24c553") /* Unknown UUID */)
                Name (_S0W, 0x03)  // _S0W: S0 Device Wake State
                Name (NBUF, Buffer (0x30)
                {
                    /* 0000 */  0x8A, 0x2B, 0x00, 0x00, 0x0D, 0x10, 0x00, 0x00,  // .+......
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0010 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00,  // ........
                    /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79, 0x00   // ......y.
                })
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    If ((Arg0 == UUID))
                    {
                        If ((Arg2 == Zero))
                        {
                            If ((((Arg1 == One) && (NHLA != Zero)) && (
                                NHLL != Zero)))
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
                                     0x01                                             // .
                                })
                            }
                        }

                        If ((Arg2 == One))
                        {
                            CreateQWordField (NBUF, 0x0E, NBAS)
                            CreateQWordField (NBUF, 0x16, NMAS)
                            CreateQWordField (NBUF, 0x26, NLEN)
                            NBAS = NHLA /* \NHLA */
                            NMAS = NHLA /* \NHLA */
                            NLEN = NHLL /* \NHLL */
                            Return (NBUF) /* \_SB_.PCI0.HDAS.NBUF */
                        }
                    }

                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (IRQM, 1, Serialized)
            {
                Name (IQAA, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x10
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x11
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x12
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x13
                    }
                })
                Name (IQAP, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x0A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x0B
                    }
                })
                Name (IQBA, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x11
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x12
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x13
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x10
                    }
                })
                Name (IQBP, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x0A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x0B
                    }
                })
                Name (IQCA, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x12
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x13
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x10
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x11
                    }
                })
                Name (IQCP, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x0A
                    }
                })
                Name (IQDA, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x13
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x10
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x11
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x12
                    }
                })
                Name (IQDP, Package (0x04)
                {
                    Package (0x04)
                    {
                        0xFFFF, 
                        Zero, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        One, 
                        Zero, 
                        0x0B
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x02, 
                        Zero, 
                        0x0A
                    }, 

                    Package (0x04)
                    {
                        0xFFFF, 
                        0x03, 
                        Zero, 
                        0x0B
                    }
                })
                Switch (ToInteger (Arg0))
                {
                    Case (Package (0x07)
                        {
                            One, 
                            0x05, 
                            0x09, 
                            0x0D, 
                            0x11, 
                            0x15, 
                            0x19
                        }

)
                    {
                        If (PICM)
                        {
                            Return (IQAA) /* \_SB_.PCI0.IRQM.IQAA */
                        }
                        Else
                        {
                            Return (IQAP) /* \_SB_.PCI0.IRQM.IQAP */
                        }
                    }
                    Case (Package (0x07)
                        {
                            0x02, 
                            0x06, 
                            0x0A, 
                            0x0E, 
                            0x12, 
                            0x16, 
                            0x1A
                        }

)
                    {
                        If (PICM)
                        {
                            Return (IQBA) /* \_SB_.PCI0.IRQM.IQBA */
                        }
                        Else
                        {
                            Return (IQBP) /* \_SB_.PCI0.IRQM.IQBP */
                        }
                    }
                    Case (Package (0x07)
                        {
                            0x03, 
                            0x07, 
                            0x0B, 
                            0x0F, 
                            0x13, 
                            0x17, 
                            0x1B
                        }

)
                    {
                        If (PICM)
                        {
                            Return (IQCA) /* \_SB_.PCI0.IRQM.IQCA */
                        }
                        Else
                        {
                            Return (IQCP) /* \_SB_.PCI0.IRQM.IQCP */
                        }
                    }
                    Case (Package (0x07)
                        {
                            0x04, 
                            0x08, 
                            0x0C, 
                            0x10, 
                            0x14, 
                            0x18, 
                            0x1C
                        }

)
                    {
                        If (PICM)
                        {
                            Return (IQDA) /* \_SB_.PCI0.IRQM.IQDA */
                        }
                        Else
                        {
                            Return (IQDP) /* \_SB_.PCI0.IRQM.IQDP */
                        }
                    }
                    Default
                    {
                        If (PICM)
                        {
                            Return (IQDA) /* \_SB_.PCI0.IRQM.IQDA */
                        }
                        Else
                        {
                            Return (IQDP) /* \_SB_.PCI0.IRQM.IQDP */
                        }
                    }

                }
            }

            Device (RP01)
            {
                Name (_ADR, 0x001C0000)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP02)
            {
                Name (_ADR, 0x001C0001)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP03)
            {
                Name (_ADR, 0x001C0002)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP04)
            {
                Name (_ADR, 0x001C0003)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP05)
            {
                Name (_ADR, 0x001C0004)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP06)
            {
                Name (_ADR, 0x001C0005)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP07)
            {
                Name (_ADR, 0x001C0006)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP08)
            {
                Name (_ADR, 0x001C0007)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP09)
            {
                Name (_ADR, 0x001D0000)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP10)
            {
                Name (_ADR, 0x001D0001)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP11)
            {
                Name (_ADR, 0x001D0002)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (RP12)
            {
                Name (_ADR, 0x001D0003)  // _ADR: Address
                OperationRegion (RPCS, PCI_Config, 0x4C, 0x04)
                Field (RPCS, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x03), 
                    RPPN,   8
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    Return (IRQM (RPPN))
                }
            }

            Device (I2C0)
            {
                Name (_ADR, 0x00150000)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 0")  // _DDN: DOS Device Name
            }

            Device (I2C1)
            {
                Name (_ADR, 0x00150001)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 1")  // _DDN: DOS Device Name
            }

            Device (I2C2)
            {
                Name (_ADR, 0x00150002)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 2")  // _DDN: DOS Device Name
            }

            Device (I2C3)
            {
                Name (_ADR, 0x00150003)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 3")  // _DDN: DOS Device Name
            }

            Device (I2C4)
            {
                Name (_ADR, 0x00190000)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 4")  // _DDN: DOS Device Name
            }

            Device (I2C5)
            {
                Name (_ADR, 0x00190001)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 5")  // _DDN: DOS Device Name
            }

            Device (I2C6)
            {
                Name (_ADR, 0x00100000)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 6")  // _DDN: DOS Device Name
            }

            Device (I2C7)
            {
                Name (_ADR, 0x00100001)  // _ADR: Address
                Name (_DDN, "Serial IO I2C Controller 7")  // _DDN: DOS Device Name
            }

            Device (FSPI)
            {
                Name (_ADR, 0x001F0005)  // _ADR: Address
                Name (_DDN, "Fast SPI")  // _DDN: DOS Device Name
            }

            Device (SPI0)
            {
                Name (_ADR, 0x001E0002)  // _ADR: Address
                Name (_DDN, "Serial IO SPI Controller 0")  // _DDN: DOS Device Name
            }

            Device (SPI1)
            {
                Name (_ADR, 0x001E0003)  // _ADR: Address
                Name (_DDN, "Serial IO SPI Controller 1")  // _DDN: DOS Device Name
            }

            Device (SPI2)
            {
                Name (_ADR, 0x00120006)  // _ADR: Address
                Name (_DDN, "Serial IO SPI Controller 2")  // _DDN: DOS Device Name
            }

            Device (SPI3)
            {
                Name (_ADR, 0x00130000)  // _ADR: Address
                Name (_DDN, "Serial IO SPI Controller 3")  // _DDN: DOS Device Name
            }

            Device (UAR0)
            {
                Name (_ADR, 0x001E0000)  // _ADR: Address
                Name (_DDN, "Serial IO UART Controller 0")  // _DDN: DOS Device Name
            }

            Device (UAR1)
            {
                Name (_ADR, 0x001E0001)  // _ADR: Address
                Name (_DDN, "Serial IO UART Controller 1")  // _DDN: DOS Device Name
            }

            Device (UAR2)
            {
                Name (_ADR, 0x00190002)  // _ADR: Address
                Name (_DDN, "Serial IO UART Controller 2")  // _DDN: DOS Device Name
            }

            Device (UAR3)
            {
                Name (_ADR, 0x00110000)  // _ADR: Address
                Name (_DDN, "Serial IO UART Controller 3")  // _DDN: DOS Device Name
            }

            Scope (\_SB.PCI0)
            {
                Method (SCSC, 1, Serialized)
                {
                    PCRA (Arg0, 0x1C20, Zero)
                    PCRA (Arg0, 0x4820, Zero)
                }

                Device (EMMC)
                {
                    Name (_ADR, 0x001A0000)  // _ADR: Address
                    Name (_DDN, "eMMC Controller")  // _DDN: DOS Device Name
                    Name (TEMP, Zero)
                    OperationRegion (SCSR, PCI_Config, Zero, 0x0100)
                    Field (SCSR, WordAcc, NoLock, Preserve)
                    {
                        Offset (0x84), 
                        PMCR,   16, 
                        Offset (0xA2), 
                            ,   2, 
                        PGEN,   1
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        SCSC (0xA1)
                    }

                    Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                    {
                        Stall (0x32)
                        PGEN = Zero
                        SCSC (0xA1)
                        PMCR &= 0xFFFC
                        TEMP = PMCR /* \_SB_.PCI0.EMMC.PMCR */
                    }

                    Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                    {
                        PGEN = One
                        PMCR |= 0x03
                        TEMP = PMCR /* \_SB_.PCI0.EMMC.PMCR */
                    }

                    Device (CARD)
                    {
                        Name (_ADR, 0x08)  // _ADR: Address
                        Method (_RMV, 0, NotSerialized)  // _RMV: Removal Status
                        {
                            Return (Zero)
                        }
                    }
                }
            }

            Scope (\_SB.PCI0)
            {
                Device (UFS)
                {
                    Name (_ADR, 0x00120007)  // _ADR: Address
                    Name (_DDN, "UFS Controller")  // _DDN: DOS Device Name
                    Name (_DSD, Package (0x02)  // _DSD: Device-Specific Data
                    {
                        ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                        Package (0x01)
                        {
                            Package (0x02)
                            {
                                "ref-clk-freq", 
                                0x0124F800
                            }
                        }
                    })
                    Method (OCPD, 0, Serialized)
                    {
                        PCRA (0x50, 0x4020, Zero)
                        PCRA (0x50, 0x4820, Zero)
                        PCRA (0x50, 0x5C20, Zero)
                        PCRA (0x50, 0x5820, Zero)
                        PCRA (0x50, 0x1078, Zero)
                    }

                    OperationRegion (SCSR, PCI_Config, Zero, 0x0100)
                    Field (SCSR, ByteAcc, NoLock, Preserve)
                    {
                        Offset (0x84), 
                        PSTA,   32, 
                        Offset (0xA2), 
                            ,   2, 
                        PGEN,   1
                    }

                    OperationRegion (PWMR, SystemMemory, 0xFE000000, 0x00010000)
                    Field (PWMR, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x1B0C), 
                            ,   18, 
                        LTRU,   1
                    }

                    Method (ULTR, 1, Serialized)
                    {
                        LTRU = Arg0
                    }

                    Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                    {
                        PGEN = Zero
                        PSTA &= 0xFFFFFFFC
                        ULTR (Zero)
                        OCPD ()
                    }

                    Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                    {
                        ULTR (One)
                        PGEN = One
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        OCPD ()
                    }
                }
            }

            Device (SBUS)
            {
                Name (_ADR, 0x001F0004)  // _ADR: Address
            }

            Device (ISHB)
            {
                Name (_ADR, 0x00120000)  // _ADR: Address
                Name (_DDN, "Integrated Sensor Hub Controller")  // _DDN: DOS Device Name
            }

            Method (UPWE, 3, Serialized)
            {
                Local0 = (Arg1 + ((Arg0 - One) * 0x10))
                OperationRegion (PSCR, SystemMemory, ((Arg2 << 0x10) + Local0), 0x10)
                Field (PSCR, DWordAcc, NoLock, Preserve)
                {
                    PSCT,   32
                }

                Local0 = PSCT /* \_SB_.PCI0.UPWE.PSCT */
                Local0 &= 0xFFFFFFFF7F01FFED
                Local0 |= 0x06000000
                PSCT = Local0
            }

            Method (UWES, 3, Serialized)
            {
                Local0 = Arg0
                While (One)
                {
                    FindSetRightBit (Local0, Local1)
                    If ((Local1 == Zero))
                    {
                        Break
                    }

                    UPWE (Local1, Arg1, Arg2)
                    Local0 &= (Local0 - One)
                }
            }

            Device (XHCI)
            {
                Name (_ADR, 0x00140000)  // _ADR: Address
                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x6D, 
                    0x03
                })
                OperationRegion (XPRT, PCI_Config, Zero, 0x0100)
                Field (XPRT, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x10), 
                    Offset (0x12), 
                    XMEM,   16
                }

                Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                {
                    UWES ((U2WE & 0x0FFF), 0x0480, XMEM)
                    UWES ((U3WE & 0x3F), 0x0540, XMEM)
                }

                Name (_S3D, 0x03)  // _S3D: S3 Device State
                Name (_S0W, 0x03)  // _S0W: S0 Device Wake State
                Name (_S3W, 0x03)  // _S3W: S3 Device Wake State
                Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                {
                }

                Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                {
                }

                Device (RHUB)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Device (HS01)
                    {
                        Name (_ADR, One)  // _ADR: Address
                    }

                    Device (HS02)
                    {
                        Name (_ADR, 0x02)  // _ADR: Address
                    }

                    Device (HS03)
                    {
                        Name (_ADR, 0x03)  // _ADR: Address
                    }

                    Device (HS04)
                    {
                        Name (_ADR, 0x04)  // _ADR: Address
                    }

                    Device (HS05)
                    {
                        Name (_ADR, 0x05)  // _ADR: Address
                    }

                    Device (HS06)
                    {
                        Name (_ADR, 0x06)  // _ADR: Address
                    }

                    Device (HS07)
                    {
                        Name (_ADR, 0x07)  // _ADR: Address
                    }

                    Device (HS08)
                    {
                        Name (_ADR, 0x08)  // _ADR: Address
                    }

                    Device (HS09)
                    {
                        Name (_ADR, 0x09)  // _ADR: Address
                    }

                    Device (HS10)
                    {
                        Name (_ADR, 0x0A)  // _ADR: Address
                    }

                    Device (SS01)
                    {
                        Name (_ADR, 0x0D)  // _ADR: Address
                    }

                    Device (SS02)
                    {
                        Name (_ADR, 0x0E)  // _ADR: Address
                    }

                    Device (SS03)
                    {
                        Name (_ADR, 0x0F)  // _ADR: Address
                    }

                    Device (SS04)
                    {
                        Name (_ADR, 0x10)  // _ADR: Address
                    }
                }
            }

            Device (SRAM)
            {
                Name (_ADR, 0x00140002)  // _ADR: Address
            }

            Device (HECI)
            {
                Name (_ADR, 0x00160000)  // _ADR: Address
                OperationRegion (HECS, PCI_Config, Zero, 0x04)
                Field (HECS, DWordAcc, NoLock, Preserve)
                {
                    VDID,   32
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    If ((VDID != 0xFFFFFFFF))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
            }

            Scope (\_SB.PCI0)
            {
                Method (_OSC, 4, NotSerialized)  // _OSC: Operating System Capabilities
                {
                    If ((Arg0 == ToUUID ("33db4d5b-1ff7-401c-9657-7441c03dd766") /* PCI Host Bridge Device */))
                    {
                        Return (Arg3)
                    }
                    Else
                    {
                        CreateDWordField (Arg3, Zero, CDW1)
                        CDW1 |= 0x04
                        Return (Arg3)
                    }
                }
            }

            Scope (\_SB)
            {
                OperationRegion (PMIO, SystemIO, 0x1800, 0x80)
                Field (PMIO, ByteAcc, NoLock, Preserve)
                {
                    Offset (0x6C), 
                        ,   19, 
                    CPWS,   1, 
                    Offset (0x7C), 
                        ,   19, 
                    CPWE,   1
                }

                Name (C2PW, Zero)
                Method (C2PM, 4, NotSerialized)
                {
                    Local0 = (One << Arg3)
                    If ((Arg0 && Arg1))
                    {
                        If ((CPWE == Zero))
                        {
                            If (CPWS)
                            {
                                CPWS = One
                            }

                            CPWE = One
                        }

                        If (((C2PW & Local0) == Zero))
                        {
                            C2PW |= Local0
                        }
                    }
                    ElseIf ((Arg0 || Arg2))
                    {
                        If ((CPWE == Zero))
                        {
                            If (CPWS)
                            {
                                CPWS = One
                            }

                            CPWE = One
                        }

                        If (((C2PW & Local0) == Zero))
                        {
                            C2PW |= Local0
                        }
                    }
                    Else
                    {
                        If (((C2PW & Local0) != Zero))
                        {
                            C2PW &= ~Local0
                        }

                        If (((CPWE != Zero) && (C2PW == Zero)))
                        {
                            CPWE = Zero
                        }
                    }

                    Return (Zero)
                }

                Method (_OSC, 4, Serialized)  // _OSC: Operating System Capabilities
                {
                    CreateDWordField (Arg3, Zero, CDW1)
                    If ((Arg0 == ToUUID ("0811b06e-4a27-44f9-8d60-3cbbc22e7b48") /* Platform-wide Capabilities */))
                    {
                        If ((Arg1 != One))
                        {
                            CDW1 |= 0x08
                        }

                        Return (Arg3)
                    }
                    ElseIf ((Arg0 == ToUUID ("23a0d13a-26ab-486c-9c5f-0ffa525a575a") /* USB4 Capabilities */))
                    {
                        CreateDWordField (Arg3, 0x08, CDW3)
                        Local0 = CDW3 /* \_SB_._OSC.CDW3 */
                        If ((Arg1 != One))
                        {
                            CDW1 |= 0x08
                            Return (Arg3)
                        }

                        Local0 |= 0x0F
                        CDW3 = Local0
                        Return (Arg3)
                    }
                    Else
                    {
                        CDW1 |= 0x04
                        Return (Arg3)
                    }
                }
            }

            Scope (_GPE)
            {
                Method (_L61, 0, NotSerialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
                {
                    Sleep (0x64)
                    If (CondRefOf (\_SB.PCI0.TXHC))
                    {
                        \_SB.PCI0.TRP0.HPEV ()
                        \_SB.PCI0.TRP1.HPEV ()
                        \_SB.PCI0.TRP2.HPEV ()
                        \_SB.PCI0.TRP3.HPEV ()
                    }

                    If (((\_SB.PCI0.TRP0.VDID != 0xFFFFFFFF) && \_SB.PCI0.TRP0.HPSX))
                    {
                        If (\_SB.PCI0.TRP0.PDCX)
                        {
                            \_SB.PCI0.TRP0.PDCX = One
                            \_SB.PCI0.TRP0.HPSX = One
                            If (!\_SB.PCI0.TRP0.PDSX)
                            {
                                \_SB.PCI0.TRP0.L0SE = Zero
                            }

                            Notify (\_SB.PCI0.TRP0, Zero) // Bus Check
                        }
                        Else
                        {
                            \_SB.PCI0.TRP0.HPSX = One
                        }
                    }

                    If (((\_SB.PCI0.TRP1.VDID != 0xFFFFFFFF) && \_SB.PCI0.TRP1.HPSX))
                    {
                        If (\_SB.PCI0.TRP1.PDCX)
                        {
                            \_SB.PCI0.TRP1.PDCX = One
                            \_SB.PCI0.TRP1.HPSX = One
                            If (!\_SB.PCI0.TRP1.PDSX)
                            {
                                \_SB.PCI0.TRP1.L0SE = Zero
                            }

                            Notify (\_SB.PCI0.TRP1, Zero) // Bus Check
                        }
                        Else
                        {
                            \_SB.PCI0.TRP1.HPSX = One
                        }
                    }

                    If (((\_SB.PCI0.TRP2.VDID != 0xFFFFFFFF) && \_SB.PCI0.TRP2.HPSX))
                    {
                        If (\_SB.PCI0.TRP2.PDCX)
                        {
                            \_SB.PCI0.TRP2.PDCX = One
                            \_SB.PCI0.TRP2.HPSX = One
                            If (!\_SB.PCI0.TRP2.PDSX)
                            {
                                \_SB.PCI0.TRP2.L0SE = Zero
                            }

                            Notify (\_SB.PCI0.TRP2, Zero) // Bus Check
                        }
                        Else
                        {
                            \_SB.PCI0.TRP2.HPSX = One
                        }
                    }

                    If (((\_SB.PCI0.TRP3.VDID != 0xFFFFFFFF) && \_SB.PCI0.TRP3.HPSX))
                    {
                        If (\_SB.PCI0.TRP3.PDCX)
                        {
                            \_SB.PCI0.TRP3.PDCX = One
                            \_SB.PCI0.TRP3.HPSX = One
                            If (!\_SB.PCI0.TRP3.PDSX)
                            {
                                \_SB.PCI0.TRP3.L0SE = Zero
                            }

                            Notify (\_SB.PCI0.TRP3, Zero) // Bus Check
                        }
                        Else
                        {
                            \_SB.PCI0.TRP3.HPSX = One
                        }
                    }
                }

                Method (_L69, 0, Serialized)  // _Lxx: Level-Triggered GPE, xx=0x00-0xFF
                {
                    If (CondRefOf (\_SB.PCI0.TXHC))
                    {
                        If ((\_SB.PCI0.TRP0.HPME () == One))
                        {
                            Notify (\_SB.PCI0.TDM0, 0x02) // Device Wake
                            Notify (\_SB.PCI0.TRP0, 0x02) // Device Wake
                        }

                        If ((\_SB.PCI0.TRP1.HPME () == One))
                        {
                            Notify (\_SB.PCI0.TDM0, 0x02) // Device Wake
                            Notify (\_SB.PCI0.TRP1, 0x02) // Device Wake
                        }

                        If ((\_SB.PCI0.TRP2.HPME () == One))
                        {
                            Notify (\_SB.PCI0.TDM1, 0x02) // Device Wake
                            Notify (\_SB.PCI0.TRP2, 0x02) // Device Wake
                        }

                        If ((\_SB.PCI0.TRP3.HPME () == One))
                        {
                            Notify (\_SB.PCI0.TDM1, 0x02) // Device Wake
                            Notify (\_SB.PCI0.TRP3, 0x02) // Device Wake
                        }
                    }

                    \_SB.PCI0.TRP0.HPME ()
                    \_SB.PCI0.TRP1.HPME ()
                    \_SB.PCI0.TRP2.HPME ()
                    \_SB.PCI0.TRP3.HPME ()
                }
            }

            Scope (\_SB)
            {
                Device (IOM)
                {
                    Name (_HID, "INTC1079")  // _HID: Hardware ID
                    Name (_DDN, "Intel(R) Alder Lake Input Output Manager(IOM) driver")  // _DDN: DOS Device Name
                    Name (_CRS, Buffer (0x0E)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xC1, 0xFB,  // ........
                        /* 0008 */  0x00, 0x16, 0x00, 0x00, 0x79, 0x00               // ....y.
                    })
                    Name (_STA, 0x0F)  // _STA: Status
                }
            }

            Scope (\_SB.PCI0)
            {
                OperationRegion (TDEN, SystemMemory, (GMHB () + 0x7090), 0x04)
                Field (TDEN, ByteAcc, NoLock, Preserve)
                {
                    TRE0,   1, 
                    TRE1,   1, 
                    TRE2,   1, 
                    TRE3,   1, 
                    Offset (0x01), 
                    THCE,   1, 
                    TDCE,   1, 
                    DME0,   1, 
                    DME1,   1, 
                    Offset (0x04)
                }

                OperationRegion (MBAR, SystemMemory, (GMHB () + 0x7100), 0x1000)
                Field (MBAR, ByteAcc, NoLock, Preserve)
                {
                    Offset (0x10), 
                    RBAR,   64
                }

                OperationRegion (PBAR, SystemMemory, (GMHB () + 0x5DA0), 0x08)
                Field (PBAR, DWordAcc, NoLock, Preserve)
                {
                    PMBD,   32, 
                    PMBC,   8, 
                    PSCM,   8, 
                        ,   15, 
                    PMBR,   1
                }

                Method (PMBY, 0, NotSerialized)
                {
                    Local0 = Zero
                    While ((PMBR && (Local0 < 0x03E8)))
                    {
                        Local0++
                        Stall (One)
                    }

                    If ((Local0 == 0x03E8))
                    {
                        Debug = "Timeout occurred."
                        Return (0xFF)
                    }

                    Return (Zero)
                }

                Method (IOMA, 0, NotSerialized)
                {
                    Return ((RBAR & 0xFFFFFFFFFFFFFFFE))
                }

                OperationRegion (IOMR, SystemMemory, (IOMA () + 0x00C10000), 0x0100)
                Field (IOMR, DWordAcc, NoLock, Preserve)
                {
                    Offset (0x40), 
                        ,   15, 
                    TD3C,   1, 
                    TACK,   1, 
                    DPOF,   1, 
                    Offset (0x70), 
                    IMCD,   32, 
                    IMDA,   32
                }

                Method (TG0N, 0, NotSerialized)
                {
                    If ((^TDM0.VDID == 0xFFFFFFFF))
                    {
                        Debug = "TDM0 does not exist."
                    }
                    Else
                    {
                        If ((^TDM0.STAT == Zero))
                        {
                            ^TDM0.D3CX ()
                            Debug = "Bring TBT RPs out of D3Code."
                            If ((^TRP0.VDID != 0xFFFFFFFF))
                            {
                                ^TRP0.D3CX ()
                            }

                            If ((^TRP1.VDID != 0xFFFFFFFF))
                            {
                                ^TRP1.D3CX ()
                            }
                        }
                        Else
                        {
                            Debug = "Drop TG0N due to it is already exit D3 cold."
                        }

                        Sleep (0x0A)
                    }
                }

                Method (TG0F, 0, NotSerialized)
                {
                    If ((^TDM0.VDID == 0xFFFFFFFF))
                    {
                        Debug = "TDM0 does not exist."
                    }
                    ElseIf ((^TDM0.STAT == One))
                    {
                        ^TDM0.D3CE ()
                        If ((^TDM0.IF30 != One))
                        {
                            Return (Zero)
                        }

                        Debug = "Push TBT RPs to D3Cold together"
                        If ((^TRP0.VDID != 0xFFFFFFFF))
                        {
                            ^TRP0.D3CE ()
                        }

                        If ((^TRP1.VDID != 0xFFFFFFFF))
                        {
                            ^TRP1.D3CE ()
                        }
                    }

                    Return (Zero)
                }

                Method (TG1N, 0, NotSerialized)
                {
                    If ((^TDM1.VDID == 0xFFFFFFFF))
                    {
                        Debug = "TDM1 does not exist."
                    }
                    Else
                    {
                        If ((^TDM1.STAT == Zero))
                        {
                            ^TDM1.D3CX ()
                            Debug = "Bring TBT RPs out of D3Code."
                            If ((^TRP2.VDID != 0xFFFFFFFF))
                            {
                                ^TRP2.D3CX ()
                            }

                            If ((^TRP3.VDID != 0xFFFFFFFF))
                            {
                                ^TRP3.D3CX ()
                            }
                        }
                        Else
                        {
                            Debug = "Drop TG1N due to it is already exit D3 cold."
                        }

                        Sleep (0x0A)
                    }
                }

                Method (TG1F, 0, NotSerialized)
                {
                    If ((^TDM1.VDID == 0xFFFFFFFF))
                    {
                        Debug = "TDM1 does not exist."
                    }
                    ElseIf ((^TDM1.STAT == One))
                    {
                        ^TDM1.D3CE ()
                        If ((^TDM1.IF30 != One))
                        {
                            Return (Zero)
                        }

                        Debug = "Push TBT RPs to D3Cold together"
                        If ((^TRP2.VDID != 0xFFFFFFFF))
                        {
                            ^TRP2.D3CE ()
                        }

                        If ((^TRP3.VDID != 0xFFFFFFFF))
                        {
                            ^TRP3.D3CE ()
                        }
                    }

                    Return (Zero)
                }

                PowerResource (TBT0, 0x05, 0x0001)
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (^^TDM0.STAT) /* \_SB_.PCI0.TDM0.STAT */
                    }

                    Method (_ON, 0, NotSerialized)  // _ON_: Power On
                    {
                        TG0N ()
                    }

                    Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                    {
                        If ((^^TDM0.SD3C == Zero))
                        {
                            TG0F ()
                        }
                    }
                }

                PowerResource (TBT1, 0x05, 0x0001)
                {
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (^^TDM1.STAT) /* \_SB_.PCI0.TDM1.STAT */
                    }

                    Method (_ON, 0, NotSerialized)  // _ON_: Power On
                    {
                        TG1N ()
                    }

                    Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                    {
                        If ((^^TDM1.SD3C == Zero))
                        {
                            TG1F ()
                        }
                    }
                }

                Method (TCON, 0, NotSerialized)
                {
                    If ((TD3C == One))
                    {
                        TD3C = Zero
                        Local0 = Zero
                        While (((TACK != Zero) && (Local0 < 0x64)))
                        {
                            Sleep (One)
                            Local0++
                        }

                        If ((Local0 == 0x64))
                        {
                            Debug = "Error: Timeout occurred."
                        }
                        Else
                        {
                            Debug = "TCSS D3 exit."
                        }
                    }
                    Else
                    {
                        Debug = "Drop TCON due to it is already exit D3 cold."
                    }
                }

                Method (TCOF, 0, NotSerialized)
                {
                    If ((((^TXHC.SD3C != Zero) || (^TDM0.SD3C != Zero)) || 
                        (^TDM1.SD3C != Zero)))
                    {
                        Debug = "Skip D3C entry."
                        Return (Zero)
                    }

                    TD3C = One
                }

                PowerResource (D3C, 0x05, 0x0000)
                {
                    Name (STAT, One)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (STAT) /* \_SB_.PCI0.D3C_.STAT */
                    }

                    Method (_ON, 0, NotSerialized)  // _ON_: Power On
                    {
                        TCON ()
                        STAT = One
                    }

                    Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                    {
                        TCOF ()
                        STAT = Zero
                    }
                }

                Device (TXHC)
                {
                    Name (_ADR, 0x000D0000)  // _ADR: Address
                    Name (_DDN, "North XHCI controller")  // _DDN: DOS Device Name
                    Name (_STR, Unicode ("North XHCI controller"))  // _STR: Description String
                    Name (DCPM, 0x04)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((THCE == One))
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    OperationRegion (XPRT, SystemMemory, BASE (_ADR), 0x0100)
                    Field (XPRT, ByteAcc, NoLock, Preserve)
                    {
                        VDID,   32, 
                        Offset (0x74), 
                        D0D3,   2, 
                        Offset (0x75), 
                        PMEE,   1, 
                            ,   6, 
                        PMES,   1
                    }

                    Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                    {
                        If ((PMEE == One))
                        {
                            PMEE = Zero
                        }
                    }

                    Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                    {
                        If ((PMEE == Zero))
                        {
                            PMEE = One
                        }
                    }

                    Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                    {
                        Return (0x04)
                    }

                    Name (SD3C, Zero)
                    Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                    {
                        Return (Package (0x01)
                        {
                            D3C, 
                        })
                    }

                    Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                    {
                        Return (Package (0x01)
                        {
                            D3C, 
                        })
                    }

                    Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }

                    Method (_S3D, 0, NotSerialized)  // _S3D: S3 Device State
                    {
                        Return (0x03)
                    }

                    Method (_S4D, 0, NotSerialized)  // _S4D: S4 Device State
                    {
                        Return (0x03)
                    }

                    Method (_S3W, 0, NotSerialized)  // _S3W: S3 Device Wake State
                    {
                        Return (0x03)
                    }

                    Method (_S4W, 0, NotSerialized)  // _S4W: S4 Device Wake State
                    {
                        Return (0x03)
                    }

                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (Package (0x02)
                        {
                            0x6D, 
                            0x04
                        })
                    }

                    Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                    {
                        C2PM (Arg0, Arg1, Arg2, DCPM)
                        SD3C = Arg1
                    }

                    Device (RHUB)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Device (HS01)
                        {
                            Name (_ADR, One)  // _ADR: Address
                        }

                        Device (SS01)
                        {
                            Name (_ADR, 0x02)  // _ADR: Address
                            Method (_DSD, 0, NotSerialized)  // _DSD: Device-Specific Data
                            {
                                Return (Package (0x02)
                                {
                                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                                    Package (0x02)
                                    {
                                        Package (0x02)
                                        {
                                            "usb4-host-interface", 
                                            TDM0, 
                                        }, 

                                        Package (0x02)
                                        {
                                            "usb4-port-number", 
                                            Zero
                                        }
                                    }
                                })
                            }
                        }

                        Device (SS02)
                        {
                            Name (_ADR, 0x03)  // _ADR: Address
                            Method (_DSD, 0, NotSerialized)  // _DSD: Device-Specific Data
                            {
                                Return (Package (0x02)
                                {
                                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                                    Package (0x02)
                                    {
                                        Package (0x02)
                                        {
                                            "usb4-host-interface", 
                                            TDM0, 
                                        }, 

                                        Package (0x02)
                                        {
                                            "usb4-port-number", 
                                            One
                                        }
                                    }
                                })
                            }
                        }

                        Device (SS03)
                        {
                            Name (_ADR, 0x04)  // _ADR: Address
                            Method (_DSD, 0, NotSerialized)  // _DSD: Device-Specific Data
                            {
                                Return (Package (0x02)
                                {
                                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                                    Package (0x02)
                                    {
                                        Package (0x02)
                                        {
                                            "usb4-host-interface", 
                                            TDM1, 
                                        }, 

                                        Package (0x02)
                                        {
                                            "usb4-port-number", 
                                            Zero
                                        }
                                    }
                                })
                            }
                        }

                        Device (SS04)
                        {
                            Name (_ADR, 0x05)  // _ADR: Address
                            Method (_DSD, 0, NotSerialized)  // _DSD: Device-Specific Data
                            {
                                Return (Package (0x02)
                                {
                                    ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301") /* Device Properties for _DSD */, 
                                    Package (0x02)
                                    {
                                        Package (0x02)
                                        {
                                            "usb4-host-interface", 
                                            TDM1, 
                                        }, 

                                        Package (0x02)
                                        {
                                            "usb4-port-number", 
                                            One
                                        }
                                    }
                                })
                            }
                        }
                    }
                }

                Device (TDM0)
                {
                    Name (_ADR, 0x000D0002)  // _ADR: Address
                    Name (_DDN, "TBT DMA0 controller")  // _DDN: DOS Device Name
                    Name (_STR, Unicode ("TBT DMA0 controller"))  // _STR: Description String
                    Name (DUID, Zero)
                    Name (DCPM, 0x06)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((DME0 == One))
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    OperationRegion (DPME, SystemMemory, BASE (_ADR), 0x0100)
                    Field (DPME, AnyAcc, NoLock, Preserve)
                    {
                        VDID,   32, 
                        Offset (0x84), 
                        PMST,   2, 
                        Offset (0x85), 
                        PMEE,   1, 
                            ,   6, 
                        PMES,   1, 
                        Offset (0xC8), 
                            ,   30, 
                        IF30,   1, 
                        INFR,   1, 
                        Offset (0xEC), 
                        TB2P,   32, 
                        P2TB,   32, 
                        Offset (0xFC), 
                        DD3E,   1, 
                        DFPE,   1, 
                        Offset (0xFF), 
                        DMAD,   8
                    }

                    Name (STAT, One)
                    Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                    {
                        Return (0x04)
                    }

                    Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                    {
                        If ((DUID == Zero))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                    {
                        If ((DUID == Zero))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (D3CX, 0, Serialized)
                    {
                        DD3E = Zero
                        STAT = One
                    }

                    Method (D3CE, 0, Serialized)
                    {
                        DD3E = One
                        STAT = Zero
                    }

                    Name (SD3C, Zero)
                    Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                    {
                        SD3C = Arg1
                    }

                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (Package (0x02)
                        {
                            0x6D, 
                            0x04
                        })
                    }
                }

                Device (TDM1)
                {
                    Name (_ADR, 0x000D0003)  // _ADR: Address
                    Name (_DDN, "TBT DMA1 controller")  // _DDN: DOS Device Name
                    Name (_STR, Unicode ("TBT DMA1 controller"))  // _STR: Description String
                    Name (DUID, One)
                    Name (DCPM, 0x07)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((DME1 == One))
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    OperationRegion (DPME, SystemMemory, BASE (_ADR), 0x0100)
                    Field (DPME, AnyAcc, NoLock, Preserve)
                    {
                        VDID,   32, 
                        Offset (0x84), 
                        PMST,   2, 
                        Offset (0x85), 
                        PMEE,   1, 
                            ,   6, 
                        PMES,   1, 
                        Offset (0xC8), 
                            ,   30, 
                        IF30,   1, 
                        INFR,   1, 
                        Offset (0xEC), 
                        TB2P,   32, 
                        P2TB,   32, 
                        Offset (0xFC), 
                        DD3E,   1, 
                        DFPE,   1, 
                        Offset (0xFF), 
                        DMAD,   8
                    }

                    Name (STAT, One)
                    Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                    {
                        Return (0x04)
                    }

                    Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                    {
                        If ((DUID == Zero))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                    {
                        If ((DUID == Zero))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (D3CX, 0, Serialized)
                    {
                        DD3E = Zero
                        STAT = One
                    }

                    Method (D3CE, 0, Serialized)
                    {
                        DD3E = One
                        STAT = Zero
                    }

                    Name (SD3C, Zero)
                    Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                    {
                        SD3C = Arg1
                    }

                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (Package (0x02)
                        {
                            0x6D, 
                            0x04
                        })
                    }
                }

                Device (TRP0)
                {
                    Name (_ADR, 0x00070000)  // _ADR: Address
                    Name (TUID, Zero)
                    Name (LTEN, Zero)
                    Name (LMSL, Zero)
                    Name (LNSL, Zero)
                    Name (DCPM, Zero)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((TRE0 == One))
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        LTEN = Zero
                        LMSL = 0x88C8
                        LNSL = 0x88C8
                    }

                    OperationRegion (PXCS, SystemMemory, BASE (_ADR), 0x0800)
                    Field (PXCS, AnyAcc, NoLock, Preserve)
                    {
                        VDID,   32, 
                        Offset (0x50), 
                        L0SE,   1, 
                            ,   3, 
                        LDIS,   1, 
                        Offset (0x51), 
                        Offset (0x52), 
                            ,   13, 
                        LASX,   1, 
                        Offset (0x5A), 
                        ABPX,   1, 
                            ,   2, 
                        PDCX,   1, 
                            ,   2, 
                        PDSX,   1, 
                        Offset (0x5B), 
                        DLSC,   1, 
                        Offset (0x60), 
                        Offset (0x62), 
                        PSPX,   1, 
                        Offset (0xA4), 
                        D3HT,   2, 
                        Offset (0xD8), 
                            ,   30, 
                        HPEX,   1, 
                        PMEX,   1, 
                        Offset (0xE2), 
                            ,   2, 
                        L23E,   1, 
                        L23R,   1, 
                        Offset (0x420), 
                            ,   30, 
                        DPGE,   1, 
                        Offset (0x5BC), 
                            ,   3, 
                        RPER,   1, 
                        RPFE,   1
                    }

                    Field (PXCS, AnyAcc, NoLock, WriteAsZeros)
                    {
                        Offset (0xDC), 
                            ,   30, 
                        HPSX,   1, 
                        PMSX,   1
                    }

                    Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }

                    Name (OPTS, Buffer (0x02)
                    {
                         0x00, 0x00                                       // ..
                    })
                    Device (PXSX)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                        {
                            If ((Arg0 == ToUUID ("e5c937d0-3553-4d7a-9117-ea4d19c3434d") /* Device Labeling Interface */))
                            {
                                If ((Arg1 >= 0x03))
                                {
                                    If ((Arg2 == Zero))
                                    {
                                        CreateBitField (OPTS, 0x09, FUN9)
                                        FUN9 = One
                                        Return (OPTS) /* \_SB_.PCI0.TRP0.OPTS */
                                    }
                                    ElseIf ((Arg2 == 0x09))
                                    {
                                        Return (Package (0x05)
                                        {
                                            0xC350, 
                                            One, 
                                            One, 
                                            0xC350, 
                                            One
                                        })
                                    }
                                }
                            }

                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }

                        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                        {
                            Return (Package (0x02)
                            {
                                0x69, 
                                0x04
                            })
                        }
                    }

                    Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            ^^TDM0.SD3C = Arg1
                        }
                        Else
                        {
                            ^^TDM1.SD3C = Arg1
                        }

                        C2PM (Arg0, Arg1, Arg2, DCPM)
                    }

                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (Package (0x02)
                        {
                            0x69, 
                            0x04
                        })
                    }

                    Method (HPEV, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && HPSX))
                        {
                            If (((PDCX == One) && (DLSC == One)))
                            {
                                PDCX = One
                                HPSX = One
                                Notify (^, Zero) // Bus Check
                            }
                            Else
                            {
                                HPSX = One
                            }
                        }
                    }

                    Name (STAT, One)
                    Method (D3CX, 0, Serialized)
                    {
                        If ((STAT != One))
                        {
                            RPFE = Zero
                            RPER = Zero
                            L23R = One
                            Local0 = Zero
                            Local1 = L23R /* \_SB_.PCI0.TRP0.L23R */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23R /* \_SB_.PCI0.TRP0.L23R */
                            }

                            STAT = One
                        }
                    }

                    Method (D3CE, 0, Serialized)
                    {
                        If ((STAT != Zero))
                        {
                            L23E = One
                            Local0 = Zero
                            Local1 = L23E /* \_SB_.PCI0.TRP0.L23E */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23E /* \_SB_.PCI0.TRP0.L23E */
                            }

                            STAT = Zero
                            RPFE = One
                            RPER = One
                        }
                    }

                    Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                    {
                        HPEV ()
                        If ((HPEX == One))
                        {
                            HPEX = Zero
                        }

                        HPME ()
                        If ((PMEX == One))
                        {
                            PMEX = Zero
                        }
                    }

                    Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                    {
                        If ((PDCX == One))
                        {
                            If ((DLSC == Zero))
                            {
                                PDCX = One
                            }
                        }

                        If ((HPEX == Zero))
                        {
                            HPEX = One
                            HPEV ()
                        }

                        If ((PMEX == Zero))
                        {
                            PMEX = One
                            HPME ()
                        }
                    }

                    Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                    {
                        Return (0x04)
                    }

                    Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (HPME, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && (PMSX == One)))
                        {
                            Notify (PXSX, 0x02) // Device Wake
                            PMSX = One
                            PSPX = One
                            Return (One)
                        }

                        Return (Zero)
                    }
                }

                Device (TRP1)
                {
                    Name (_ADR, 0x00070001)  // _ADR: Address
                    Name (TUID, One)
                    Name (LTEN, Zero)
                    Name (LMSL, Zero)
                    Name (LNSL, Zero)
                    Name (DCPM, One)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((TRE1 == One))
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        LTEN = Zero
                        LMSL = 0x88C8
                        LNSL = 0x88C8
                    }

                    OperationRegion (PXCS, SystemMemory, BASE (_ADR), 0x0800)
                    Field (PXCS, AnyAcc, NoLock, Preserve)
                    {
                        VDID,   32, 
                        Offset (0x50), 
                        L0SE,   1, 
                            ,   3, 
                        LDIS,   1, 
                        Offset (0x51), 
                        Offset (0x52), 
                            ,   13, 
                        LASX,   1, 
                        Offset (0x5A), 
                        ABPX,   1, 
                            ,   2, 
                        PDCX,   1, 
                            ,   2, 
                        PDSX,   1, 
                        Offset (0x5B), 
                        DLSC,   1, 
                        Offset (0x60), 
                        Offset (0x62), 
                        PSPX,   1, 
                        Offset (0xA4), 
                        D3HT,   2, 
                        Offset (0xD8), 
                            ,   30, 
                        HPEX,   1, 
                        PMEX,   1, 
                        Offset (0xE2), 
                            ,   2, 
                        L23E,   1, 
                        L23R,   1, 
                        Offset (0x420), 
                            ,   30, 
                        DPGE,   1, 
                        Offset (0x5BC), 
                            ,   3, 
                        RPER,   1, 
                        RPFE,   1
                    }

                    Field (PXCS, AnyAcc, NoLock, WriteAsZeros)
                    {
                        Offset (0xDC), 
                            ,   30, 
                        HPSX,   1, 
                        PMSX,   1
                    }

                    Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }

                    Name (OPTS, Buffer (0x02)
                    {
                         0x00, 0x00                                       // ..
                    })
                    Device (PXSX)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                        {
                            If ((Arg0 == ToUUID ("e5c937d0-3553-4d7a-9117-ea4d19c3434d") /* Device Labeling Interface */))
                            {
                                If ((Arg1 >= 0x03))
                                {
                                    If ((Arg2 == Zero))
                                    {
                                        CreateBitField (OPTS, 0x09, FUN9)
                                        FUN9 = One
                                        Return (OPTS) /* \_SB_.PCI0.TRP1.OPTS */
                                    }
                                    ElseIf ((Arg2 == 0x09))
                                    {
                                        Return (Package (0x05)
                                        {
                                            0xC350, 
                                            One, 
                                            One, 
                                            0xC350, 
                                            One
                                        })
                                    }
                                }
                            }

                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }

                        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                        {
                            Return (Package (0x02)
                            {
                                0x69, 
                                0x04
                            })
                        }
                    }

                    Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            ^^TDM0.SD3C = Arg1
                        }
                        Else
                        {
                            ^^TDM1.SD3C = Arg1
                        }

                        C2PM (Arg0, Arg1, Arg2, DCPM)
                    }

                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (Package (0x02)
                        {
                            0x69, 
                            0x04
                        })
                    }

                    Method (HPEV, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && HPSX))
                        {
                            If (((PDCX == One) && (DLSC == One)))
                            {
                                PDCX = One
                                HPSX = One
                                Notify (^, Zero) // Bus Check
                            }
                            Else
                            {
                                HPSX = One
                            }
                        }
                    }

                    Name (STAT, One)
                    Method (D3CX, 0, Serialized)
                    {
                        If ((STAT != One))
                        {
                            RPFE = Zero
                            RPER = Zero
                            L23R = One
                            Local0 = Zero
                            Local1 = L23R /* \_SB_.PCI0.TRP1.L23R */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23R /* \_SB_.PCI0.TRP1.L23R */
                            }

                            STAT = One
                        }
                    }

                    Method (D3CE, 0, Serialized)
                    {
                        If ((STAT != Zero))
                        {
                            L23E = One
                            Local0 = Zero
                            Local1 = L23E /* \_SB_.PCI0.TRP1.L23E */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23E /* \_SB_.PCI0.TRP1.L23E */
                            }

                            STAT = Zero
                            RPFE = One
                            RPER = One
                        }
                    }

                    Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                    {
                        HPEV ()
                        If ((HPEX == One))
                        {
                            HPEX = Zero
                        }

                        HPME ()
                        If ((PMEX == One))
                        {
                            PMEX = Zero
                        }
                    }

                    Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                    {
                        If ((PDCX == One))
                        {
                            If ((DLSC == Zero))
                            {
                                PDCX = One
                            }
                        }

                        If ((HPEX == Zero))
                        {
                            HPEX = One
                            HPEV ()
                        }

                        If ((PMEX == Zero))
                        {
                            PMEX = One
                            HPME ()
                        }
                    }

                    Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                    {
                        Return (0x04)
                    }

                    Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (HPME, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && (PMSX == One)))
                        {
                            Notify (PXSX, 0x02) // Device Wake
                            PMSX = One
                            PSPX = One
                            Return (One)
                        }

                        Return (Zero)
                    }
                }

                Device (TRP2)
                {
                    Name (_ADR, 0x00070002)  // _ADR: Address
                    Name (TUID, 0x02)
                    Name (LTEN, Zero)
                    Name (LMSL, Zero)
                    Name (LNSL, Zero)
                    Name (DCPM, 0x02)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((TRE2 == One))
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        LTEN = Zero
                        LMSL = 0x88C8
                        LNSL = 0x88C8
                    }

                    OperationRegion (PXCS, SystemMemory, BASE (_ADR), 0x0800)
                    Field (PXCS, AnyAcc, NoLock, Preserve)
                    {
                        VDID,   32, 
                        Offset (0x50), 
                        L0SE,   1, 
                            ,   3, 
                        LDIS,   1, 
                        Offset (0x51), 
                        Offset (0x52), 
                            ,   13, 
                        LASX,   1, 
                        Offset (0x5A), 
                        ABPX,   1, 
                            ,   2, 
                        PDCX,   1, 
                            ,   2, 
                        PDSX,   1, 
                        Offset (0x5B), 
                        DLSC,   1, 
                        Offset (0x60), 
                        Offset (0x62), 
                        PSPX,   1, 
                        Offset (0xA4), 
                        D3HT,   2, 
                        Offset (0xD8), 
                            ,   30, 
                        HPEX,   1, 
                        PMEX,   1, 
                        Offset (0xE2), 
                            ,   2, 
                        L23E,   1, 
                        L23R,   1, 
                        Offset (0x420), 
                            ,   30, 
                        DPGE,   1, 
                        Offset (0x5BC), 
                            ,   3, 
                        RPER,   1, 
                        RPFE,   1
                    }

                    Field (PXCS, AnyAcc, NoLock, WriteAsZeros)
                    {
                        Offset (0xDC), 
                            ,   30, 
                        HPSX,   1, 
                        PMSX,   1
                    }

                    Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }

                    Name (OPTS, Buffer (0x02)
                    {
                         0x00, 0x00                                       // ..
                    })
                    Device (PXSX)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                        {
                            If ((Arg0 == ToUUID ("e5c937d0-3553-4d7a-9117-ea4d19c3434d") /* Device Labeling Interface */))
                            {
                                If ((Arg1 >= 0x03))
                                {
                                    If ((Arg2 == Zero))
                                    {
                                        CreateBitField (OPTS, 0x09, FUN9)
                                        FUN9 = One
                                        Return (OPTS) /* \_SB_.PCI0.TRP2.OPTS */
                                    }
                                    ElseIf ((Arg2 == 0x09))
                                    {
                                        Return (Package (0x05)
                                        {
                                            0xC350, 
                                            One, 
                                            One, 
                                            0xC350, 
                                            One
                                        })
                                    }
                                }
                            }

                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }

                        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                        {
                            Return (Package (0x02)
                            {
                                0x69, 
                                0x04
                            })
                        }
                    }

                    Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            ^^TDM0.SD3C = Arg1
                        }
                        Else
                        {
                            ^^TDM1.SD3C = Arg1
                        }

                        C2PM (Arg0, Arg1, Arg2, DCPM)
                    }

                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (Package (0x02)
                        {
                            0x69, 
                            0x04
                        })
                    }

                    Method (HPEV, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && HPSX))
                        {
                            If (((PDCX == One) && (DLSC == One)))
                            {
                                PDCX = One
                                HPSX = One
                                Notify (^, Zero) // Bus Check
                            }
                            Else
                            {
                                HPSX = One
                            }
                        }
                    }

                    Name (STAT, One)
                    Method (D3CX, 0, Serialized)
                    {
                        If ((STAT != One))
                        {
                            RPFE = Zero
                            RPER = Zero
                            L23R = One
                            Local0 = Zero
                            Local1 = L23R /* \_SB_.PCI0.TRP2.L23R */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23R /* \_SB_.PCI0.TRP2.L23R */
                            }

                            STAT = One
                        }
                    }

                    Method (D3CE, 0, Serialized)
                    {
                        If ((STAT != Zero))
                        {
                            L23E = One
                            Local0 = Zero
                            Local1 = L23E /* \_SB_.PCI0.TRP2.L23E */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23E /* \_SB_.PCI0.TRP2.L23E */
                            }

                            STAT = Zero
                            RPFE = One
                            RPER = One
                        }
                    }

                    Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                    {
                        HPEV ()
                        If ((HPEX == One))
                        {
                            HPEX = Zero
                        }

                        HPME ()
                        If ((PMEX == One))
                        {
                            PMEX = Zero
                        }
                    }

                    Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                    {
                        If ((PDCX == One))
                        {
                            If ((DLSC == Zero))
                            {
                                PDCX = One
                            }
                        }

                        If ((HPEX == Zero))
                        {
                            HPEX = One
                            HPEV ()
                        }

                        If ((PMEX == Zero))
                        {
                            PMEX = One
                            HPME ()
                        }
                    }

                    Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                    {
                        Return (0x04)
                    }

                    Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (HPME, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && (PMSX == One)))
                        {
                            Notify (PXSX, 0x02) // Device Wake
                            PMSX = One
                            PSPX = One
                            Return (One)
                        }

                        Return (Zero)
                    }
                }

                Device (TRP3)
                {
                    Name (_ADR, 0x00070003)  // _ADR: Address
                    Name (TUID, 0x03)
                    Name (LTEN, Zero)
                    Name (LMSL, Zero)
                    Name (LNSL, Zero)
                    Name (DCPM, 0x03)
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        If ((TRE3 == One))
                        {
                            Return (0x0F)
                        }
                        Else
                        {
                            Return (Zero)
                        }
                    }

                    Method (_INI, 0, NotSerialized)  // _INI: Initialize
                    {
                        LTEN = Zero
                        LMSL = 0x88C8
                        LNSL = 0x88C8
                    }

                    OperationRegion (PXCS, SystemMemory, BASE (_ADR), 0x0800)
                    Field (PXCS, AnyAcc, NoLock, Preserve)
                    {
                        VDID,   32, 
                        Offset (0x50), 
                        L0SE,   1, 
                            ,   3, 
                        LDIS,   1, 
                        Offset (0x51), 
                        Offset (0x52), 
                            ,   13, 
                        LASX,   1, 
                        Offset (0x5A), 
                        ABPX,   1, 
                            ,   2, 
                        PDCX,   1, 
                            ,   2, 
                        PDSX,   1, 
                        Offset (0x5B), 
                        DLSC,   1, 
                        Offset (0x60), 
                        Offset (0x62), 
                        PSPX,   1, 
                        Offset (0xA4), 
                        D3HT,   2, 
                        Offset (0xD8), 
                            ,   30, 
                        HPEX,   1, 
                        PMEX,   1, 
                        Offset (0xE2), 
                            ,   2, 
                        L23E,   1, 
                        L23R,   1, 
                        Offset (0x420), 
                            ,   30, 
                        DPGE,   1, 
                        Offset (0x5BC), 
                            ,   3, 
                        RPER,   1, 
                        RPFE,   1
                    }

                    Field (PXCS, AnyAcc, NoLock, WriteAsZeros)
                    {
                        Offset (0xDC), 
                            ,   30, 
                        HPSX,   1, 
                        PMSX,   1
                    }

                    Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }

                    Name (OPTS, Buffer (0x02)
                    {
                         0x00, 0x00                                       // ..
                    })
                    Device (PXSX)
                    {
                        Name (_ADR, Zero)  // _ADR: Address
                        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                        {
                            If ((Arg0 == ToUUID ("e5c937d0-3553-4d7a-9117-ea4d19c3434d") /* Device Labeling Interface */))
                            {
                                If ((Arg1 >= 0x03))
                                {
                                    If ((Arg2 == Zero))
                                    {
                                        CreateBitField (OPTS, 0x09, FUN9)
                                        FUN9 = One
                                        Return (OPTS) /* \_SB_.PCI0.TRP3.OPTS */
                                    }
                                    ElseIf ((Arg2 == 0x09))
                                    {
                                        Return (Package (0x05)
                                        {
                                            0xC350, 
                                            One, 
                                            One, 
                                            0xC350, 
                                            One
                                        })
                                    }
                                }
                            }

                            Return (Buffer (One)
                            {
                                 0x00                                             // .
                            })
                        }

                        Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                        {
                            Return (Package (0x02)
                            {
                                0x69, 
                                0x04
                            })
                        }
                    }

                    Method (_DSW, 3, NotSerialized)  // _DSW: Device Sleep Wake
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            ^^TDM0.SD3C = Arg1
                        }
                        Else
                        {
                            ^^TDM1.SD3C = Arg1
                        }

                        C2PM (Arg0, Arg1, Arg2, DCPM)
                    }

                    Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                    {
                        Return (Package (0x02)
                        {
                            0x69, 
                            0x04
                        })
                    }

                    Method (HPEV, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && HPSX))
                        {
                            If (((PDCX == One) && (DLSC == One)))
                            {
                                PDCX = One
                                HPSX = One
                                Notify (^, Zero) // Bus Check
                            }
                            Else
                            {
                                HPSX = One
                            }
                        }
                    }

                    Name (STAT, One)
                    Method (D3CX, 0, Serialized)
                    {
                        If ((STAT != One))
                        {
                            RPFE = Zero
                            RPER = Zero
                            L23R = One
                            Local0 = Zero
                            Local1 = L23R /* \_SB_.PCI0.TRP3.L23R */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23R /* \_SB_.PCI0.TRP3.L23R */
                            }

                            STAT = One
                        }
                    }

                    Method (D3CE, 0, Serialized)
                    {
                        If ((STAT != Zero))
                        {
                            L23E = One
                            Local0 = Zero
                            Local1 = L23E /* \_SB_.PCI0.TRP3.L23E */
                            While (Local1)
                            {
                                If ((Local0 > 0x14))
                                {
                                    Break
                                }

                                Sleep (0x05)
                                Local0++
                                Local1 = L23E /* \_SB_.PCI0.TRP3.L23E */
                            }

                            STAT = Zero
                            RPFE = One
                            RPER = One
                        }
                    }

                    Method (_PS0, 0, Serialized)  // _PS0: Power State 0
                    {
                        HPEV ()
                        If ((HPEX == One))
                        {
                            HPEX = Zero
                        }

                        HPME ()
                        If ((PMEX == One))
                        {
                            PMEX = Zero
                        }
                    }

                    Method (_PS3, 0, Serialized)  // _PS3: Power State 3
                    {
                        If ((PDCX == One))
                        {
                            If ((DLSC == Zero))
                            {
                                PDCX = One
                            }
                        }

                        If ((HPEX == Zero))
                        {
                            HPEX = One
                            HPEV ()
                        }

                        If ((PMEX == Zero))
                        {
                            PMEX = One
                            HPME ()
                        }
                    }

                    Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
                    {
                        Return (0x04)
                    }

                    Method (_PR0, 0, NotSerialized)  // _PR0: Power Resources for D0
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (_PR3, 0, NotSerialized)  // _PR3: Power Resources for D3hot
                    {
                        If (((TUID == Zero) || (TUID == One)))
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT0, 
                            })
                        }
                        Else
                        {
                            Return (Package (0x02)
                            {
                                D3C, , 
                                TBT1, 
                            })
                        }
                    }

                    Method (HPME, 0, Serialized)
                    {
                        If (((VDID != 0xFFFFFFFF) && (PMSX == One)))
                        {
                            Notify (PXSX, 0x02) // Device Wake
                            PMSX = One
                            PSPX = One
                            Return (One)
                        }

                        Return (Zero)
                    }
                }
            }

            Scope (GFX0)
            {
                OperationRegion (GFXC, PCI_Config, Zero, 0x0100)
                Field (GFXC, DWordAcc, NoLock, Preserve)
                {
                    Offset (0x10), 
                    BAR0,   64, 
                    Offset (0xE4), 
                    ASLE,   32, 
                    Offset (0xFC), 
                    ASLS,   32
                }

                OperationRegion (GFRG, SystemMemory, (BAR0 & 0xFFFFFFFFFFFFFFF0), 0x00400000)
                Field (GFRG, DWordAcc, NoLock, Preserve)
                {
                    Offset (0xC8258), 
                    BCLV,   32
                }

                Field (GFRG, DWordAcc, NoLock, Preserve)
                {
                    Offset (0xC8254), 
                    BCLM,   32
                }

                Name (BRLV, Zero)
                Name (BRVA, Zero)
                Device (BOX3)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    OperationRegion (OPRG, SystemMemory, ASLS, 0x0400)
                    Field (OPRG, DWordAcc, NoLock, Preserve)
                    {
                        Offset (0x58), 
                        MBOX,   32, 
                        Offset (0x300), 
                        ARDY,   1, 
                        Offset (0x304), 
                        ASLC,   32, 
                        TCHE,   32, 
                        ALSI,   32, 
                        BCLP,   32, 
                        PFIT,   32, 
                        CBLV,   32
                    }

                    Method (XBCM, 1, Serialized)
                    {
                        If ((ASLS == Zero))
                        {
                            Return (Ones)
                        }

                        If (((MBOX & 0x04) == Zero))
                        {
                            Return (Ones)
                        }

                        Local1 = ((Arg0 * 0xFF) / 0x64)
                        If ((Local1 > 0xFF))
                        {
                            Local1 = 0xFF
                        }

                        BCLP = (Local1 | 0x80000000)
                        If ((ARDY == Zero))
                        {
                            Return (Ones)
                        }

                        ASLC = 0x02
                        ASLE = One
                        Local0 = 0x20
                        While ((Local0 > Zero))
                        {
                            Sleep (One)
                            If (((ASLC & 0x02) == Zero))
                            {
                                Local1 = ((ASLC >> 0x0C) & 0x03)
                                If ((Local1 == Zero))
                                {
                                    Return (Zero)
                                }
                                Else
                                {
                                    Return (Ones)
                                }
                            }

                            Local0--
                        }

                        Return (Ones)
                    }
                }

                Device (LEGA)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Method (DRCL, 2, NotSerialized)
                    {
                        Return (((Arg0 + (Arg1 / 0x02)) / Arg1))
                    }

                    Method (XBCM, 1, NotSerialized)
                    {
                        BCLV = DRCL ((Arg0 * BCLM), 0x64)
                    }

                    Method (XBQC, 0, NotSerialized)
                    {
                        If ((BCLM == Zero))
                        {
                            Return (Zero)
                        }

                        Local0 = DRCL ((BCLV * 0x64), BCLM)
                        Local1 = 0x02
                        While ((Local1 < (SizeOf (BRIG) - One)))
                        {
                            Local2 = DerefOf (BRIG [Local1])
                            Local3 = DerefOf (BRIG [(Local1 + One)])
                            If ((Local0 < Local3))
                            {
                                If (((Local0 < Local2) || ((Local0 - Local2) < (Local3 - 
                                    Local0))))
                                {
                                    Return (Local2)
                                }
                                Else
                                {
                                    Return (Local3)
                                }
                            }

                            Local1++
                        }

                        Return (Local3)
                    }
                }

                Method (XBCM, 1, NotSerialized)
                {
                    BRLV = Arg0
                    BRVA = One
                    If ((^BOX3.XBCM (Arg0) == Ones))
                    {
                        If ((BCLM != Zero))
                        {
                            ^LEGA.XBCM (Arg0)
                        }
                    }
                }

                Method (XBQC, 0, NotSerialized)
                {
                    If ((BCLM == Zero))
                    {
                        If ((BRVA != Zero))
                        {
                            Return (BRLV) /* \_SB_.PCI0.GFX0.BRLV */
                        }

                        Local0 = DerefOf (BRIG [Zero])
                        Return (Local0)
                    }

                    Local0 = ^LEGA.XBQC ()
                    If (((BRVA != Zero) && (Local0 != BRLV)))
                    {
                        If ((BRCT == Zero))
                        {
                            BRCT = One
                            XBCM (BRLV)
                            Local0 = ^LEGA.XBQC ()
                            BRCT = Zero
                        }
                    }

                    BRLV = Local0
                    BRVA = One
                    Return (Local0)
                }

                Name (BRCT, Zero)
                Method (BRID, 1, NotSerialized)
                {
                    Local0 = Match (BRIG, MEQ, Arg0, MTR, Zero, 0x02)
                    If ((Local0 == Ones))
                    {
                        Return ((SizeOf (BRIG) - One))
                    }

                    Return (Local0)
                }

                Method (XBCL, 0, NotSerialized)
                {
                    BRCT = One
                    Return (BRIG) /* \_SB_.PCI0.GFX0.BRIG */
                }

                Method (_DOS, 1, NotSerialized)  // _DOS: Disable Output Switching
                {
                }

                Method (DECB, 0, NotSerialized)
                {
                    If (BRCT)
                    {
                        Notify (LCD0, 0x87) // Device-Specific
                    }
                    Else
                    {
                        Local0 = BRID (XBQC ())
                        If ((Local0 != 0x02))
                        {
                            Local0--
                        }

                        XBCM (DerefOf (BRIG [Local0]))
                    }
                }

                Method (INCB, 0, NotSerialized)
                {
                    If (BRCT)
                    {
                        Notify (LCD0, 0x86) // Device-Specific
                    }
                    Else
                    {
                        Local0 = BRID (XBQC ())
                        If ((Local0 != (SizeOf (BRIG) - One)))
                        {
                            Local0++
                        }

                        XBCM (DerefOf (BRIG [Local0]))
                    }
                }
            }

            Scope (GFX0)
            {
                Name (BRIG, Package (0x67)
                {
                    0x64, 
                    0x64, 
                    Zero, 
                    One, 
                    0x02, 
                    0x03, 
                    0x04, 
                    0x05, 
                    0x06, 
                    0x07, 
                    0x08, 
                    0x09, 
                    0x0A, 
                    0x0B, 
                    0x0C, 
                    0x0D, 
                    0x0E, 
                    0x0F, 
                    0x10, 
                    0x11, 
                    0x12, 
                    0x13, 
                    0x14, 
                    0x15, 
                    0x16, 
                    0x17, 
                    0x18, 
                    0x19, 
                    0x1A, 
                    0x1B, 
                    0x1C, 
                    0x1D, 
                    0x1E, 
                    0x1F, 
                    0x20, 
                    0x21, 
                    0x22, 
                    0x23, 
                    0x24, 
                    0x25, 
                    0x26, 
                    0x27, 
                    0x28, 
                    0x29, 
                    0x2A, 
                    0x2B, 
                    0x2C, 
                    0x2D, 
                    0x2E, 
                    0x2F, 
                    0x30, 
                    0x31, 
                    0x32, 
                    0x33, 
                    0x34, 
                    0x35, 
                    0x36, 
                    0x37, 
                    0x38, 
                    0x39, 
                    0x3A, 
                    0x3B, 
                    0x3C, 
                    0x3D, 
                    0x3E, 
                    0x3F, 
                    0x40, 
                    0x41, 
                    0x42, 
                    0x43, 
                    0x44, 
                    0x45, 
                    0x46, 
                    0x47, 
                    0x48, 
                    0x49, 
                    0x4A, 
                    0x4B, 
                    0x4C, 
                    0x4D, 
                    0x4E, 
                    0x4F, 
                    0x50, 
                    0x51, 
                    0x52, 
                    0x53, 
                    0x54, 
                    0x55, 
                    0x56, 
                    0x57, 
                    0x58, 
                    0x59, 
                    0x5A, 
                    0x5B, 
                    0x5C, 
                    0x5D, 
                    0x5E, 
                    0x5F, 
                    0x60, 
                    0x61, 
                    0x62, 
                    0x63, 
                    0x64
                })
            }

            Device (GNA)
            {
                Name (_ADR, 0x00080000)  // _ADR: Address
                Name (_DDN, "GNA Scoring Accelerator")  // _DDN: DOS Device Name
                OperationRegion (GNAC, PCI_Config, Zero, 0x04)
                Field (GNAC, DWordAcc, NoLock, Preserve)
                {
                    VDID,   32
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    If ((VDID != 0xFFFFFFFF))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
            }
        }
    }

    Name (SSFG, 0x0D)
    If (One)
    {
        SSFG &= 0xFE
    }

    If (Zero)
    {
        SSFG &= 0xF7
    }

    If (CondRefOf (\OSFG))
    {
        SSFG = OSFG /* External reference */
    }

    Name (_S0, Package (0x04)  // _S0_: S0 System State
    {
        Zero, 
        Zero, 
        Zero, 
        Zero
    })
    If ((SSFG & One))
    {
        Name (_S1, Package (0x04)  // _S1_: S1 System State
        {
            One, 
            Zero, 
            Zero, 
            Zero
        })
    }

    If ((SSFG & 0x04))
    {
        Name (_S3, Package (0x04)  // _S3_: S3 System State
        {
            0x05, 
            Zero, 
            Zero, 
            Zero
        })
    }

    If ((SSFG & 0x08))
    {
        Name (_S4, Package (0x04)  // _S4_: S4 System State
        {
            0x06, 
            0x04, 
            Zero, 
            Zero
        })
    }

    Name (_S5, Package (0x04)  // _S5_: S5 System State
    {
        0x07, 
        Zero, 
        Zero, 
        Zero
    })
    Scope (_SB.PCI0.LPCB)
    {
        Device (SIO)
        {
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_ADR, Zero)  // _ADR: Address
            Device (ECMM)
            {
                Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                Name (_UID, 0x04)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (_CRS, Buffer (0x0A)  // _CRS: Current Resource Settings
                {
                    /* 0000 */  0x47, 0x01, 0x00, 0x09, 0x00, 0x09, 0x08, 0xFF,  // G.......
                    /* 0008 */  0x79, 0x00                                       // y.
                })
            }

            Device (ECUI)
            {
                Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                Name (_UID, 0x03)  // _UID: Unique ID
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (_CRS, Buffer (0x22)  // _CRS: Current Resource Settings
                {
                    /* 0000 */  0x47, 0x01, 0x00, 0x02, 0x00, 0x02, 0x01, 0x01,  // G.......
                    /* 0008 */  0x47, 0x01, 0x04, 0x02, 0x04, 0x02, 0x01, 0x01,  // G.......
                    /* 0010 */  0x47, 0x01, 0x00, 0x08, 0x00, 0x08, 0x08, 0x80,  // G.......
                    /* 0018 */  0x47, 0x01, 0x80, 0x08, 0x80, 0x08, 0x08, 0x80,  // G.......
                    /* 0020 */  0x79, 0x00                                       // y.
                })
            }
        }

        Scope (^^PCI0)
        {
            Device (PS2K)
            {
                Name (_UID, Zero)  // _UID: Unique ID
                Name (_HID, "GOOG000A")  // _HID: Hardware ID
                Name (_CID, Package (0x02)  // _CID: Compatible ID
                {
                    EisaId ("PNP0303") /* IBM Enhanced Keyboard (101/102-key, PS/2 Mouse) */, 
                    EisaId ("PNP030B")
                })
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }

                Name (_CRS, Buffer (0x16)  // _CRS: Current Resource Settings
                {
                    /* 0000 */  0x47, 0x01, 0x60, 0x00, 0x60, 0x00, 0x01, 0x01,  // G.`.`...
                    /* 0008 */  0x47, 0x01, 0x64, 0x00, 0x64, 0x00, 0x01, 0x01,  // G.d.d...
                    /* 0010 */  0x23, 0x02, 0x00, 0x01, 0x79, 0x00               // #...y.
                })
            }
        }

        Device (EC0)
        {
            Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_GPE, 0x6E)  // _GPE: General Purpose Events
            Name (TOFS, 0xC8)
            Name (TNCA, 0xFC)
            Name (TNOP, 0xFD)
            Name (TBAD, 0xFE)
            Name (TNPR, 0xFF)
            Name (DWRN, 0x0F)
            Name (DLOW, 0x0A)
            OperationRegion (ERAM, EmbeddedControl, Zero, 0x20)
            Field (ERAM, ByteAcc, Lock, Preserve)
            {
                RAMV,   8, 
                TSTB,   8, 
                TSTC,   8, 
                KBLV,   8, 
                FAND,   8, 
                PATI,   8, 
                PATT,   8, 
                PATC,   8, 
                CHGL,   8, 
                TBMD,   1, 
                DDPN,   3, 
                STTB,   1, 
                Offset (0x0A), 
                DFUD,   1, 
                FLSH,   1, 
                PFAN,   1, 
                KBLE,   1, 
                LTBR,   1, 
                LEDC,   1, 
                MTNS,   1, 
                KEYB,   1, 
                PSTR,   1, 
                P80P,   1, 
                THRM,   1, 
                SBKL,   1, 
                WIFI,   1, 
                HOST,   1, 
                GPIO,   1, 
                I2CB,   1, 
                CHRG,   1, 
                BATT,   1, 
                SBAT,   1, 
                HANG,   1, 
                PMUI,   1, 
                DSEC,   1, 
                UPDC,   1, 
                UMUX,   1, 
                MSFF,   1, 
                TVST,   1, 
                TCMV,   1, 
                RTCD,   1, 
                FPRD,   1, 
                TPAD,   1, 
                RWSG,   1, 
                DEVE,   1, 
                Offset (0x0E), 
                Offset (0x12), 
                BTID,   8, 
                USPP,   8, 
                RFWU,   8, 
                PBOK,   8, 
                BSRF,   8
            }

            OperationRegion (EMEM, SystemIO, 0x0900, 0xFF)
            Field (EMEM, ByteAcc, NoLock, Preserve)
            {
                TIN0,   8, 
                TIN1,   8, 
                TIN2,   8, 
                TIN3,   8, 
                TIN4,   8, 
                TIN5,   8, 
                TIN6,   8, 
                TIN7,   8, 
                TIN8,   8, 
                TIN9,   8, 
                Offset (0x10), 
                FAN0,   16, 
                FAN1,   16, 
                Offset (0x24), 
                BTVR,   8, 
                Offset (0x30), 
                LIDS,   1, 
                PBTN,   1, 
                WPDI,   1, 
                RECK,   1, 
                RECD,   1, 
                Offset (0x40), 
                BTVO,   32, 
                BTPR,   32, 
                BTRA,   32, 
                ACEX,   1, 
                BTEX,   1, 
                BFDC,   1, 
                BFCG,   1, 
                BFCR,   1, 
                BFIV,   1, 
                BFCT,   1, 
                Offset (0x4D), 
                BTCN,   8, 
                BTIX,   8, 
                Offset (0x50), 
                BTDA,   32, 
                BTDV,   32, 
                BTDF,   32, 
                BTCC,   32, 
                BMFG,   64, 
                BMOD,   64, 
                BSER,   64, 
                BTYP,   64, 
                Offset (0x80), 
                ALS0,   16, 
                Offset (0xA6), 
                GPUD,   8, 
                Offset (0xA7), 
                PWRT,   8, 
                EOVD,   8
            }

            Name (ENS0, Zero)
            Name (RES0, Zero)
            Method (S0IX, 1, Serialized)
            {
                If ((Arg0 == One))
                {
                    ENS0 = One
                    Sleep (0xD2)
                    Notify (CREC, One) // Device Check
                }
                Else
                {
                    RES0 = One
                    Notify (CREC, 0x02) // Device Wake
                }
            }

            Device (LID0)
            {
                Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)  // _HID: Hardware ID
                Method (_LID, 0, NotSerialized)  // _LID: Lid Status
                {
                    Return (LIDS) /* \_SB_.PCI0.LPCB.EC0_.LIDS */
                }

                Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                {
                    0x51, 
                    0x05
                })
            }

            Method (TINS, 1, Serialized)
            {
                Switch (ToInteger (Arg0))
                {
                    Case (Zero)
                    {
                        Return (TIN0) /* \_SB_.PCI0.LPCB.EC0_.TIN0 */
                    }
                    Case (One)
                    {
                        Return (TIN1) /* \_SB_.PCI0.LPCB.EC0_.TIN1 */
                    }
                    Case (0x02)
                    {
                        Return (TIN2) /* \_SB_.PCI0.LPCB.EC0_.TIN2 */
                    }
                    Case (0x03)
                    {
                        Return (TIN3) /* \_SB_.PCI0.LPCB.EC0_.TIN3 */
                    }
                    Case (0x04)
                    {
                        Return (TIN4) /* \_SB_.PCI0.LPCB.EC0_.TIN4 */
                    }
                    Case (0x05)
                    {
                        Return (TIN5) /* \_SB_.PCI0.LPCB.EC0_.TIN5 */
                    }
                    Case (0x06)
                    {
                        Return (TIN6) /* \_SB_.PCI0.LPCB.EC0_.TIN6 */
                    }
                    Case (0x07)
                    {
                        Return (TIN7) /* \_SB_.PCI0.LPCB.EC0_.TIN7 */
                    }
                    Case (0x08)
                    {
                        Return (TIN8) /* \_SB_.PCI0.LPCB.EC0_.TIN8 */
                    }
                    Case (0x09)
                    {
                        Return (TIN9) /* \_SB_.PCI0.LPCB.EC0_.TIN9 */
                    }
                    Default
                    {
                        Return (TIN0) /* \_SB_.PCI0.LPCB.EC0_.TIN0 */
                    }

                }
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (ECMD, Buffer (0x12)
                {
                    /* 0000 */  0x47, 0x01, 0x62, 0x00, 0x62, 0x00, 0x00, 0x01,  // G.b.b...
                    /* 0008 */  0x47, 0x01, 0x66, 0x00, 0x66, 0x00, 0x00, 0x01,  // G.f.f...
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                Return (ECMD) /* \_SB_.PCI0.LPCB.EC0_._CRS.ECMD */
            }

            Method (DPTU, 0, NotSerialized)
            {
            }

            Method (_REG, 2, NotSerialized)  // _REG: Region Availability
            {
                PWRS = ACEX /* \_SB_.PCI0.LPCB.EC0_.ACEX */
                PNOT ()
                DPTU ()
            }

            Method (TSRD, 1, Serialized)
            {
                Local0 = TINS (Arg0)
                If ((Local0 == TNCA))
                {
                    Return (Zero)
                }

                If ((Local0 == TNPR))
                {
                    Return (Zero)
                }

                If ((Local0 == TNOP))
                {
                    Return (Zero)
                }

                If ((Local0 == TBAD))
                {
                    Return (Zero)
                }

                Local0 += TOFS /* \_SB_.PCI0.LPCB.EC0_.TOFS */
                Local0 *= 0x0A
                Return (Local0)
            }

            Method (_Q01, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: LID CLOSE"
                DPTU ()
                Notify (LID0, 0x80) // Status Change
            }

            Method (_Q02, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: LID OPEN"
                DPTU ()
                Notify (CREC, 0x02) // Device Wake
                Notify (LID0, 0x80) // Status Change
            }

            Method (_Q03, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: POWER BUTTON"
            }

            Method (ACUP, 0, NotSerialized)
            {
                PWRS = ACEX /* \_SB_.PCI0.LPCB.EC0_.ACEX */
                Notify (AC, 0x80) // Status Change
                PNOT ()
            }

            Method (_Q04, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: AC CONNECTED"
                ACUP ()
            }

            Method (_Q05, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: AC DISCONNECTED"
                ACUP ()
            }

            Method (_Q06, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: BATTERY LOW"
                Notify (BAT0, 0x80) // Status Change
            }

            Method (_Q07, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: BATTERY CRITICAL"
                Notify (BAT0, 0x80) // Status Change
            }

            Method (_Q08, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: BATTERY INFO"
                Notify (BAT0, 0x81) // Information Change
            }

            Method (_Q0A, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: THERMAL OVERLOAD"
                Notify (_TZ, 0x80) // Status Change
            }

            Method (_Q0B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: THERMAL"
                Notify (_TZ, 0x80) // Status Change
            }

            Method (_Q0D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: KEY PRESSED"
                Notify (CREC, 0x02) // Device Wake
            }

            Method (_Q10, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: THERMAL SHUTDOWN"
                Notify (_TZ, 0x80) // Status Change
            }

            Method (_Q11, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: BATTERY SHUTDOWN"
                Notify (BAT0, 0x80) // Status Change
            }

            Method (_Q16, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: GOT PD EVENT"
                Notify (^^^^CREC.ECPD, 0x80) // Status Change
                If (CondRefOf (\_SB.DPTF.TPWR))
                {
                    Notify (^^^^DPTF.TPWR, 0x81) // Information Change
                }
            }

            Method (_Q17, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: BATTERY STATUS"
                Notify (BAT0, 0x80) // Status Change
                PNOT ()
            }

            Method (_Q18, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: PANIC"
                Notify (CREC, 0xB0) // Device-Specific
            }

            Method (_Q1B, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: MKBP"
                Notify (CREC, 0x80) // Status Change
            }

            Method (_Q1C, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: USB MUX"
                Notify (^^^^CREC.ECPD, 0x80) // Status Change
            }

            Method (_Q1D, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: TABLET mode switch Event"
                Notify (CREC, 0x02) // Device Wake
                DPTU ()
            }

            Method (_Q21, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                Debug = "EC: Body Detect Change Event"
                DPTU ()
            }

            Mutex (PATM, 0x01)
            Method (PATS, 3, Serialized)
            {
                If (Acquire (PATM, 0x03E8))
                {
                    Return (Zero)
                }

                PATI = ToInteger (Arg0)
                Local1 = (ToInteger (Arg1) / 0x0A)
                PATT = (Local1 - TOFS) /* \_SB_.PCI0.LPCB.EC0_.TOFS */
                PATC = Arg2
                Release (PATM)
                Return (One)
            }

            Method (PAT0, 2, NotSerialized)
            {
                Return (PATS (Arg0, Arg1, 0x02))
            }

            Method (PAT1, 2, NotSerialized)
            {
                Return (PATS (Arg0, Arg1, 0x03))
            }

            Method (PATD, 1, Serialized)
            {
                If (Acquire (PATM, 0x03E8))
                {
                    Return (Zero)
                }

                PATI = ToInteger (Arg0)
                PATT = Zero
                PATC = Zero
                PATC = One
                Release (PATM)
                Return (One)
            }

            Method (_Q09, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                DPTU ()
                If (!Acquire (PATM, 0x03E8))
                {
                    Local0 = PATI /* \_SB_.PCI0.LPCB.EC0_.PATI */
                    While ((Local0 != 0xFF))
                    {
                        Local0 = PATI /* \_SB_.PCI0.LPCB.EC0_.PATI */
                    }

                    Release (PATM)
                }
            }

            Method (CHGS, 1, Serialized)
            {
                CHGL = ToInteger (Arg0)
            }

            Method (CHGD, 0, Serialized)
            {
                CHGL = 0xFF
            }

            Method (RCTM, 0, NotSerialized)
            {
                Return (TBMD) /* \_SB_.PCI0.LPCB.EC0_.TBMD */
            }

            Device (AC)
            {
                Name (_HID, "ACPI0003" /* Power Source Device */)  // _HID: Hardware ID
                Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
                {
                    _SB, 
                })
                Method (_PSR, 0, NotSerialized)  // _PSR: Power Source
                {
                    Return (ACEX) /* \_SB_.PCI0.LPCB.EC0_.ACEX */
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (0x0F)
                }
            }

            Mutex (BATM, 0x00)
            Method (BTSW, 1, NotSerialized)
            {
                If ((Arg0 != Zero))
                {
                    Return (One)
                }

                Return (Zero)
            }

            Method (BSTA, 1, Serialized)
            {
                If (Acquire (BATM, 0x03E8))
                {
                    Return (Zero)
                }

                If ((!BTSW (Arg0) && BTEX))
                {
                    Local0 = 0x1F
                }
                Else
                {
                    Local0 = 0x0F
                }

                Release (BATM)
                Return (Local0)
            }

            Name (BRSS, 0xFF)
            Name (BRI1, Zero)
            Name (BRI2, Zero)
            Name (BRI3, Zero)
            Name (BRS1, Buffer (0x20)
            {
                 0x00                                             // .
            })
            Name (BRS2, Buffer (0x20)
            {
                 0x00                                             // .
            })
            Name (BRS3, Buffer (0x20)
            {
                 0x00                                             // .
            })
            Method (BRSX, 1, Serialized)
            {
                If (((Arg0 == Zero) || (Arg0 > 0x03)))
                {
                    Return ("")
                }

                If (((Arg0 == One) && (BRI1 == One)))
                {
                    Return (BRS1) /* \_SB_.PCI0.LPCB.EC0_.BRS1 */
                }

                If (((Arg0 == 0x02) && (BRI2 == One)))
                {
                    Return (BRS2) /* \_SB_.PCI0.LPCB.EC0_.BRS2 */
                }

                If (((Arg0 == 0x03) && (BRI3 == One)))
                {
                    Return (BRS3) /* \_SB_.PCI0.LPCB.EC0_.BRS3 */
                }

                If ((BRSS == 0xFF))
                {
                    BSRF = Zero
                    BRSS = BSRF /* \_SB_.PCI0.LPCB.EC0_.BSRF */
                    If ((BRSS == 0xFF))
                    {
                        BRSS = Zero
                    }
                }

                If ((BRSS == Zero))
                {
                    If ((Arg0 == One))
                    {
                        Local0 = ToString (Concatenate (BMOD, Zero), Ones)
                    }
                    ElseIf ((Arg0 == 0x02))
                    {
                        Local0 = ToString (Concatenate (BSER, Zero), Ones)
                    }
                    ElseIf ((Arg0 == 0x03))
                    {
                        Local0 = ToString (Concatenate (BMFG, Zero), Ones)
                    }
                }
                Else
                {
                    BSRF = Arg0
                    Local0 = Buffer (0x21){}
                    Local2 = Zero
                    While ((Local2 < (SizeOf (Local0) - One)))
                    {
                        Local1 = BSRF /* \_SB_.PCI0.LPCB.EC0_.BSRF */
                        If ((Local1 == Zero))
                        {
                            Break
                        }

                        Local0 [Local2] = Local1
                        Local2++
                    }

                    Local0 [Local2] = Zero
                    Local0 = ToString (Local0, Ones)
                }

                If ((Arg0 == One))
                {
                    BRS1 = Local0
                    BRI1 = One
                }

                If ((Arg0 == 0x02))
                {
                    BRS2 = Local0
                    BRI2 = One
                }

                If ((Arg0 == 0x03))
                {
                    BRS3 = Local0
                    BRI3 = One
                }

                Return (Local0)
            }

            Method (BBIX, 2, Serialized)
            {
                If (Acquire (BATM, 0x03E8))
                {
                    Return (Arg1)
                }

                If (BTSW (Arg0))
                {
                    Release (BATM)
                    Return (Arg1)
                }

                Arg1 [0x03] = BTDF /* \_SB_.PCI0.LPCB.EC0_.BTDF */
                Arg1 [0x05] = BTDV /* \_SB_.PCI0.LPCB.EC0_.BTDV */
                Local0 = BTDA /* \_SB_.PCI0.LPCB.EC0_.BTDA */
                Arg1 [0x02] = Local0
                Local2 = ((Local0 * DWRN) / 0x64)
                Arg1 [0x06] = Local2
                Local2 = ((Local0 * DLOW) / 0x64)
                Arg1 [0x07] = Local2
                Arg1 [0x08] = BTCC /* \_SB_.PCI0.LPCB.EC0_.BTCC */
                Arg1 [0x10] = BRSX (One)
                Arg1 [0x11] = BRSX (0x02)
                Arg1 [0x13] = BRSX (0x03)
                Release (BATM)
                Return (Arg1)
            }

            Method (BBIF, 3, Serialized)
            {
                Local0 = BBIX (Arg0, Arg2)
                Arg1 [One] = DerefOf (Local0 [0x02])
                Arg1 [0x02] = DerefOf (Local0 [0x03])
                Arg1 [0x04] = DerefOf (Local0 [0x05])
                Arg1 [0x05] = DerefOf (Local0 [0x06])
                Arg1 [0x06] = DerefOf (Local0 [0x07])
                Arg1 [0x09] = DerefOf (Local0 [0x10])
                Arg1 [0x0A] = DerefOf (Local0 [0x11])
                Arg1 [0x0C] = DerefOf (Local0 [0x13])
                Return (Arg1)
            }

            Method (BBST, 3, Serialized)
            {
                If (Acquire (BATM, 0x03E8))
                {
                    Return (Arg1)
                }

                If (BTSW (Arg0))
                {
                    Release (BATM)
                    Return (Arg1)
                }

                Local1 = Zero
                If (ACEX)
                {
                    If (BFCG)
                    {
                        Local1 = 0x02
                    }
                    ElseIf (BFDC)
                    {
                        Local1 = One
                    }
                }
                Else
                {
                    Local1 = One
                }

                If (BFCR)
                {
                    Local1 |= 0x04
                }

                Arg1 [Zero] = Local1
                If ((Local1 != DerefOf (Arg2)))
                {
                    Arg2 = Local1
                    If ((Arg0 == Zero))
                    {
                        Notify (BAT0, 0x80) // Status Change
                    }
                }

                Arg1 [One] = BTPR /* \_SB_.PCI0.LPCB.EC0_.BTPR */
                Local1 = BTRA /* \_SB_.PCI0.LPCB.EC0_.BTRA */
                Arg1 [0x02] = Local1
                Arg1 [0x03] = BTVO /* \_SB_.PCI0.LPCB.EC0_.BTVO */
                Release (BATM)
                Return (Arg1)
            }

            Device (BAT0)
            {
                Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
                Name (_UID, One)  // _UID: Unique ID
                Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
                {
                    _SB, 
                })
                Name (PBIF, Package (0x0D)
                {
                    One, 
                    0xFFFFFFFF, 
                    0xFFFFFFFF, 
                    One, 
                    0xFFFFFFFF, 
                    0x03, 
                    0xFFFFFFFF, 
                    One, 
                    One, 
                    "", 
                    "", 
                    "LION", 
                    ""
                })
                Name (PBIX, Package (0x14)
                {
                    Zero, 
                    One, 
                    0xFFFFFFFF, 
                    0xFFFFFFFF, 
                    One, 
                    0xFFFFFFFF, 
                    0x03, 
                    0xFFFFFFFF, 
                    Zero, 
                    0x00018000, 
                    0x01F4, 
                    0x0A, 
                    0xFFFFFFFF, 
                    0xFFFFFFFF, 
                    One, 
                    One, 
                    "", 
                    "", 
                    "LION", 
                    ""
                })
                Name (PBST, Package (0x04)
                {
                    Zero, 
                    0xFFFFFFFF, 
                    0xFFFFFFFF, 
                    0xFFFFFFFF
                })
                Name (BSTP, Zero)
                Method (_STA, 0, Serialized)  // _STA: Status
                {
                    Return (BSTA (Zero))
                }

                Method (_BIF, 0, Serialized)  // _BIF: Battery Information
                {
                    Return (BBIF (Zero, PBIF, PBIX))
                }

                Method (_BIX, 0, Serialized)  // _BIX: Battery Information Extended
                {
                    Return (BBIX (Zero, PBIX))
                }

                Method (_BST, 0, Serialized)  // _BST: Battery Status
                {
                    Return (BBST (Zero, PBST, RefOf (BSTP)))
                }
            }

            Scope (\_SB)
            {
                Device (CREC)
                {
                    Name (_HID, "GOOG0004")  // _HID: Hardware ID
                    Name (_UID, One)  // _UID: Unique ID
                    Name (_DDN, "EC Command Device")  // _DDN: DOS Device Name
                    Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
                    {
                        0x51, 
                        0x05
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        Name (RBUF, Buffer (0x0B)
                        {
                            /* 0000 */  0x89, 0x06, 0x00, 0x05, 0x01, 0x62, 0x00, 0x00,  // .....b..
                            /* 0008 */  0x00, 0x79, 0x00                                 // .y.
                        })
                        Return (RBUF) /* \_SB_.CREC._CRS.RBUF */
                    }

                    Device (CKSC)
                    {
                        Name (_HID, "GOOG0007")  // _HID: Hardware ID
                        Name (_UID, One)  // _UID: Unique ID
                        Name (_DDN, "EC MKBP Device")  // _DDN: DOS Device Name
                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            Return (0x0F)
                        }
                    }

                    Device (ECPD)
                    {
                        Name (_HID, "GOOG0003")  // _HID: Hardware ID
                        Name (_UID, One)  // _UID: Unique ID
                        Name (_DDN, "EC PD Device")  // _DDN: DOS Device Name
                        Method (_STA, 0, NotSerialized)  // _STA: Status
                        {
                            Return (0x0F)
                        }
                    }

                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (0x0F)
                    }
                }
            }

            Scope (^^^CREC)
            {
                Device (KBLT)
                {
                    Name (_HID, "GOOG0002")  // _HID: Hardware ID
                    Name (_UID, One)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (0x0F)
                    }
                }
            }

            Scope (\_SB)
            {
                Device (KBLT)
                {
                    Name (_HID, "GOOG0002")  // _HID: Hardware ID
                    Name (_UID, One)  // _UID: Unique ID
                    Method (_STA, 0, NotSerialized)  // _STA: Status
                    {
                        Return (Zero)
                    }

                    Method (KBQC, 0, NotSerialized)
                    {
                        Return (^^PCI0.LPCB.EC0.KBLV) /* \_SB_.PCI0.LPCB.EC0_.KBLV */
                    }

                    Method (KBCM, 1, NotSerialized)
                    {
                        ^^PCI0.LPCB.EC0.KBLV = Arg0
                    }
                }
            }
        }
    }
}

