# Windows 11 Update

**Makes Windows 11 genuinely faster, quicker and lighter.** A free, open optimization package with 12 reversible changes, delivered as one small signed update.

[![Latest version](https://img.shields.io/badge/version-26H2.3-0067c0)](https://github.com/GoStudios-Real/Windows11Update/releases/latest)
[![Package](https://img.shields.io/badge/package-~11%20KB-0f7b3f)](https://github.com/GoStudios-Real/Windows11Update/releases/latest/download/Windows11FastLight-Package.zip)
[![License: MIT](https://img.shields.io/badge/license-MIT-555555)](LICENSE)

**[Download the latest release](https://github.com/GoStudios-Real/Windows11Update/releases/latest/download/Windows11FastLight-Package.zip)** · **[Website](https://gostudios-real.github.io/Windows11Update/)**

---

## What it does

Twelve optimizations applied in one pass:

| # | Optimization | Effect |
|---|--------------|--------|
| 1 | Disable telemetry & data collection | Privacy, less background upload |
| 2 | Disable unnecessary startup apps | OneDrive, Skype, Cortana, Teams, Xbox, Phone Link, Widgets, BingWeather, Spotify, Discord, Steam |
| 3 | Disable unnecessary services | DiagTrack, SysMain, WSearch, MapsBroker and more (13 total) |
| 4 | Optimize visual effects | Performance mode for a snappier UI |
| 5 | Disable tips, tricks & suggestions | No more content suggestions |
| 6 | Optimize SSD drives | ReTrim on SSDs, scheduled defrag disabled |
| 7 | Disable hibernation | Frees disk space equal to your RAM |
| 8 | Clean temporary files | Temp files and Windows Update cache |
| 9 | Disable background apps | Packaged apps stop running when idle |
| 10 | Optimize network | TCP autotuning, RSS, chimney offload, ECN |
| 11 | Optimize search indexing | Index essential locations only |
| 12 | Optimize memory management | Paging executive off, tuned page file |

All changes are reversible. No system files are deleted or modified.

## Versions

| Version | KB | Status | Notes |
|---------|----|--------|-------|
| **26H2.3** | KB5000007 | **Latest** | Full 12-optimization set, signed installer, Undo guide |
| 26H2.2 | KB5000006 | Superseded | Memory/page-file tuning, telemetry policy 0, visual effects |
| 26H2.1 | KB5000005 | Superseded | Initial public build, basic service + telemetry changes |
| 26H2.4 | — | Planned | Profile presets, offline rollback snapshot, scheduled maintenance |

Every release is cumulative — installing the latest includes everything from earlier versions.

## System requirements

- Windows 11, 64-bit
- Administrator PowerShell window
- ~11 KB of disk space for the package
- No reboot required

## Install

### Option 1 — Direct install (recommended)

Run in an **elevated** PowerShell after extracting the release ZIP:

```powershell
powershell -ExecutionPolicy Bypass -File "Windows11FastLight-Setup.ps1" -Silent
```

### Option 2 — Download and install in one block

```powershell
Invoke-WebRequest -Uri "https://github.com/GoStudios-Real/Windows11Update/releases/latest/download/Windows11FastLight-Package.zip" -OutFile "C:\temp\update.zip"
Expand-Archive "C:\temp\update.zip" -DestinationPath "C:\temp\update" -Force
powershell -ExecutionPolicy Bypass -File "C:\temp\update\Windows11FastLight-Setup.ps1" -Silent
```

### Option 3 — Trust the certificate first (signed verification)

```powershell
# Trust the GoStudios certificate once per machine
powershell -ExecutionPolicy Bypass -File "Trust-GoStudiosCert.ps1" -CerPath "GoStudios.cer"

# Confirm the signature
Get-AuthenticodeSignature ".\Windows11FastLight-Setup.ps1" | Select-Object Status, SignerCertificate

# Then install
powershell -ExecutionPolicy Bypass -File "Windows11FastLight-Setup.ps1" -Silent
```

## Verify

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Windows11FastLight" |
  Select-Object DisplayName, DisplayVersion

Get-Service -Name DiagTrack, SysMain, WSearch |
  Select-Object Name, Status, StartType
```

`DisplayVersion` should read **26H2.3**.

## Undo

```powershell
# Re-enable services
Set-Service -Name SysMain -StartupType Automatic
Set-Service -Name WSearch -StartupType Automatic

# Re-enable hibernation
powercfg /h on

# Re-enable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 1
```

## FAQ

**Is it safe?** Yes — every change is a registry value or a service start type, and all of them are reversible. No system files are removed.

**Will it break Windows Update?** No. Windows Update services stay enabled; only unnecessary background services are stopped.

**Can I undo it?** Yes, see [Undo](#undo).

**Does it work on Windows 10?** It targets Windows 11. Some changes may work on Windows 10 but are untested.

**Is this from Microsoft?** No. This is a community project by GoStudios, built on Microsoft's documented Windows 11 settings. It is not affiliated with or endorsed by Microsoft.

## Based on

Microsoft's official Windows 11 page: <https://www.microsoft.com/en-us/software-download/windows11>

## License

MIT License — Copyright (c) 2026 GoStudios. Windows and Windows 11 are trademarks of Microsoft Corporation.
