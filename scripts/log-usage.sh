#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DB_PATH="${OPENCODE_DB:-$HOME/.local/share/opencode/opencode.db}"
LOG_DIR="$PROJECT_DIR/.aifinops"
LOG_FILE="$LOG_DIR/log.csv"
HEADER="timestamp,session_id,issue,agent,model,tokens_input,tokens_output,tokens_reasoning,cache_read,cache_write,cost_usd,parent_session_id"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Log AI token usage from the OpenCode database.

Reads the local opencode.db SQLite database, finds the most recently
updated top-level session (or a specific one), and appends one CSV row per
session to .aifinops/log.csv: the session itself plus every subagent (child)
session under it. Each row keeps its own session_id, agent role, and model,
so usage from all roles (architect, developer, tester, security-auditor,
ux-ui, explore, general) is accounted for separately.

Options:
  --session-id ID   Log a specific session (default: latest top-level session)
  --issue NUM       GitHub issue number (default: auto-detect from latest open enhancement)
  --agent ROLE      Override agent role for the top-level row only (default: auto-detect)
  --dry-run         Print the CSV rows without writing to the file
  -h, --help        Show this help

Data source: OpenCode tracks per-message cost and tokens in its SQLite
database (~/.local/share/opencode/opencode.db). The session table has
pre-aggregated totals. Child (subagent) sessions are linked via parent_id.
Rows are deduplicated by session_id, so re-running does not re-append
already-logged sessions.
EOF
  exit 1
}

SESSION_ID=""
ISSUE=""
AGENT=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --session-id) SESSION_ID="$2"; shift 2 ;;
    --issue) ISSUE="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ ! -f "$DB_PATH" ]]; then
  echo "Error: OpenCode database not found at $DB_PATH"
  exit 1
fi

# Ensure log directory and header exist
mkdir -p "$LOG_DIR"
if [[ ! -f "$LOG_FILE" ]]; then
  echo "$HEADER" > "$LOG_FILE"
fi

# Query the database: emits one CSV line per session (parent first, then children).
ROWS=$(python3 -c "
import sqlite3, json, sys
conn = sqlite3.connect('$DB_PATH')
conn.row_factory = sqlite3.Row
c = conn.cursor()

COLS = 'id, parent_id, title, agent, model, tokens_input, tokens_output, tokens_reasoning, tokens_cache_read, tokens_cache_write, cost'

def model_name(raw):
    if not raw:
        return ''
    try:
        obj = json.loads(raw)
        return obj.get('id', raw)
    except (json.JSONDecodeError, TypeError):
        return raw

def csv_safe(v):
    return str(v).replace(',', ';')

session_id = '''$SESSION_ID'''
if session_id:
    c.execute(f'SELECT {COLS} FROM session WHERE id = ?', (session_id,))
else:
    c.execute(f'SELECT {COLS} FROM session WHERE parent_id IS NULL ORDER BY time_updated DESC LIMIT 1')

r = c.fetchone()
if not r:
    print('ERROR:No session found', file=sys.stderr)
    sys.exit(1)

def emit(row, parent_id):
    total = (row['tokens_input'] or 0) + (row['tokens_output'] or 0) + (row['tokens_reasoning'] or 0) + (row['cost'] or 0)
    if total == 0:
        return
    print(f'{row[\"id\"]},{csv_safe(row[\"title\"])},{csv_safe(row[\"agent\"])},{csv_safe(model_name(row[\"model\"]))},' + \
          f'{row[\"tokens_input\"] or 0},{row[\"tokens_output\"] or 0},{row[\"tokens_reasoning\"] or 0},' + \
          f'{row[\"tokens_cache_read\"] or 0},{row[\"tokens_cache_write\"] or 0},{row[\"cost\"] or 0:.6f},{parent_id}')

emit(r, r['parent_id'] or '')

c.execute(f'SELECT {COLS} FROM session WHERE parent_id = ? ORDER BY time_updated', (r['id'],))
for ch in c.fetchall():
    emit(ch, r['id'])

conn.close()
" 2>&1) || ROWS="ERROR:$ROWS"

if [[ "$ROWS" == ERROR:* ]]; then
  echo "Error querying database: $ROWS"
  exit 1
fi

if [[ -z "$ROWS" ]]; then
  echo "No sessions with usage found."
  exit 0
fi

# Auto-detect issue from latest open enhancement if not provided
if [[ -z "$ISSUE" ]]; then
  ISSUE=$(gh issue list --label enhancement --state open --json number --jq '.[0].number' 2>/dev/null || echo "")
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Detect agent role from a session title (fallback when DB agent is empty)
detect_agent() {
  case "$1" in
    *"Architect:"*|*"architect"*) echo "architect" ;;
    *"Developer:"*|*"developer"*) echo "developer" ;;
    *"Tester:"*|*"tester"*) echo "tester" ;;
    *"Security"*|*"audit"*) echo "security-auditor" ;;
    *"UX"*|*"ui"*) echo "ux-ui" ;;
    *"explore"*|*"Explore"*) echo "explore" ;;
    *"general"*|*"General"*) echo "general" ;;
    *"@"*" subagent"*) echo "subagent" ;;
    *) echo "build" ;;
  esac
}

