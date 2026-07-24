# notify-send compatible wrapper for Windows using BurntToast or balloon tips.
# Usage: windows_notify.ps1 [-u urgency] [-A action] TITLE BODY
# Supports -u (urgency: critical uses longer timeout) and -A (ignored).

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$remaining
)

$u = ""
$A = ""
$positional = @()
$i = 0
while ($i -lt $remaining.Count) {
    if ($remaining[$i] -eq "-u" -and ($i + 1) -lt $remaining.Count) {
        $u = $remaining[$i + 1]; $i += 2
    } elseif ($remaining[$i] -eq "-A" -and ($i + 1) -lt $remaining.Count) {
        $A = $remaining[$i + 1]; $i += 2
    } else {
        $positional += $remaining[$i]; $i++
    }
}
$remaining = $positional

$title = if ($remaining.Count -ge 1) { $remaining[0] } else { "Notification" }
$body  = if ($remaining.Count -ge 2) { $remaining[1..($remaining.Count-1)] -join ' ' } else { "" }
$timeout = if ($u -eq "critical") { 30 } else { 10 }

# Try BurntToast first (richer notifications with sound)
if (Get-Module -ListAvailable -Name BurntToast -ErrorAction SilentlyContinue) {
    $params = @{
        Text = @($title, $body)
    }
    if ($u -eq "critical") {
        $params.Sound = "Alarm"
    }
    New-BurntToastNotification @params
} else {
    # Fallback to balloon tip
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $iconType = if ($u -eq "critical") {
        [System.Windows.Forms.ToolTipIcon]::Error
    } else {
        [System.Windows.Forms.ToolTipIcon]::Info
    }
    $notify.ShowBalloonTip($timeout, $title, $body, $iconType)
}
