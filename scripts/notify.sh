#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOPIC="${NTFY_TOPIC:-subvocal-hitl}"
NTFY_URL="https://ntfy.sh/$TOPIC"

usage() {
  echo "Usage: $0 <title> <message> [issue_url]"
  echo ""
  echo "Sends a push notification via ntfy.sh."
  echo ""
  echo "Arguments:"
  echo "  title      Short notification title (e.g. 'Plan ready')"
  echo "  message    Notification body text"
  echo "  issue_url  GitHub issue URL — makes notification clickable (optional)"
  echo ""
  echo "Environment:"
  echo "  NTFY_TOPIC  ntfy.sh topic (default: subvocal-hitl)"
  exit 1
}

if [ $# -lt 2 ]; then
  usage
fi

TITLE="${1//$'\n'/}"
TITLE="${TITLE//$'\r'/}"
MESSAGE="${2//$'\n'/}"
MESSAGE="${MESSAGE//$'\r'/}"
ISSUE_URL="${3:-}"

echo -e "${BLUE}[notify]${NC} $TITLE — $MESSAGE"

CURL_OPTS=(
  -H "Title: $TITLE"
  -H "Tags: bell"
  -d "$MESSAGE"
)
if [ -n "$ISSUE_URL" ]; then
  CURL_OPTS+=(-H "Click: $ISSUE_URL")
fi

curl -s -o /dev/null -w "%{http_code}" \
  "${CURL_OPTS[@]}" \
  "$NTFY_URL" 2>/dev/null | grep -q 200 && {
  echo -e "  ${GREEN}✓${NC} Notification sent (topic: $TOPIC)"
  [ -n "$ISSUE_URL" ] && echo -e "  ${YELLOW}🔗${NC} $ISSUE_URL"
} || {
  echo -e "  ${RED}✗${NC} Notification failed (topic: $TOPIC)"
}
