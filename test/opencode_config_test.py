#!/usr/bin/env python3
"""Executable test spec for opencode.json agent model assignments (Issue #230).

Verifies that opencode.json satisfies the approved plan:

1.  The file exists, parses as JSON, and declares the opencode schema.
2.  A `provider.groq` block exists with api "openai", the
    SUBVOCAL_GROQ_API_KEY env placeholder, the Groq baseURL, and sensible
    timeouts.
3.  developer          -> groq/openai/gpt-oss-120b
4.  tester             -> groq/openai/gpt-oss-20b
5.  security-auditor   -> nvidia/openai/gpt-oss-20b
6.  architect          -> nvidia/meta/llama-3.3-70b-instruct (unchanged)
7.  ux-ui              -> nvidia/mistralai/mistral-nemotron (unchanged)
8.  model/small_model  -> opencode/big-pickle (unchanged)
9.  The three heavy subagents (developer, tester, security-auditor) must
    NOT all share one provider — at least two distinct providers must be
    used so they draw from independent rate-limit quotas.

Usage:
    python3 test/opencode_config_test.py

Exit code is 0 when every assertion passes, 1 otherwise. The script is
deterministic: it only reads opencode.json, performs no network calls, and
writes nothing.
"""

import json
import sys
from pathlib import Path

CONFIG_PATH = Path(__file__).resolve().parent.parent / "opencode.json"

EXPECTED = {
    "schema": "https://opencode.ai/config.json",
    "groq_api": "openai",
    "groq_api_key": "{env:SUBVOCAL_GROQ_API_KEY}",
    "groq_base_url": "https://api.groq.com/openai/v1",
    "groq_timeout": 120000,
    "groq_header_timeout": 30000,
    "groq_chunk_timeout": 60000,
    "groq_set_cache_key": True,
    "developer_model": "groq/openai/gpt-oss-120b",
    "tester_model": "groq/openai/gpt-oss-20b",
    "security_auditor_model": "nvidia/openai/gpt-oss-20b",
    "architect_model": "nvidia/meta/llama-3.3-70b-instruct",
    "ux_ui_model": "nvidia/mistralai/mistral-nemotron",
    "main_model": "opencode/big-pickle",
    "small_model": "opencode/big-pickle",
}

# Heavy subagents that must be spread across independent provider quotas.
HEAVY_AGENTS = ["developer", "tester", "security-auditor"]


def provider_of(model_id):
    """Extract the provider name from a model id like 'groq/openai/gpt-oss-120b'."""
    return model_id.split("/", 1)[0]


RESULTS = []


def check(name, ok, detail=""):
    """Record one assertion result, print it, and return whether it passed."""
    RESULTS.append((name, ok))
    tag = "PASS" if ok else "FAIL"
    suffix = f" — {detail}" if detail else ""
    print(f"[{tag}] {name}{suffix}")
    return ok


def load_config():
    """Return (config, errors): the parsed JSON and a list of load errors."""
    errors = []
    if not CONFIG_PATH.exists():
        errors.append(f"opencode.json not found at {CONFIG_PATH}")
        return None, errors
    try:
        with open(CONFIG_PATH, encoding="utf-8") as fh:
            return json.load(fh), errors
    except json.JSONDecodeError as exc:
        errors.append(f"opencode.json is not valid JSON: {exc}")
        return None, errors


def main():
    config, load_errors = load_config()
    for err in load_errors:
        check("opencode.json exists and is valid JSON", False, err)
    if config is None:
        print("\nStopping: cannot validate a config that failed to load.")
        return 1

    check(
        "declares the opencode config schema",
        config.get("$schema") == EXPECTED["schema"],
        f'got {config.get("$schema")!r}',
    )

    # 2. provider.groq block.
    groq = (config.get("provider") or {}).get("groq")
    groq_options = (groq or {}).get("options") or {}
    check(
        "provider.groq exists",
        isinstance(groq, dict),
        f'provider keys: {sorted((config.get("provider") or {}).keys())}',
    )
    check(
        "provider.groq.api == 'openai'",
        groq and groq.get("api") == EXPECTED["groq_api"],
        f'got {(groq or {}).get("api")!r}',
    )
    check(
        "provider.groq.options.apiKey == '{env:SUBVOCAL_GROQ_API_KEY}'",
        groq_options.get("apiKey") == EXPECTED["groq_api_key"],
        f'got {groq_options.get("apiKey")!r}',
    )
    check(
        "provider.groq.options.baseURL == Groq v1 endpoint",
        groq_options.get("baseURL") == EXPECTED["groq_base_url"],
        f'got {groq_options.get("baseURL")!r}',
    )
    check(
        "provider.groq.options.timeout == 120000",
        groq_options.get("timeout") == EXPECTED["groq_timeout"],
        f'got {groq_options.get("timeout")!r}',
    )
    check(
        "provider.groq.options.headerTimeout == 30000",
        groq_options.get("headerTimeout") == EXPECTED["groq_header_timeout"],
        f'got {groq_options.get("headerTimeout")!r}',
    )
    check(
        "provider.groq.options.chunkTimeout == 60000",
        groq_options.get("chunkTimeout") == EXPECTED["groq_chunk_timeout"],
        f'got {groq_options.get("chunkTimeout")!r}',
    )
    check(
        "provider.groq.options.setCacheKey == true",
        groq_options.get("setCacheKey") is EXPECTED["groq_set_cache_key"],
        f'got {groq_options.get("setCacheKey")!r}',
    )

    # 3–7. Per-agent model assignments.
    agents = config.get("agent") or {}
    agent_models = {
        "developer": EXPECTED["developer_model"],
        "tester": EXPECTED["tester_model"],
        "security-auditor": EXPECTED["security_auditor_model"],
        "architect": EXPECTED["architect_model"],
        "ux-ui": EXPECTED["ux_ui_model"],
    }
    for agent_name, expected_model in agent_models.items():
        actual = (agents.get(agent_name) or {}).get("model")
        check(
            f"agent.{agent_name}.model == {expected_model!r}",
            actual == expected_model,
            f'got {actual!r}',
        )

    # 8. Main model + small_model unchanged.
    check(
        "model == 'opencode/big-pickle'",
        config.get("model") == EXPECTED["main_model"],
        f'got {config.get("model")!r}',
    )
    check(
        "small_model == 'opencode/big-pickle'",
        config.get("small_model") == EXPECTED["small_model"],
        f'got {config.get("small_model")!r}',
    )

    # 9. Heavy subagents spread across >= 2 distinct providers.
    heavy_providers = set()
    for agent_name in HEAVY_AGENTS:
        model = (agents.get(agent_name) or {}).get("model")
        if model:
            heavy_providers.add(provider_of(model))
    provider_detail = ", ".join(
        f"{agent}={provider_of((agents.get(agent) or {}).get('model') or '')}"
        for agent in HEAVY_AGENTS
    )
    check(
        "heavy subagents use >= 2 distinct providers",
        len(heavy_providers) >= 2,
        f"providers used: {sorted(heavy_providers) or 'none'} ({provider_detail})",
    )

    print()
    passed = sum(1 for _, ok in RESULTS if ok)
    failed = len(RESULTS) - passed
    print(f"{passed} passed, {failed} failed (of {len(RESULTS)} assertions)")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
