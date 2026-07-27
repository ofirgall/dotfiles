$desktop = [Environment]::GetFolderPath("Desktop")
$ws = New-Object -ComObject WScript.Shell

$komorebic = "C:\Program Files\komorebi\bin\komorebic.exe"
$yasb = "C:\Program Files\YASB\yasb.exe"
$kanata = "$env:USERPROFILE\.cargo\bin\kanata.exe"
$kanataConfig = "$env:USERPROFILE\.config\kanata\kanata.kbd"
$flowLauncher = "$env:LOCALAPPDATA\FlowLauncher\Flow.Launcher.exe"

$startCmd = @"
& '$komorebic' start --whkd
Start-Process '$yasb'
Start-Process '$kanata' -ArgumentList '-c', '$kanataConfig' -WindowStyle Hidden
Start-Process '$flowLauncher'
"@

$stopCmd = @"
& '$komorebic' stop --whkd
Stop-Process -Name yasb -Force -ErrorAction SilentlyContinue
Stop-Process -Name kanata -Force -ErrorAction SilentlyContinue
Stop-Process -Name Flow.Launcher -Force -ErrorAction SilentlyContinue
"@

$restartCmd = @"
& '$komorebic' stop --whkd
Stop-Process -Name yasb -Force -ErrorAction SilentlyContinue
Stop-Process -Name kanata -Force -ErrorAction SilentlyContinue
Stop-Process -Name Flow.Launcher -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
& '$komorebic' start --whkd
Start-Process '$yasb'
Start-Process '$kanata' -ArgumentList '-c', '$kanataConfig' -WindowStyle Hidden
Start-Process '$flowLauncher'
"@

$shortcuts = @(
    @{ Name = "Start Desktop"; Command = $startCmd; Icon = "C:\Program Files\komorebi\bin\komorebi.exe,0" }
    @{ Name = "Stop Desktop"; Command = $stopCmd; Icon = "C:\Program Files\komorebi\bin\komorebi.exe,0" }
    @{ Name = "Restart Desktop"; Command = $restartCmd; Icon = "C:\Program Files\komorebi\bin\komorebi.exe,0" }
)

foreach ($s in $shortcuts) {
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($s.Command)
    $encoded = [Convert]::ToBase64String($bytes)

    $path = "$desktop\$($s.Name).lnk"
    $link = $ws.CreateShortcut($path)
    $link.TargetPath = "powershell.exe"
    $link.Arguments = "-WindowStyle Hidden -EncodedCommand $encoded"
    if ($s.Icon) { $link.IconLocation = $s.Icon }
    $link.Save()
    Write-Host "Created: $path"
}
