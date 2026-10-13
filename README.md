# Open audio and keyboard drivers for the ASUS Chromebook CX15 (CX1505CTA) on Windows

**English** · [Español](README.es.md)

Open-source Windows 11 drivers for the **ASUS Chromebook CX15, model
CX1505CTA**, built on Google's **Telith** board (Nissa platform). With them the
speakers, the 3.5 mm headset jack, the internal microphones and the top-row keys
work on Windows. No paid driver is needed.

| Hardware | |
|---|---|
| Model | ASUS Chromebook CX15 — **CX1505CTA** |
| Board | Google **Telith** (SKU `Telithn50`), Nissa platform (`Google_Nissa`) |
| Processor | Intel Processor N50 (Alder Lake-N) |
| Audio DSP / HDA controller | Intel, PCI `8086:54C8` |
| Audio codec | Realtek **RT5650** (ACPI `10EC5650`, I2C address `0x1A`) |
| Microphones | 2 digital microphones (DMIC) on the DSP + 3.5 mm combo jack |
| Keyboard | ChromeOS "Vivaldi" keyboard, 15 top-row keys + `fn` (ACPI `GOOG000A`) |
| Firmware needed | MrChromebox UEFI (Full ROM) |

> [!WARNING]
> **These drivers are not signed by Microsoft. Windows must run in test-signing
> mode ("Test Mode") to load them, with Secure Boot disabled.**
>
> Getting drivers signed by Microsoft requires a paid EV code-signing
> certificate, which this project does not have. Before you continue, be aware
> of what Test Mode means:
>
> - Windows will load **any** test-signed driver, not only Microsoft-signed
>   ones. Malware running as administrator could use this to load its own
>   driver. Keep Microsoft Defender on, and use a standard (non-administrator)
>   account for daily work.
> - Secure Boot must be off, so boot-level malware is not blocked.
> - **Smart App Control** and **Memory integrity** (Core isolation) in Windows
>   Security must stay **off**. Either one blocks test-signed drivers even in
>   Test Mode: the sound stops and, if `telithfn` is installed, the built-in
>   keyboard stops working too. Depending on the Windows version, Smart App
>   Control cannot be turned back on once it is off.
> - Some anti-cheat systems (for example Vanguard or FACEIT) refuse to run, and
>   some DRM-protected video may play at lower quality.
> - A "Test Mode" watermark is shown on the desktop.
>
> These are kernel-mode drivers written by an independent developer. They are
> not reviewed or audited by anyone else. A bug can crash Windows (blue screen).
> **Use them at your own risk.** The project is not affiliated with ASUS,
> Google, Intel, Realtek, Microsoft or CoolStar.

## What works

| Feature | Status |
|---|---|
| Internal speakers | ✅ |
| Headphones (3.5 mm jack), switching automatically on plug/unplug | ✅ |
| Internal microphone (digital microphones on the DSP) | ✅ |
| Headset microphone (combo jack, CTIA) | ✅ |
| Standby, hibernation and Fast Startup (the DSP is booted again on resume) | ✅ |
| Top-row keys: volume, brightness, screenshot, etc. | ✅ (CoolStar keyboard driver + settings from this project) |
| `fn` + top row = F1…F15 | ✅ (`telithfn` filter) |
| HDMI / DisplayPort audio | ❌ not implemented |
| Headset buttons | ❌ not implemented |

Known issue: switching between headphones and speakers produces a short
audible glitch.

## How it works

```
 Windows audio engine
        │  WaveRT (PortCls)
 ┌──────▼────────┐  kernel callback  ┌──────────────┐  I2C  ┌──────────────────┐
 │ telithaudio   │──────────────────▶│ rt5650       │──────▶│ Realtek RT5650   │
 │ (endpoints,   │◀──── jack state ──│ (codec)      │       │ codec            │
 │  SOF IPC3)    │                   └──────────────┘       └────────▲─────────┘
 └──────┬────────┘                                                   │ I2S (SSP0/SSP1)
        │ ADSP bus interface                                         │
 ┌──────▼────────┐   HDA host DMA, IPC   ┌────────────────────────────┴───┐
 │ sklhdaudbus   │──────────────────────▶│ Intel audio DSP running the    │
 │ (CoolStar,    │                       │ Sound Open Firmware (SOF)      │◀── DMIC
 │  BSD-3)       │                       └────────────────────────────────┘
 └───────────────┘
```

