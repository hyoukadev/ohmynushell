---
name: rime
description: install and configure rime
---

# Install

```nu
winget install weasel # for windows
winget install squirrel # for macos
```

# Configure rime-moran

1. 通过 plum 或小狼毫的输入法设定，安装以下配置：
  - `rimeinn/rime-moran@simp`
  - `rimeinn/rime-kagiroi`

2. 将 `<repo>/rime/moran.custom.yaml` 文件放置到：
  ```nu
  ($env.APPDATA)/Rime/moran.custom.yaml # windows
  ```
