# 需求文档：跨平台一致开发环境

## 1. 范围

配置系统覆盖 Windows、macOS、Linux/WSL 和 Android/Termux，目标是让核心命令行工具、编辑器、终端复用相同配置与操作习惯。

## 2. 功能需求

### 2.1 核心工具

- Nushell 作为交互 Shell。
- Starship 作为 Prompt。
- Zellij 作为终端复用器。
- Helix、Yazi、mise、uv、zoxide 等使用跨平台配置。
- 视觉统一为 Catppuccin Latte 和 Maple Mono NF CN。

### 2.2 配置管理

- 被 Git 跟踪的文件是期望状态的唯一来源。
- 每台机器生成的绝对路径脚本放入 `vendor/autoload/` 并忽略。
- `manifest.nuon` 集中声明目录和文件配置，`setup.nu` 提供幂等 apply 与 doctor，不生成持久 `.bak`。
- 所有平台仅使用 Symbolic Link；Windows 权限不足时明确失败，不允许降级为 Junction、HardLink 或 Copy。
- Windows Terminal 必须合并配置片段，不能覆盖设备相关 Profile。

### 2.3 平台适配

- Windows 配置目录使用 `%APPDATA%` 或 `%LOCALAPPDATA%`。
- Linux 遵循 XDG 目录规范。
- macOS 根据工具约定使用 `~/.config` 或 `~/Library`。
- 不适用于当前平台的工具必须明确跳过。
- 平台判断不得产生空脚本路径或启动解析错误。

### 2.4 网络与环境变量

- 代理不得在启动时无条件启用。
- 提供 `proxy on`、`proxy off`、`proxy status`。
- PATH 生成文件不得固化 AI Agent、MSYS 或项目临时目录。
- Windows Python CLI 使用 UTF-8 模式。

### 2.5 Agent 支持

- `AGENTS.md` 必须记录目标状态、官方来源、平台差异、安装顺序和验证命令。
- Agent 在操作前检查环境和 Git 状态。
- 第三方资源必须来自官方仓库并进行校验。
- 修改真实用户配置前必须说明破坏性影响；优先无损合并，禁止遗留持久 `.bak`。
- 完成报告必须区分已验证、静态验证、跳过和失败项目。

## 3. 非功能需求

- **可读**：配置和模块命名直接表达目标。
- **幂等**：重复安装不产生额外文件或破坏源文件。
- **安全**：链接管理不得解析目标链接后误操作源目录。
- **可移植**：仓库不能依赖某台机器的绝对 PATH 快照。
- **可审查**：主题文件可以与官方源逐字节比较。
- **可验证**：Nushell、TOML、JSON、KDL 及工具运行时均有检查方式。

## 4. 验收标准

- Nushell 配置在支持的平台上无解析错误。
- `manifest.nuon` 可以解析，且 `nu setup.nu doctor --strict` 通过。
- Starship 使用 `catppuccin_latte`，并能生成 Prompt。
- Zellij 使用 Latte、Nushell 和 `main` 会话。
- Yazi 只保留 Latte flavor。
- 配置中的终端统一选择 Maple Mono NF CN 12pt。
- Windows Terminal 合并操作保留原 Profile 列表和 GUID。
- 代理默认不由配置主动设置。
- `git diff --check` 和对应工具健康检查通过。
