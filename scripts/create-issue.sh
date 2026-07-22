#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") --title <title> --why <text> --what <text> --how <text> [-l <label>] [--notify]

Create a GitHub issue using the WHY/WHAT/HOW template.

Options:
  --title <title>   Issue title (required)
  --why <text>      WHY section content (required)
  --what <text>     WHAT section content (required)
  --how <text>      HOW section content (required)
  -l <label>        GitHub label (default: enhancement)
  --notify          Run notify.sh after creation
  -h, --help        Show this help
EOF
  exit 1
}

TITLE=""
WHY=""
WHAT=""
HOW=""
LABEL="enhancement"
NOTIFY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --why) WHY="$2"; shift 2 ;;
    --what) WHAT="$2"; shift 2 ;;
    --how) HOW="$2"; shift 2 ;;
    -l) LABEL="$2"; shift 2 ;;
    --notify) NOTIFY=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$TITLE" || -z "$WHY" || -z "$WHAT" || -z "$HOW" ]]; then
  echo "Error: --title, --why, --what, and --how are all required."
  usage
fi

BODY="## WHY
${WHY}

## WHAT
${WHAT}

## HOW
${HOW}"

ISSUE_URL=$(gh issue create --title "$TITLE" --body "$BODY" --label "$LABEL")
echo "$ISSUE_URL"

if [[ "$NOTIFY" == true ]]; then
  "$SCRIPT_DIR/notify.sh" "Plan ready" "Issue created: $TITLE" "$ISSUE_URL"
fi
