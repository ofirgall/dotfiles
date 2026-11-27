. "$env:DOTS_LIB/fonts.ps1"
$cfg = Import-PowerShellDataFile "$PSScriptRoot/fonts.psd1"
$dir = Get-UserFontDir
$patterns = @($cfg.Fonts.Values) + 'Maple'
foreach ($p in $patterns) {
    if (-not (Get-ChildItem $dir -File -Filter "*$p*" -ErrorAction SilentlyContinue)) { exit 1 }
}
exit 0
