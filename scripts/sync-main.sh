#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--base <branch>] [--rebase] [--merge] [--dry-run]

Sync current branch with a base branch.

Options:
  --base <branch>   Base branch to sync with (default: development)
  --rebase          Use rebase instead of merge (default)
  --merge           Use merge instead of rebase
  --dry-run         Show what would happen without executing
  -h, --help        Show this help
EOF
  exit 1
}

BASE="development"
MODE="rebase"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) BASE="$2"; shift 2 ;;
    --rebase) MODE="rebase"; shift ;;
    --merge) MODE="merge"; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

CURRENT=$(git branch --show-current)
if [[ "$CURRENT" == "$BASE" ]]; then
  echo "❌ Already on $BASE. Nothing to sync."
  exit 1
fi

echo "📥 Fetching latest from origin..."
git fetch origin

AHEAD=$(git rev-list --count "origin/$BASE..HEAD")
BEHIND=$(git rev-list --count "HEAD..origin/$BASE")

echo "   Branch: $CURRENT"
echo "   Ahead of $BASE: $AHEAD commits"
echo "   Behind $BASE: $BEHIND commits"

if [[ "$BEHIND" -eq 0 ]]; then
  echo "✅ Already up to date with $BASE."
  exit 0
fi

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "DRY RUN — would execute:"
  if [[ "$MODE" == "rebase" ]]; then
    echo "  git rebase origin/$BASE"
  else
    echo "  git merge origin/$BASE"
  fi
  exit 0
fi

echo ""
if [[ "$MODE" == "rebase" ]]; then
  echo "🔄 Rebasing onto origin/$BASE..."
  if ! git rebase "origin/$BASE"; then
    echo "❌ Rebase failed. Resolve conflicts, then run: git rebase --continue"
    exit 1
  fi
else
  echo "🔀 Merging origin/$BASE..."
  if ! git merge "origin/$BASE"; then
    echo "❌ Merge failed. Resolve conflicts, then complete the merge."
    exit 1
  fi
fi

echo "✅ Synced $CURRENT with $BASE."
git log --oneline -3
