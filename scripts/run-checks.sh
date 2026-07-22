#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--fix] [--format] [--ci]

Run all pre-commit checks: dart analyze + flutter test + format check.

Options:
  --fix       Auto-fix analysis issues after check
  --format    Also check dart format
  --ci        Strict mode — fail on warnings
  -h, --help  Show this help
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXIT_CODE=0

echo "═══════════════════════════════════════"
echo " Pre-commit checks"
echo "═══════════════════════════════════════"
echo ""

# 1. Analyze
echo "🔍 Step 1: dart analyze"
ANALYZE_ARGS=()
[[ "$CI_MODE" == true ]] && ANALYZE_ARGS+=(--ci)
if ! "$SCRIPT_DIR/analyze.sh" "${ANALYZE_ARGS[@]+"${ANALYZE_ARGS[@]}"}"; then
  EXIT_CODE=1
  echo "❌ Analysis failed."
else
  echo "✅ Analysis clean."
fi
echo ""

# 2. Format
if [[ "$DO_FORMAT" == true ]]; then
  echo "📝 Step 2: dart format"
  if ! dart format --output=none --set-exit-if-changed .; then
    EXIT_CODE=1
    echo "❌ Formatting issues found."
  else
    echo "✅ Formatting clean."
  fi
  echo ""
fi

# 3. Tests
echo "🧪 Step 3: flutter test"
TEST_ARGS=()
[[ "$CI_MODE" == true ]] && TEST_ARGS+=(--ci)
if ! "$SCRIPT_DIR/run-tests.sh" "${TEST_ARGS[@]+"${TEST_ARGS[@]}"}"; then
  EXIT_CODE=1
  echo "❌ Tests failed."
else
  echo "✅ All tests passed."
fi
echo ""

echo "═══════════════════════════════════════"
if [[ "$EXIT_CODE" -eq 0 ]]; then
  echo "✅ All checks passed. Ready to commit."
else
  echo "❌ Some checks failed. Fix issues before committing."
fi
echo "═══════════════════════════════════════"

exit $EXIT_CODE
