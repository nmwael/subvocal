# Human-in-the-Loop Workflow

This project uses a Human-in-the-Loop (HITL) approval workflow. Specialist subagents plan, develop, test, and audit code.

## ⚠️ HARD GATE: NEVER SKIP STEP 2

**You MUST NOT create, edit, or modify any code files until the human has explicitly approved an architect's plan.** Operational tasks (starting services, running commands, reading files) are exempt. Everything else requires: architect plans -> human approves -> developer implements.

## Workflow

1. **Architect** explores the codebase and produces an implementation plan (creates a GitHub issue for tracking)
2. **Human reviews and approves the plan** — **HARD GATE: developer must not start until human gives explicit approval**.

   **Option A — Manual approval** (human comments `approved` on the issue):
   ```bash
   ./scripts/watch-approval.sh
   ```
   Polls the latest open enhancement issue every 10s. When a comment containing `approved`, `lgtm`, `looks good`, or `go ahead` is detected, sends a notification and exits 0.

   **Option B — Direct notify** (human approves in chat):
   ```bash
   ISSUE_NUM=$(gh issue list --label enhancement --state open --json number --jq '.[0].number')
   ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUM"
   ./scripts/notify.sh "Plan approved" "Issue #$ISSUE_NUM: $(gh issue view "$ISSUE_NUM" --json title --jq '.title') — developer starting" "$ISSUE_URL"
   ```
3. **Developer** implements code changes following the approved plan (works autonomously, presents completed work for review)
4. **Tester** writes and runs tests to validate changes (works autonomously, presents completed test results for review, closes the GitHub issue when done)
5. **Security Auditor** reviews the final code for vulnerabilities (read-only)

Step 2 (human approval) is NEVER skippable. Steps 3-5 may be skipped per task scope, but never without first passing step 2.

### Memory Aid: YOU ALWAYS FORGET THE HITL GATE

You have a pattern of treating "small" or "obvious" code changes as exempt from the HITL workflow. **This is incorrect.** The following examples ARE code changes that require architect → issue → approval:

- Adding/changing tests (widget, unit, integration)
- Modifying source files for any reason (even "obvious" fixes)
- Adding configuration files (CI config, analysis_options.yaml)
- Installing packages — these modify `pubspec.yaml`
- Creating or modifying `.gitignore`, `.editorconfig`, or any non-README file

**The only exempt operations are:**
- Running commands that don't create or edit files (`flutter`, `dart`, `curl`)
- Reading files, searching, exploring
- Starting/stopping services

> **Rule of thumb:** If it touches a tracked or tracked-adjacent file, it needs an issue and approval. "But it's small!" is not an exemption — it's the exact rationalization that has caused every previous violation.

## Agent Roles

### `@architect`
Read-only analyst. Explores the codebase, understands existing patterns, and produces structured implementation plans by creating GitHub issues for tracking. Plans must include estimated AI time (time the AI will spend implementing the complete flow) and estimated token usage. Cannot edit files or run commands.

> **Notification gate**: When the plan is ready (issue created/updated), run:
> ```bash
> ISSUE_NUM=$(gh issue list --label enhancement --state open --json number --jq '.[0].number')
> ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUM"
> ./scripts/notify.sh "Plan ready" "Issue #$ISSUE_NUM: $(gh issue view "$ISSUE_NUM" --json title --jq '.title') — plan ready for review" "$ISSUE_URL"
> ```
>
> After notifying, **run `watch-approval.sh`** to block until the human approves:
> ```bash
> ./scripts/watch-approval.sh
> ```
> This polls the issue every 10s for `approved`/`lgtm`/`looks good`/`go ahead`. On detection, it notifies and exits 0. Only then may the developer begin implementation.

### `@developer`
Implements code changes. Edits source files and runs build/compile commands autonomously. When work is complete, presents a summary of all changes and asks for human review. On failure, retries up to 3 times before escalating to the user.

> **Notification gate**: When implementation is done and review is requested, run:
> ```bash
> ISSUE_NUM=$(gh issue list --label enhancement --state open --json number --jq '.[0].number')
> ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUM"
> ./scripts/notify.sh "Implementation done" "Issue #$ISSUE_NUM: $(gh issue view "$ISSUE_NUM" --json title --jq '.title') — ready for review" "$ISSUE_URL"
> ```

### `@tester`
Writes and runs tests. Edits test files and executes test commands autonomously. When tests are complete, presents results and asks for human review. On failure, retries up to 3 times before escalating to the user.

