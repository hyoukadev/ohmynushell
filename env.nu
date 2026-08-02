# env.nu
#
# Installed by:
# version = "0.103.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

use std/util "path add"

# User-level tool locations shared across platforms.
path add ($nu.home-dir | path join .cargo bin)
path add ($nu.home-dir | path join .local bin)

# Homebrew's default Apple Silicon locations.
if $nu.os-info.name == "macos" {
  path add /opt/homebrew/bin
  path add /opt/homebrew/sbin
}
# source $"($nu.home-dir)/.cargo/env.nu"


$env.EDITOR = "hx"
$env.config.buffer_editor = "hx"
$env.DFT_BACKGROUND = "light"

# Yazi requires file(1) for MIME detection. Git for Windows ships it outside
# the normal Windows PATH, so derive its location from the active Git binary.
if $nu.os-info.family == "windows" {
  let git = (which git | get -o 0.path)
  if $git != null {
    let candidates = [
      ($git | path dirname | path dirname | path join usr bin file.exe)
      ($git | path dirname | path dirname | path dirname | path join usr bin file.exe)
    ]
    let file = ($candidates | where {|path| $path | path exists} | get -o 0)
    if $file != null {
      $env.YAZI_FILE_ONE = $file
    }
  }
}

# Keep Python-based CLIs (such as Tavily) Unicode-safe on Windows.
$env.PYTHONUTF8 = "1"

# end of file