WRITTEN=0
SKIPPED=0
FIRST_ROW=true

while IFS= read -r line; do
  SESSION_ID_VAL=$(echo "$line" | cut -d',' -f1)
  TITLE_VAL=$(echo "$line" | cut -d',' -f2)
  DB_AGENT=$(echo "$line" | cut -d',' -f3)
  MODEL=$(echo "$line" | cut -d',' -f4)
  TOKENS_IN=$(echo "$line" | cut -d',' -f5)
  TOKENS_OUT=$(echo "$line" | cut -d',' -f6)
  TOKENS_REASON=$(echo "$line" | cut -d',' -f7)
  CACHE_R=$(echo "$line" | cut -d',' -f8)
  CACHE_W=$(echo "$line" | cut -d',' -f9)
  COST=$(echo "$line" | cut -d',' -f10)
  PARENT_ID_VAL=$(echo "$line" | cut -d',' -f11)

  # Agent: --agent overrides the top-level row only; otherwise prefer the DB
  # role, then fall back to title detection.
  if [[ -n "$AGENT" ]] && [[ "$FIRST_ROW" == true ]]; then
    AGENT_VAL="$AGENT"
  elif [[ -n "$DB_AGENT" ]] && [[ "$DB_AGENT" != "null" ]]; then
    AGENT_VAL="$DB_AGENT"
  else
    AGENT_VAL=$(detect_agent "$TITLE_VAL")
  fi

  CSV_ROW="${TIMESTAMP},${SESSION_ID_VAL},${ISSUE:-},${AGENT_VAL},${MODEL},${TOKENS_IN},${TOKENS_OUT},${TOKENS_REASON},${CACHE_R},${CACHE_W},${COST},${PARENT_ID_VAL}"

  if grep -q ",${SESSION_ID_VAL}," "$LOG_FILE" 2>/dev/null; then
    SKIPPED=$((SKIPPED + 1))
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [skip, already logged] $CSV_ROW"
    fi
  else
    if [[ "$DRY_RUN" == true ]]; then
      echo "$CSV_ROW"
    else
      echo "$CSV_ROW" >> "$LOG_FILE"
    fi
    WRITTEN=$((WRITTEN + 1))
    echo "Logged: ${AGENT_VAL} | ${MODEL} | in=${TOKENS_IN} out=${TOKENS_OUT} cost=\$${COST}"
  fi

  FIRST_ROW=false
done <<< "$ROWS"

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "--- DRY RUN ---"
  echo "header: $HEADER"
fi

if [[ "$SKIPPED" -gt 0 ]] && [[ "$DRY_RUN" == false ]]; then
  echo "Skipped $SKIPPED already-logged session(s)."
fi
