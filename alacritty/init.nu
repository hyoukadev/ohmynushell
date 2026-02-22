use ../modules/pathvar.nu *
use ../modules/do.nu *
use ../modules/files.nu *

let target = do auto {
  _: { pathvar xdg_config_home | path join alacritty }
}

let source = do auto {
  _: { pathvar workspace | path join alacritty }
}

export def install [] {
  # Setup OS-specific config inside the repo first
  do auto {
    unix: {
      symlink ($source | path join alacritty.toml) ($source | path join alacritty.unix.toml)
    }
    windows: {
      symlink ($source | path join alacritty.toml) ($source | path join alacritty.windows.toml)
    }
  }

  symlink $target $source
}

export def uninstall [] {
  if ($target | path exists) {
    rm $target
  }
}
