#!/usr/bin/env nu
# Throwaway probe: spin a small CCX, check /dev/kvm, destroy.
use ./env.nu *
hetzner-resolve-env

let name = $"kvm-probe-(date now | format date '%s')"
let key_file = $env.HETZNER_SSH_KEY
let key_name = $env.HETZNER_SSH_KEY_NAME
let location = ($env.HETZNER_HOST_LOCATION? | default "fsn1")
let server_type = ($env.HETZNER_PROBE_TYPE? | default "ccx13")
let image = ($env.HETZNER_HOST_IMAGE? | default "ubuntu-24.04")

# Always clean up the probe server, even on error
def --env cleanup [name: string] {
    print $"Cleaning up ($name)..."
    try { hcloud server delete $name | ignore }
}

try {
    print $"Creating ($name) (($server_type), ($image), ($location))..."
    hcloud server create --name $name --type $server_type --image $image --location $location --ssh-key $key_name

    let ip = (hcloud server ip $name | str trim)
    print $"IP: ($ip) — waiting for SSH..."

    let ssh_opts = ["-o" "StrictHostKeyChecking=no" "-o" "UserKnownHostsFile=/dev/null" "-o" "ConnectTimeout=3" "-i" $key_file]
    let target = $"root@($ip)"

    mut up = false
    for i in 1..30 {
        let ok = (try { ^ssh ...$ssh_opts $target "echo ready" | ignore; true } catch { false })
        if $ok {
            print "✓ SSH up"
            $up = true
            break
        }
        sleep 5sec
    }
    if not $up {
        print --stderr "✗ SSH never came up"
        cleanup $name
        exit 1
    }

    print ""
    print "=== KVM probe results ==="
    let probe = '
        echo "/dev/kvm:"
        ls -l /dev/kvm 2>&1 | sed "s/^/  /"
        echo "CPU virt flags:"
        grep -E -o "vmx|svm" /proc/cpuinfo | sort -u | sed "s/^/  /"
        echo "Nested KVM enabled:"
        cat /sys/module/kvm_intel/parameters/nested 2>/dev/null | sed "s/^/  intel: /"
        cat /sys/module/kvm_amd/parameters/nested 2>/dev/null | sed "s/^/  amd: /"
    '
    ^ssh ...$ssh_opts $target $probe
    cleanup $name
} catch {|e|
    print --stderr $"Error during probe: ($e.msg)"
    cleanup $name
    exit 1
}
