use ../modules/pathvar.nu *
use ../modules/do.nu *
use ../modules/files.nu *

let target = do auto {
  macos: { $nu.home-dir | path join Library Rime moran.custom.yaml }
  _: { pathvar xdg_config_home | path join Rime moran.custom.yaml }
}

let source = do auto {
  _: { pathvar workspace | path join rime moran.custom.yaml }
}

export def install [] {
  symlink $target $source
}

export def uninstall [] {
  if ($target | path exists) {
    rm $target
  }
}