> **Notification gate**: When tests are done and results are presented, run:
> ```bash
> ISSUE_NUM=$(gh issue list --label enhancement --state open --json number --jq '.[0].number')
> ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUM"
> ./scripts/notify.sh "Tests done" "Issue #$ISSUE_NUM: $(gh issue view "$ISSUE_NUM" --json title --jq '.title') — test results ready" "$ISSUE_URL"
> ```

### `@security-auditor`
Security reviewer. Inspects code for OWASP Top 10, injection risks, authentication flaws, and sensitive data exposure. Read-only — cannot modify code or run commands.

> **Notification gate**: When security audit is complete, run:
> ```bash
> ISSUE_NUM=$(gh issue list --label enhancement --state open --json number --jq '.[0].number')
> ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUM"
> ./scripts/notify.sh "Security audit done" "Issue #$ISSUE_NUM: $(gh issue view "$ISSUE_NUM" --json title --jq '.title') — audit complete" "$ISSUE_URL"
> ```

### `@ux-ui`
Read-only reviewer. Reviews Flutter widget trees, screen layouts, navigation flows, accessibility semantics, visual consistency, and user-facing interaction patterns. Can produce UI mockups/specs using PlantUML (already in the toolchain).

**Capabilities:**
- Review widget hierarchy for accessibility (semantic labels, focus order, screen reader support)
- Evaluate layout responsiveness and visual consistency
- Review user flows and navigation patterns
- Suggest improvements for onboarding, error states, loading states, and empty states
- Ensure adherence to Material Design (or chosen design system) guidelines
- Cannot edit files or run commands

> **Notification gate**: When UX/UI review is complete, run:
> ```bash
> ISSUE_NUM=$(gh issue list --label enhancement --state open --json number --jq '.[0].number')
> ISSUE_URL="https://github.com/nmwael/subvocal/issues/$ISSUE_NUM"
> ./scripts/notify.sh "UX/UI review done" "Issue #$ISSUE_NUM: $(gh issue view "$ISSUE_NUM" --json title --jq '.title') — review complete" "$ISSUE_URL"
> ```

## Reference Books by Role

All reference books sourced from https://github.com/ciembor/agent-rules-books/

- **All agents**: docs/release-it.mini.md — Release It! patterns for production-ready systems
- **@architect**: docs/clean-architecture.mini.md, docs/patterns-of-enterprise-application-architecture.mini.md — architecture and design patterns
- **@developer**: docs/clean-code.mini.md, docs/refactoring.mini.md — code quality and refactoring
- **@tester**: docs/clean-code.mini.md, docs/refactoring.mini.md — readable tests and safe refactoring
- **@security-auditor**: all docs — security review benefits from understanding the full design intent
- **@ux-ui**: all docs — UX/UI review benefits from understanding the full design intent

## Commit Rules

- Never stage, commit, or push changes unless the user explicitly requests it
- Do not run `git add`, `git commit`, or `git push` commands autonomously
- If the user asks about the state of work, show a diff or status summary instead
- If the user asks to commit, always use `git commit -S` (signed commits) when signing is configured
- Before attempting a signed commit, verify the hardware token is accessible by running `gpg --card-status`. If the token is unavailable (e.g., "Forbidden"), inform the user to insert their hardware token before proceeding — do not attempt the commit without confirmation
- If a signed commit fails despite a prepared token, it is likely the human needs to press the hardware button — inform the user rather than retrying or skipping the signature
- Commit messages must be prefixed with a conventional commit type: `doc:` (documentation), `chore:` (tooling/config), `feat:` (feature), `fix:` (bug fix), `refactor:` (code restructuring), `test:` (test changes), or other types as appropriate

## Retry Rules

- On failure (build error, test failure, validation rejection), retry up to 3 attempts
- After 3 failed attempts, stop and present the failure to the user with diagnostic information
- Do not keep retrying without informing the user

## Rules

- Before starting work, read this file and understand the workflow
- After completing a task, provide a clear summary of what was done
- If a plan would benefit from another agent's review, delegate via the Task tool
- Never bypass the HITL approval gate by using a subagent to indirectly perform a denied action
- Never develop directly on the `main` branch. All work must be done in a dedicated development or feature branch

### PRE-FLIGHT CHECK (MANDATORY BEFORE ANY CODE CHANGE)

When a user requests any task that involves creating, editing, or modifying code:

