# ==========================================
# CREDENTIALS SETUP
# ==========================================
$CorrectUser = "admin"
$CorrectPass = "1234"

# ==========================================
# UI HELPER FUNCTIONS
# ==========================================
function Get-Width { if ($Host.UI.RawUI.WindowSize.Width) { return $Host.UI.RawUI.WindowSize.Width }; return 80 }
function Write-Center ([string]$Txt, [string]$Col = "White") {
    $P = [Math]::Max(0, [Math]::Floor(((Get-Width) - $Txt.Length) / 2))
    Write-Host (" " * $P + $Txt) -ForegroundColor $Col
}

function Show-Login {
    Clear-Host
    Write-Center ("=" * 50) "Cyan"; Write-Center "SYSTEM AUTHORIZATION REQUIRED" "Cyan"; Write-Center ("=" * 50) "Cyan"; Write-Host ""
    Write-Host " Enter Username: " -NoNewline; $U = Read-Host
    Write-Host " Enter Password: " -NoNewline; $P = ""; while ($true) {
        $K = [Console]::ReadKey($true)
        if ($K.Key -eq "Enter") { Write-Host ""; break }
        elseif ($K.Key -eq "Backspace") { if ($P.Length -gt 0) { $P = $P.Substring(0, $P.Length - 1); Write-Host "`b `b" -NoNewline } }
        else { $P += $K.KeyChar; Write-Host "*" -NoNewline }
    }
    if ($U -eq $CorrectUser -and $P -eq $CorrectPass) { Write-Center "[+] Access Granted. Loading..." "Green"; Start-Sleep -Seconds 1; return $true }
    else { Write-Center "[-] Invalid Credentials!" "Red"; Start-Sleep -Seconds 2; return $false }
}

function Show-Menu {
    Clear-Host
    Write-Center ("=" * 60) "Cyan"; Write-Center "  Ultimate Pro-Level Optimization  " "Cyan"; Write-Center ("=" * 60) "Cyan"; Write-Host ""
    Write-Center "--- SYSTEM MAINTENANCE ---" "Yellow"; Write-Center "[1] Clean Deep System Cache & Temp Files"; Write-Host ""
    Write-Center "--- PERFORMANCE TWEAKS ---" "Yellow"; Write-Center "[2] Optimize Windows Visual Settings"; Write-Host ""
    Write-Center "--- PRIVACY & SECURITY ---" "Yellow"; Write-Center "[3] Completely Disable Telemetry"; Write-Host ""
    Write-Center ("-" * 40) "Cyan"; Write-Center "[Q] Safe Quit Program"; Write-Center ("-" * 40) "Cyan"; Write-Host ""
}

function Show-DiskSpace {
    Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, VolumeName, 
        @{N="Size(GB)";E={[Math]::Round($_.Size/1GB,1)}}, @{N="Free(GB)";E={[Math]::Round($_.FreeSpace/1GB,1)}} | Format-Table | Out-String | ForEach-Object { Write-Center $_.TrimEnd() "Cyan" }
}

# ==========================================
# MAIN LOOP
# ==========================================
while (-not (Show-Login)) {}

