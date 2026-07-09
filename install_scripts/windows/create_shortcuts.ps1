$desktop = [Environment]::GetFolderPath("Desktop")
$ws = New-Object -ComObject WScript.Shell

$shortcuts = @(
    @{
        Name = "Komorebi + WHKD"
        Target = "C:\Program Files\komorebi\bin\komorebic.exe"
        Arguments = "start --whkd"
        Icon = "C:\Program Files\komorebi\bin\komorebi.exe,0"
    },
    @{
        Name = "YASB"
        Target = "C:\Program Files\YASB\yasb.exe"
        Icon = "C:\Program Files\YASB\yasb.exe,0"
    },
    @{
        Name = "Kanata"
        Target = "$env:USERPROFILE\.cargo\bin\kanata.exe"
        Arguments = "-c $env:USERPROFILE\.config\kanata\kanata.kbd"
        Icon = "$env:USERPROFILE\.cargo\bin\kanata.exe,0"
    },
    @{
        Name = "winghostty"
        Target = "C:\Program Files\winghostty\winghostty.exe"
        Icon = "C:\Program Files\winghostty\winghostty.exe,0"
    }
)

foreach ($s in $shortcuts) {
    $path = "$desktop\$($s.Name).lnk"
    $link = $ws.CreateShortcut($path)
    $link.TargetPath = $s.Target
    if ($s.Arguments) { $link.Arguments = $s.Arguments }
    if ($s.Icon) { $link.IconLocation = $s.Icon }
    $link.Save()
    Write-Host "Created: $path"
}
