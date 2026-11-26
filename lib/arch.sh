# Shared helpers: CPU architecture and OS names for installers. Source it from a package script:
#   source "$DOTS_LIB/arch.sh"
# Replaces the hardcoded x86_64/amd64 strings in the pre-dots installers.
# Needs $DOTS_ARCH (x86_64|aarch64) and $DOTS_OS (linux|macos), which dots always sets.

# dots_arch <go|zig|nerd|codelldb|bluetuith>: the architecture spelling that tool's releases use.
dots_arch() {
	local kind="${1:?usage: dots_arch <go|zig|nerd|codelldb|bluetuith>}"
	case "${DOTS_ARCH:-$(uname -m)}" in
	x86_64 | amd64) case "$kind" in
		go) echo amd64 ;;
		zig | nerd | bluetuith) echo x86_64 ;;
		codelldb) echo x64 ;;
		*) echo "dots_arch: unknown kind '$kind'" >&2; return 1 ;;
		esac ;;
	aarch64 | arm64) case "$kind" in
		go) echo arm64 ;;
		zig | nerd) echo aarch64 ;;
		codelldb | bluetuith) echo arm64 ;;
		*) echo "dots_arch: unknown kind '$kind'" >&2; return 1 ;;
		esac ;;
	*) echo "dots_arch: unsupported architecture '${DOTS_ARCH:-$(uname -m)}'" >&2; return 1 ;;
	esac
}

# dots_os_title: Linux or Darwin (the capitalised spelling release asset names use).
dots_os_title() {
	case "${DOTS_OS:-$(uname -s | tr '[:upper:]' '[:lower:]')}" in
	linux) echo Linux ;;
	macos | darwin) echo Darwin ;;
	*) echo "dots_os_title: unsupported OS '${DOTS_OS:-}'" >&2; return 1 ;;
	esac
}
