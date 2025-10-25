# File: Register-DarkModeScheduler.ps1
function Register-DarkModeScheduler {
    param(
        [string]$DarkTime = "19:00",
        [string]$LightTime = "07:00"
    )
    
    $scriptBlock = {
        function Set-SystemTheme {
            param([bool]$IsDark)
            $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            $appsValue = if ($IsDark) { 0 } else { 1 }
            $systemValue = if ($IsDark) { 0 } else { 1 }
            Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value $appsValue -Force
            Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value $systemValue -Force
            Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Sleep 2
            if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) {
                Start-Process explorer
            }
        }
        $currentHour = (Get-Date).Hour
        $isDark = $currentHour -ge 19 -or $currentHour -lt 7
        Set-SystemTheme -IsDark $isDark
        Add-Content -Path "$env:USERPROFILE\ThemeLog.txt" -Value "$(Get-Date): Set theme to $(if($isDark){'Dark'}else{'Light'})"
    }
    
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -Command `"$scriptBlock`""
    $triggerDark = New-ScheduledTaskTrigger -Daily -At $DarkTime
    $triggerLight = New-ScheduledTaskTrigger -Daily -At $LightTime
    
    Register-ScheduledTask -TaskName "AutoDarkMode_Dark" -Action $action -Trigger $triggerDark -Description "Auto-switch to dark mode" -Force
    Register-ScheduledTask -TaskName "AutoDarkMode_Light" -Action $action -Trigger $triggerLight -Description "Auto-switch to light mode" -Force
    
    Write-Host "✅ Scheduled tasks created!" -ForegroundColor Green
    Write-Host "🌙 Dark mode: $DarkTime" -ForegroundColor Cyan
    Write-Host "☀️ Light mode: $LightTime" -ForegroundColor Yellow
}

Register-DarkModeScheduler


Gimme a quick github page for this