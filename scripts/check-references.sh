#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <search-text> [--paths <dir1,dir2,...>] [--ignore-case]

Search for stale text references across the codebase.

Options:
  <search-text>    Text to search for (required, first positional arg)
  --paths <dirs>   Comma-separated directories (default: lib,test,integration_test)
  --ignore-case    Case-insensitive search
  -h, --help       Show this help
EOF
  exit 1
}

SEARCH_TEXT=""
PATHS="lib,test,integration_test"
IGNORE_CASE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --paths) PATHS="$2"; shift 2 ;;
    --ignore-case) IGNORE_CASE="-i"; shift ;;
    -h|--help) usage ;;
    -*) echo "Unknown option: $1"; usage ;;
    *)
      if [[ -z "$SEARCH_TEXT" ]]; then
        SEARCH_TEXT="$1"; shift
      else
        echo "Unexpected argument: $1"; usage
      fi
      ;;
  esac
done

if [[ -z "$SEARCH_TEXT" ]]; then
  echo "Error: search text is required."
  usage
fi

IFS=',' read -ra DIRS <<< "$PATHS"

echo "🔍 Searching for: $SEARCH_TEXT"
echo "   Paths: ${DIRS[*]}"
echo ""

MATCH_COUNT=0
for dir in "${DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    while IFS= read -r line; do
      if [[ -n "$line" ]]; then
        echo "  $line"
        MATCH_COUNT=$((MATCH_COUNT + 1))
      fi
    done < <(grep -rn $IGNORE_CASE "$SEARCH_TEXT" "$dir" 2>/dev/null || true)
  fi
done

echo ""
if [[ $MATCH_COUNT -gt 0 ]]; then
  echo "⚠️  Found $MATCH_COUNT stale reference(s)."
  exit 1
else
  echo "✅ No references found."
  exit 0
fi
