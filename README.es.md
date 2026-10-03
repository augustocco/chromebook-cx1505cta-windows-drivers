# Drivers abiertos de audio y teclado para el ASUS Chromebook CX15 (CX1505CTA) en Windows

[English](README.md) · **Español**

Drivers de código abierto para Windows 11 en el **ASUS Chromebook CX15, modelo
CX1505CTA**, construido sobre la placa **Telith** de Google (plataforma Nissa).
Hacen funcionar en Windows los altavoces, el jack de 3,5 mm, los micrófonos
internos y las teclas de la fila superior, sin ningún driver de pago.

| Hardware | |
|---|---|
| Modelo | ASUS Chromebook CX15 — **CX1505CTA** |
| Placa | Google **Telith** (SKU `Telithn50`), plataforma Nissa (`Google_Nissa`) |
| Procesador | Intel Processor N50 (Alder Lake-N) |
| DSP de audio / controlador HDA | Intel, PCI `8086:54C8` |
| Códec de audio | Realtek **RT5650** (ACPI `10EC5650`, dirección I2C `0x1A`) |
| Micrófonos | 2 micrófonos digitales (DMIC) en el DSP + jack combinado de 3,5 mm |
| Teclado | Teclado «Vivaldi» de ChromeOS, 15 teclas en la fila superior + `fn` (ACPI `GOOG000A`) |
| Firmware necesario | UEFI de MrChromebox (Full ROM) |

> [!WARNING]
> **Estos drivers no están firmados por Microsoft. Para cargarlos, Windows debe
> estar en «modo de prueba» (test signing) y con Secure Boot desactivado.**
>
> Para que Microsoft los firme hace falta un certificado de firma de código EV
> de pago, y este proyecto no lo tiene. Antes de continuar, ten en cuenta lo que
> implica el modo de prueba:
>
> - Windows cargará **cualquier** driver firmado «de prueba», no solo los
>   firmados por Microsoft. Un programa malicioso con permisos de administrador
>   podría aprovecharlo para cargar un driver propio. Mantén Microsoft Defender
>   activo y usa una cuenta estándar (no administradora) para el día a día.
> - Secure Boot tiene que estar desactivado, así que no se bloquea el malware de
>   arranque.
> - Algunos antitrampas de juegos (por ejemplo Vanguard o FACEIT) no funcionan,
>   y algunos videos con DRM pueden reproducirse con menos calidad.
> - Aparece la marca de agua «Modo de prueba» en el escritorio.
>
> Son drivers de kernel escritos por un desarrollador independiente. Nadie más
> los ha revisado ni auditado, y un fallo puede provocar un pantallazo azul.
> **Úsalos bajo tu propia responsabilidad.** El proyecto no tiene relación con
> ASUS, Google, Intel, Realtek, Microsoft ni CoolStar.

## Qué funciona

| Función | Estado |
|---|---|
| Altavoces internos | ✅ |
| Auriculares (jack de 3,5 mm), con cambio automático al enchufar y desenchufar | ✅ |
| Micrófono interno (micrófonos digitales en el DSP) | ✅ |
| Micrófono de auriculares (jack combinado, CTIA) | ✅ |
| Suspensión, hibernación e Inicio rápido (el DSP se vuelve a arrancar al despertar) | ✅ |
| Teclas de la fila superior: volumen, brillo, captura, etc. | ✅ (driver de teclado de CoolStar + configuración de este proyecto) |
| `fn` + fila superior = F1…F15 | ✅ (filtro `telithfn`) |
| Audio por HDMI / DisplayPort | ❌ no implementado |
| Botones del auricular | ❌ no implementado |

Problema conocido: al cambiar entre auriculares y altavoces se oye un pequeño
corte.

## Cómo funciona

```
 Motor de audio de Windows
        │  WaveRT (PortCls)
 ┌──────▼────────┐  callback de kernel  ┌──────────────┐  I2C  ┌──────────────────┐
 │ telithaudio   │─────────────────────▶│ rt5650       │──────▶│ Códec Realtek    │
 │ (dispositivos,│◀── estado del jack ──│ (códec)      │       │ RT5650           │
 │  SOF IPC3)    │                      └──────────────┘       └────────▲─────────┘
 └──────┬────────┘                                                      │ I2S (SSP0/SSP1)
        │ interfaz de bus ADSP                                          │
 ┌──────▼────────┐   DMA HDA, IPC   ┌───────────────────────────────────┴┐
 │ sklhdaudbus   │─────────────────▶│ DSP de audio Intel con             │
 │ (CoolStar,    │                  │ Sound Open Firmware (SOF)          │◀── DMIC
 │  BSD-3)       │                  └────────────────────────────────────┘
 └───────────────┘
```

