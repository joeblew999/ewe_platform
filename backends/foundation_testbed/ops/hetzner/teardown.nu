#!/usr/bin/env nu
# Delete ALL servers + SSH keys + local context (full reset).
use ./env.nu *
hetzner-resolve-env

let ctx = $env.HETZNER_CONTEXT

print "Deleting all servers..."
let servers = (try { hcloud server list -o "columns=name" -o noheader | lines | where ($it | str length) > 0 } catch { [] })
for name in $servers {
    hcloud server delete $name
    print $"  deleted server: ($name)"
}

print "Deleting all SSH keys..."
let keys = (try { hcloud ssh-key list -o "columns=name" -o noheader | lines | where ($it | str length) > 0 } catch { [] })
for name in $keys {
    hcloud ssh-key delete $name
    print $"  deleted ssh-key: ($name)"
}

print $"Removing local context '($ctx)'..."
try { hcloud context delete $ctx | ignore }

print ""
print "✓ Hetzner resources + local context cleared."
print ""
print "To fully delete the Hetzner project itself (the empty shell + revoke"
print "the API token), do it in the web console:"
print "  https://console.hetzner.cloud → project → Settings → bottom of page"
