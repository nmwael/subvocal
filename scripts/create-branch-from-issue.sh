#!/usr/bin/env bash
set -euo pipefail

# create-branch-from-issue.sh
# Creates a git branch from a GitHub issue number
# Usage: ./scripts/create-branch-from-issue.sh --issue NUMBER [--title SLUG] [--base BRANCH]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Creates a git branch named issue/{number}-{slug} from a GitHub issue.

OPTIONS:
    --issue NUMBER      GitHub issue number (required)
    --title SLUG        Branch slug (optional, defaults to issue title)
    --base BRANCH       Base branch (optional, defaults to current branch)
    --dry-run           Show what would be done without executing
    -h, --help          Show this help message

EXAMPLES:
    $(basename "$0") --issue 42
    $(basename "$0") --issue 42 --title "add-subtitle-search"
    $(basename "$0") --issue 42 --base development --dry-run
EOF
    exit 0
}

ISSUE_NUMBER=""
TITLE_SLUG=""
BASE_BRANCH=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --issue)
            ISSUE_NUMBER="$2"
            shift 2
            ;;
        --title)
            TITLE_SLUG="$2"
            shift 2
            ;;
        --base)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            echo "Run with --help for usage" >&2
            exit 1
            ;;
    esac
done

if [[ -z "$ISSUE_NUMBER" ]]; then
    echo "Error: --issue is required" >&2
    echo "Run with --help for usage" >&2
    exit 1
fi

if ! [[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Error: Issue number must be numeric" >&2
    exit 1
fi

if [[ -z "$BASE_BRANCH" ]]; then
    BASE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

if [[ -z "$TITLE_SLUG" ]]; then
    TITLE_SLUG=$(gh issue view "$ISSUE_NUMBER" --json title --jq '.title' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)
fi

BRANCH_NAME="issue/${ISSUE_NUMBER}-${TITLE_SLUG}"

if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
    echo "Error: Branch $BRANCH_NAME already exists" >&2
    exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] Would create branch: $BRANCH_NAME from $BASE_BRANCH"
    echo "[dry-run] Would switch to: $BRANCH_NAME"
    echo "$BRANCH_NAME"
    exit 0
fi

git checkout -b "$BRANCH_NAME" "$BASE_BRANCH"
echo "$BRANCH_NAME"