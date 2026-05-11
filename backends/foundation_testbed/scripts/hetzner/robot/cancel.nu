#!/usr/bin/env nu
# Schedule cancellation of the AX41 at the end of the current billing cycle.
# Reversible until the cycle ends (call robot:cancel-revoke to undo).
use ./env.nu *
robot-resolve-env

let target = (robot-target)
let date = ($env.HETZNER_ROBOT_CANCEL_DATE? | default "now")
# 'now' tells Robot to cancel at the earliest possible date (end of current cycle)

let resp = (robot-post $"/server/($target)/cancellation" $"cancellation_date=($date)")
print $"✓ Cancellation scheduled for ($target): ($resp.cancellation.cancellation_date)"
print $"  Reservation: ($resp.cancellation.reserved? | default 'n/a')"
