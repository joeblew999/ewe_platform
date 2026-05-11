#!/usr/bin/env nu
# Activate Linux rescue mode and reboot the server.
# After ~2 min the server boots into rescue Linux; ssh root@IP with the
# rescue root password (returned by this task) OR with your SSH key
# (preferred — pass keys via the env.SSH_KEYS env var if needed).
use ./env.nu *
robot-resolve-env

let target = (robot-target)
print $"Activating rescue mode on ($target)..."
let rescue = (robot-post $"/boot/($target)/rescue" "os=linux&arch=64")
print $"✓ Rescue activated. Root password: ($rescue.rescue.password)"

print $"Triggering hardware reset on ($target)..."
robot-post $"/reset/($target)" "type=hw"
print "✓ Reset triggered. Wait ~2 min, then ssh root@($target) (rescue Linux)."
