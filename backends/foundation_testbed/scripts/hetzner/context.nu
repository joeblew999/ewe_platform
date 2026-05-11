#!/usr/bin/env nu
# Save Hetzner API token in hcloud's local config (idempotent, interactive).
use ./env.nu *
hetzner-resolve-env

let ctx = $env.HETZNER_CONTEXT
let exists = (try { hcloud context list | str contains $ctx } catch { false })
if $exists {
    print $"✓ hcloud context '($ctx)' already exists"
} else {
    print $"Creating hcloud context '($ctx)' — paste your API token when prompted:"
    hcloud context create $ctx
}
hcloud context use $ctx
print $"Active: (hcloud context active | str trim)"
