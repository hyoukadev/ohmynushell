# Rime（可选组件）

Rime 不属于核心开发工具链，不通过 `manifest.nuon` 自动部署。仅在需要中文输入法时由 Agent 按操作系统和实际输入法前端配置。

## 受 Git 管理的文件

- `rime/default.custom.yaml`
- `rime/moran.custom.yaml`

## Windows

1. 安装并启用小狼毫（Weasel）。
2. 通过 Plum 或小狼毫输入法设定安装所需方案，例如：
   - `rimeinn/rime-moran@simp`
   - `rimeinn/rime-kagiroi`
3. 将仓库中的自定义文件复制到 Rime 用户目录：

   ```nu
   cp rime/default.custom.yaml ($env.APPDATA | path join Rime default.custom.yaml)
   cp rime/moran.custom.yaml ($env.APPDATA | path join Rime moran.custom.yaml)
   ```

4. 在小狼毫菜单中执行“重新部署”。

## macOS/Linux

先确认所使用的 Rime 前端及其用户目录，再复制同一组 `*.custom.yaml` 文件并重新部署。不要使用 Windows 专属包管理器安装 macOS/Linux 输入法前端。

## Agent 规则

- Rime 仅在用户明确要求时处理。
- 先检查现有前端、用户目录、方案和自定义文件，再修改。
- 不复制完整 Rime 数据目录，不提交 Plum 下载内容或词库。
