#!/usr/bin/env nu
# Verify hcloud is authenticated against the active project.
# Nushell port of the bash version — pilot for the full ops migration.

let ctx = try { hcloud context active | str trim } catch { "none" }

let authed = try {
    hcloud server list | ignore
    true
} catch {
    false
}

if not $authed {
    print --stderr $"✗ hcloud not authenticated for context '($ctx)'."
    print --stderr "  Run: mise run hcloud:context"
    exit 1
}

print $"✓ Authenticated as context '($ctx)'"
