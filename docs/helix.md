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

## 文件与 Git 工作流

Helix 保持专注于编辑、LSP 和搜索，外部 TUI 工具由 Zellij 承载：

- Yazi 配置目录整体链接到仓库，并使用阻塞式 `hx` opener 编辑文本文件；`package.toml`、`flavors/` 和 `plugins/` 由 `ya pkg` 生成并被 Git 忽略；
- LazyGit 作为待评估的 Git UI，不是仓库绑定的唯一选择；
- Delta 提供 Catppuccin Latte 亮色 diff；
- ripgrep、fd 与 zoxide 支持搜索和导航。

当前不声明 Zellij `Alt` 快捷键。确定最终采用的文件管理和 Git 工具后，再添加快捷键或布局，避免过早耦合。

Windows 的 Delta 推荐设置：

```nu
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light true
git config --global delta.syntax-theme "Catppuccin Latte"
git config --global merge.conflictStyle zdiff3
```
