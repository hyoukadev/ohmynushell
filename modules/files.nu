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

def create-windows-symbolic-link [link: path, original: path] {
  # PowerShell New-Item can still demand elevation after Developer Mode is
  # enabled. Windows mklink honors unprivileged symbolic-link creation and
  # creates the same SymbolicLink reparse type required by this repository.
  let result = if ($original | path type) == "dir" {
    (^cmd /d /c mklink /D $link $original | complete)
  } else {
    (^cmd /d /c mklink $link $original | complete)
  }
  if $result.exit_code != 0 {
    let detail = ([$result.stdout $result.stderr] | str join " " | str trim)
    error make {msg: $"Failed to create Windows Symbolic Link: ($detail)"}
  }
}


def assert-symlink-capability [original: path] {
  if $nu.os-info.family == "windows" {
    let probe = ($env.TEMP | path join $"nu-symlink-probe-(random chars -l 12)")
    create-windows-symbolic-link $probe $original
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
    create-windows-symbolic-link $link $original
  } else {
    ^ln -s $original $link
  }
}
