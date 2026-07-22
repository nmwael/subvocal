#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--run-id <id>] [--output <dir>]

Download CI test artifacts from the latest or a specific run.

Options:
  --run-id <id>     GitHub Actions run ID (default: latest on current branch)
  --output <dir>    Output directory (default: /tmp/ci-artifacts)
  -h, --help        Show this help
EOF
  exit 1
}

RUN_ID=""
OUTPUT_DIR="/tmp/ci-artifacts"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-id) RUN_ID="$2"; shift 2 ;;
    --output) OUTPUT_DIR="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

BRANCH=$(git branch --show-current)

if [[ -z "$RUN_ID" ]]; then
  echo "🔍 Finding latest run on $BRANCH..."
  RUN_ID=$(gh run list --branch "$BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId')
  if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
    echo "❌ No CI runs found for branch $BRANCH."
    exit 1
  fi
fi

echo "📦 Run: #$RUN_ID"
echo "📁 Output: $OUTPUT_DIR"
echo ""

mkdir -p "$OUTPUT_DIR"

gh api "repos/{owner}/{repo}/actions/runs/$RUN_ID/artifacts" --jq '.artifacts[] | .name' 2>/dev/null | while read -r name; do
  echo "↓ Downloading: $name"
  URL=$(gh api "repos/{owner}/{repo}/actions/runs/$RUN_ID/artifacts" --jq ".artifacts[] | select(.name==\"$name\") | .archive_download_url")
  curl -sL -H "Authorization: token $(gh auth token)" "$URL" -o "$OUTPUT_DIR/$name.zip"
  unzip -o -q "$OUTPUT_DIR/$name.zip" -d "$OUTPUT_DIR/$name" 2>/dev/null || true
done

echo ""
echo "📁 Contents:"
find "$OUTPUT_DIR" -type f -name "*.xml" -o -name "*.json" -o -name "*.png" 2>/dev/null | while read -r f; do
  echo "  $f"
done

echo ""
echo "Done. Artifacts in: $OUTPUT_DIR"
