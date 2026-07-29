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
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/srt_parser_test.dart

# Integration tests (requires emulator/device)
flutter test integration_test/
```

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
