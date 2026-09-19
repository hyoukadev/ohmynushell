#!/usr/bin/env nu

use ./modules/files.nu *

const REPO_ROOT = path self .
const MANIFEST_PATH = path self manifest.nuon


def manifest [] {
  open $MANIFEST_PATH
}


def platform-active [platforms: list<string>] {
  ($platforms | any {|platform|
    $platform == $nu.os-info.name or $platform == $nu.os-info.family
  })
}


def config-home [] {
  if $nu.os-info.family == "windows" {
    $env.APPDATA
  } else {
    $nu.home-dir | path join .config
  }
}


def resolve-source [entry: record] {
  $REPO_ROOT | path join ...$entry.source
}


def resolve-target [entry: record] {
  let base = match $entry.target.base {
    "repo" => $REPO_ROOT
    "config" => (config-home)
    _ => (error make {msg: $"Unknown target base: ($entry.target.base)"})
  }
  $base | path join ...$entry.target.path
}


def selected-links [app?: string] {
  let links = (manifest | get links | where {|entry| platform-active $entry.platforms})
  if $app == null {
    $links
  } else {
    $links | where app == $app
  }
}


def apply-yazi-packages [] {
  if (which ya | is-empty) {
    print "⏭️ Yazi package manager not installed"
    return
  }

  let packages = (ya pkg list | lines)
  for flavor in [catppuccin-frappe catppuccin-macchiato] {
    let package = $"yazi-rs/flavors:($flavor)"
    if ($packages | any {|line| $line | str contains $package}) {
      ya pkg delete $package
    }
  }
  if not ($packages | any {|line| $line | str contains "yazi-rs/flavors:catppuccin-latte"}) {
    ya pkg add yazi-rs/flavors:catppuccin-latte
  }
  print "✅ Yazi flavor: Catppuccin Latte"
  for plugin in [smart-enter] {
    let package = $"yazi-rs/plugins:($plugin)"
    if not ($packages | any {|line| $line | str contains $package}) {
      ya pkg add $package
    }
  }
  print "✅ Yazi plugins: smart-enter"
}


def windows-terminal-target [] {
  $env.LOCALAPPDATA | path join Packages Microsoft.WindowsTerminal_8wekyb3d8bbwe LocalState settings.json
}


def apply-windows-terminal [] {
  if $nu.os-info.name != "windows" {
    return
  }

  let target = (windows-terminal-target)
  if not ($target | path exists) {
    print $"⏭️ Windows Terminal settings not found: ($target)"
    return
  }

  let current = (open $target)
  let desired = (open ($REPO_ROOT | path join windows-terminal settings.fragment.json))
  let name = $desired.schemes.0.name
  let defaults = ($current.profiles.defaults? | default {} | merge $desired.profiles.defaults)
  let schemes = ($current.schemes? | default [] | where name != $name | append $desired.schemes.0)
  let themes = ($current.themes? | default [] | where name != $name | append $desired.themes.0)
  $current
    | upsert profiles.defaults $defaults
    | upsert schemes $schemes
    | upsert themes $themes
    | upsert theme $desired.theme
    | to json --indent 4
    | save --force $target
  print $"✅ Windows Terminal: ($name), Maple Mono NF CN"
}


def known-apps [] {
  (manifest | get links.app | append windows-terminal | uniq | sort)
}


def main [] {
  print "Usage: nu setup.nu <apply|doctor|apps> [app]"
}


def "main apps" [] {
  known-apps
}


def "main apply" [app?: string] {
  if $app != null and $app not-in (known-apps) {
    error make {msg: $"Unknown app '($app)'. Available: (known-apps | str join ', ')"}
  }

  let links = (selected-links $app)
  for entry in $links {
    symlink (resolve-target $entry) (resolve-source $entry)
  }
  if $app != null and ($links | is-empty) and $app != "windows-terminal" {
    print $"⏭️ ($app) does not apply to ($nu.os-info.name)"
  }

  if $app == null or $app == "yazi" {
    apply-yazi-packages
  }
  if $app == null or $app == "windows-terminal" {
    apply-windows-terminal
  }
}


def executable-status [command: string, --verify] {
  if (which $command | is-empty) {
    return "missing"
  }
  if $verify {
    let result = (do { run-external $command "--version" } | complete)
    if $result.exit_code != 0 {
      return "broken"
    }
  }
  "ok"
}


