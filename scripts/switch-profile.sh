#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-}"

if [ -z "$PROFILE" ]; then
  echo "Select profile:"
  echo "  1) OpenCode  (all agents use opencode/big-pickle)"
  echo "  2) NVIDIA    (agents use NVIDIA models)"
  echo ""
  read -rp "Choice [1/2]: " PROFILE
fi

case "$PROFILE" in
  1|opencode)
    echo "Already on OpenCode profile (opencode.json)"
    ;;
  2|nvidia)
    cp opencode.json opencode.json.bak
    cp opencode.nvidia.json opencode.json
    echo "Switched to NVIDIA profile"
    echo "Previous config backed up to opencode.json.bak"
    ;;
  *)
    echo "Usage: $0 {1|2|opencode|nvidia}"
    echo "  1, opencode    All agents use opencode/big-pickle (default)"
    echo "  2, nvidia      Agents use NVIDIA models (requires NVIDIA_API_KEY)"
    exit 1
    ;;
esac

echo "Restart opencode for changes to take effect."
