---
name: zoxide-for-nushell
description: install zoxide and configure it for nushell
---

# Install zoxide
```nu
mise use zoxide@latest -g
```

# Configure zoxide for nushell

```nu
zoxide init nushell | save -f ($nu.vendor-autoload-dirs | path join "zoxide.nu")
```
