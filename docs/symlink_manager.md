# 跨平台 Symbolic Link 管理

所有映射集中声明在 `manifest.nuon`，由 `setup.nu` 解析；底层安全操作仅由 `modules/files.nu` 提供。

## 使用

```nu
nu setup.nu apps
nu setup.nu apply
nu setup.nu apply zellij
nu setup.nu doctor --strict
```

新增应用时只增加 manifest 记录，不创建新的 `init.nu`：

```nu
{
  app: "example"
  name: "example-config"
  platforms: ["windows" "unix"]
  source: ["example"]
  target: { base: "config" path: ["example"] }
}
```

`target.base` 支持：

- `repo`：仓库根目录；
- `config`：Windows `%APPDATA%`，Unix `~/.config`。

## 行为

1. 确认源存在；
2. 正确 Symbolic Link 直接返回；
3. 创建权限检查通过后，移除错误目标；
4. 创建父目录和 Symbolic Link；
5. 不创建 `.bak`，不降级为 Junction、HardLink 或 Copy。

## 平台要求

- Windows：PowerShell `New-Item -ItemType SymbolicLink`，要求 Developer Mode 或管理员权限；
- Linux/macOS/Android：`ln -s`。

## 安全约束

目标必须使用：

```nu
$target | path expand --no-symlink
```

不能先解析目标链接再移动或删除，否则目标会变成源目录。Windows 在修改已有目标前先创建临时软链验证权限，避免权限失败后留下缺失目标。

## 验证

```nu
nu setup.nu doctor --strict
nu --no-config-file modules/files.test.nu
```

Windows 首次创建软链的测试需要 Developer Mode 或提升权限。