1. **STOP** — do not edit or create any files.
2. **CLASSIFY** — is this an operational task (running commands, reading files, starting services) or a code change? Operational tasks are exempt.
3. **IF code change** — route through the architect agent. The architect must explore, produce a plan, create a GitHub issue, and present it to the user for approval.
4. **WAIT** for explicit human approval (e.g., "approved", "looks good", "go ahead") before implementing.
5. **Only then** implement using the developer agent or directly.

If the user asks you to "just do it" or bypasses the gate, refuse politely and explain that step 2 is required.

### PRE-TASK RITUAL (DO NOT SKIP)

Before every response that involves code, forcibly re-read the Memory Aid section above and confirm to yourself: "Is this a code change that needs HITL?" If the answer is ambiguous, treat it as needing HITL. Only if every touched file is definitively exempt (read-only command, no file creation/editing) may you proceed.

## GPG / Signed Commits

The project requires signed commits via a hardware token. The devcontainer forwards the GPG agent socket from the host.

### How it works
- The host GPG agent socket is bind-mounted into the container at `~/.gnupg/S.gpg-agent`
- `gpg --card-status` may report "Forbidden" inside the container, but **signing still works** because the socket delegates to the host's `scdaemon`
- When prompted for a PIN during signing, the host's `pinentry` program will pop up on the host machine

### Committing with a signed commit
```bash
# Stage files
git add -A
# Commit with signature
git commit -S -m "type: message"
# Push
git push
```

### Troubleshooting
- If `gpg --card-status` says "Forbidden" or "No card", try the commit anyway — signing may still work via the forwarded socket
- If the commit hangs, check the host machine for a `pinentry` pop-up requesting your smartcard PIN
- If `gpg --card-status` says "No such device" or "No card" and the commit also fails, the hardware token socket is not forwarded. Recreate the devcontainer with GPG forwarding enabled
- To verify a commit was signed: `git log --show-signature -1`

## Devcontainer Environment

This project runs in a devcontainer with the following setup:

- **Container base**: Debian Bullseye (`mcr.microsoft.com/devcontainers/base:bullseye`)
- **Flutter**: Installed via devcontainer feature (`ghcr.io/awf-project/devcontainer-features/flutter:1`), latest stable channel
- **Dart**: Bundled with Flutter SDK
- **GitHub CLI (`gh`)**: Authenticated and available. Use `echo "$AI_FUN_TOKEN" | gh auth login --with-token` if re-authentication is needed. The token is a GitHub fine-grained PAT stored in the `AI_FUN_TOKEN` environment variable.
- **Development**: Run `flutter pub get` in project root, then `flutter run` to launch on connected device/emulator
- **Android emulator**: Not available in devcontainer; test on physical device or use `flutter build apk --debug` and side-load

## Diagram Convention

When architecture diagrams are required in documentation (e.g., DEVELOPMENT.md), use PlantUML fenced code blocks with ````plantuml` syntax. This ensures diagrams are renderable by PlantUML-compatible tools and remain readable as plain text.

## Pull Requests

When approved work is ready to merge, @architect generates a pull request with a descriptive title and a "WHY WHAT HOW" template body:

### WHY
Why is this change needed? What problem does it solve?

### WHAT
What was changed? Briefly list the major changes.

### HOW
How does the implementation work? Key design decisions and architecture notes.

## Project Summary

### Goal
Cross-platform Flutter app for picking subtitles from OpenSubtitles and reading them aloud via TTS in sync with streaming video (Netflix, Prime, etc.). Useful for accessibility (visually impaired) and language learning.

### Key Decisions
- **Clean Architecture**: Domain (SRT parsing, TTS orchestration) independent from Flutter framework and OpenSubtitles API details
- **Riverpod**: State management — simpler than BLoC, compile-safe, good for solo dev
- **Custom SRT parser**: SRT format is simple; avoids dependency risk
- **flutter_tts**: Wraps platform TTS (Android TTS / iOS AVSpeechSynthesizer)
- **OpenSubtitles REST API v2**: Largest subtitle database; free tier available
- **SRT-timed utterance scheduling**: Calculate delays between subtitle entries from timestamps

### Relevant Files
- `PLAN.md`: Full architecture and implementation plan
- `AGENTS.md`: This file — HITL workflow
- `DEVELOPMENT.md`: Development setup guide
- `docs/`: Reference books (clean-code, clean-architecture, etc.)

## Tooling Preferences

- **Dart analysis**: Use `dart analyze` for static analysis. Run `dart fix --dry-run` before `dart fix --apply`.
- **Flutter tests**: Use `flutter test` for unit/widget tests. For integration tests, use `flutter test integration_test/`.
- **Code formatting**: Use `dart format` (not Prettier for Dart files).
