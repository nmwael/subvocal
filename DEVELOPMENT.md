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
