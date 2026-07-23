#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_DIR/.finops/log.csv"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Generate a usage report from .finops/log.csv.

Options:
  --by-agent        Group totals by agent role
  --by-model        Group totals by model
  --by-issue        Group totals by issue number
  --today           Show only today's entries
  --last N          Show last N entries (default: all)
  --summary         Show overall totals only
  --json            Output as JSON
  -h, --help        Show this help
EOF
  exit 1
}

GROUP_BY=""
FILTER_TODAY=false
LAST_N=""
SUMMARY_ONLY=false
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --by-agent) GROUP_BY="agent"; shift ;;
    --by-model) GROUP_BY="model"; shift ;;
    --by-issue) GROUP_BY="issue"; shift ;;
    --today) FILTER_TODAY=true; shift ;;
    --last) LAST_N="$2"; shift 2 ;;
    --summary) SUMMARY_ONLY=true; shift ;;
    --json) JSON_OUTPUT=true; shift ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ ! -f "$LOG_FILE" ]]; then
  echo "No usage data found. Run log-usage.sh first."
  exit 0
fi

export LOG_FILE GROUP_BY FILTER_TODAY LAST_N SUMMARY_ONLY JSON_OUTPUT

python3 -c "
import csv, sys, json, os
from collections import defaultdict
from datetime import datetime, timezone

log_file = os.environ['LOG_FILE']
group_by = os.environ.get('GROUP_BY', '')
filter_today = os.environ.get('FILTER_TODAY', 'false') == 'true'
last_n = os.environ.get('LAST_N', '')
summary_only = os.environ.get('SUMMARY_ONLY', 'false') == 'true'
json_out = os.environ.get('JSON_OUTPUT', 'false') == 'true'

rows = []
with open(log_file, 'r') as f:
    reader = csv.DictReader(f)
    for r in reader:
        rows.append(r)

if not rows:
    print('No usage entries found.')
    sys.exit(0)

# Filter by today
today_str = datetime.now(timezone.utc).strftime('%Y-%m-%d')
if filter_today:
    rows = [r for r in rows if r['timestamp'].startswith(today_str)]
    if not rows:
        print(f'No entries for today ({today_str}).')
        sys.exit(0)

# Last N
if last_n:
    rows = rows[-int(last_n):]

# Sum totals
def sum_row(acc, r):
    acc['tokens_input'] += int(r['tokens_input'])
    acc['tokens_output'] += int(r['tokens_output'])
    acc['tokens_reasoning'] += int(r['tokens_reasoning'])
    acc['cache_read'] += int(r['cache_read'])
    acc['cache_write'] += int(r['cache_write'])
    acc['cost_usd'] += float(r['cost_usd'])
    acc['count'] += 1
    return acc

def new_acc():
    return {'tokens_input': 0, 'tokens_output': 0, 'tokens_reasoning': 0,
            'cache_read': 0, 'cache_write': 0, 'cost_usd': 0.0, 'count': 0}

def fmt_tokens(n):
    if n >= 1_000_000:
        return f'{n/1_000_000:.1f}M'
    if n >= 1_000:
        return f'{n/1_000:.1f}k'
    return str(n)

def fmt_cost(c):
    if c == 0:
        return 'free'
    return f'\${c:.4f}'

if summary_only or not group_by:
    total = new_acc()
    for r in rows:
        sum_row(total, r)

    if json_out:
        print(json.dumps(total, indent=2))
    else:
        print(f'Entries:     {total[\"count\"]}')
        print(f'Input:       {fmt_tokens(total[\"tokens_input\"])} tokens')
        print(f'Output:      {fmt_tokens(total[\"tokens_output\"])} tokens')
        print(f'Reasoning:   {fmt_tokens(total[\"tokens_reasoning\"])} tokens')
        print(f'Cache read:  {fmt_tokens(total[\"cache_read\"])} tokens')
        print(f'Cache write: {fmt_tokens(total[\"cache_write\"])} tokens')
        print(f'Cost:        {fmt_cost(total[\"cost_usd\"])}')

if group_by:
    groups = defaultdict(new_acc)
    for r in rows:
        key = r.get(group_by, 'unknown') or 'unknown'
        sum_row(groups[key], r)

    if json_out:
        print(json.dumps(dict(groups), indent=2))
    else:
        print(f'\n--- By {group_by} ---')
        for key in sorted(groups.keys()):
            g = groups[key]
            print(f'  {key}: {g[\"count\"]} sessions | in={fmt_tokens(g[\"tokens_input\"])} out={fmt_tokens(g[\"tokens_output\"])} | {fmt_cost(g[\"cost_usd\"])}')
" 2>&1
