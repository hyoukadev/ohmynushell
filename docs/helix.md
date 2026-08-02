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

## 代码查看与检索工作流

Helix 保持专注于编辑、LSP 和搜索，外部 CLI/TUI 工具按成本逐层补充：

1. `fd` 或 `rg --files` 确定候选路径；
2. `rg` 搜索准确文本和正则；
3. `ast-grep` 按 AST 结构搜索调用形态和重构目标；
4. Helix LSP 查定义、引用、类型和诊断；
5. Tig、`git blame`、`git log -L/-S/-G` 解释代码历史；
6. 只读取相关实现、测试和配置，不默认打包整个仓库给本地 Agent。

结构化搜索示例：

```nu
ast-grep run --lang typescript --pattern 'console.log($A)'
ast-grep run --lang javascript --pattern 'fetch($URL, $$$ARGS)'
```

Helix 使用无配置 Nushell 执行外部命令。按 `Space Shift+B` 时会从当前 buffer 路径定位 Git 根目录，并把当前行的 blame 显示在状态栏，不依赖启动 Helix 时的工作目录；非 Git 文件会显示明确提示。查看整个文件并向父提交追溯时使用：

```nu
tig blame -- path/to/file
```

## 文件与 Git 工作流

- Yazi 配置目录整体链接到仓库，并使用阻塞式 `hx` opener 编辑文本文件；`package.toml`、`flavors/` 和 `plugins/` 由 `ya pkg` 生成并被 Git 忽略；
- LazyGit 作为待评估的 Git UI，不是仓库绑定的唯一选择；
- Delta 是默认 Git pager，展示 Git 实际记录的行级 patch；
- Difftastic 作为独立 difftool，按需解释重构和格式化后的语法结构变化；
- ripgrep、fd 与 zoxide 支持搜索和导航。

当前不声明 Zellij `Alt` 快捷键。确定最终采用的文件管理和 Git 工具后，再添加快捷键或布局，避免过早耦合。

Windows 推荐安装来源：

```nu
winget install --id ast-grep.ast-grep --exact
winget install --id Wilfred.difftastic --exact
```

Delta 与 Difftastic 配置：

```nu
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light true
git config --global delta.syntax-theme "Catppuccin Latte"
git config --global merge.conflictStyle zdiff3

git config --global diff.tool difftastic
git config --global difftool.prompt false
git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'
git config --global alias.dft difftool
```

日常和提交前使用 Delta；结构化理解使用 Difftastic：

```nu
git diff
git diff --staged

git dft
git dft --staged
git dft HEAD~1 HEAD -- path/to/file
```

不要全局设置 `diff.external = difft`，否则会取代默认的 Delta 工作流。Difftastic 使用 `DFT_BACKGROUND=light` 适配 Latte；它用于理解结构，最终仍以 Delta 展示的标准 Git patch 为准。
