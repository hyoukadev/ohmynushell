# ✨oh my nushell✨

> 声明式跨平台开发环境配置

这个仓库用于在 Windows、macOS、Linux/WSL 间保持尽可能一致的命令行开发体验。仓库保存期望状态，`manifest.nuon` 声明软链映射，`setup.nu` 负责配置收敛与检查，AI Agent 根据当前机器安装缺失工具并处理系统级操作。

> **验证状态**：Windows 已验证；macOS、Linux/WSL 的映射已声明，待对应平台实机验证。

## 工具组合

| 分类 | 工具 |
|---|---|
| 核心 | Nushell、Starship、Zellij、Helix、Yazi、mise、uv、zoxide |
| 编辑辅助 | ripgrep、fd、ast-grep、Tig、Delta、Difftastic；LazyGit 待评估 |
| 终端 | Windows Terminal（Windows）、Ghostty（macOS/Linux）、Alacritty（可选） |
| 外观 | Catppuccin Latte、Maple Mono NF CN（Windows Terminal 10pt） |
| 可选 | Rime |

## 设计原则

- **Learn once, use anywhere**：优先选择跨平台工具和一致的操作方式。
- **声明式配置**：`manifest.nuon` 是全部 Symbolic Link 映射的唯一来源。
- **单一入口**：使用 `setup.nu` 执行 apply、apps 和 doctor。
- **Agent 驱动**：安装方式和版本选择由 Agent 根据平台与现状决定，不维护易过时的批量安装脚本。
- **官方来源**：主题和字体使用上游官方文件，不维护近似配色。
- **显式修改**：不创建 `.bak`，不把 Windows 软链降级为 Junction、HardLink 或 Copy。

## 前置条件

1. 已安装 Git 和 Nushell。
2. 仓库根目录必须是 Nushell 配置目录 `$nu.data-dir`。可在 Nushell 中查看：

   ```nu
   $nu.data-dir
   ```

3. Windows 必须启用 **Developer Mode**，或从管理员终端运行首次软链创建；权限不足时 `setup.nu` 会直接失败。
4. 其他工具、Maple Mono NF CN 字体和本机 autoload 集成可交给支持本仓库 `AGENTS.md` 的 AI Agent 安装。

## 快速开始

进入仓库后先检查，不要直接应用未知差异：

```nu
cd $nu.data-dir
nu setup.nu apps
nu setup.nu doctor --strict
```

首次检查发现未配置项并返回非零状态是正常现象。确认输出后应用当前平台的全部配置：

```nu
nu setup.nu apply
nu setup.nu doctor --strict
```

也可以只应用一个工具：

```nu
nu setup.nu apply helix
nu setup.nu apply zellij
```

## Agent 使用方式

让 AI Agent 先完整阅读 [`AGENTS.md`](./AGENTS.md)，再检查操作系统、工具版本、现有软链和 Git 状态。Agent 应负责：

- 安装缺失工具并选择适合当前平台的来源；
- 从官方仓库下载并校验主题与字体；
- 生成当前机器的 `vendor/autoload/*.nu`；
- 执行 `setup.nu apply` 与 `setup.nu doctor --strict`；
- 区分已验证、跳过和仍需人工确认的项目。

## 配置边界

`setup.nu` 管理：

- `manifest.nuon` 中声明的文件和目录 Symbolic Link；
- Yazi Catppuccin Latte flavor；
- Windows Terminal 的主题、默认字体和字号定向合并。

本仓库不会自动管理：

- PowerShell Profile；
- 完整 Windows Terminal `settings.json` 和设备相关 Profile GUID；
- 系统级字体安装；
- 第三方工具的固定安装版本。

`vendor/autoload/` 包含 mise、Starship、zoxide 等工具针对本机生成的集成，可能带有绝对路径，因此被 Git 忽略。

## 常用命令

代理默认关闭：

```nu
proxy status
proxy on
proxy off
```

查看和应用配置：

```nu
nu setup.nu apps
nu setup.nu apply [app]
nu setup.nu doctor --strict
```

## 维护

- 新增或修改软链映射：编辑 [`manifest.nuon`](./manifest.nuon)，不要新增每个应用独立的安装脚本。
- 修改后至少运行：

  ```nu
  nu setup.nu doctor --strict
  git diff --check
  ```

- 不提交 history、凭据、Token、字体文件、下载的 Rime 方案或机器生成的 autoload 文件。

## 文档

- [AI Agent 操作契约](./AGENTS.md)
- [架构设计](./docs/design.md)
- [需求与验收标准](./docs/requirements.md)
- [Symbolic Link 安全设计](./docs/symlink_manager.md)
- [Helix 语言环境](./docs/helix.md)
- [Rime 可选配置](./docs/rime.md)

## License

[MIT](./LICENSE) © 2026 hyoukadev
