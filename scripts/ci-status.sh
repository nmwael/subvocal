#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--branch <name>] [--artifacts] [--limit <n>]

Check CI run status and optionally download test artifacts.

Options:
  --branch <name>     Filter by branch (default: current branch)
  --artifacts         Download test result artifacts
  --limit <n>         Number of runs to show (default: 3)
  -h, --help          Show this help
EOF
  exit 1
}

BRANCH=""
ARTIFACTS=false
LIMIT=3

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) BRANCH="$2"; shift 2 ;;
    --artifacts) ARTIFACTS=true; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$BRANCH" ]]; then
  BRANCH=$(git branch --show-current)
fi

echo "📋 Latest $LIMIT CI runs on $BRANCH:"
echo ""

gh run list --branch "$BRANCH" --limit "$LIMIT" --json databaseId,displayTitle,status,conclusion,headBranch,createdAt \
  --jq '.[] | "  #\(.databaseId)  \(.status)/\(.conclusion // "—")  \(.displayTitle)  \(.createdAt)"'

echo ""

LATEST=$(gh run list --branch "$BRANCH" --limit 1 --json databaseId,conclusion --jq '.[0]')
RUN_ID=$(echo "$LATEST" | jq -r '.databaseId')
CONCLUSION=$(echo "$LATEST" | jq -r '.conclusion // "in_progress"')

if [[ "$CONCLUSION" == "in_progress" ]]; then
  echo "⏳ Run #$RUN_ID is still in progress..."
  exit 0
fi

if [[ "$CONCLUSION" != "success" ]]; then
  echo "❌ Run #$RUN_ID finished: $CONCLUSION"
  echo "   View: $(gh run view "$RUN_ID" --json url --jq '.url')"
fi

if [[ "$ARTIFACTS" == true ]]; then
  echo ""
  echo "📦 Downloading test artifacts from run #$RUN_ID..."
  ARTIFACTS_DIR="/tmp/ci-artifacts-$$"
  mkdir -p "$ARTIFACTS_DIR"

  gh api "repos/{owner}/{repo}/actions/runs/$RUN_ID/artifacts" --jq '.artifacts[] | .name' 2>/dev/null | while read -r name; do
    echo "  ↓ $name"
    URL=$(gh api "repos/{owner}/{repo}/actions/runs/$RUN_ID/artifacts" --jq ".artifacts[] | select(.name==\"$name\") | .archive_download_url")
    curl -sL -H "Authorization: token $(gh auth token)" "$URL" -o "$ARTIFACTS_DIR/$name.zip"
    unzip -o -q "$ARTIFACTS_DIR/$name.zip" -d "$ARTIFACTS_DIR/$name" 2>/dev/null || true
    # Show test result summary if present
    if [[ -f "$ARTIFACTS_DIR/$name/unit-test-results.xml" ]]; then
      echo "  📊 Unit tests:"
      grep -E 'tests=|failures=|errors=' "$ARTIFACTS_DIR/$name/unit-test-results.xml" | head -1
    fi
    if [[ -f "$ARTIFACTS_DIR/$name/integration-results.json" ]]; then
      TOTAL=$(grep -c '"type":"testDone"' "$ARTIFACTS_DIR/$name/integration-results.json" 2>/dev/null || echo "?")
      FAILS=$(grep '"result":"error"' "$ARTIFACTS_DIR/$name/integration-results.json" 2>/dev/null | wc -l || echo "?")
      echo "  📊 Integration tests: $TOTAL total, $FAILS failed"
    fi
  done
  echo ""
  echo "📁 Artifacts saved to: $ARTIFACTS_DIR"
fi
