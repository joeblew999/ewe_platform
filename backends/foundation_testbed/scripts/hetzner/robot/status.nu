#!/usr/bin/env nu
# List dedicated servers and their state.
use ./env.nu *
robot-resolve-env

print "=== Robot servers ==="
let servers = (robot-get "/server")
$servers | each {|s|
    {
        number: $s.server.server_number,
        ip: $s.server.server_ip,
        product: $s.server.product,
        dc: $s.server.dc,
        status: $s.server.status,
        cancelled: $s.server.cancelled,
        paid_until: $s.server.paid_until,
    }
}
