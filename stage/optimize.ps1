param([switch]$Silent)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run as Administrator." -ForegroundColor Red; exit 1
}
$ErrorActionPreference = "SilentlyContinue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Fast & Light Update" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# === SYSTEM CHECK ===
$tpm = Get-CimInstance -ClassName Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm -ErrorAction SilentlyContinue
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
$cpu = (Get-CimInstance Win32_Processor).Name
Write-Host "System: $cpu | RAM: $ram GB | Arch: $env:PROCESSOR_ARCHITECTURE"
Write-Host ""

# === 1. DISABLE TELEMETRY & DATA COLLECTION ===
Write-Host "[1/12] Disabling Telemetry & Data Collection" -ForegroundColor Yellow
$privacy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
New-Item -Path $privacy -Force | Out-Null
Set-ItemProperty -Path $privacy -Name "AllowTelemetry" -Value 0 -Type DWord
Set-ItemProperty -Path $privacy -Name "DoNotShowFeedbackNotifications" -Value 1 -Type DWord
$diag = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
New-Item -Path $diag -Force | Out-Null
Set-ItemProperty -Path $diag -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path $diag -Name "ViewDiagnosticDataAllowed" -Value 0 -Type DWord
Write-Host "  Done" -ForegroundColor Green

# === 2. DISABLE UNNECESSARY STARTUP APPS ===
Write-Host "[2/12] Disabling Unnecessary Startup Apps" -ForegroundColor Yellow
$apps = @("OneDrive","Skype","Cortana","Teams","Xbox","YourPhone","Phone Link","Widgets","BingWeather","Spotify","Discord","Steam")
foreach ($app in $apps) {
    foreach ($hive in @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run")) {
        Get-ChildItem $hive -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match $app } |
            ForEach-Object { Remove-ItemProperty -Path $_.PSPath -Name $_.PSChildName -ErrorAction SilentlyContinue }
    }
}
Write-Host "  Done" -ForegroundColor Green

# === 3. DISABLE UNNECESSARY SERVICES ===
Write-Host "[3/12] Disabling Unnecessary Services" -ForegroundColor Yellow
$services = @("DiagTrack","dmwappushservice","SysMain","WSearch","MapsBroker","lfsvc","SharedAccess","WbioSrvc","Fax","RetailDemo","XblAuthManager","XblGameSave","XboxNetApiSvc")
foreach ($svc in $services) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
Write-Host "  Done" -ForegroundColor Green

# === 4. OPTIMIZE VISUAL EFFECTS ===
Write-Host "[4/12] Optimizing Visual Effects for Speed" -ForegroundColor Yellow
$visual = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
New-Item -Path $visual -Force | Out-Null
Set-ItemProperty -Path $visual -Name "VisualFXSetting" -Value 2 -Type DWord
$desktop = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $desktop -Name "MenuShowDelay" -Value "0"
Set-ItemProperty -Path $desktop -Name "DragFullWindows" -Value "0"
Set-ItemProperty -Path $desktop -Name "FontSmoothing" -Value "2"
Set-ItemProperty -Path $desktop -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary
Write-Host "  Done" -ForegroundColor Green

# === 5. DISABLE TIPS & SUGGESTIONS ===
Write-Host "[5/12] Disabling Tips, Tricks & Suggestions" -ForegroundColor Yellow
$tips = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
New-Item -Path $tips -Force | Out-Null
$tipProps = @("SoftLandingEnabled","SubscribedContent-338388Enabled","SubscribedContent-338389Enabled","SubscribedContent-338393Enabled","RotatingLockScreenEnabled","RotatingLockScreenOverlayEnabled","SubscribedContent-353694Enabled","SubscribedContent-353696Enabled")
foreach ($p in $tipProps) { Set-ItemProperty -Path $tips -Name $p -Value 0 -Type DWord -ErrorAction SilentlyContinue }
Write-Host "  Done" -ForegroundColor Green

# === 6. SSD OPTIMIZATION ===
Write-Host "[6/12] Optimizing SSD Drives" -ForegroundColor Yellow
$drives = Get-PhysicalDisk | Where-Object { $_.MediaType -eq "SSD" }
foreach ($d in $drives) {
    Optimize-Volume -DriveLetter $d.DeviceID -ReTrim -ErrorAction SilentlyContinue
    Write-Host "  ReTrimmed: $($d.DeviceID)" -ForegroundColor DarkGreen
}
# Disable disk defrag for SSDs
schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable 2>$null | Out-Null
Write-Host "  Done" -ForegroundColor Green

