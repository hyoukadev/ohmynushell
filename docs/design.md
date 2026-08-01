# 设计文档：声明式跨平台开发环境

## 1. 目标

在 Windows、macOS、Linux/WSL 和 Android/Termux 上提供一致的核心工具、快捷键和视觉体验。仓库描述最终状态，AI Agent 根据机器现状安装依赖，`setup.nu` 负责确定性的配置收敛和检查。

核心组合：Nushell、Starship、Zellij、Helix、Yazi、mise、uv、Catppuccin Latte、Maple Mono NF CN。

## 2. 原则

1. 可移植配置必须进入 Git；机器生成文件必须忽略。
2. `manifest.nuon` 是全部 Symbolic Link 映射的唯一来源。
3. `setup.nu` 是唯一的 apply/doctor 入口，不维护每个应用各自的安装脚本。
4. Windows Terminal 只做定向合并，保留设备 Profile 和 GUID。
5. 所有平台只使用 Symbolic Link，不降级为 Junction、HardLink 或 Copy。
6. 不产生持久 `.bak`；替换实体目标前由 Agent 说明破坏性影响。
7. 主题和字体使用官方内容，不手写近似值。
8. 代理默认关闭，通过 `proxy on/off` 显式控制。

## 3. 目录结构

```text
nushell/
├── AGENTS.md                  # Agent 目标、来源和操作契约
├── manifest.nuon              # 软链声明
├── setup.nu                   # apply/apps/doctor
├── config.nu / env.nu         # Nushell 入口
├── modules/files.nu           # 唯一底层模块：安全软链
├── helpers/                   # 交互命令
├── themes/                    # 官方 Nushell Latte 主题
├── starship/                  # 被 Git 跟踪的 Starship 配置
├── windows-terminal/          # 可安全合并的配置片段
├── alacritty|ghostty|helix|yazi|zellij/
└── vendor/autoload/           # 每台机器生成，Git 忽略
```

## 4. 配置模型

### 4.1 普通配置

`manifest.nuon` 中每一项包含：

- `app`：应用分组，可用于单独 apply；
- `platforms`：`windows`、`unix` 等；
- `source`：相对仓库根目录；
- `target.base`：`repo` 或平台配置目录；
- `target.path`：目标相对路径。

应用配置统一执行：

```nu
nu setup.nu apps
nu setup.nu apply
nu setup.nu apply helix
nu setup.nu doctor --strict
```

### 4.2 特殊配置

只有两类不适合软链清单：

- Yazi package/flavor：`setup.nu` 调用 `ya pkg`，只保留 Catppuccin Latte。
- Windows Terminal：合并 `windows-terminal/settings.fragment.json`，不替换完整设置。

### 4.3 机器生成配置

`vendor/autoload/*.nu` 由本机工具生成，例如 `mise activate nu`、`starship init nu` 和 `zoxide init nushell`。它们可能包含绝对路径，必须被 Git 忽略。

## 5. Symbolic Link 安全

目标路径使用 `path expand --no-symlink`，避免把目标解析成源目录后误删除源文件。Windows 创建前检查 Symbolic Link 权限；权限不足直接失败。已存在目标只有在能力检查成功后才会移除。

Windows 必须启用 Developer Mode 或使用提升权限的终端。Unix 使用 `ln -s`。

## 6. Agent 执行模型

1. 盘点操作系统、工具版本、Git 状态和现有配置；
2. 安装缺失工具并从官方源下载主题/字体；
3. 生成本机 `vendor/autoload` 集成；
4. 执行 `nu setup.nu apply [app]`；
5. 执行 `nu setup.nu doctor --strict` 和工具健康检查；
6. 报告已完成、跳过及失败项。

固定的软件安装脚本不再作为核心架构；安装决策由 Agent 根据当前平台和版本完成。

## 7. 验证门槛

- Nushell `env.nu` 与 `config.nu` 可加载；
- `manifest.nuon` 可解析，`setup.nu doctor --strict` 通过；
- Symbolic Link 回归测试通过；
- Starship、Zellij、Yazi、Helix 配置无解析错误；
- Windows Terminal 保留设备 Profile；
- 活跃配置不存在旧 Frappe/Macchiato；
- `git diff --check` 通过。
