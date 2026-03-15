---
name: nushell
description: install and setup nushell for os
---

# Install

```nu
winget install nushell # for windows
cargo install nu --locked # for macos/linux
```

# Set nushell as default shell

### macOS
1. add nushell execute file path to `/etc/shells`
2. set nushell as default shell using `chsh` command
