export def "pathvar xdg_config_home" [] {
  match $nu.os-info.family {
    "windows" => {
      $env.APPDATA
    }
    "unix" => {
      $nu.home-dir | path join .config
    }
  }
}

export def "pathvar workspace" [] {
  $nu.default-config-dir | path dirname
}

export def "pathvar autoload" [] {
  pathvar workspace | path join nushell vendor autoload
}
