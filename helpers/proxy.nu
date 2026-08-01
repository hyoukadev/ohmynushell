const DEFAULT_HTTP_PROXY = "http://127.0.0.1:10808"
const DEFAULT_SOCKS_PROXY = "socks5://127.0.0.1:10808"

# Enable the proxy for the current Nushell process and its child processes.
export def --env "proxy on" [
  --http: string = $DEFAULT_HTTP_PROXY
  --socks: string = $DEFAULT_SOCKS_PROXY
] {
  load-env {
    http_proxy: $http
    https_proxy: $http
    all_proxy: $socks
    HTTP_PROXY: $http
    HTTPS_PROXY: $http
    ALL_PROXY: $socks
  }
  print $"✅ Proxy enabled: HTTP=($http), SOCKS=($socks)"
}

# Disable proxy variables for the current Nushell process and its child processes.
export def --env "proxy off" [] {
  hide-env -i http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
  print "✅ Proxy disabled"
}

export def "proxy status" [] {
  {
    enabled: (($env.HTTP_PROXY? | is-not-empty) or ($env.http_proxy? | is-not-empty))
    http: ($env.HTTP_PROXY? | default $env.http_proxy? | default null)
    socks: ($env.ALL_PROXY? | default $env.all_proxy? | default null)
  }
}
