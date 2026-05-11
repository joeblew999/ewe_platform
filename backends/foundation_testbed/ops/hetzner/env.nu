# Auto-resolve HETZNER_* env vars from existing hcloud state.
# `use ./env.nu *` then call `hetzner-resolve-env`.

export def --env hetzner-resolve-env [] {
    # ── Context: explicit > active context > "testbed" ────────────────────
    let ctx_set = ("HETZNER_CONTEXT" in $env) and (not ($env.HETZNER_CONTEXT | is-empty))
    if not $ctx_set {
        let active = (try { hcloud context active | str trim } catch { "" })
        if ($active | is-empty) {
            $env.HETZNER_CONTEXT = "testbed"
        } else {
            $env.HETZNER_CONTEXT = $active
            print $"→ auto-detected hcloud context: ($active)"
        }
    }
    try { hcloud context use $env.HETZNER_CONTEXT | ignore }

    # ── SSH key: only auto-detect if neither name nor file is set ─────────
    let name_set = ("HETZNER_SSH_KEY_NAME" in $env) and (not ($env.HETZNER_SSH_KEY_NAME | is-empty))
    let file_set = ("HETZNER_SSH_KEY" in $env) and (not ($env.HETZNER_SSH_KEY | is-empty))

    if (not $name_set) and (not $file_set) {
        let remote = (try {
            hcloud ssh-key list -o "columns=name,public_key" -o noheader
            | lines
            | where ($it | str length) > 0
            | each {|l|
                let parts = ($l | split row --regex '\s+')
                { name: ($parts | get 0), key: $"($parts | get 1) ($parts | get 2)" }
            }
        } catch { [] })

        let local = (try {
            glob $"($env.HOME)/.ssh/*.pub"
            | each {|f|
                let parts = (open --raw $f | str trim | split row --regex '\s+')
                { file: $f, key: $"($parts | get 0) ($parts | get 1)" }
            }
        } catch { [] })

        for r in $remote {
            let m = ($local | where key == $r.key | first)
            if $m != null {
                $env.HETZNER_SSH_KEY_NAME = $r.name
                $env.HETZNER_SSH_KEY = ($m.file | str replace ".pub" "")
                print $"→ auto-detected SSH key '($r.name)' ↔ ($env.HETZNER_SSH_KEY)"
                break
            }
        }
    }

    # ── Fallbacks ─────────────────────────────────────────────────────────
    if (not ("HETZNER_SSH_KEY" in $env)) or ($env.HETZNER_SSH_KEY | is-empty) {
        $env.HETZNER_SSH_KEY = $"($env.HOME)/.ssh/id_ed25519"
    }
    if (not ("HETZNER_SSH_KEY_NAME" in $env)) or ($env.HETZNER_SSH_KEY_NAME | is-empty) {
        $env.HETZNER_SSH_KEY_NAME = $"($env.USER)-laptop"
    }
}
