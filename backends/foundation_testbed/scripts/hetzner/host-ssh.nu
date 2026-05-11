#!/usr/bin/env nu
# Open an interactive SSH session on the host.
use ./env.nu *
hetzner-resolve-env

let name = ($env.HETZNER_HOST_NAME? | default "testbed-host")
let key_file = $env.HETZNER_SSH_KEY
let ip = (hcloud server ip $name | str trim)
^ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $key_file $"root@($ip)"
