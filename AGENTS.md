# AI Agent Configuration Contract

This repository is the source of truth for a consistent Windows, macOS, Linux/WSL, and Android/Termux development environment.

## Goal

Converge the current machine to the declared state while preserving machine-specific data. Prefer inspection, targeted merge, and validation over replacing whole user configuration files. Do not leave persistent `.bak` files.

## Desired state

| Area | Desired value |
|---|---|
| Shell | Nushell |
| Prompt | Starship |
| Multiplexer | Zellij, session `main` |
| Editor | Helix |
| File manager | Yazi |
| Runtime manager | mise |
| Python tools | uv |
| Theme | Catppuccin Latte |
| Terminal font | Maple Mono NF CN; Windows Terminal 10 pt, Alacritty/Ghostty 12 pt |
| Terminal (Windows) | Windows Terminal; Alacritty optional |
| Terminal (macOS/Linux) | Ghostty; Alacritty fallback |
| Proxy | Disabled by default; explicit `proxy on/off` |

## Repository assumptions

- The repository root is the Nushell data/config directory (`$nu.data-dir`).
- `manifest.nuon` declares all symbolic-link mappings; `setup.nu` is the only apply/doctor entry point.
- Tracked files are declarative sources. Files below `vendor/autoload/` are generated per machine and intentionally ignored.
- Never commit history, credentials, tokens, machine-specific profile GUIDs, or generated activation snapshots.
- Before changing a third-party theme, fetch the official source with `gh` and compare it instead of recreating colors manually.

## Official theme sources

- Nushell: `catppuccin/nushell`, `themes/catppuccin_latte.nu`
- Alacritty: `catppuccin/alacritty`, `catppuccin-latte.toml`
- Starship: `catppuccin/starship`; select `palette = "catppuccin_latte"`
- Windows Terminal: `catppuccin/windows-terminal`, `latte.json` and `latteTheme.json`
- Yazi: `yazi-rs/flavors:catppuccin-latte`
- Font: `subframe7536/maple-font`, release asset `MapleMono-NF-CN.zip`

## Optional components

- Helix language tooling is described in [`docs/helix.md`](./docs/helix.md). Install platform-appropriate packages until the declared executable names pass doctor; do not restore a fixed batch installer.
- Rime is outside the core setup manifest and is handled only on explicit user request. Follow [`docs/rime.md`](./docs/rime.md); do not commit downloaded schemas, dictionaries, or Plum data.

## Agent workflow

1. Inspect the OS, installed tool versions, Git status, existing links, and target application settings.
2. Explain destructive or security-sensitive operations before execution. Do not create persistent `.bak` files; if a temporary safety copy is required, remove it after successful validation.
3. Install missing tools with the platform-native package manager where practical:
   - Windows: `winget`
   - macOS: Homebrew or official release
   - Linux: distribution package, mise, Cargo, or official release based on freshness
4. Install Maple Mono NF CN:
   - Windows: copy TTF files to `%LOCALAPPDATA%\Microsoft\Windows\Fonts`; register each value under `HKCU\Software\Microsoft\Windows NT\CurrentVersion\Fonts` using the font's display name and the **full absolute TTF path** as data (a bare filename is invalid for per-user fonts); call `AddFontResourceEx`, then broadcast `WM_FONTCHANGE`.
   - macOS: copy TTF files to `~/Library/Fonts`.
   - Linux: copy TTF files to `~/.local/share/fonts`, then run `fc-cache -f`.
5. Generate machine-local Nushell integrations:

   ```nu
   mkdir ($nu.data-dir | path join vendor autoload)
   mise activate nu | save --force ($nu.data-dir | path join vendor autoload mise.nu)
   starship init nu | save --force ($nu.data-dir | path join vendor autoload starship.nu)
   zoxide init nushell | save --force ($nu.data-dir | path join vendor autoload zoxide.nu)
   ```

   Generate these from a clean OS PATH. Do not preserve transient Agent, MSYS, or project-specific paths in activation snapshots.
6. Apply the declarative manifest through the single entry point:

   ```nu
   nu setup.nu apps
   nu setup.nu apply             # all applicable configuration
   nu setup.nu apply alacritty   # one application
   nu setup.nu doctor --strict
   ```

   `manifest.nuon` is the only source of symbolic-link mappings. Do not add per-application installer scripts.
7. `setup.nu` handles the two non-link operations: Yazi flavor convergence and Windows Terminal settings merge. Never replace the complete Windows Terminal settings file because profile GUIDs are device-specific.
8. Validate before reporting completion.

## Platform behavior

- Every platform uses symbolic links for both files and directories.
- On Windows, require Developer Mode or an elevated process. If symbolic-link creation is denied, stop and report the prerequisite; never fall back to Junction, HardLink, or Copy.
- Ghostty is configured as the preferred macOS/Linux terminal and starts Zellij.
- Windows Terminal defaults are merged from the tracked fragment. Alacritty remains a cross-platform fallback.
- Zellij uses Nushell as its default shell and attaches to or creates the `main` session.

## Proxy commands

The configuration never enables a localhost proxy automatically:

```nu
proxy status
proxy on
proxy off
proxy on --http http://127.0.0.1:10808 --socks socks5://127.0.0.1:10808
```

## Required validation

```nu
# Nushell configuration
nu --env-config env.nu --config config.nu -c 'print NU_CONFIG_OK'

# Declarative setup and link state
nu --no-config-file setup.nu apps
nu --no-config-file setup.nu doctor --strict

# Tool checks
starship print-config
zellij setup --check
yazi --debug
hx --health

git diff --check
```

Also verify:

- `STARSHIP_CONFIG` points to `starship/starship.toml`.
- No Frappe or Macchiato references remain in active configuration.
- Maple Mono NF CN is installed and selected by every configured terminal.
- Localhost proxy variables are absent unless explicitly enabled.
- Generated files and secrets remain ignored by Git.
