def log [emoji: string, msg: string] {
  print $"($emoji) ($msg)"
}

def is-symbolic-link [link: path] {
  let entry = (ls -a ($link | path dirname) | where name == $link | first)
  if $entry.type != "symlink" {
    return false
  }
  if $nu.os-info.family == "windows" {
    let link_type = (^powershell -NoProfile -Command $"$ErrorActionPreference = 'Stop'; Get-Item -LiteralPath '($link)' -Force | Select-Object -ExpandProperty LinkType" | str trim)
    return ($link_type == "SymbolicLink")
  }
  true
}

def assert-symlink-capability [original: path] {
  if $nu.os-info.family == "windows" {
    let probe = ($env.TEMP | path join $"nu-symlink-probe-(random chars -l 12)")
    ^powershell -NoProfile -Command $"$ErrorActionPreference = 'Stop'; New-Item -ItemType SymbolicLink -Path '($probe)' -Target '($original)' | Out-Null"
    rm $probe
  }
}

export def "symlink status" [link: path, original: path] {
  let link = ($link | path expand --no-symlink)
  let original = ($original | path expand)
  if not ($original | path exists) {
    return {status: "source-missing", link: $link, source: $original}
  }
  if not ($link | path exists) {
    return {status: "missing", link: $link, source: $original}
  }
  if not (is-symbolic-link $link) {
    return {status: "wrong-type", link: $link, source: $original}
  }
  let current = ($link | path expand)
  if $current != $original {
    return {status: "wrong-target", link: $link, source: $original, current: $current}
  }
  {status: "ok", link: $link, source: $original}
}

export def symlink [link: path, original: path] {
  # Expand paths to absolute to avoid relative path confusion
  # Never resolve the destination itself: doing so would turn an existing
  # symlink into its source path and could move/delete the source directory.
  let link = ($link | path expand --no-symlink)
  let original = ($original | path expand)

  if not ($original | path exists) {
    log "❌" $"Source not found: ($original)"
    return
  }

  if ($link | path exists) {
    # Check type via ls on parent to avoid following symlinks or listing dir contents
    # We use `path dirname` to list the parent directory
    let link_dirname = ($link | path dirname)
    # Find the specific entry. `ls` returns absolute paths if we don't specify otherwise,
    # but let's be safe matching the name.
    let entry = (ls -a $link_dirname | where name == $link | first)
    let type = $entry.type

    if $type == "symlink" {
      # On Windows, `ls` reports Junctions as symlinks too. Require the exact
      # SymbolicLink reparse type rather than accepting a Junction as converged.
      let correct_type = (is-symbolic-link $link)
      let current_target = ($link | path expand)

      if $correct_type and $current_target == $original {
        log "✅" $"Already linked: ($link)"
        return
      }

      # Check capability before removing an existing reparse point.
      assert-symlink-capability $original
      log "🔄" $"Updating link: ($link)"
      rm $link
    } else {
      # Check capability before removing an existing real file or directory.
      assert-symlink-capability $original
      log "🗑️" $"Removing existing target: ($link)"
      rm -r $link
    }
  }

  # Ensure parent directory exists
  let parent = ($link | path dirname)
  if not ($parent | path exists) {
    mkdir $parent
  }

  # Also covers the case where the destination did not exist.
  assert-symlink-capability $original
  log "🔗" $"Creating link: ($link) -> ($original)"

  if $nu.os-info.family == "windows" {
    # Windows requires Developer Mode or elevation for symbolic links.
    # Fail explicitly rather than changing link semantics.
    ^powershell -NoProfile -Command $"New-Item -ItemType SymbolicLink -Path '($link)' -Target '($original)' | Out-Null"
  } else {
    ^ln -s $original $link
  }
}