- **`drivers/telithaudio`** is the Windows audio driver, a PortCls/WaveRT driver
  based on Microsoft's SimpleAudioSample. It exposes four endpoints: speakers,
  headphones, microphone and headset microphone. It boots the DSP with Intel's
  SOF firmware and loads the audio topology through SOF IPC3.
- **`drivers/sofdsp`** contains the DSP boot, IPC, topology and PCM code, ported
  from the Linux SOF driver. `telithaudio` compiles it in.
- **`drivers/rt5650`** is the RT5650 codec driver, derived from the Linux
  `rt5645.c` driver. It handles jack detection and the speaker, headphone and
  microphone paths.
- **`drivers/telithfn`** is a small keyboard filter that turns the top row into
  F1…F15 while `fn` is held.
- **`tools/tplg`** reads the Linux topology `sof-adl-rt5650.tplg` and converts
  it into the IPC message list `drivers/sofdsp/sof-adl-rt5650.ipc`.
- **`tools/keyboard`** generates the settings file for CoolStar's keyboard
  driver.
- **`firmware/`** holds Intel's signed SOF firmware `sof-adl-n.ri` (from
  sof-bin v2026.09.1).
- **`audio/`** holds the ACPI tables of this Chromebook, as reference.

## Requirements

1. An **ASUS Chromebook CX15, model CX1505CTA (board Telith / Telithn50)**, with the
   **MrChromebox UEFI firmware** (Full ROM) and **Windows 11 x64**. Other
   Chromebooks are **not** supported: the topology, the codec routing and the
   key map are specific to this board.
2. CoolStar's **free** Chromebook drivers, installed by following the guide at
   <https://coolstar.org/chromebook/windows-install.html>: Chrome EC, keyboard
   and the rest. Do **not** install a paid audio driver at the same time. If one
   is installed, remove it first.
3. **sklhdaudbus**, CoolStar's open-source HDA bus driver (BSD-3-Clause), built
   from <https://github.com/coolstar/sklhdaudbus>. It binds to the audio
   controller (`PCI\VEN_8086&DEV_54C8`) and creates the DSP device
   `CSAUDIO\ADSP&CTLR_VEN_8086&CTLR_DEV_54C8` that `telithaudio` installs on.
4. **Test mode** (see the warning above):
   - Disable Secure Boot in the UEFI setup.
   - In an administrator console, run `bcdedit /set testsigning on`, then
     restart.

## Building

You need Visual Studio 2022 with "Desktop development with C++" and the
**Windows Driver Kit** component (WDK 10.0.26100). Use the **64-bit** MSBuild;
the 32-bit one fails while validating INF files.

```powershell
$msb = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\amd64\MSBuild.exe"
& $msb drivers\telithaudio\SimpleAudioSample.sln /p:Configuration=Release /p:Platform=x64
& $msb drivers\rt5650\rt5650.vcxproj              /p:Configuration=Release /p:Platform=x64
& $msb drivers\telithfn\telithfn.vcxproj          /p:Configuration=Release /p:Platform=x64
```

Visual Studio signs the packages with a test certificate (`WDKTestCert`). Export
that certificate (`.cer`) and import it on the Chromebook, from an administrator
console:

```powershell
certutil -addstore Root WDKTestCert.cer
certutil -addstore TrustedPublisher WDKTestCert.cer
```

The packages end up in:

