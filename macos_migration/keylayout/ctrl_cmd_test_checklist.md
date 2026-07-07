# Ctrl+C/V Remapping Test Checklist

## GUI apps (browser, Finder)

- [ ] Ctrl+C copies text
- [ ] Ctrl+V pastes text
- [ ] Ctrl+X cuts text
- [ ] Ctrl+Z undoes
- [ ] Ctrl+A selects all
- [ ] Ctrl+F opens find
- [ ] Ctrl+T opens new tab (browser)
- [ ] Ctrl+W closes tab (browser)
- [ ] Ctrl+N opens new window
- [ ] Ctrl+Tab switches tabs (browser)
- [ ] Ctrl+Shift+Tab switches tabs backwards

## Ghostty terminal

- [ ] Ctrl+C sends SIGINT (run `sleep 999` then Ctrl+C to kill it)
- [ ] Ctrl+Shift+C copies selected text
- [ ] Ctrl+Shift+V pastes from clipboard
- [ ] Ctrl+B triggers tmux prefix (if tmux is running)
- [ ] Alt+Shift+{letter} tmux navigation still works

## Cursor IDE (excluded from remapping)

- [ ] Ctrl+C sends raw Ctrl+C (not copy) -- verify in integrated terminal with `sleep 999`
- [ ] Cmd+C (physical Super-position key + C) copies in editor

## Negative tests

- [ ] Ctrl+C in Ghostty does NOT copy (should SIGINT)
- [ ] Ctrl+V in Ghostty does NOT paste (should send raw)
