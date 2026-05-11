#!/usr/bin/env nu
# Stop a VM profile on the host.
use ./env.nu *
hetzner-resolve-env

def main [profile: string] {
    let name = ($env.HETZNER_HOST_NAME? | default "testbed-host")
    let key_file = $env.HETZNER_SSH_KEY
    let ip = (hcloud server ip $name | str trim)
    ^ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $key_file $"root@($ip)" $"testbed stop ($profile)"
}