| Driver | Folder |
|---|---|
| telithaudio | `drivers\telithaudio\x64\Release\package\` (`telithaudio.inf/.sys/.cat`, `sof-adl-n.ri`, `sof-adl-rt5650.ipc`) |
| rt5650 | `drivers\rt5650\x64\Release\rt5650\` |
| telithfn | `drivers\telithfn\x64\Release\telithfn\` |

## Installing

Run everything from an **administrator** console on the Chromebook.

1. **Codec:**
   ```powershell
   pnputil /add-driver rt5650.inf /install
   ```
2. **Audio:**
   ```powershell
   pnputil /add-driver telithaudio.inf /install
   ```
   Restart. Windows should then show **Speakers** and **Microphone**.
   **Headphones** and **Headset microphone** appear when something is plugged
   into the jack.
3. **Top-row keys (optional).** Generate the settings and copy them over
   CoolStar's. Keep a backup of the original file.
   ```powershell
   python tools\keyboard\make_croskbsettings.py croskbsettings.bin
   copy C:\Windows\System32\drivers\croskbsettings.bin croskbsettings.bin.orig
   copy croskbsettings.bin C:\Windows\System32\drivers\croskbsettings.bin
   ```
   The new settings take effect after a restart.
4. **`fn` key (optional, needs step 3):**
   ```powershell
   pnputil /add-driver telithfn.inf /install
   # telithfn must sit BELOW croskeyboard (first in the list):
   Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Enum\ACPI\GOOG000A\0' `
       -Name UpperFilters -Type MultiString -Value @('telithfn','croskeyboard')
   ```
   Restart. Windows does not always apply the order from the INF, so set it by
   hand as shown. Reinstalling CoolStar's keyboard driver may undo it.

## Uninstalling

Find each package's published name (`oemNN.inf`) with `pnputil /enum-drivers`,
then remove it with `pnputil /delete-driver oemNN.inf /uninstall`.

> [!IMPORTANT]
> Before you remove `telithfn`, put the keyboard filters back the way they were.
> Otherwise the keyboard will not start after the restart:
> ```powershell
> Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Enum\ACPI\GOOG000A\0' `
>     -Name UpperFilters -Type MultiString -Value @('croskeyboard')
> ```

To restore the original keyboard settings, copy `croskbsettings.bin.orig` back
and restart.

## Regenerating the DSP topology

```powershell
python tools\tplg\tplg2ipc.py sof-adl-rt5650.tplg drivers\sofdsp\sof-adl-rt5650.ipc
```

The `.tplg` file comes from sof-bin (`sof-tplg/`). The converter loads the
speaker, headset and DMIC pipelines and runs every pipeline on DSP core 0. It
also sets the speaker pipeline to a 1 ms period, because with 10 ms the sound
gets distorted after switching outputs.

## Licenses

Each folder carries its own `LICENSE` file. In short:

| Part | License |
|---|---|
| `drivers/telithaudio` | MS-PL (Microsoft SimpleAudioSample). `telith_hw.c/.h` are GPL-2.0-only OR BSD-3-Clause |
| `drivers/sofdsp`, `drivers/common`, `drivers/telithfn` | GPL-2.0-only OR BSD-3-Clause. `adsp_bus.h` is BSD-3-Clause (CoolStar) |
| `drivers/rt5650` | GPL-2.0-only (derived from Linux `rt5645.c`, © Realtek) |
| `tools/tplg` | GPL-2.0-only |
| `tools/keyboard` | BSD-3-Clause |
| `firmware/sof-adl-n.ri` | Intel SOF firmware licence (`firmware/LICENCE.Intel`) |

## Contact and bug reports

Please open an [issue](https://github.com/augustocco/chromebook-cx1505cta-windows-drivers/issues) for bugs, questions or to report that the
drivers work (or not) on your device. Include your Windows version, what you
tried and what happened. Contributions through pull requests are welcome.

## Credits

- [Sound Open Firmware](https://github.com/thesofproject) and the Linux SOF
  driver, by Intel.
- The Linux `rt5645` codec driver, by Realtek.
- CoolStar, for `sklhdaudbus` and the free Chrome EC and keyboard drivers.
- MrChromebox, for the UEFI firmware.
- Microsoft, for the Windows driver samples.
