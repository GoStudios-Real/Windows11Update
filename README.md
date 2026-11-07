# Windows 11 Fast & Light Update

Makes Windows 11 genuinely faster, quicker, and lighter. Based on Microsoft's official Windows 11 specifications.

## Download

**[Download Windows11FastLight-Package.zip](https://github.com/GoStudios-Real/Windows11FastLightUpdate/releases/latest/download/Windows11FastLight-Package.zip)**

## What it does

12 optimizations applied:
1. Disables telemetry & data collection
2. Disables unnecessary startup apps (OneDrive, Skype, Cortana, Teams, Xbox, Phone Link, Widgets, BingWeather, Spotify, Discord, Steam)
3. Disables unnecessary services (DiagTrack, SysMain, WSearch, MapsBroker, and more)
4. Optimizes visual effects for speed
5. Disables tips, tricks & suggestions
6. Optimizes SSD drives (ReTrim + disable defrag)
7. Disables hibernation (frees disk space)
8. Cleans temporary files + Windows Update cache
9. Disables background apps
10. Optimizes network settings (TCP autotuning, RSS, chimney, ECN)
11. Optimizes search indexing
12. Optimizes memory management

## System Requirements

- Windows 11 (64-bit)
- TPM 2.0
- Secure Boot
- 4 GB RAM minimum
- 64 GB storage

## Install

### Option 1: Run the installer (recommended)
```powershell
# Run as Administrator
powershell -ExecutionPolicy Bypass -File "Windows11FastLight-Setup.ps1" -Silent
```

### Option 2: Trust cert first (for signed verification)
```powershell
# Trust the GoStudios cert (once per machine)
powershell -ExecutionPolicy Bypass -File "Trust-GoStudiosCert.ps1" -CerPath "GoStudios.cer"
# Then install
powershell -ExecutionPolicy Bypass -File "Windows11FastLight-Setup.ps1" -Silent
```

## Verify

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Windows11FastLight" | Select-Object DisplayName, DisplayVersion
Get-Service -Name DiagTrack, SysMain, WSearch | Select-Object Name, Status, StartType
```

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

## Based on

Microsoft's official Windows 11 page: https://www.microsoft.com/en-us/software-download/windows11

## License

MIT License - Copyright (c) 2026 GoStudios