#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DB_PATH="${OPENCODE_DB:-$HOME/.local/share/opencode/opencode.db}"
LOG_DIR="$PROJECT_DIR/.finops"
LOG_FILE="$LOG_DIR/log.csv"
HEADER="timestamp,session_id,issue,agent,model,tokens_input,tokens_output,tokens_reasoning,cache_read,cache_write,cost_usd"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Log AI token usage from the OpenCode database for the latest session.

Reads the local opencode.db SQLite database, finds the most recently
updated session (or a specific one), and appends a CSV row to .finops/log.csv.

Options:
  --session-id ID   Log a specific session (default: latest updated)
  --issue NUM       GitHub issue number (default: auto-detect from latest open enhancement)
  --agent ROLE      Agent role (default: auto-detect from session title)
  --dry-run         Print the CSV row without writing to file
  -h, --help        Show this help

Data source: OpenCode tracks per-message cost and tokens in its SQLite
database (~/.local/share/opencode/opencode.db). The session table has
pre-aggregated totals.
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

# Query the database
ROW=$(python3 -c "
import sqlite3, json, sys

conn = sqlite3.connect('$DB_PATH')
conn.row_factory = sqlite3.Row
c = conn.cursor()

session_id = '''$SESSION_ID'''
if session_id:
    c.execute('''
        SELECT id, title, agent, model, cost,
               tokens_input, tokens_output, tokens_reasoning,
               tokens_cache_read, tokens_cache_write
        FROM session WHERE id = ?
    ''', (session_id,))
else:
    c.execute('''
        SELECT id, title, agent, model, cost,
               tokens_input, tokens_output, tokens_reasoning,
               tokens_cache_read, tokens_cache_write
        FROM session
        WHERE parent_id IS NULL
        ORDER BY time_updated DESC
        LIMIT 1
    ''')

r = c.fetchone()
if not r:
    print('ERROR:No session found', file=sys.stderr)
    sys.exit(1)

# Parse model name from JSON
model_raw = r['model'] or ''
try:
    model_obj = json.loads(model_raw)
    model_name = model_obj.get('id', model_raw)
except (json.JSONDecodeError, TypeError):
    model_name = model_raw

# Output as CSV-safe values
title = (r['title'] or '').replace(',', ';')
print(f'{r[\"id\"]},{title},{r[\"agent\"] or \"\"},{model_name},{r[\"tokens_input\"] or 0},{r[\"tokens_output\"] or 0},{r[\"tokens_reasoning\"] or 0},{r[\"tokens_cache_read\"] or 0},{r[\"tokens_cache_write\"] or 0},{r[\"cost\"] or 0:.6f}')

conn.close()
" 2>&1)

if [[ $? -ne 0 ]] || [[ "$ROW" == ERROR:* ]]; then
  echo "Error querying database: $ROW"
  exit 1
fi

# Auto-detect agent from session title if not provided
if [[ -z "$AGENT" ]]; then
  TITLE=$(echo "$ROW" | cut -d',' -f2)
  case "$TITLE" in
    *"Architect:"*|*"architect"*) AGENT="architect" ;;
    *"Developer:"*|*"developer"*) AGENT="developer" ;;
    *"Tester:"*|*"tester"*) AGENT="tester" ;;
    *"Security"*|*"audit"*) AGENT="security-auditor" ;;
    *"UX"*|*"ui"*) AGENT="ux-ui" ;;
    *"@"*" subagent"*) AGENT="subagent" ;;
    *) AGENT="build" ;;
  esac
fi

# Auto-detect issue from latest open enhancement if not provided
if [[ -z "$ISSUE" ]]; then
  ISSUE=$(gh issue list --label enhancement --state open --json number --jq '.[0].number' 2>/dev/null || echo "")
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID_VAL=$(echo "$ROW" | cut -d',' -f1)
MODEL=$(echo "$ROW" | cut -d',' -f4)
TOKENS_IN=$(echo "$ROW" | cut -d',' -f5)
TOKENS_OUT=$(echo "$ROW" | cut -d',' -f6)
TOKENS_REASON=$(echo "$ROW" | cut -d',' -f7)
CACHE_R=$(echo "$ROW" | cut -d',' -f8)
CACHE_W=$(echo "$ROW" | cut -d',' -f9)
COST=$(echo "$ROW" | cut -d',' -f10)

CSV_ROW="${TIMESTAMP},${SESSION_ID_VAL},${ISSUE:-},${AGENT},${MODEL},${TOKENS_IN},${TOKENS_OUT},${TOKENS_REASON},${CACHE_R},${CACHE_W},${COST}"

if $DRY_RUN; then
  echo "$HEADER"
  echo "$CSV_ROW"
else
  echo "$CSV_ROW" >> "$LOG_FILE"
  echo "Logged: ${AGENT} | ${MODEL} | in=${TOKENS_IN} out=${TOKENS_OUT} cost=\$${COST}"
fi
