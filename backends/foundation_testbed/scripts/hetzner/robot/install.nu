#!/usr/bin/env nu
# Run installimage over rescue SSH to install a fresh Linux.
# Assumes the server is currently in rescue mode (run robot:rescue first
# and wait ~2 min for it to boot).
use ./env.nu *
robot-resolve-env

let target = (robot-target)
let key_file = ($env.HETZNER_SSH_KEY? | default $"($env.HOME)/.ssh/id_ed25519")
let hostname = ($env.HETZNER_ROBOT_HOSTNAME? | default "testbed-ax41")

# Minimal installimage autosetup template (Ubuntu 24.04, software RAID1 on
# 2× NVMe, default partitioning). Adjust to taste.
let autosetup = $'
HOSTNAME ($hostname)
DRIVE1 /dev/nvme0n1
DRIVE2 /dev/nvme1n1
SWRAID 1
SWRAIDLEVEL 1
PART /boot ext3 1024M
PART lvm vg0 all
LV vg0 root / ext4 50G
LV vg0 swap swap swap 4G
IMAGE /root/.oldroot/nfs/install/../images/Ubuntu-2404-noble-amd64-base.tar.gz
'

let ssh_opts = ["-o" "StrictHostKeyChecking=no" "-o" "UserKnownHostsFile=/dev/null" "-i" $key_file]
let remote = $"root@($target)"

print $"Writing /autosetup on ($target)..."
echo $autosetup | ^ssh ...$ssh_opts $remote "cat > /autosetup"

print "Running installimage..."
^ssh ...$ssh_opts $remote "/root/.oldroot/nfs/install/installimage -a -c /autosetup"

print "Rebooting into installed system (this leaves rescue)..."
^ssh ...$ssh_opts $remote "shutdown -r now"
print $"✓ installimage triggered. Wait ~5 min, then ssh root@($target) (real Linux)."
