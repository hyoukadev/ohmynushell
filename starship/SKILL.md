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
http get https://raw.githubusercontent.com/catppuccin/starship/refs/heads/main/starship.toml | save -f ($nu.data-dir | path dirname | path join startship startship.toml)
```
