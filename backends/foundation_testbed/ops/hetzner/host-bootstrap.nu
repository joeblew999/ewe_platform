#!/usr/bin/env nu
# Install QEMU + KVM userspace on the host (idempotent).
use ./env.nu *
hetzner-resolve-env

let name = ($env.HETZNER_HOST_NAME? | default "testbed-host")
let key_file = $env.HETZNER_SSH_KEY
let ip = try { hcloud server ip $name | str trim } catch {
    print --stderr $"ERROR: host '($name)' not found. Run host:up first."
    exit 1
}

let remote = $'
    set -e
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq qemu-system-x86 qemu-utils ovmf curl tar xz-utils
    echo "✓ QEMU $(qemu-system-x86_64 --version | head -1)"
    if [ -e /dev/kvm ]; then
        echo "✓ /dev/kvm available"
    else
        echo "⚠ /dev/kvm MISSING — QEMU will run in TCG (slow)"
    fi
'
^ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $key_file $"root@($ip)" $remote
