# SPDX-License-Identifier: BSD-3-Clause
"""Generate croskbsettings.bin for CoolStar croskeyboard4 on the Telith
(ASUS Chromebook CX15, Vivaldi top row with 15 keys and a real fn key).

Layout of the file (packed, little endian), from croskeyboard4 sys/croskeyboard.h:
  RemapCfgs: magic 'BKrC', UINT32 remappings, BOOLEAN FlipSearchAndAssistantOnPixelbook,
             INT32 HasAssistantKey, INT32 IsNonChromeEC, RemapCfg cfg[]
  RemapCfg:  INT32 LeftCtrl, LeftAlt, Search, Assistant, LeftShift, RightCtrl, RightAlt,
             RightShift (0 = ignore, 1 = must be pressed, 2 = must not be pressed),
             RemapCfgKey originalKey, BOOLEAN remapVivaldiToFnKeys, RemapCfgKey remappedKey,
             RemapCfgKey additionalKeys[8]   (RemapCfgKey = USHORT MakeCode, USHORT Flags)
Key flags: 1 = break, 2 = E0 prefix. The first matching entry wins.

Behaviour produced:
  top row without fn -> the action printed on the key (ChromeOS layout)
  fn + top row       -> F1..F15 (sent by the EC itself; IsNonChromeEC=1 stops the
                        driver from turning F1..F10 back into Chromebook actions)

Usage: python make_croskbsettings.py croskbsettings.bin
"""

import struct
import sys

ANY, YES, NO = 0, 1, 2
E0, BREAK = 2, 1

LWIN = (0x5B, E0)
LSHIFT_DOWN = (0x2A, 0)
LSHIFT_UP = (0x2A, BREAK)
LALT_DOWN = (0x38, 0)
LCTRL_UP = (0x1D, BREAK)
LALT_UP = (0x38, BREAK)

# Vivaldi scancodes of this keyboard (function-row-physmap in the coreboot SSDT)
FULLSCREEN = (0x11, E0)
OVERVIEW = (0x12, E0)
SNAPSHOT = (0x13, E0)
BRIGHT_DN = (0x14, E0)
BRIGHT_UP = (0x15, E0)
KBLIGHT_DN = (0x17, E0)
KBLIGHT_UP = (0x18, E0)
DICTATE = (0x27, E0)          # F8
DO_NOT_DISTURB = (0x28, E0)   # F9
ACCESSIBILITY = (0x29, E0)    # F10
MIC_MUTE = (0x1B, E0)         # F12
# back (E0 6A), refresh (E0 67), play/pause, mute, volume and brightness are
# understood by Windows / the driver as they are: no entry needed.


def cfg(orig, remapped, add=(), ctrl=ANY, alt=ANY, search=ANY, shift=ANY):
    entry = struct.pack('<8i', ctrl, alt, search, ANY, shift, ANY, ANY, ANY)
    entry += struct.pack('<HH', *orig)
    entry += struct.pack('<B', 0)
    entry += struct.pack('<HH', *remapped)
    keys = list(add) + [(0, 0)] * (8 - len(add))
    for k in keys:
        entry += struct.pack('<HH', *k)
    assert len(entry) == 73
    return entry


def scan(c):
    return (c, 0)


CFGS = [
    # --- top row (no fn) ---
    cfg(FULLSCREEN, scan(0x19), [LWIN, LSHIFT_UP], shift=YES),     # Shift + fullscreen: Win+P
    cfg(FULLSCREEN, scan(0x57)),                                   # fullscreen: F11
    cfg(OVERVIEW, scan(0x0F), [LWIN]),                             # overview: Win+Tab
    cfg(SNAPSHOT, scan(0x1F), [LWIN, LSHIFT_DOWN]),                # screenshot: Win+Shift+S
    cfg(BRIGHT_DN, KBLIGHT_DN, alt=YES),                           # Alt + brightness: keyboard light
    cfg(BRIGHT_UP, KBLIGHT_UP, alt=YES),
    cfg(DICTATE, scan(0x23), [LWIN]),                              # dictation: Win+H
    cfg(DO_NOT_DISTURB, scan(0x31), [LWIN]),                       # do not disturb: Win+N
    cfg(ACCESSIBILITY, scan(0x16), [LWIN]),                        # accessibility: Win+U
    cfg(MIC_MUTE, scan(0x25), [LWIN, LALT_DOWN]),                  # mic mute: Win+Alt+K

    # --- CoolStar defaults for the rest of the keyboard ---
    cfg(scan(0x0E), (0x53, E0), ctrl=YES, alt=YES),                # Ctrl+Alt+Backspace: Ctrl+Alt+Del
    cfg(scan(0x0E), (0x53, E0), [LCTRL_UP], ctrl=YES, alt=NO),     # Ctrl+Backspace: Delete
    cfg((0x4B, E0), (0x47, E0), [LCTRL_UP], ctrl=YES),             # Ctrl+Left: Home
    cfg((0x4D, E0), (0x4F, E0), [LCTRL_UP], ctrl=YES),             # Ctrl+Right: End
    cfg((0x48, E0), (0x49, E0), [LCTRL_UP], ctrl=YES),             # Ctrl+Up: Page Up
    cfg((0x50, E0), (0x51, E0), [LCTRL_UP], ctrl=YES),             # Ctrl+Down: Page Down
    cfg(scan(0x5D), scan(0x26), [LWIN], search=NO),                # lock key: Win+L
    cfg(scan(0x5D), scan(0x26), search=YES),
    cfg((0x53, E0), scan(0x45), [LALT_UP], alt=YES),               # Alt+Delete: Num Lock
]


def main():
    header = b'BKrC' + struct.pack('<IBii', len(CFGS), 1, 0, 1)   # IsNonChromeEC = enable
    data = header + b''.join(CFGS)
    with open(sys.argv[1], 'wb') as f:
        f.write(data)
    print('%d remappings, %d bytes' % (len(CFGS), len(data)))


if __name__ == '__main__':
    main()
