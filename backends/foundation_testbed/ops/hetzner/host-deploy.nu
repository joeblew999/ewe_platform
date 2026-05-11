#!/usr/bin/env nu
# Copy local testbed binary to the host's /usr/local/bin.
use ./env.nu *
hetzner-resolve-env

let name = ($env.HETZNER_HOST_NAME? | default "testbed-host")
let key_file = $env.HETZNER_SSH_KEY
let root = (^git rev-parse --show-toplevel | str trim)
let bin = $"($root)/target/x86_64-unknown-linux-musl/release/testbed"

if not ($bin | path exists) {
    print --stderr $"ERROR: ($bin) not found."
    print --stderr "  Build it: mise run cross:build"
    exit 1
}

let ip = (hcloud server ip $name | str trim)
let ssh_target = $"root@($ip)"
let ssh_opts = ["-o" "StrictHostKeyChecking=no" "-o" "UserKnownHostsFile=/dev/null" "-i" $key_file]

^scp ...$ssh_opts $bin $"($ssh_target):/usr/local/bin/testbed"
^ssh ...$ssh_opts $ssh_target "chmod +x /usr/local/bin/testbed && testbed --version 2>&1 | head -1"
print $"✓ Deployed to ($name)"
