#!/usr/bin/env nu
# Create the persistent testbed host (idempotent).
use ./env.nu *
hetzner-resolve-env

let name = ($env.HETZNER_HOST_NAME? | default "testbed-host")
let server_type = ($env.HETZNER_HOST_TYPE? | default "ccx23")
let image = ($env.HETZNER_HOST_IMAGE? | default "ubuntu-24.04")
let location = ($env.HETZNER_HOST_LOCATION? | default "fsn1")
let key_name = $env.HETZNER_SSH_KEY_NAME

let exists = (try { hcloud server describe $name | ignore; true } catch { false })
if $exists {
    let ip = (hcloud server ip $name | str trim)
    print $"✓ Host '($name)' already exists at ($ip)"
    return
}

print $"Creating ($name) (($server_type), ($image), ($location))..."
hcloud server create --name $name --type $server_type --image $image --location $location --ssh-key $key_name
let ip = (hcloud server ip $name | str trim)
print $"✓ ($name) created at ($ip)"
