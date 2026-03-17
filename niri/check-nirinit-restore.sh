#!/usr/bin/env bash
set -u

echo "=== nirinit restore health check ==="
echo

echo "[1] Service state"
systemctl --user is-active nirinit.service || true

echo
echo "[2] Current-boot nirinit logs (last 60 lines)"
journalctl --user -u nirinit.service -b --no-pager -n 60 || true

echo
echo "[3] Generated launcher wrappers"
ls -la /run/user/1000/nirinit-launchers || true

echo
echo "[4] Saved launch commands (from session.json)"
jq -r '.[].launch_command // empty' "$HOME/.local/share/nirinit/session.json" 2>/dev/null | sort -u || true