- **`drivers/telithaudio`** es el driver de audio de Windows, de tipo
  PortCls/WaveRT y basado en el ejemplo SimpleAudioSample de Microsoft. Crea
  cuatro dispositivos (altavoces, auriculares, micrófono y micrófono de
  auriculares). Arranca el DSP con el firmware SOF de Intel y carga la topología
  de audio por IPC3.
- **`drivers/sofdsp`** contiene el arranque del DSP, la comunicación IPC, la
  topología y los PCM, portados del driver SOF de Linux. `telithaudio` lo
  incluye al compilar.
- **`drivers/rt5650`** es el driver del códec RT5650, derivado del driver
  `rt5645.c` de Linux. Se encarga de la detección del jack y de las rutas de
  altavoces, auriculares y micrófono.
- **`drivers/telithfn`** es un filtro de teclado pequeño que convierte la fila
  superior en F1…F15 mientras se mantiene pulsada `fn`.
- **`tools/tplg`** lee la topología de Linux `sof-adl-rt5650.tplg` y la
  convierte en la lista de mensajes IPC `drivers/sofdsp/sof-adl-rt5650.ipc`.
- **`tools/keyboard`** genera la configuración del driver de teclado de
  CoolStar.
- **`firmware/`** contiene el firmware SOF firmado por Intel, `sof-adl-n.ri`
  (de sof-bin v2026.09.1).
- **`audio/`** contiene las tablas ACPI de este Chromebook, como referencia.

## Requisitos

1. Un **ASUS Chromebook CX15, modelo CX1505CTA (placa Telith / Telithn50)**, con el
   **firmware UEFI de MrChromebox** (Full ROM) y **Windows 11 x64**. Otros
   Chromebooks **no** están soportados: la topología, las rutas del códec y el
   mapa de teclas son propios de esta placa.
2. Los drivers **gratuitos** de CoolStar para Chromebook (Chrome EC, teclado y
   el resto), instalados según la guía de
   <https://coolstar.org/chromebook/windows-install.html>. **No** instales a la
   vez un driver de audio de pago; si tienes uno instalado, desinstálalo antes.
3. **sklhdaudbus**, el driver de bus HDA de código abierto de CoolStar
   (BSD-3-Clause), compilado desde <https://github.com/coolstar/sklhdaudbus>.
   Se instala sobre el controlador de audio (`PCI\VEN_8086&DEV_54C8`) y crea el
   dispositivo del DSP `CSAUDIO\ADSP&CTLR_VEN_8086&CTLR_DEV_54C8`, que es donde
   se instala `telithaudio`.
4. **Modo de prueba** (ver la advertencia de arriba):
   - Desactiva Secure Boot en la configuración UEFI.
   - En una consola de administrador, ejecuta `bcdedit /set testsigning on` y
     reinicia.

## Compilar

Necesitas Visual Studio 2022 con «Desarrollo para el escritorio con C++» y el
componente **Windows Driver Kit** (WDK 10.0.26100). Usa el MSBuild de
**64 bits**; el de 32 bits falla al validar los INF.

```powershell
$msb = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\amd64\MSBuild.exe"
& $msb drivers\telithaudio\SimpleAudioSample.sln /p:Configuration=Release /p:Platform=x64
& $msb drivers\rt5650\rt5650.vcxproj              /p:Configuration=Release /p:Platform=x64
& $msb drivers\telithfn\telithfn.vcxproj          /p:Configuration=Release /p:Platform=x64
```

Visual Studio firma los paquetes con un certificado de prueba (`WDKTestCert`).
Exporta ese certificado (`.cer`) e impórtalo en el Chromebook desde una consola
de administrador:

```powershell
certutil -addstore Root WDKTestCert.cer
certutil -addstore TrustedPublisher WDKTestCert.cer
```

Los paquetes quedan en:

