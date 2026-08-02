# Helix 语言环境

Helix 配置由 `helix/config.toml` 与 `helix/languages.toml` 提供；语言工具由 AI Agent 根据操作系统和当前环境安装，不维护固定的批量安装脚本。

## 必要工具

| 语言/格式 | 命令 | 用途 |
|---|---|---|
| Rust | `rust-analyzer` | Language Server |
| TOML | `taplo` | Language Server |
| Typst | `tinymist` | Language Server |
| Lua | `lua-language-server` | Language Server |
| JavaScript/TypeScript | `typescript-language-server` | Language Server |
| JavaScript/TypeScript | `vscode-eslint-language-server` | ESLint Language Server |
| YAML | `yaml-language-server` | Language Server、格式化与 Schema |
| Markdown | `markdown-oxide` | Language Server |

`lldb-dap`、`ansible-language-server`、Marksman 和 Biome 是可选工具；只有明确需要调试、Ansible、替代 Markdown Server 或 Biome formatter 时才安装。

## Windows 推荐来源

```nu
rustup component add rust-analyzer

winget install --id tamasfe.taplo --exact
winget install --id Myriad-Dreamin.Tinymist --exact
winget install --id LuaLS.lua-language-server --exact
winget install --id FelixZeller.markdown-oxide --exact

npm install --global typescript typescript-language-server vscode-langservers-extracted yaml-language-server
```

macOS/Linux 由 Agent 优先选择 Homebrew、系统包、mise 或官方 release，确保最终命令名与上表一致。

## 验证

```nu
nu setup.nu doctor --strict

hx --health rust
hx --health toml
hx --health typst
hx --health lua
hx --health javascript
hx --health typescript
hx --health yaml
hx --health markdown
```

注意：rustup 可能创建 `rust-analyzer` shim，但组件尚未安装；因此 doctor 会实际执行 `rust-analyzer --version`，而不只检查 PATH。
