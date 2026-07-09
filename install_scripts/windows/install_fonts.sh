#!/bin/bash
set -e

FONT_DIR="$LOCALAPPDATA/Microsoft/Windows/Fonts"
mkdir -p "$FONT_DIR"

FONTS=(
    "CascadiaCode"
    "UbuntuMono"
    "JetBrainsMono"
    "IosevkaTerm"
    "CommitMono"
    "0xProto"
    "Recursive"
)

NERD_FONTS_VERSION="v3.3.0"
NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

for font in "${FONTS[@]}"; do
    if ls "$FONT_DIR"/*"$font"* &>/dev/null; then
        echo "$font Nerd Font already installed"
        continue
    fi

    echo "Installing $font Nerd Font..."
    curl -fsSL -o "$TMPDIR/$font.zip" "$NERD_FONTS_URL/$font.zip"
    unzip -qo "$TMPDIR/$font.zip" -d "$TMPDIR/$font"

    find "$TMPDIR/$font" \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONT_DIR/" \;
    rm -rf "$TMPDIR/$font" "$TMPDIR/$font.zip"
done

# Maple Mono NF (separate release page)
if ! ls "$FONT_DIR"/*Maple* &>/dev/null; then
    echo "Installing Maple Mono NF..."
    MAPLE_VERSION="v7.0-beta36"
    curl -fsSL -o "$TMPDIR/MapleMono.zip" "https://github.com/subframe7536/maple-font/releases/download/$MAPLE_VERSION/MapleMono-NF.zip"
    unzip -qo "$TMPDIR/MapleMono.zip" -d "$TMPDIR/MapleMono"
    find "$TMPDIR/MapleMono" \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONT_DIR/" \;
fi

# Remove CaskaydiaCove italic variants (matching macOS)
rm -f "$FONT_DIR"/Caskaydia*Italic*

# Register fonts via PowerShell
powershell.exe -Command "
    \$fontDir = [Environment]::GetFolderPath('LocalApplicationData') + '\\Microsoft\\Windows\\Fonts'
    \$regPath = 'HKCU:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts'
    Get-ChildItem \$fontDir -Filter '*.ttf' | ForEach-Object {
        Set-ItemProperty -Path \$regPath -Name \$_.BaseName -Value \$_.FullName -ErrorAction SilentlyContinue
    }
    Get-ChildItem \$fontDir -Filter '*.otf' | ForEach-Object {
        Set-ItemProperty -Path \$regPath -Name \$_.BaseName -Value \$_.FullName -ErrorAction SilentlyContinue
    }
"

echo "Nerd Fonts installed"
