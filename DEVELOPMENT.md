# subvocal — Development Guide

For system architecture (subtitle providers, translation services, TTS engine,
data flow diagrams), see [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## Development Setup

### Prerequisites

- Flutter SDK 3.x
- GitHub CLI (`gh`)
- OpenSubtitles API key (from https://opensubtitles.com)

### Quick Start

```bash
# Activate opencode profile
node .opencode/merge-config.js opencode

# Get dependencies
flutter pub get

# Run in debug mode
flutter run
```

### VS Code Extensions

The devcontainer installs these automatically:

- **Dart-Code.dart-code** / **Dart-Code.flutter** — Dart/Flutter language support
- **SonarSource.sonarlint-vscode** — real-time linting
- **jebbs.plantuml** — PlantUML diagrams
- **redhat.vscode-yaml** — YAML support
- **eamodio.gitlens** — Git annotations
- **yzhang.markdown-all-in-one** — Markdown preview
- **usernamehw.errorlens** — inline error display

---

## Building

```bash
# Analyze
dart analyze

# Format
dart format .

# Unit + widget tests
flutter test

# APK (debug)
flutter build apk --debug

# APK (release)
flutter build apk --release

# iOS (requires macOS)
flutter build ios
```

---

## Testing

```bash
# Run all tests (unit + widget + goldens)
flutter test

# Run unit tests (includes BDD scenarios)
flutter test test/unit/

# Run a specific test file
flutter test test/unit/srt_parser_bdd_test.dart

# Run only BDD test files (test/**/*_bdd_test.dart)
./scripts/run-tests.sh --features

# Integration tests (requires emulator/device)
flutter test integration_test/
```

### TDD / BDD

This project uses test-driven development (red–green–refactor) with a BDD
layer as the living behavior spec:

1. **Red** — write a failing BDD scenario (Given/When/Then) or unit test
2. **Green** — implement the minimal code to make it pass
3. **Refactor** — clean up while keeping the suite green

BDD scenarios live in `test/**/*_bdd_test.dart` and use `bdd_framework`:

```dart
import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/bdd_config.dart';

void main() async {
  configureBdd(clearOutput: true);

  final feature = BddFeature('Feature Title', description: '...');

  Bdd(feature)
      .scenario('...')
      .given('...')
      .when('...')
      .then('...')
      .run((ctx) async {
    // assertions
  });

  await BddReporter.reportAll();
}
```

On every run, scenarios auto-export to plain-language `.feature` files under
`test/features/generated/` (gitignored) for stakeholder review.

**Notes:**
- `main()` must be `void main() async { ... await BddReporter.reportAll(); }`.
- Configure exactly ONE reporter via `configureBdd()` — `bdd_framework` 4.0.7
  stores the same `BddFeature` in every reporter, so multiple reporters export
  each scenario twice.

**Decision — widget BDD deferred:** widget tests stay plain `testWidgets` —
`bdd_framework` 4.0.7 has no widget support (its `bddWidgetTest`/
`BddWidgetContext` exist only on the unreleased main branch), so BDD scenarios
apply to unit tests only. Revisit when bdd_framework ships widget support.

---

## Versioning

This project follows [Semantic Versioning (SemVer)](https://semver.org/).

### Format

Versions are defined in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- **Major** (1): Breaking changes
- **Minor** (0): New features, backward compatible
- **Patch** (0): Bug fixes, backward compatible
- **Build** (+1): Auto-incremented by CI on production releases

### Release Types

| Type | Tag Format | Source | Frequency |
|---|---|---|---|
| Production | `v{major}.{minor}.{patch}+{build}` | `main` | On release |
| Development | `dev-{run_number}` | `development` | Every push |

### Development builds

Every push to `development` triggers a dev build published as a GitHub prerelease at:
https://github.com/nmwael/subvocal/releases

Production releases from `main` use the pubspec.yaml version for tagging.

### Bumping versions

- **Production release**: Bump `version` in `pubspec.yaml` before merging to `main`
- **Development builds**: Auto-tagged by CI, no manual version bump needed

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENSUBTITLES_API_KEY` | Yes | API key from opensubtitles.com |
| `SUBDL_API_KEY` | No | API key from subdl.com (2,000 req/day free) |
| `GOOGLE_TRANSLATE_API_KEY` | No | Google Cloud Translation API key |
| `AZURE_TRANSLATE_API_KEY` | No | Azure Translator subscription key |
| `AZURE_TRANSLATE_REGION` | No | Azure Translator region |
| `AI_FUN_TOKEN` | No | GitHub PAT for AI tooling |
| `OPENROUTER_API_KEY` | No | OpenRouter API key for AI |

---

## Code Conventions

- **Clean Architecture**: Domain layer has zero Flutter imports
- **Clean Code**: Small functions, meaningful names, single responsibility
- **Riverpod**: All state through providers; no setState in business logic
- **Dart**: Follow effective_dart style guide
- **Testing**: Unit tests for domain, widget tests for presentation
