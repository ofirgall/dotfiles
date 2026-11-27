---
id: developer-mode
title: Turn on Developer Mode (needed for file symlinks)
when: 'os = "windows"'
after: always
check: '(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1'
revision: 1
---

dots links config files with symlinks. Without Developer Mode (or an admin shell) Windows refuses to
create them, and dots falls back to hardlinks and junctions, which break on directories across drives.

Settings > System > For developers > **Developer Mode** > On. No reboot is needed.

The check is PowerShell (the `check` shell on Windows is assumed to be pwsh).
TODO(dots-windows): a manual action cannot name its check's shell; `doctor` should also report this itself.
