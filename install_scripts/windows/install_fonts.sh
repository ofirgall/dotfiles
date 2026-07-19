#!/bin/bash
set -e

FONT_DIR="$LOCALAPPDATA/Microsoft/Windows/Fonts"
mkdir -p "$FONT_DIR"

# Map: zip-name -> installed-file-pattern
declare -A FONTS
FONTS[CascadiaCode]="CaskaydiaCove"
FONTS[UbuntuMono]="UbuntuMono"
FONTS[JetBrainsMono]="JetBrainsMono"
FONTS[IosevkaTerm]="IosevkaTerm"
FONTS[CommitMono]="CommitMono"
FONTS[0xProto]="0xProto"
FONTS[Recursive]="RecMono"

NERD_FONTS_VERSION="v3.3.0"
NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

for zip_name in "${!FONTS[@]}"; do
    check_pattern="${FONTS[$zip_name]}"
    if ls "$FONT_DIR"/*"$check_pattern"* &>/dev/null; then
        echo "$zip_name Nerd Font already installed"
        continue
    fi

    echo "Installing $zip_name Nerd Font..."
    curl -fsSL -o "$TMPDIR/$zip_name.zip" "$NERD_FONTS_URL/$zip_name.zip"
    unzip -qo "$TMPDIR/$zip_name.zip" -d "$TMPDIR/$zip_name"

    find "$TMPDIR/$zip_name" \( -name "*.ttf" -o -name "*.otf" \) -print0 | while IFS= read -r -d '' f; do
        cp "$f" "$FONT_DIR/" 2>/dev/null || true
    done
    rm -rf "$TMPDIR/$zip_name" "$TMPDIR/$zip_name.zip"
done

# Maple Mono NF (separate release page)
if ! ls "$FONT_DIR"/*Maple* &>/dev/null; then
    echo "Installing Maple Mono NF..."
    MAPLE_VERSION="v7.0-beta36"
    curl -fsSL -o "$TMPDIR/MapleMono.zip" "https://github.com/subframe7536/maple-font/releases/download/$MAPLE_VERSION/MapleMono-NF.zip"
    unzip -qo "$TMPDIR/MapleMono.zip" -d "$TMPDIR/MapleMono"
    find "$TMPDIR/MapleMono" \( -name "*.ttf" -o -name "*.otf" \) -print0 | while IFS= read -r -d '' f; do
        cp "$f" "$FONT_DIR/" 2>/dev/null || true
    done
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
