# Nerdwand Mono and Lyth Mono NFM are patched locally with single-cell icons
# using Nordwand's nerd font script. Lyth's own Nerd Font release has double-width icons.
if [ "$DOTS_OS" = macos ]; then
	FONTS_DIR="$HOME/Library/Fonts"
else
	FONTS_DIR="$HOME/.local/share/fonts/dots/font-nerdwand-lyth"
fi
mkdir -p "$FONTS_DIR"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Pinned to the last upstream commit before 2026-11-09 (when this script was last known to work):
# later commits moved the build to otf and then restructured generate_font / scripts.nerd_font.
NORDWAND_REV=6a58cb2c1cbc6a502a7a3df5dd37743bcced6e1c
mkdir "$TMP_DIR/nordwand"
cd "$TMP_DIR/nordwand"
git init -q
git fetch -q --depth 1 https://github.com/tywr/Nordwand-Mono "$NORDWAND_REV"
git checkout -q FETCH_HEAD
uv sync -q

# Use the plain (slanted) k and x in italics instead of their alternate forms.
# `-i.bak` is the form both GNU and BSD sed accept.
sed -i.bak 's/^    default_italic = True$/    italic_only = True/' \
	src/glyphs/lowercase/k_2.py src/glyphs/lowercase/x_2.py
rm -f src/glyphs/lowercase/k_2.py.bak src/glyphs/lowercase/x_2.py.bak
uv run python -m generate_font --ttf --font-version 1.4.0 >/dev/null 2>&1
make build-nerd-font >/dev/null 2>&1
cp fonts/nerd-font/*.ttf "$FONTS_DIR/"

curl -fsSL -o "$TMP_DIR/lyth.zip" https://github.com/why-trv/LythMono/releases/download/v0.10.0/LythMono.zip
unzip -oq "$TMP_DIR/lyth.zip" -d "$TMP_DIR/lyth"
uv run python -m scripts.nerd_font -i "$TMP_DIR/lyth/LythMono/TTF" -o "$TMP_DIR/lyth-nfm" \
	--family "LythMono NFM" >/dev/null 2>&1
cp "$TMP_DIR"/lyth-nfm/*.ttf "$FONTS_DIR/"
touch "$FONTS_DIR/.nerdwand-plain-italic-k-x"
