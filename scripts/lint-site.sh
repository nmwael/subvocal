#!/usr/bin/env bash
# Lint the landing page HTML files
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if ! command -v npx &>/dev/null; then
  echo "error: npx not found. Install Node.js first." >&2
  exit 1
fi

echo "Linting landing page HTML..."
npx --yes htmlhint "$REPO_ROOT/site/**/*.html" --config "$REPO_ROOT/.htmlhintrc"
echo "✅ HTML lint passed."
