# asdf shims per repo: inside a git repo with a .tool-versions, put asdf's shims
# first on PATH (and drift's atlas binary ahead of them); outside, take them off.
# Runs on every cd (chpwd hook) and once at startup (post_init.zsh).

autoload -Uz add-zsh-hook
zmodload -F zsh/stat b:zstat

# ensure-atlas.sh results, keyed by "<repo root>:<.tool-versions mtime>" so a
# version bump (which rewrites .tool-versions) re-resolves it.
typeset -gA _asdf_atlas_dir_cache
# ASDF_<TOOL>_VERSION vars exported as fallbacks for the current repo.
typeset -ga _asdf_system_fallbacks

_asdf_update_path_for_repo() {
	local asdf_shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
	local repo_root var tool

	path=("${(@)path:#$asdf_shims}")

	# Drop the fallbacks set for the previous repo.
	for var in $_asdf_system_fallbacks; do unset $var; done
	_asdf_system_fallbacks=()

	local d=$PWD
	while [[ $d != / ]]; do
		[[ -e $d/.git ]] && { repo_root=$d; break }
		d=${d:h}
	done

	if [[ -n "$repo_root" && -f "$repo_root/.tool-versions" ]]; then
		path=("$asdf_shims" $path)

		# A pinned tool that isn't installed makes its shim fail outright, which
		# silently breaks anything running it (e.g. herdr's agent hooks need
		# python3). Fall back to the system version for just those tools.
		for tool in ${(f)"$(asdf current 2>/dev/null | awk 'NR > 1 && $4 == "false" { print $1 }')"}; do
			var="ASDF_${${tool:u}//-/_}_VERSION"
			export $var=system
			_asdf_system_fallbacks+=($var)
		done

		# Atlas is excluded from asdf (fragile plugin) and resolved via ensure-atlas.sh.
		# That takes ~160ms, so it runs once per repo, not on every cd.
		local ensure_atlas="$repo_root/IaC/local-dev/scripts/ensure-atlas.sh"
		if [[ -x "$ensure_atlas" ]]; then
			local -a mtime
			zstat -A mtime +mtime "$repo_root/.tool-versions" 2>/dev/null
			local key="$repo_root:${mtime[1]}"
			local atlas_bin_dir=${_asdf_atlas_dir_cache[$key]}
			if [[ -z "$atlas_bin_dir" || ! -d "$atlas_bin_dir" ]]; then
				# Empty output must stay empty: ${"":h} is ".", which would put the
				# current directory on PATH.
				local atlas_bin
				atlas_bin=$("$ensure_atlas" 2>/dev/null)
				atlas_bin_dir=${atlas_bin:+${atlas_bin:h}}
				[[ -n "$atlas_bin_dir" && -d "$atlas_bin_dir" ]] \
					&& _asdf_atlas_dir_cache[$key]=$atlas_bin_dir
			fi
			if [[ -n "$atlas_bin_dir" && -d "$atlas_bin_dir" ]]; then
				path=("${(@)path:#$atlas_bin_dir}")
				path=("$atlas_bin_dir" $path)
			fi
		fi
	fi

	export PATH
}

add-zsh-hook chpwd _asdf_update_path_for_repo
