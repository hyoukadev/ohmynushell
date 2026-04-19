# Linux and WSL2
use std/util "path add"

path add ($nu.home-dir | path join .local bin)
# /var/lib/flatpak/exports/share
# /home/ice/.local/share/flatpak/exports/share

# mise activate | save ($nu.data-dir | path join mise.nu)

let local_http_proxy = "http://127.0.0.1:10808"
let local_socks_proxy = "socks5://127.0.0.1:10808"

$env.http_proxy = $local_http_proxy
$env.https_proxy = $local_http_proxy
$env.all_proxy = $local_socks_proxy

$env.HTTP_PROXY = $local_http_proxy
$env.HTTPS_PROXY = $local_http_proxy
$env.ALL_PROXY = $local_socks_proxy


