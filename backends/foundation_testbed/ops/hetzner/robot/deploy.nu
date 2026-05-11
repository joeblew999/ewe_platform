#!/usr/bin/env nu
# Copy local testbed binary to the AX41's /usr/local/bin.
# Assumes installimage has completed and the server is running real Linux.
use ./env.nu *
robot-resolve-env

let target = (robot-target)
let key_file = ($env.HETZNER_SSH_KEY? | default $"($env.HOME)/.ssh/id_ed25519")
let root = (^git rev-parse --show-toplevel | str trim)
let bin = $"($root)/target/x86_64-unknown-linux-musl/release/testbed"

if not ($bin | path exists) {
    print --stderr $"ERROR: ($bin) not found."
    print --stderr "  Build it: mise run cross:build"
    exit 1
}

let ssh_opts = ["-o" "StrictHostKeyChecking=no" "-o" "UserKnownHostsFile=/dev/null" "-i" $key_file]
let remote = $"root@($target)"

^scp ...$ssh_opts $bin $"($remote):/usr/local/bin/testbed"
^ssh ...$ssh_opts $remote "chmod +x /usr/local/bin/testbed && testbed --version 2>&1 | head -1"
print $"✓ Deployed to ($target)"
