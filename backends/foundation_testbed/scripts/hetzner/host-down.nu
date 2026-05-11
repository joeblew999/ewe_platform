#!/usr/bin/env nu
# Delete the persistent testbed host (the ONLY way to remove it).
let name = ($env.HETZNER_HOST_NAME? | default "testbed-host")
hcloud server delete $name
print $"✓ ($name) deleted"
