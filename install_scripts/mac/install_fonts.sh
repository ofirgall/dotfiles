#!/bin/bash
set -e

eval "$(/opt/homebrew/bin/brew shellenv)"

brew install --cask \
    font-caskaydia-cove-nerd-font \
    font-ubuntu-mono-nerd-font \
    font-jetbrains-mono-nerd-font \
    font-iosevka-term-nerd-font \
    font-commit-mono-nerd-font \
    font-0xproto-nerd-font \
    font-recursive-mono-nerd-font \
    font-maple-mono-nf \
    font-nordwand-mono \
    font-paper-mono

# Remove Caskaydia custom italic fonts
rm -f ~/Library/Fonts/Caskaydia*Italic*

FONTS_DIR=~/Library/Fonts
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Cilantro Code Mono (not on Homebrew)
if ! ls "$FONTS_DIR"/CilantroCodeMono-*.ttf &>/dev/null; then
    for style in Regular Bold; do
        curl -fsSL -o "$FONTS_DIR/CilantroCodeMono-$style.ttf" \
            "https://github.com/DraftingDreamer/FontCilantroCode/releases/download/v1.000/CilantroCodeMono-$style.ttf"
    done
fi

# Nerdwand Mono and Lyth Mono NFM are patched locally with single-cell icons
# using Nordwand's nerd font script. Lyth's own Nerd Font release has double-width icons.
if ! ls "$FONTS_DIR"/NerdwandMono-*.ttf "$FONTS_DIR"/LythMonoNFM-*.ttf &>/dev/null; then
    brew install fontforge uv
    git clone -q --depth 1 https://github.com/tywr/Nordwand-Mono "$TMP_DIR/nordwand"
    cd "$TMP_DIR/nordwand"
    uv sync -q

    mkdir -p fonts/ttf
    curl -fsSL -o "$TMP_DIR/nordwand-ttf.zip" \
        https://github.com/tywr/Nordwand-Mono/releases/download/1.4.0/NordwandMono-TTF.zip
    unzip -oq "$TMP_DIR/nordwand-ttf.zip" -d "$TMP_DIR/nordwand-ttf"
    find "$TMP_DIR/nordwand-ttf" -name '*.ttf' -exec cp {} fonts/ttf/ \;
    make build-nerd-font >/dev/null 2>&1
    cp fonts/nerd-font/*.ttf "$FONTS_DIR/"

    curl -fsSL -o "$TMP_DIR/lyth.zip" \
        https://github.com/why-trv/LythMono/releases/download/v0.10.0/LythMono.zip
    unzip -oq "$TMP_DIR/lyth.zip" -d "$TMP_DIR/lyth"
    uv run python -m scripts.nerd_font -i "$TMP_DIR/lyth/LythMono/TTF" -o "$TMP_DIR/lyth-nfm" \
        --family "LythMono NFM" >/dev/null 2>&1
    cp "$TMP_DIR"/lyth-nfm/*.ttf "$FONTS_DIR/"
    cd - >/dev/null
fi
