# Resolve Robot API credentials + target server.
# `use ./env.nu *` then call `robot-resolve-env`.
#
# Required env (no auto-detection — Robot has no equivalent to hcloud context):
#   HETZNER_ROBOT_USER       webservice user (NOT account email)
#   HETZNER_ROBOT_PASSWORD   webservice password (NOT account password)
#
# Optional:
#   HETZNER_ROBOT_SERVER     server number or primary IP; if unset, first
#                            server returned by /server is used
#   HETZNER_ROBOT_BASE       API base url (default: https://robot-ws.your-server.de)

export def --env robot-resolve-env [] {
    let user_set = ("HETZNER_ROBOT_USER" in $env) and (not ($env.HETZNER_ROBOT_USER | is-empty))
    let pass_set = ("HETZNER_ROBOT_PASSWORD" in $env) and (not ($env.HETZNER_ROBOT_PASSWORD | is-empty))
    if (not $user_set) or (not $pass_set) {
        print --stderr "ERROR: Robot credentials missing."
        print --stderr "  Set HETZNER_ROBOT_USER and HETZNER_ROBOT_PASSWORD."
        print --stderr "  Create them at: https://robot.hetzner.com → Settings → Web service settings"
        print --stderr "  (These are NOT your account email/password.)"
        exit 1
    }
    $env.HETZNER_ROBOT_BASE = ($env.HETZNER_ROBOT_BASE? | default "https://robot-ws.your-server.de")
}

# Wrapper around `http get` with Robot basic-auth applied.
export def robot-get [path: string] {
    http get --user $env.HETZNER_ROBOT_USER --password $env.HETZNER_ROBOT_PASSWORD $"($env.HETZNER_ROBOT_BASE)($path)"
}

# Wrapper around `http post` (form-encoded) with Robot basic-auth applied.
export def robot-post [path: string, body: any] {
    http post --user $env.HETZNER_ROBOT_USER --password $env.HETZNER_ROBOT_PASSWORD --content-type "application/x-www-form-urlencoded" $"($env.HETZNER_ROBOT_BASE)($path)" $body
}

# Resolve target server identifier (IP or number) from env or first listed.
export def robot-target [] {
    if ("HETZNER_ROBOT_SERVER" in $env) and (not ($env.HETZNER_ROBOT_SERVER | is-empty)) {
        $env.HETZNER_ROBOT_SERVER
    } else {
        let servers = (robot-get "/server")
        if ($servers | is-empty) {
            print --stderr "ERROR: no Robot servers found in account."
            exit 1
        }
        $servers | first | get server.server_ip
    }
}
