#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--fix] [--format] [--ci]

Run dart analyze with optional auto-fix and formatting.

Options:
  --fix      Run dart fix --apply after analysis (only if no errors)
  --format   Run dart format --set-exit-if-changed . after analysis
  --ci       Fail on warnings too (exit non-zero)
  -h, --help Show this help
EOF
  exit 1
}

DO_FIX=false
DO_FORMAT=false
CI_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix) DO_FIX=true; shift ;;
    --format) DO_FORMAT=true; shift ;;
    --ci) CI_MODE=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

EXIT_CODE=0

echo "🔍 Running dart analyze..."
if ! dart analyze; then
  EXIT_CODE=1
  echo "❌ Analysis found errors."
else
  echo "✅ Analysis clean."
fi

if [[ "$EXIT_CODE" -eq 0 ]] && [[ "$DO_FIX" == true ]]; then
  echo ""
  echo "🔧 Running dart fix --dry-run..."
  dart fix --dry-run
  echo ""
  echo "🔧 Applying fixes..."
  dart fix --apply
fi

if [[ "$DO_FORMAT" == true ]]; then
  echo ""
  echo "📝 Checking formatting..."
  if ! dart format --output=none --set-exit-if-changed .; then
    EXIT_CODE=1
    echo "❌ Formatting issues found."
  else
    echo "✅ Formatting clean."
  fi
fi

exit $EXIT_CODE
