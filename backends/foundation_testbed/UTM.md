# foundation_testbed on macOS via UTM

Default dev workflow. Run testbed VMs **locally on your Mac** with
Hypervisor.framework hardware acceleration via UTM. No cross-compile, no
SSH, no cloud bill.

The mise tasks in `mise.toml` are the single source of truth.
This doc explains the **shape** of the local-Mac workflow.
For remote / Linux deploys, see [HETZNER.md](HETZNER.md).

## Why this path

| | Local + UTM (this doc) | Remote + Hetzner |
|---|---|---|
| Setup | Install UTM.app, done | Token + ssh key + cross-build + deploy |
| Acceleration | Hypervisor.framework | KVM (Linux only) |
| Cost | $0 | ~€0.02–€0.05/hr |
| Iteration speed | Native, instant | SSH round-trip |
| Constraint | Single Mac's RAM/cores | Whatever you provision |

Pick local for day-to-day dev. Pick Hetzner for: CI, Linux-specific
behavior, workloads bigger than your laptop.

## Prereqs

Just one thing:

- **UTM.app** at `/Applications/UTM.app` — install from
  [mac.getutm.app](https://mac.getutm.app) (or the Mac App Store)

That's it. The cargo build pulls in the `utm` provider via the
`all-providers` feature.

## Task surface

Run from inside `backends/foundation_testbed/`.

| Task | What |
|---|---|
| `check` | Verify UTM.app is present |
| `build` | Native release build with `cli + all-providers` |
| `doctor` | Build + run testbed health check |
| `start <profile>` | Boot a VM (`linux-build` default), provider auto-picked |
| `stop  <profile>` | Stop a VM |
| `test` | Run unit tests |
| `clippy` | Lint with deny-warnings |

## Typical session

```bash
cd backends/foundation_testbed

mise run check                    # verifies UTM.app
mise run doctor                   # sanity check the host
mise run start  linux-build       # boots UTM VM with acceleration
# ... work in the VM ...
mise run stop   linux-build
```

## Default profile RAM (from `src/config.rs`)

| Profile | RAM |
|---|---|
| `linux-build` (heavy) | 12 GB |
| `windows-build` (heavy) | 12 GB |
| `linux-build` (minimal) | 4 GB |
| `windows-build` (minimal) | 4 GB |

Override via the profile config; see the testbed's
[README.md](README.md) for details.

## What this isn't

- **Not a deploy target.** UTM runs on your laptop; if your Mac is
  asleep, the VMs are paused. For continuous runs use Hetzner.
- **Not for Windows builds at scale.** A single Mac with 32 GB can host
  one or two heavy VMs concurrently; for parallel matrix builds go
  remote.

## Status

- `check` task verified: UTM.app detected.
- `build` / `cross:build` / `doctor` all compile with
  `--features cli,all-providers` so the UTM provider is actually in the
  binary.
- `start` / `stop` fixed to include the `cli` feature (without it the
  `[[bin]]` skips because `required-features = ["cli"]`).
