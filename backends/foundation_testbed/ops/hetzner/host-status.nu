#!/usr/bin/env nu
# Show host state + all servers/keys in the project.
print "=== Active context ==="
try { hcloud context active } catch { print "(none)" }
print ""
print "=== Servers ==="
hcloud server list
print ""
print "=== SSH keys ==="
hcloud ssh-key list