def helix-tool-checks [] {
  [
    {app: "helix", name: "rust-analyzer", status: (executable-status rust-analyzer --verify), target: "rust-analyzer"}
    {app: "helix", name: "taplo", status: (executable-status taplo), target: "taplo"}
    {app: "helix", name: "tinymist", status: (executable-status tinymist), target: "tinymist"}
    {app: "helix", name: "lua-language-server", status: (executable-status lua-language-server), target: "lua-language-server"}
    {app: "helix", name: "typescript-language-server", status: (executable-status typescript-language-server), target: "typescript-language-server"}
    {app: "helix", name: "vscode-eslint-language-server", status: (executable-status vscode-eslint-language-server), target: "vscode-eslint-language-server"}
    {app: "helix", name: "yaml-language-server", status: (executable-status yaml-language-server), target: "yaml-language-server"}
    {app: "helix", name: "markdown-oxide", status: (executable-status markdown-oxide), target: "markdown-oxide"}
  ]
}


def yazi-file-check [] {
  if $nu.os-info.family == "windows" {
    let git = (which git | get -o 0.path)
    if $git == null {
      return {app: "workspace", name: "file", status: "missing", target: "Git for Windows file.exe"}
    }
    let candidates = [
      ($git | path dirname | path dirname | path join usr bin file.exe)
      ($git | path dirname | path dirname | path dirname | path join usr bin file.exe)
    ]
    let file = ($candidates | where {|path| $path | path exists} | get -o 0)
    return {app: "workspace", name: "file", status: (if $file != null { "ok" } else { "missing" }), target: ($file | default "Git for Windows file.exe")}
  }
  {app: "workspace", name: "file", status: (executable-status file), target: "file"}
}


def workspace-tool-checks [] {
  [
    {app: "workspace", name: "yazi", status: (executable-status yazi), target: "yazi"}
    {app: "workspace", name: "lazygit", status: (executable-status lazygit), target: "lazygit"}
    {app: "workspace", name: "delta", status: (executable-status delta), target: "delta"}
    {app: "workspace", name: "difftastic", status: (executable-status difft), target: "difft"}
    {app: "workspace", name: "ast-grep", status: (executable-status ast-grep), target: "ast-grep"}
    {app: "workspace", name: "tig", status: (executable-status tig), target: "tig"}
    {app: "workspace", name: "ripgrep", status: (executable-status rg), target: "rg"}
    {app: "workspace", name: "fd", status: (executable-status fd), target: "fd"}
    {app: "workspace", name: "zoxide", status: (executable-status zoxide), target: "zoxide"}
    (yazi-file-check)
  ]
}


def "main doctor" [--strict] {
  let links = (selected-links | each {|entry|
    let result = (symlink status (resolve-target $entry) (resolve-source $entry))
    {app: $entry.app, name: $entry.name, status: $result.status, target: $result.link}
  })

  let starship = ($REPO_ROOT | path join starship starship.toml)
  let starship_check = {
    app: "starship"
    name: "starship-config"
    status: (if ($starship | path exists) and ((open $starship).palette? == "catppuccin_latte") {"ok"} else {"invalid"})
    target: $starship
  }
  let yazi_check = {
    app: "yazi"
    name: "yazi-flavor"
    status: (if (which ya | is-empty) {
      "tool-missing"
    } else {
      let packages = (ya pkg list | lines | str join "\n")
      if ($packages | str contains "catppuccin-latte") and not ($packages | str contains "catppuccin-frappe") and not ($packages | str contains "catppuccin-macchiato") {"ok"} else {"invalid"}
    })
    target: "yazi package registry"
  }
  let windows_terminal_checks = if $nu.os-info.name == "windows" {
    let target = (windows-terminal-target)
    [{
      app: "windows-terminal"
      name: "windows-terminal-settings"
      status: (if ($target | path exists) {
        let settings = (open $target)
        if $settings.profiles.defaults.font.face? == "Maple Mono NF CN" and $settings.profiles.defaults.font.size? == 10 and $settings.profiles.defaults.colorScheme? == "Catppuccin Latte" {"ok"} else {"invalid"}
      } else {"missing"})
      target: $target
    }]
  } else { [] }
  let checks = ($links | append $starship_check | append $yazi_check | append $windows_terminal_checks | append (helix-tool-checks) | append (workspace-tool-checks))
  print $checks

  let failures = ($checks | where status != "ok")
  if $strict and ($failures | is-not-empty) {
    error make {msg: $"Doctor found ($failures | length) problems"}
  }
}
