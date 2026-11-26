---
id: tailscale
title: Tailscale CLI with HTTPS certificates (needed by Collie)
when: 'os = "macos"'
after: always
check: 'command -v tailscale >/dev/null && tailscale status --json | grep -q "\"CertDomains\": *\["'
revision: 1
---

Collie is reachable only over the tailnet through `tailscale serve`.

1. Install the CLI from the Tailscale app: Settings, "Install CLI" (Tailscale.app is not a brew
   package, so dots does not declare it).
2. Enable HTTPS certificates at https://login.tailscale.com/admin/dns.
