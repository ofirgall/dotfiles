#!/usr/bin/env bash
# Copy a Cursor conversation from one workspace to another.
#
# Cursor stores a conversation in two places, both keyed by the conversation
# UUID:
#   1. ~/.cursor/projects/<workspace-slug>/agent-transcripts/<conv-uuid>/
#   2. ~/.cursor/chats/<chat-hash>/<conv-uuid>/
#
# chat-hash = md5(realpath(workspacePath)) — same algorithm cursor-agent uses
# (see versions/.../*.index.js: createHash("md5").update(resolve(cwd))). The
# absolute workspacePath is recorded in projects/<slug>/worker.log; we grep
# it out and md5 it. Falls back to a transcript-UUID scan if worker.log is
# missing.

set -euo pipefail

CURSOR_DIR="$HOME/.cursor"
PROJECTS_DIR="$CURSOR_DIR/projects"
CHATS_DIR="$CURSOR_DIR/chats"

die() {
    echo "error: $*" >&2
    exit 1
}

command -v fzf >/dev/null || die "fzf is required"
[[ -d "$PROJECTS_DIR" ]] || die "$PROJECTS_DIR does not exist"
[[ -d "$CHATS_DIR" ]] || die "$CHATS_DIR does not exist"

# List workspace slugs that have an agent-transcripts/ dir.
list_workspaces_with_transcripts() {
    local d
    for d in "$PROJECTS_DIR"/*/; do
        [[ -d "${d}agent-transcripts" ]] && basename "$d"
    done
}

# Extract the absolute workspace path that cursor recorded in worker.log.
workspace_path_from_slug() {
    local log="$PROJECTS_DIR/$1/worker.log"
    [[ -f "$log" ]] || return 1
    local p
    p="$(grep -aoE 'workspacePath=[^[:space:]]+' "$log" | head -1)"
    [[ -n "$p" ]] || return 1
    printf '%s' "${p#workspacePath=}"
}

# Resolve chat-hash for a workspace. Cursor's cursor-agent computes the chat
# dir as md5(realpath(workspacePath)) joined under ~/.cursor/chats/ — see
# cursor-agent/src/.../computeChatsDir (`createHash("md5").update(resolve(cwd))
# .digest("hex")`). Compute it directly; fall back to scanning transcripts
# only if worker.log is missing (older projects).
resolve_chat_hash() {
    local workspace="$1"
    local ws_path hash
    if ws_path="$(workspace_path_from_slug "$workspace")"; then
        ws_path="$(readlink -f "$ws_path" 2>/dev/null || printf '%s' "$ws_path")"
        hash="$(printf '%s' "$ws_path" | md5sum | cut -d' ' -f1)"
        printf '%s' "$hash"
        return 0
    fi
    local transcripts="$PROJECTS_DIR/$workspace/agent-transcripts"
    local uuid hash_dir
    [[ -d "$transcripts" ]] || return 1
    for uuid in "$transcripts"/*/; do
        [[ -d "$uuid" ]] || continue
        uuid="$(basename "$uuid")"
        for hash_dir in "$CHATS_DIR"/*/; do
            if [[ -d "${hash_dir}${uuid}" ]]; then
                basename "$hash_dir"
                return 0
            fi
        done
    done
    return 1
}

# 1. Pick source workspace.
src_ws="$(list_workspaces_with_transcripts | fzf --prompt='Source workspace> ' --height=40% --reverse)"
[[ -n "$src_ws" ]] || die "no source workspace selected"

# 2. Pick conversation from source workspace.
src_transcripts="$PROJECTS_DIR/$src_ws/agent-transcripts"
conv_uuid="$(
    find "$src_transcripts" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %f\n' \
        | sort -rn \
        | awk '{ ts=$1; $1=""; sub(/^ /,""); printf "%s\t(%s)\n", $0, strftime("%Y-%m-%d %H:%M", ts) }' \
        | fzf --prompt='Conversation> ' --height=40% --reverse --with-nth=1.. \
        | awk '{print $1}'
)"
[[ -n "$conv_uuid" ]] || die "no conversation selected"
[[ -d "$src_transcripts/$conv_uuid" ]] || die "transcript dir not found: $src_transcripts/$conv_uuid"

# 3. Pick destination workspace (exclude source).
dst_ws="$(
    list_workspaces_with_transcripts \
        | grep -vxF "$src_ws" \
        | fzf --prompt='Destination workspace> ' --height=40% --reverse
)"
[[ -n "$dst_ws" ]] || die "no destination workspace selected"

# 4. Resolve chat-hashes.
src_hash="$(resolve_chat_hash "$src_ws")" \
    || die "could not resolve chat-hash for source workspace '$src_ws' (no transcripts found in any chats/ dir)"
dst_hash="$(resolve_chat_hash "$dst_ws")" || die "could not resolve chat-hash for destination workspace '$dst_ws' (no worker.log and no existing transcripts to scan). Open Cursor in that workspace once, then re-run."

src_transcript_path="$src_transcripts/$conv_uuid"
dst_transcript_dir="$PROJECTS_DIR/$dst_ws/agent-transcripts"
dst_transcript_path="$dst_transcript_dir/$conv_uuid"

src_chat_path="$CHATS_DIR/$src_hash/$conv_uuid"
dst_chat_dir="$CHATS_DIR/$dst_hash"
dst_chat_path="$dst_chat_dir/$conv_uuid"

[[ -d "$src_chat_path" ]] || die "source chat dir not found: $src_chat_path"
[[ -e "$dst_transcript_path" ]] && die "destination already has transcript: $dst_transcript_path"
[[ -e "$dst_chat_path" ]] && die "destination already has chat: $dst_chat_path"

cat <<EOF
About to copy conversation $conv_uuid

  Transcript:
    $src_transcript_path
      -> $dst_transcript_dir/

  Chat:
    $src_chat_path
      -> $dst_chat_dir/

EOF

read -r -p "Proceed? [y/N] " ans
[[ "$ans" == "y" || "$ans" == "Y" ]] || die "aborted"

mkdir -p "$dst_transcript_dir" "$dst_chat_dir"
cp -r "$src_transcript_path" "$dst_transcript_dir/"
cp -r "$src_chat_path" "$dst_chat_dir/"

echo "done."
