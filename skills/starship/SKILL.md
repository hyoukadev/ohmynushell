---
name: starship
description: install starship and config the theme
---
# Install starship
```nu
mise use starship@latest -g
```

# Configure starship theme
```nu
$env.STARSHIP_CONFIG = ($nu.vendor-autoload-dirs | path join "starship.toml")

http get https://raw.githubusercontent.com/catppuccin/starship/refs/heads/main/starship.toml | save -f $env.STARSHIP_CONFIG
```

# Configure starship for nushell
```nu
starship init nu | save -f ($nu.vendor-autoload-dirs | path join "starship.nu")
```
