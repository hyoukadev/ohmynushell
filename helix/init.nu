use ../modules/pathvar.nu *
use ../modules/do.nu *
use ../modules/files.nu *

let target = do auto {
  _: { pathvar xdg_config_home | path join helix }
}

let source = do auto {
  _: { $nu.data-dir | path join helix }
}

export def install [] {
  symlink $target $source
}

export def uninstall [] {
  if ($target | path exists) {
    rm $target
  }
}
