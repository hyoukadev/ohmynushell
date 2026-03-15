---
name: mise-for-nushell
description: install mise and config it for nushell
---

# Install
```nu
winget install jdx.mise # for windows
curl https://mise.run | sh # for linux/macos
```

# Activate mise for nushell
```nu
# https://mise.jdx.dev/installing-mise.html#nushell
mise activate nu | save -f ($nu.vendor-autoload-dirs | path join "mise.nu")
```
