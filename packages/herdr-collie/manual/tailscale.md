---
id: tailscale
title: Tailscale CLI with HTTPS certificates (needed by Collie)
when: 'os = "macos"'
after: always
check: 'T=$(command -v tailscale || echo /Applications/Tailscale.app/Contents/MacOS/Tailscale); [ -x "$T" ] && "$T" status --json | grep -q "\"CertDomains\": *\["'
revision: 2
---

Collie is reachable only over the tailnet through `tailscale serve`.

1. Install the Tailscale app and log in (it is not a brew package, so dots does not declare it).
   Its binary (`/Applications/Tailscale.app/Contents/MacOS/Tailscale`) is the CLI: my-zsh-conf
   aliases `tailscale` to it, and the Collie setup uses it directly.
2. Enable HTTPS certificates at https://login.tailscale.com/admin/dns.
