#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--unit] [--widget] [--integration] [--file <path>] [--coverage] [--all]

Run Flutter tests by category.

Options:
  --unit          Run only test/unit/
  --widget        Run only test/widgets/
  --integration   Run only integration_test/
  --file <path>   Run a specific test file
  --coverage      Generate coverage report
  --all           Run all tests (default)
  -h, --help      Show this help
EOF
  exit 1
}

RUN_UNIT=false
RUN_WIDGET=false
RUN_INTEGRATION=false
RUN_FILE=""
RUN_ALL=false
COVERAGE=false
ANY_FILTER=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --unit) RUN_UNIT=true; ANY_FILTER=true; shift ;;
    --widget) RUN_WIDGET=true; ANY_FILTER=true; shift ;;
    --integration) RUN_INTEGRATION=true; ANY_FILTER=true; shift ;;
    --file) RUN_FILE="$2"; ANY_FILTER=true; shift 2 ;;
    --coverage) COVERAGE=true; shift ;;
    --all) RUN_ALL=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ "$ANY_FILTER" == false ]]; then
  RUN_ALL=true
fi

EXTRA_ARGS=()
if [[ "$COVERAGE" == true ]]; then
  EXTRA_ARGS+=(--coverage=coverage/)
fi

EXIT_CODE=0

run() {
  echo "▶ Running: $*"
  if ! "$@"; then
    EXIT_CODE=1
  fi
  echo ""
}

if [[ "$RUN_ALL" == true ]] || [[ "$RUN_UNIT" == true ]]; then
  run flutter test test/unit/ "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
fi

if [[ "$RUN_ALL" == true ]] || [[ "$RUN_WIDGET" == true ]]; then
  run flutter test test/widgets/ "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
fi

if [[ "$RUN_ALL" == true ]]; then
  run flutter test test/widget_test.dart "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
fi

if [[ "$RUN_INTEGRATION" == true ]]; then
  run flutter test integration_test/ "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
fi

if [[ -n "$RUN_FILE" ]]; then
  run flutter test "$RUN_FILE" "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}"
fi

if [[ "$COVERAGE" == true ]] && [[ -f coverage/lcov.info ]]; then
  echo "📊 Coverage report: coverage/lcov.info"
fi

exit $EXIT_CODE
