#!/usr/bin/env nu
# Upload local SSH public key to Hetzner Cloud (idempotent).
use ./env.nu *
hetzner-resolve-env

let key_file = $env.HETZNER_SSH_KEY
let key_name = $env.HETZNER_SSH_KEY_NAME
let pub = $"($key_file).pub"

if not ($pub | path exists) {
    print --stderr $"ERROR: ($pub) not found."
    print --stderr $"       Generate one with: ssh-keygen -t ed25519 -f ($key_file)"
    print --stderr "       Or point at an existing key: $env.HETZNER_SSH_KEY = /path/to/private_key"
    exit 1
}

let registered = (try { hcloud ssh-key describe $key_name | ignore; true } catch { false })
if $registered {
    print $"✓ SSH key '($key_name)' already registered with Hetzner"
} else {
    hcloud ssh-key create --name $key_name --public-key-from-file $pub
    print $"✓ Uploaded ($pub) as Hetzner key '($key_name)'"
}
