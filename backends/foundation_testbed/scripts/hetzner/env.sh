# shellcheck shell=bash
#
# Auto-resolve HETZNER_* env vars from existing hcloud state.
#
# Source this at the top of any task that uses HETZNER_CONTEXT,
# HETZNER_SSH_KEY, or HETZNER_SSH_KEY_NAME. Behaviour:
#
# - If the env var is already set, leave it alone (explicit overrides win).
# - Else, try to detect from current hcloud config:
#     - context  → the active context
#     - SSH key  → the first Hetzner-registered key whose public-key bytes
#                  match a local *.pub file
# - Else, fall back to greenfield defaults (context=testbed, key=$USER-laptop,
#   path=~/.ssh/id_ed25519).
#
# All detection requires `hcloud` to be on PATH. Failures degrade silently
# to defaults — auth failures during list calls are not fatal here.

# ── Context ─────────────────────────────────────────────────────────────
if [ -z "${HETZNER_CONTEXT:-}" ]; then
    HETZNER_CONTEXT="$(hcloud context active 2>/dev/null || true)"
    if [ -n "$HETZNER_CONTEXT" ]; then
        echo "→ auto-detected hcloud context: $HETZNER_CONTEXT"
    else
        HETZNER_CONTEXT="testbed"
    fi
fi
hcloud context use "$HETZNER_CONTEXT" >/dev/null 2>&1 || true

# ── SSH key (only auto-detect if neither name nor file are set) ─────────
if [ -z "${HETZNER_SSH_KEY_NAME:-}" ] && [ -z "${HETZNER_SSH_KEY:-}" ]; then
    while read -r _name _pubkey; do
        [ -z "$_name" ] && continue
        _remote_key="$(echo "$_pubkey" | awk '{print $1" "$2}')"
        for _local_pub in "$HOME"/.ssh/*.pub; do
            [ -f "$_local_pub" ] || continue
            if [ "$_remote_key" = "$(awk '{print $1" "$2}' "$_local_pub")" ]; then
                HETZNER_SSH_KEY_NAME="$_name"
                HETZNER_SSH_KEY="${_local_pub%.pub}"
                echo "→ auto-detected SSH key '$_name' ↔ $HETZNER_SSH_KEY"
                break 2
            fi
        done
    done < <(hcloud ssh-key list -o columns=name,public_key -o noheader 2>/dev/null)
    unset _name _pubkey _remote_key _local_pub
fi

# ── Fallbacks (greenfield) ──────────────────────────────────────────────
: "${HETZNER_SSH_KEY:=$HOME/.ssh/id_ed25519}"
: "${HETZNER_SSH_KEY_NAME:=$USER-laptop}"

export HETZNER_CONTEXT HETZNER_SSH_KEY HETZNER_SSH_KEY_NAME
