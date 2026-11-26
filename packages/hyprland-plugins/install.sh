# hypr-dots/install_plugins.sh minus its apt line (the apt package is a requirement) and with
# the waybar-vd clone over https.
hyprpm update
hyprpm -v add https://github.com/ofirgall/hyprland-virtual-desktops
hyprpm enable virtual-desktops

# FIXME: use native monocle layout when upgrading hyprland
hyprpm -v add https://github.com/ofirgall/hyprland-monocle
hyprpm enable monocle

hyprpm reload -n # Reload the plugins

dir="$HOME/.local/share/waybar-vd"
if [ -d "$dir/.git" ]; then git -C "$dir" pull --ff-only; else git clone https://github.com/ofirgall/waybar-vd.git "$dir"; fi
(cd "$dir" && ./build.sh)
