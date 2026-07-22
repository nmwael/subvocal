#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") -m <message> [--type <type>] [--all] [--files <f1> <f2> ...] [--dry-run]

Stage, create a signed commit, and push.

Options:
  -m <message>    Commit message body (required)
  --type <type>   Conventional commit type: feat, fix, doc, chore, refactor, test (default: chore)
  --all           Stage all changes (git add -A)
  --files <f...>  Stage specific files
  --dry-run       Show what would happen without executing
  -h, --help      Show this help
EOF
  exit 1
}

MESSAGE=""
TYPE="chore"
STAGE_ALL=false
FILES=()
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m) MESSAGE="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --all) STAGE_ALL=true; shift ;;
    --files) shift; while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do FILES+=("$1"); shift; done ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$MESSAGE" ]]; then
  echo "Error: -m <message> is required."
  usage
fi

if [[ "$STAGE_ALL" == false ]] && [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Error: specify --all or --files <f1> <f2> ..."
  usage
fi

FULL_MESSAGE="${TYPE}: ${MESSAGE}"

# Check GPG card status (informational only — socket may still work)
echo "🔐 Checking GPG card status..."
CARD_STATUS=$(gpg --card-status 2>&1 || true)
if echo "$CARD_STATUS" | grep -qi "forbidden\|no card"; then
  echo "⚠️  GPG card not directly accessible (signing may still work via forwarded socket)"
fi

# Stage files
if [[ "$STAGE_ALL" == true ]]; then
  echo "📦 Staging all changes..."
  git add -A
else
  echo "📦 Staging: ${FILES[*]}"
  git add "${FILES[@]}"
fi

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "DRY RUN — would execute:"
  echo "  git commit -S -m \"$FULL_MESSAGE\""
  echo "  git push"
  echo ""
  git status --short
  exit 0
fi

# Commit
echo "✍️  Committing: $FULL_MESSAGE"
if ! git commit -S -m "$FULL_MESSAGE"; then
  echo "❌ Commit failed."
  exit 1
fi

# Push
echo "🚀 Pushing..."
if ! git push; then
  echo "❌ Push failed."
  exit 1
fi

echo ""
echo "✅ Done. Signed commit:"
git log --show-signature -1
