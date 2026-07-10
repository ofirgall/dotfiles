# Run this script as Administrator (right-click Terminal → Run as Admin)
# These settings require elevated privileges

# Disable Win+L lock screen (so whkd can use Win+L for tiling)
# You can still lock via Start menu → Lock or Ctrl+Alt+Del → Lock
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableLockWorkstation" -Value 1 -Type DWord
Write-Host "Disabled Win+L lock screen"

Write-Host "`nDone. Restart komorebi+whkd for changes to take effect."