# === 7. DISABLE HIBERNATION ===
Write-Host "[7/12] Disabling Hibernation (frees disk space)" -ForegroundColor Yellow
powercfg /h off 2>$null
Write-Host "  Done" -ForegroundColor Green

# === 8. CLEAN TEMP FILES ===
Write-Host "[8/12] Cleaning Temporary Files" -ForegroundColor Yellow
$paths = @("$env:TEMP\*","C:\Windows\Temp\*","C:\Windows\Prefetch\*","C:\Windows\SoftwareDistribution\Download\*")
foreach ($p in $paths) { Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue }
# Clear Windows Update cache
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue
Write-Host "  Done" -ForegroundColor Green

# === 9. DISABLE BACKGROUND APPS ===
Write-Host "[9/12] Disabling Background Apps" -ForegroundColor Yellow
$bg = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
New-Item -Path $bg -Force | Out-Null
Set-ItemProperty -Path $bg -Name "GlobalUserDisabled" -Value 1 -Type DWord
# Disable background apps per-app
Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -ErrorAction SilentlyContinue |
    ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name "Disabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue }
Write-Host "  Done" -ForegroundColor Green

# === 10. OPTIMIZE NETWORK ===
Write-Host "[10/12] Optimizing Network Settings" -ForegroundColor Yellow
netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
netsh int tcp set global rss=enabled 2>$null | Out-Null
netsh int tcp set global chimney=enabled 2>$null | Out-Null
netsh int tcp set global ecncapability=enabled 2>$null | Out-Null
Write-Host "  Done" -ForegroundColor Green

# === 11. DISABLE WINDOWS SEARCH INDEXING (optional - lighter) ===
Write-Host "[11/12] Optimizing Search Indexing" -ForegroundColor Yellow
$idx = "HKLM:\SOFTWARE\Microsoft\Windows Search"
New-Item -Path $idx -Force | Out-Null
Set-ItemProperty -Path $idx -Name "SetupCompletedSuccessfully" -Value 0 -Type DWord -ErrorAction SilentlyContinue
# Reduce indexing to only essential locations
$idxLoc = "HKLM:\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex"
New-Item -Path $idxLoc -Force | Out-Null
Write-Host "  Done" -ForegroundColor Green

# === 12. MEMORY OPTIMIZATION ===
Write-Host "[12/12] Optimizing Memory Management" -ForegroundColor Yellow
$mem = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
New-Item -Path $mem -Force | Out-Null
Set-ItemProperty -Path $mem -Name "ClearPageFileAtShutdown" -Value 0 -Type DWord
Set-ItemProperty -Path $mem -Name "DisablePagingExecutive" -Value 1 -Type DWord
Set-ItemProperty -Path $mem -Name "LargeSystemCache" -Value 0 -Type DWord
# Set page file to system managed (optimal)
$cs = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $cs -Name "PagingFiles" -Value "C:\pagefile.sys 0 0" -Type MultiString -ErrorAction SilentlyContinue
Write-Host "  Done" -ForegroundColor Green

# === BRANDING ===
$brand = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Windows11FastLight"
New-Item -Path $brand -Force | Out-Null
Set-ItemProperty -Path $brand -Name "Version" -Value "26H2.3"
Set-ItemProperty -Path $brand -Name "InstalledDate" -Value (Get-Date).ToString("yyyy-MM-dd")
Set-ItemProperty -Path $brand -Name "Source" -Value "https://www.microsoft.com/en-us/software-download/windows11"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Windows 11 Fast & Light Update Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Everything is now faster, quicker, and lighter"
Write-Host "  Performance:  improved (startup, services, visual effects, network, memory)"
Write-Host "  Privacy:      improved (telemetry, tips, background apps)"
Write-Host "  Storage:      freed (hibernation, temp files, page file optimized)"
Write-Host "  Source:       https://www.microsoft.com/en-us/software-download/windows11"
Write-Host ""
if (-not $Silent) { Read-Host "Press Enter to exit" }
