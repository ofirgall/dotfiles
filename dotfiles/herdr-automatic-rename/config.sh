# herdr-automatic-rename config; see config.example.sh in the plugin for every knob.

# Leave Git branches out of tab breadcrumbs (directory › program only).
SHOW_BRANCH=0

# Jump-key number style: tabs "2 │ api › nvim", workspaces "[7] herdr".
# INDEX_FORMAT='%s    󰅂 │ '
# INDEX_FORMAT='%s ▏'
INDEX_FORMAT='%s| '
# INDEX_FORMAT_WORKSPACES=' [%s] '
INDEX_FORMAT_WORKSPACES='%s. '
# INDEX_FORMAT_WORKSPACES='[%s] '

# herdr draws space jump numbers itself (the `index` sidebar token), which
# follow skipped spaces and the tenth-space 0; leave workspace names unnumbered.
# Named explicitly (not via AUTO_INDEX) so the plugin strips the old prefixes.
AUTO_INDEX_WORKSPACES=0
