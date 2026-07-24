# Manual Setup Steps (Windows)

Steps that require manual intervention and can't be run by the install scripts.

## Admin Setup

Open **Terminal as Administrator** (right-click Start → Terminal (Admin)) and run:

```powershell
& "$env:USERPROFILE\dotfiles\install_scripts\windows\setup_admin.ps1"
```

This currently:
- Disables Win+L lock screen so whkd can use Win+L for tiling
  (you can still lock via Start menu → Lock or Ctrl+Alt+Del → Lock)

## Desktop Shortcuts

Create start/stop shortcuts for GUI apps:

```powershell
& "$env:USERPROFILE\dotfiles\install_scripts\windows\create_shortcuts.ps1"
```

## Developer Mode

Must be enabled before running the install (required for NTFS symlinks):

Settings → System → For developers → Developer Mode → On
