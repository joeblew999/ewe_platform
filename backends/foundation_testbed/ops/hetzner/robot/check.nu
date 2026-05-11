#!/usr/bin/env nu
# Verify Robot creds work by listing servers.
use ./env.nu *
robot-resolve-env

let servers = (try { robot-get "/server" } catch {|e|
    print --stderr $"✗ Robot API call failed: ($e.msg)"
    print --stderr "  Common cause: wrong webservice user/password."
    exit 1
})

print $"✓ Robot API authenticated. ($servers | length) server\(s\) in account."
