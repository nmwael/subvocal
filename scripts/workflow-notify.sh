#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <status> [message]

Look up the latest open enhancement issue and send a workflow notification.

Statuses:
  plan-ready    "Plan ready"
  approved      "Plan approved"
  implementing  "Developer starting"
  impl-done     "Implementation done"
  tests-done    "Tests done"
  audit-done    "Security audit done"
  ux-done       "UX/UI review done"

Options:
  <status>      Workflow status (required)
  <message>     Additional context message (optional)
  -h, --help    Show this help
EOF
  exit 1
}

STATUS=""
MESSAGE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    -*) echo "Unknown option: $1"; usage ;;
    *)
      if [[ -z "$STATUS" ]]; then
        STATUS="$1"; shift
      elif [[ -z "$MESSAGE" ]]; then
        MESSAGE="$1"; shift
      else
        echo "Unexpected argument: $1"; usage
      fi
      ;;
  esac
done

if [[ -z "$STATUS" ]]; then
  echo "Error: status is required."
  usage
fi

# Find latest open enhancement issue
ISSUE_JSON=$(gh issue list --label enhancement --state open --json number,title --jq '.[0]' 2>/dev/null || echo "null")

if [[ "$ISSUE_JSON" == "null" || -z "$ISSUE_JSON" ]]; then
  echo "⚠️  No open enhancement issues found."
  exit 1
fi

ISSUE_NUM=$(echo "$ISSUE_JSON" | jq -r '.number')
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUM"

# Map status to notification title
case "$STATUS" in
  plan-ready)    TITLE="Plan ready" ;;
  approved)      TITLE="Plan approved" ;;
  implementing)  TITLE="Developer starting" ;;
  impl-done)     TITLE="Implementation done" ;;
  tests-done)    TITLE="Tests done" ;;
  audit-done)    TITLE="Security audit done" ;;
  ux-done)       TITLE="UX/UI review done" ;;
  *)
    echo "Unknown status: $STATUS"
    usage
    ;;
esac

BODY="Issue #$ISSUE_NUM: $ISSUE_TITLE"
if [[ -n "$MESSAGE" ]]; then
  BODY="$BODY — $MESSAGE"
fi

"$SCRIPT_DIR/notify.sh" "$TITLE" "$BODY" "$ISSUE_URL"
