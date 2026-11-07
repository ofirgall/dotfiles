#!/bin/bash
set -e

LOCALAPPDATA="${LOCALAPPDATA:-$HOME/AppData/Local}"
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

# Nerdwand Mono is patched locally with single-cell icons using Nordwand's
# nerd font script (it isn't attached to releases).
if ! ls "$FONT_DIR"/NerdwandMono-*.ttf &>/dev/null; then
    echo "Installing Nerdwand Mono..."
    NORDWAND_VERSION="1.4.0"
    # The 1.4.0 patch script crashes on glyphs added by the patcher, fixed later.
    NORDWAND_SCRIPT_VERSION="1.5.2"
    FONTFORGE_BIN="/c/Program Files/FontForgeBuilds/bin"

    if [ ! -x "$FONTFORGE_BIN/fontforge.exe" ]; then
        winget.exe install --id FontForge.FontForge -e --silent --accept-package-agreements --accept-source-agreements
    fi
    if ! command -v uv &>/dev/null; then
        winget.exe install --id astral-sh.uv -e --silent --accept-package-agreements --accept-source-agreements
    fi

    git -c advice.detachedHead=false clone -q --depth 1 --branch "$NORDWAND_SCRIPT_VERSION" https://github.com/tywr/Nordwand-Mono "$TMPDIR/nordwand"
    curl -fsSL -o "$TMPDIR/nordwand-ttf.zip" \
        "https://github.com/tywr/Nordwand-Mono/releases/download/$NORDWAND_VERSION/NordwandMono-TTF.zip"
    unzip -qo "$TMPDIR/nordwand-ttf.zip" -d "$TMPDIR/nordwand-ttf"
    mkdir -p "$TMPDIR/nordwand/fonts/ttf"
    find "$TMPDIR/nordwand-ttf" -name '*.ttf' -exec cp {} "$TMPDIR/nordwand/fonts/ttf/" \;

    # font-patcher has no .py extension, so Windows fontforge needs -lang=py
    # or it runs the file as a native fontforge script.
    # Don't set PYTHONHOME like fontforge.bat does: it breaks uv's python,
    # and fontforge.exe finds its bundled python without it.
    (
        cd "$TMPDIR/nordwand"
        sed -i 's/"-script",/"-lang=py", "-script",/' src/scripts/nerd_font.py
        grep -q '"-lang=py"' src/scripts/nerd_font.py
        PATH="$FONTFORGE_BIN:$HOME/AppData/Local/Microsoft/WinGet/Links:$PATH" uv run python -m scripts.nerd_font
    )
    cp "$TMPDIR"/nordwand/fonts/nerd-font/*.ttf "$FONT_DIR/"
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
