#!/usr/bin/env nu
# Bring up a ready host: cross-build, create, install QEMU, deploy, doctor (serial).
mise run cross:build
mise run host:up
mise run host:bootstrap
mise run host:deploy
mise run vm:doctor
