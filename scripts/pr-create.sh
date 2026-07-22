#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --title <title> --why <text> --what <text> --how <text> [-l <label>] [--base <branch>]

Create a pull request with the WHY/WHAT/HOW template.

Options:
  --title <title>     PR title (required)
  --why <text>        WHY section (required)
  --what <text>       WHAT section (required)
  --how <text>        HOW section (required)
  -l <label>          GitHub label (default: enhancement)
  --base <branch>     Base branch (default: development)
  -h, --help          Show this help
EOF
  exit 1
}

TITLE=""
WHY=""
WHAT=""
HOW=""
LABEL="enhancement"
BASE="development"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --why) WHY="$2"; shift 2 ;;
    --what) WHAT="$2"; shift 2 ;;
    --how) HOW="$2"; shift 2 ;;
    -l) LABEL="$2"; shift 2 ;;
    --base) BASE="$2"; shift 2 ;;
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

gh pr create --title "$TITLE" --body "$BODY" --base "$BASE" --label "$LABEL"
