#!/usr/bin/env nu
# First-time setup: save token, upload SSH key, run KVM probe (serial).
mise run hcloud:context
mise run hcloud:ssh-key
mise run hil:probe-kvm
