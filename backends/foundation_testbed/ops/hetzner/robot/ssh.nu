#!/usr/bin/env nu
# Open an interactive SSH session on the AX41.
use ./env.nu *
robot-resolve-env

let target = (robot-target)
let key_file = ($env.HETZNER_SSH_KEY? | default $"($env.HOME)/.ssh/id_ed25519")
^ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $key_file $"root@($target)"