while ($true) {
    while ([Console]::KeyAvailable) { [Console]::ReadKey($true) | Out-Null }
    Show-Menu
    Write-Host (" " * [Math]::Max(0, [Math]::Floor(((Get-Width) - 30) / 2))) + "Select a menu item: " -NoNewline
    $choice = [Console]::ReadKey($true).KeyChar

    switch ($choice) {
        '1' {
            Clear-Host; Write-Center "[+] Starting Deep System Cleanup..." "Yellow"; Write-Host ""
            Write-Center "--- DISK SPACE BEFORE ---" "Cyan"; Show-DiskSpace

            $Targets = @(
                "$env:TEMP\*", "C:\Windows\Temp\*", "$env:LOCALAPPDATA\Temp\*", "C:\Windows\Prefetch\*", 
                "C:\Windows\Logs\*", "C:\Windows\System32\LogFiles\*", "C:\Windows\SoftwareDistribution\Download\*",
                "C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache\*", "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\*",
                "$env:APPDATA\Microsoft\Windows\Recent\*", "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db",
                "$env:LOCALAPPDATA\IconCache.db", "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db",
                "$env:LOCALAPPDATA\Microsoft\DirectX\Cache\*", "$env:LOCALAPPDATA\D3DSCache\*", "C:\Windows\Installer\*.tmp",
                "C:\Windows\*.dmp", "C:\Windows\Minidump\*", "C:\Windows\MEMORY.DMP", 
                "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*", "$env:LOCALAPPDATA\Microsoft\Windows\INetCookies\*"
            )
            
            Write-Host "Purging temporary system and cache files..." -ForegroundColor Gray
            foreach ($T in $Targets) { Remove-Item -Path $T -Recurse -Force -ErrorAction SilentlyContinue }

            Write-Host "Stopping browsers and clearing browser cache..." -ForegroundColor Gray
            "chrome", "msedge", "firefox" | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
            Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
            
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            Clear-RecycleBin -Force -Confirm:$false -ErrorAction SilentlyContinue

            Write-Host "Configuring and running advanced cleanmgr..." -ForegroundColor Gray
            $Keys = @("Active Setup Temp Folders", "Downloaded Program Files", "Internet Cache Files", "Offline Pages Files", "Old ChkDsk Files", "Previous Installations", "Recycle Bin", "Service Pack Cleanup", "Setup Log Files", "System error memory dump files", "System error minidump files", "Temporary Files", "Temporary Setup Files", "Thumbnail Cache", "Update Cleanup", "Upgrade Discarded Files", "Windows Error Reporting Archive Files", "Windows Error Reporting Queue Files", "Windows Upgrade Log Files")
            foreach ($K in $Keys) {
                $R = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$K"
                if (Test-Path $R) { Set-ItemProperty -Path $R -Name "StateFlags0001" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue }
            }
            cmd.exe /c "cleanmgr /sagerun:1" | Out-Null

            Write-Host ""; Write-Center "[+] Deep cleanup finished successfully!" "Green"; Write-Host ""
            Write-Center "--- DISK SPACE AFTER ---" "Cyan"; Show-DiskSpace
            Write-Host "Press Enter to return to the dashboard..." -NoNewline; Read-Host
        }
        '2' {
            Clear-Host; Write-Center "[+] Visual optimization in progress..." "Yellow"; Write-Host ""
            $P = @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")
            foreach ($Path in $P) { if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null } }
            Set-ItemProperty -Path $P[0] -Name "EnableTransparency" -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $P[1] -Name "TaskbarAcrylicOpacity" -Value 2 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $P[1] -Name "UseOLEDTaskbarTransparency" -Value 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3
            $Adv = "HKCU:\Software\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Set-ItemProperty $Adv -Name "IconsOnly" -Value 0
            Set-ItemProperty $Adv -Name "ListviewAlphaSelect" -Value 1
            Set-ItemProperty $Adv -Name "ListviewShadow" -Value 0
            $Desk = "HKCU:\Control Panel\Desktop"
            Set-ItemProperty $Desk -Name "DragFullWindows" -Value 1
            Set-ItemProperty $Desk -Name "FontSmoothing" -Value 2
            Set-ItemProperty $Desk -Name "FontSmoothingType" -Value 2
            Set-ItemProperty $Desk -Name "UserPreferencesMask" -Value ([byte[]](0x90, 0x12, 0x01, 0x80, 0x10, 0x00, 0x00, 0x00))
            Set-ItemProperty "$Desk\WindowMetrics" -Name "MinAnimate" -Value 0
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow" -Name "DefaultValue" -Value 0
            $API = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern bool SystemParametersInfo(uint a, uint b, IntPtr c, uint d);' -Name "W32" -PassThru
            $API::SystemParametersInfo(0x002A, 0, [IntPtr]::Zero, 3)
            Stop-Process -Name explorer -Force
            Write-Center "[+] All interface tweaks applied successfully!" "Green"; Write-Host ""
            Write-Host "Press Enter to return to the dashboard..." -NoNewline; Read-Host
        }
        '5' {
            Clear-Host; Write-Center "[+] Disabling Windows telemetry systems..." "Yellow"; Write-Host ""
            $Tweaks = @(
                @{ P = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; N = "Enabled"; V = 0 },
                @{ P = "HKLM:\SOFTWARE\Microsoft\SQMClient\Windows"; N = "CEIPEnable"; V = 0 },
                @{ P = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; N = "EnableActivityFeed"; V = 0 },
                @{ P = "HKCU:\Software\Microsoft\Clipboard"; N = "EnableClipboardHistory"; V = 0 },
                @{ P = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting"; N = "Disabled"; V = 1 },
                @{ P = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"; N = "GlobalUserDisabled"; V = 1 },
                @{ P = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; N = "PersonalizationReportingEnabled"; V = 0 },
                @{ P = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; N = "CortanaConsent"; V = 0 }
            )
            foreach ($T in $Tweaks) {
                if (-not (Test-Path $T.P)) { New-Item -Path $T.P -Force | Out-Null }
                Set-ItemProperty -Path $T.P -Name $T.N -Value $T.V -Type DWord -Force -ErrorAction SilentlyContinue
            }
            "DiagTrack", "dmwappushservice" | ForEach-Object {
                Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
                Set-Service -Name $_ -StartupType Disabled -ErrorAction SilentlyContinue
            }
            Write-Center "[+] Telemetry collection services completely disabled!" "Green"; Write-Host ""
            Write-Host "Press Enter to return to the dashboard..." -NoNewline; Read-Host
        }
        'q' { Clear-Host; Write-Host ""; Write-Center "[+] Shutting down utility engine..." "Red"; Start-Sleep -Seconds 1; Clear-Host; break }
        default { continue }
    }
}
