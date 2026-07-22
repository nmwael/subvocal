#!/usr/bin/env bash
set -euo pipefail

BASE="development"

BRANCH=$(git branch --show-current)
echo "🌿 Branch: $BRANCH"
echo ""

echo "📊 Status:"
git status --short
echo ""

AHEAD=$(git rev-list --count "origin/$BASE..HEAD" 2>/dev/null || echo "?")
BEHIND=$(git rev-list --count "HEAD..origin/$BASE" 2>/dev/null || echo "?")
echo "📈 Ahead of $BASE: $AHEAD | Behind $BASE: $BEHIND"
echo ""

UNCOMMITTED=$(git diff --stat 2>/dev/null | tail -1)
UNSTAGED=$(git diff --cached --stat 2>/dev/null | tail -1)

if [[ -n "$UNCOMMITTED" ]]; then
  echo "📝 Uncommitted changes:"
  git diff --stat
  echo ""
fi

if [[ -n "$UNSTAGED" ]]; then
  echo "📝 Staged changes:"
  git diff --cached --stat
  echo ""
fi

echo "📅 Recent commits:"
git log --oneline -5
