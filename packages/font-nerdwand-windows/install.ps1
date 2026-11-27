$ErrorActionPreference = 'Stop'
. "$env:DOTS_LIB/fonts.ps1"

# Nerdwand Mono is patched locally with single-cell icons using Nordwand's nerd font script
# (the patched font is not attached to releases).
$NordwandVersion = '1.4.0'
# The 1.4.0 patch script crashes on glyphs added by the patcher, fixed later.
$NordwandScriptVersion = '1.5.2'
$FontforgeBin = 'C:\Program Files\FontForgeBuilds\bin'

if (-not (Test-Path "$FontforgeBin\fontforge.exe")) { throw "fontforge not found in $FontforgeBin (package fontforge)" }

$tmp = New-TempDir
try {
    git -c advice.detachedHead=false clone -q --depth 1 --branch $NordwandScriptVersion https://github.com/tywr/Nordwand-Mono "$tmp\nordwand"
    if ($LASTEXITCODE -ne 0) { throw 'git clone failed' }
    Invoke-WebRequest -Uri "https://github.com/tywr/Nordwand-Mono/releases/download/$NordwandVersion/NordwandMono-TTF.zip" -OutFile "$tmp\nordwand-ttf.zip"
    Expand-Archive -Path "$tmp\nordwand-ttf.zip" -DestinationPath "$tmp\nordwand-ttf" -Force
    New-Item -ItemType Directory -Force -Path "$tmp\nordwand\fonts\ttf" | Out-Null
    Get-ChildItem "$tmp\nordwand-ttf" -Recurse -Filter '*.ttf' | Copy-Item -Destination "$tmp\nordwand\fonts\ttf"

    # font-patcher has no .py extension, so Windows fontforge needs -lang=py or it runs the file as a
    # native fontforge script. Don't set PYTHONHOME like fontforge.bat does: it breaks uv's python, and
    # fontforge.exe finds its bundled python without it.
    $script = "$tmp\nordwand\src\scripts\nerd_font.py"
    (Get-Content $script -Raw).Replace('"-script",', '"-lang=py", "-script",') | Set-Content $script -NoNewline
    if (-not (Select-String -Path $script -SimpleMatch '"-lang=py"' -Quiet)) { throw 'patching nerd_font.py failed' }

    Push-Location "$tmp\nordwand"
    try {
        $env:PATH = "$FontforgeBin;$env:LOCALAPPDATA\Microsoft\WinGet\Links;$env:PATH"
        uv run python -m scripts.nerd_font
        if ($LASTEXITCODE -ne 0) { throw 'nerd_font patch failed' }
    } finally { Pop-Location }

    Copy-FontsFrom "$tmp\nordwand\fonts\nerd-font"
    Register-UserFonts
} finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
