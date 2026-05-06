#!/usr/bin/env bash
# Copy a Cursor conversation from one workspace to another.
#
# Cursor stores a conversation in two places, both keyed by the conversation
# UUID:
#   1. ~/.cursor/projects/<workspace-slug>/agent-transcripts/<conv-uuid>/
#   2. ~/.cursor/chats/<chat-hash>/<conv-uuid>/
#
# There is no direct workspace -> chat-hash mapping on disk, so we infer it
# by finding which chats/<hash>/ dir contains any transcript UUID that the
# workspace already owns.

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

# Resolve chat-hash for a workspace by finding any of its transcript UUIDs
# under chats/<hash>/. Echoes the hash on success, returns 1 if none found.
resolve_chat_hash() {
    local workspace="$1"
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
dst_hash="$(resolve_chat_hash "$dst_ws")" || die "could not resolve chat-hash for destination workspace '$dst_ws'.
The destination workspace has no existing transcripts that we can use to
locate its chats/<hash>/ directory. Open Cursor in that workspace and start
any conversation once (it can be empty), then re-run this script."

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

cp -r "$src_transcript_path" "$dst_transcript_dir/"
cp -r "$src_chat_path" "$dst_chat_dir/"

echo "done."