| Driver | Carpeta |
|---|---|
| telithaudio | `drivers\telithaudio\x64\Release\package\` (`telithaudio.inf/.sys/.cat`, `sof-adl-n.ri`, `sof-adl-rt5650.ipc`) |
| rt5650 | `drivers\rt5650\x64\Release\rt5650\` |
| telithfn | `drivers\telithfn\x64\Release\telithfn\` |

## Instalar

Ejecuta todo desde una consola de **administrador** en el Chromebook.

1. **Códec:**
   ```powershell
   pnputil /add-driver rt5650.inf /install
   ```
2. **Audio:**
   ```powershell
   pnputil /add-driver telithaudio.inf /install
   ```
   Reinicia. Después deberían aparecer **Altavoces** y **Micrófono**.
   **Auriculares** y **Micrófono de auriculares** aparecen al enchufar algo en
   el jack.
3. **Teclas de la fila superior (opcional).** Genera la configuración y cópiala
   sobre la de CoolStar. Guarda antes una copia del archivo original.
   ```powershell
   python tools\keyboard\make_croskbsettings.py croskbsettings.bin
   copy C:\Windows\System32\drivers\croskbsettings.bin croskbsettings.bin.orig
   copy croskbsettings.bin C:\Windows\System32\drivers\croskbsettings.bin
   ```
   La nueva configuración se aplica al reiniciar.
4. **Tecla `fn` (opcional, requiere el paso 3):**
   ```powershell
   pnputil /add-driver telithfn.inf /install
   # telithfn debe quedar DEBAJO de croskeyboard (primero en la lista):
   Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Enum\ACPI\GOOG000A\0' `
       -Name UpperFilters -Type MultiString -Value @('telithfn','croskeyboard')
   ```
   Reinicia. Windows no siempre respeta el orden que indica el INF, por eso se
   fija a mano como arriba. Reinstalar el driver de teclado de CoolStar puede
   deshacerlo.

## Desinstalar

Busca el nombre publicado de cada paquete (`oemNN.inf`) con
`pnputil /enum-drivers` y quítalo con
`pnputil /delete-driver oemNN.inf /uninstall`.

> [!IMPORTANT]
> Antes de quitar `telithfn`, deja los filtros del teclado como estaban. Si no,
> el teclado no arrancará después de reiniciar:
> ```powershell
> Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Enum\ACPI\GOOG000A\0' `
>     -Name UpperFilters -Type MultiString -Value @('croskeyboard')
> ```

Para recuperar la configuración original del teclado, vuelve a copiar
`croskbsettings.bin.orig` y reinicia.

## Regenerar la topología del DSP

```powershell
python tools\tplg\tplg2ipc.py sof-adl-rt5650.tplg drivers\sofdsp\sof-adl-rt5650.ipc
```

El archivo `.tplg` viene de sof-bin (`sof-tplg/`). El conversor carga las
pipelines de altavoces, auriculares y DMIC, y las ejecuta todas en el núcleo 0
del DSP. También fija la pipeline de altavoces en un periodo de 1 ms, porque
con 10 ms el sonido se distorsiona después de cambiar de salida.

## Licencias

Cada carpeta lleva su propio archivo `LICENSE`. En resumen:

| Parte | Licencia |
|---|---|
| `drivers/telithaudio` | MS-PL (SimpleAudioSample de Microsoft). `telith_hw.c/.h` son GPL-2.0-only O BSD-3-Clause |
| `drivers/sofdsp`, `drivers/common`, `drivers/telithfn` | GPL-2.0-only O BSD-3-Clause. `adsp_bus.h` es BSD-3-Clause (CoolStar) |
| `drivers/rt5650` | GPL-2.0-only (derivado de `rt5645.c` de Linux, © Realtek) |
| `tools/tplg` | GPL-2.0-only |
| `tools/keyboard` | BSD-3-Clause |
| `firmware/sof-adl-n.ri` | Licencia del firmware SOF de Intel (`firmware/LICENCE.Intel`) |

## Contacto y reporte de errores

Para errores, preguntas o para contar si los drivers funcionan (o no) en tu
equipo, abre un [issue](https://github.com/augustocco/chromebook-cx1505cta-windows-drivers/issues). Indica tu versión de Windows, qué hiciste y
qué pasó. Las contribuciones por pull request son bienvenidas.

## Créditos

- [Sound Open Firmware](https://github.com/thesofproject) y el driver SOF de
  Linux, de Intel.
- El driver de códec `rt5645` de Linux, de Realtek.
- CoolStar, por `sklhdaudbus` y los drivers gratuitos de Chrome EC y teclado.
- MrChromebox, por el firmware UEFI.
- Microsoft, por los ejemplos de drivers de Windows.
