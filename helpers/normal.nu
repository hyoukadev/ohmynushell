def "ice ip" [] {
  if $nu.os-info.name == "macos" {
    ipconfig getifaddr en0
  }
}

# A small cross-platform package-manager convenience wrapper.
def --wrapped apt [...args] {
  match $nu.os-info.name {
    "windows" => { ^winget ...$args }
    "macos" => { ^brew ...$args }
    _ => { ^apt ...$args }
  }
}


