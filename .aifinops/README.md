# .aifinops

AI FinOps data directory. Contains CSV logs of AI token usage per task, generated automatically by `scripts/log-usage.sh` and `scripts/workflow-notify.sh`.

## log.csv

Tracks per-task token consumption and cost. One row per workflow notification boundary (plan-ready, impl-done, tests-done, audit-done).

### Columns

| Column | Description |
|--------|-------------|
| `timestamp` | ISO 8601 UTC timestamp of the log entry |
| `session_id` | OpenCode session identifier |
| `issue` | GitHub issue number this work relates to |
| `agent` | Agent role that completed the task (build, architect, tester, etc.) |
| `model` | Model used (e.g. `big-pickle`) |
| `tokens_input` | Total input tokens consumed in this session segment |
| `tokens_output` | Total output tokens produced in this session segment |
| `tokens_reasoning` | Tokens used for reasoning/thinking |
| `cache_read` | Tokens read from prompt cache |
| `cache_write` | Tokens written to prompt cache |
| `cost_usd` | Estimated cost in USD (may be $0.00 for free-tier models) |

### Example

```csv
timestamp,session_id,issue,agent,model,tokens_input,tokens_output,tokens_reasoning,cache_read,cache_write,cost_usd
2026-07-24T07:07:51Z,ses_06d1d2485ffeIoCKfIzvjbstjZ,103,build,big-pickle,38801,5321,1566,990464,0,0.000000
```

### Usage

```bash
# Generate a summary report
./scripts/usage-report.sh --summary

# Report by agent role
./scripts/usage-report.sh --by-agent

# Report by model
./scripts/usage-report.sh --by-model
```
