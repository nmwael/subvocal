#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APPROVAL_KEYWORDS=("approved" "lgtm" "looks good" "go ahead" ":+1:")

usage() {
  echo "Usage: $0 [issue_number] [--timeout <seconds>]"
  echo ""
  echo "Polls GitHub issue comments for human approval, then sends a notification."
  echo ""
  echo "Arguments:"
  echo "  issue_number     GitHub issue number (default: latest open enhancement)"
  echo ""
  echo "Options:"
  echo "  --timeout <sec>  Stop waiting after N seconds (default: 1800 = 30 min)"
  echo ""
  echo "Exits 0 on approval, 1 on timeout."
  exit 1
}

ISSUE_NUMBER=""
TIMEOUT=1800

while [ $# -gt 0 ]; do
  case "$1" in
    --timeout)
      TIMEOUT="$2"; shift 2 ;;
    --help|-h)
      usage ;;
    *)
      if [ -z "$ISSUE_NUMBER" ]; then
        ISSUE_NUMBER="$1"; shift
      else
        usage
      fi
      ;;
  esac
done

if [ -z "$ISSUE_NUMBER" ]; then
  echo -e "${BLUE}${NC} No issue number given, finding latest open enhancement..."
  ISSUE_NUMBER=$(gh issue list --label enhancement --state open --json number --jq '.[0].number')
  if [ -z "$ISSUE_NUMBER" ]; then
    echo -e "${YELLOW}${NC} No open enhancement issues found."
    exit 1
  fi
  echo -e "${GREEN}${NC} Found issue #$ISSUE_NUMBER"
fi

ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUMBER"
echo -e "${BLUE}${NC} Watching $ISSUE_URL for approval comment..."
echo -e "${BLUE}${NC} Timeout: ${TIMEOUT}s (polling every 10s)"
echo ""

POLL_INTERVAL=10
MAX_POLLS=$((TIMEOUT / POLL_INTERVAL))
KNOWN_COUNT=0
POLLS=0

get_comment_count() {
  gh issue view "$ISSUE_NUMBER" --json comments --jq '(.comments | length)' 2>/dev/null || echo 0
}

get_latest_comment_body() {
  gh issue view "$ISSUE_NUMBER" --json comments --jq '(.comments | last | .body // "")' 2>/dev/null || echo ""
}

get_latest_comment_author() {
  gh issue view "$ISSUE_NUMBER" --json comments --jq '(.comments | last | .author.login // "")' 2>/dev/null || echo ""
}

KNOWN_COUNT=$(get_comment_count)

while [ $POLLS -lt $MAX_POLLS ]; do
  sleep "$POLL_INTERVAL"
  POLLS=$((POLLS + 1))

  CURRENT_COUNT=$(get_comment_count)
  if [ "$CURRENT_COUNT" -le "$KNOWN_COUNT" ]; then
    echo -n "."
    continue
  fi

  echo ""
  NEW_COUNT=$((CURRENT_COUNT - KNOWN_COUNT))
  echo -e "${BLUE}${NC} $NEW_COUNT new comment(s) detected"

  LATEST_BODY=$(get_latest_comment_body)
  LATEST_AUTHOR=$(get_latest_comment_author)
  BODY_LOWER=$(echo "$LATEST_BODY" | tr '[:upper:]' '[:lower:]')

  APPROVED=false
  for kw in "${APPROVAL_KEYWORDS[@]}"; do
    KW_LOWER=$(echo "$kw" | tr '[:upper:]' '[:lower:]')
    if echo "$BODY_LOWER" | grep -q "$KW_LOWER"; then
      APPROVED=true
      break
    fi
  done

  if [ "$APPROVED" = true ]; then
    echo -e "${GREEN}${NC} Approval detected from @$LATEST_AUTHOR!"
    "$SCRIPT_DIR/notify.sh" "Plan approved" "Issue #$ISSUE_NUMBER — approved by @$LATEST_AUTHOR — developer starting" "$ISSUE_URL"
    exit 0
  fi

  echo -e "${YELLOW}${NC} Comment from @$LATEST_AUTHOR did not contain approval keywords"
  KNOWN_COUNT=$CURRENT_COUNT
  echo -n "."
done

echo ""
echo -e "${YELLOW}${NC} Timeout reached (${TIMEOUT}s) — no approval comment found"
exit 1
