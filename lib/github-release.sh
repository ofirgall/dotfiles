# Shared helpers: GitHub release assets. Source it from a package script:
#   source "$DOTS_LIB/github-release.sh"
# Replaces download_latest_release() from the pre-dots installer helpers. Nothing is eval'd.
# Uses $GITHUB_TOKEN when set (avoids API rate limits).

# gh_release_url <owner/repo> <asset-regex> [tag]
# Print the download URL of the first asset whose URL matches the extended regex (latest
# release unless a tag is given). Fails loudly when nothing matches.
gh_release_url() {
	local repo="${1:?usage: gh_release_url <owner/repo> <asset-regex> [tag]}"
	local re="${2:?usage: gh_release_url <owner/repo> <asset-regex> [tag]}"
	local tag="${3:-}"
	local api="https://api.github.com/repos/$repo/releases/latest"
	[ -z "$tag" ] || api="https://api.github.com/repos/$repo/releases/tags/$tag"
	local auth=()
	[ -z "${GITHUB_TOKEN:-}" ] || auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
	local body
	body=$(curl -fsSL "${auth[@]+"${auth[@]}"}" -H 'Accept: application/vnd.github+json' "$api") || {
		echo "gh_release_url: cannot fetch $api" >&2
		return 1
	}
	local url
	url=$(printf '%s\n' "$body" | grep -Eo '"browser_download_url": *"[^"]+"' | sed -E 's/^[^:]*: *"//; s/"$//' | grep -E -- "$re" | head -n1 || true)
	if [ -z "$url" ]; then
		echo "gh_release_url: no asset in $repo${tag:+ ($tag)} matches /$re/. Assets:" >&2
		printf '%s\n' "$body" | grep -Eo '"browser_download_url": *"[^"]+"' >&2 || true
		return 1
	fi
	printf '%s\n' "$url"
}

# gh_release_download <owner/repo> <asset-regex> <dest-file> [tag]
gh_release_download() {
	local url
	url=$(gh_release_url "$1" "$2" "${4:-}") || return 1
	echo "Downloading $url" >&2
	curl -fsSL -o "${3:?dest file required}" "$url"
}
