# Shared helpers for Windows font packages (pwsh). Dot-source it from a package script:
#   . "$env:DOTS_LIB/fonts.ps1"
# TODO(dots-windows): replaced by the `font` provider (dots task 7.9: per-OS font dirs, HKCU registry values).

function Get-UserFontDir {
    $dir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    return $dir
}

# Register every ttf/otf in the user font dir for the current user (no admin needed).
function Register-UserFonts {
    $dir = Get-UserFontDir
    $reg = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
    Get-ChildItem $dir -File | Where-Object { $_.Extension -in '.ttf', '.otf' } | ForEach-Object {
        Set-ItemProperty -Path $reg -Name $_.BaseName -Value $_.FullName -ErrorAction SilentlyContinue
    }
}

# Copy every ttf/otf below $Path into the user font dir.
function Copy-FontsFrom {
    param([string]$Path)
    $dir = Get-UserFontDir
    Get-ChildItem $Path -Recurse -File | Where-Object { $_.Extension -in '.ttf', '.otf' } |
        ForEach-Object { Copy-Item $_.FullName $dir -Force -ErrorAction SilentlyContinue }
}

function New-TempDir {
    $t = Join-Path ([IO.Path]::GetTempPath()) ("dots-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $t | Out-Null
    return $t
}
