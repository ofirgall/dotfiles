$ErrorActionPreference = 'Stop'
. "$env:DOTS_LIB/fonts.ps1"
$cfg = Import-PowerShellDataFile "$PSScriptRoot/fonts.psd1"
$dir = Get-UserFontDir
$tmp = New-TempDir
try {
    foreach ($zip in $cfg.Fonts.Keys) {
        $pattern = $cfg.Fonts[$zip]
        if (Get-ChildItem $dir -File -Filter "*$pattern*" -ErrorAction SilentlyContinue) {
            Write-Host "$zip Nerd Font already installed"
            continue
        }
        Write-Host "Installing $zip Nerd Font..."
        $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/$($cfg.NerdFontsVersion)/$zip.zip"
        Invoke-WebRequest -Uri $url -OutFile "$tmp\$zip.zip"
        Expand-Archive -Path "$tmp\$zip.zip" -DestinationPath "$tmp\$zip" -Force
        Copy-FontsFrom "$tmp\$zip"
    }

    # Maple Mono NF (its own release page)
    if (-not (Get-ChildItem $dir -File -Filter '*Maple*' -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing Maple Mono NF...'
        $url = "https://github.com/subframe7536/maple-font/releases/download/$($cfg.MapleVersion)/MapleMono-NF.zip"
        Invoke-WebRequest -Uri $url -OutFile "$tmp\MapleMono.zip"
        Expand-Archive -Path "$tmp\MapleMono.zip" -DestinationPath "$tmp\MapleMono" -Force
        Copy-FontsFrom "$tmp\MapleMono"
    }

    # Remove CaskaydiaCove italic variants (matching macOS)
    Get-ChildItem $dir -File -Filter 'Caskaydia*Italic*' | Remove-Item -Force

    Register-UserFonts
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
