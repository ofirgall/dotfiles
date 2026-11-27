---
id: execution-policy
title: Allow PowerShell scripts to run (windows_notify.ps1)
when: 'os = "windows"'
after: always
check: '(Get-ExecutionPolicy -Scope CurrentUser) -in "Unrestricted","RemoteSigned","Bypass"'
revision: 1
---

The notification scripts (`~/dotfiles_scripts/notify/windows_notify.ps1`) are unsigned. In PowerShell:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

(The old setup note used `Unrestricted` from an admin shell; the current-user scope needs no admin.)
