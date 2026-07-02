# subvocal — Architecture & Implementation Plan

**subvocal** is a cross-platform Flutter app that lets users pick subtitles (from
OpenSubtitles or local `.srt` files) and have them read aloud via TTS in sync
with streaming video (Netflix, Prime, etc.).

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Flutter 3.x (Dart 3.x) |
| State Mgmt | Riverpod |
| Architecture | Clean Architecture (domain/data/presentation) |
| Platforms | Android + iOS |
| TTS | `flutter_tts` (wraps platform TTS) |
| Networking | OpenSubtitles REST API v2 |
| SRT Parsing | Custom parser (`dart:io` + `dart:convert`) |
| Local Storage | sqflite or Hive |
| DI | Riverpod (provider injection) |
| Linting | `flutter_lints` / custom analysis_options.yaml |

---

## MVP Scope (Phase 1)

1. **Flutter project scaffolding** — clean-architecture folder layout, Riverpod
2. **SRT Parser** — parse `.srt` into `List<SubtitleEntry>` with start/end times + text
3. **OpenSubtitles integration** — search by show/movie name, language filter, download `.srt`
4. **TTS Engine service** — sequential utterance playback with SRT timing, play/pause/seek/speed
5. **Player Screen** — current subtitle display + full playback controls
6. **File Import** — pick `.srt` from device filesystem
7. **Basic Home Screen** — recent subtitles, import/search entry points

### Non-MVP (Phase 2+)
- Library management (favorites, history, tags)
- Language-learning features (word highlight, repeat phrase)
- Voice/engine selection
- Background audio playback
- Auto-sync via microphone audio fingerprinting
- Additional subtitle formats (ASS, VTT, SSA)

---

## Folder Structure (Clean Architecture)

```
lib/
├── core/
│   ├── constants/         # API keys, durations, etc.
│   ├── errors/            # Failure types, exceptions
│   ├── theme/             # AppTheme, colors, typography
│   └── utils/             # Date parsing, string helpers
├── data/
│   ├── datasources/
│   │   ├── opensubtitles_api.dart
│   │   └── local_file_source.dart
│   ├── models/
│   │   ├── subtitle_model.dart        # DTO with JSON serialization
│   │   ├── search_result_model.dart
│   │   └── subtitle_entry_model.dart
│   └── repositories/
│       ├── subtitle_repository_impl.dart
│       └── tts_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── subtitle.dart
│   │   ├── subtitle_entry.dart
│   │   └── search_result.dart
│   ├── repositories/
│   │   ├── subtitle_repository.dart   # abstract
│   │   └── tts_repository.dart        # abstract
│   └── usecases/
│       ├── parse_srt.dart
│       ├── search_subtitles.dart
│       ├── download_subtitle.dart
│       └── play_subtitle_sequence.dart
├── presentation/
│   ├── providers/
│   │   ├── player_provider.dart
│   │   ├── search_provider.dart
│   │   └── subtitle_list_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── search_screen.dart
│   │   └── player_screen.dart
│   └── widgets/
│       ├── subtitle_display.dart
│       ├── playback_controls.dart
│       ├── subtitle_list_tile.dart
│       └── speed_selector.dart
├── app.dart
└── main.dart
```

---

## Data Flow

```
[Search Screen]
      │
      ▼
SearchSubtitles UseCase → SubtitleRepository → OpenSubtitles API
      │                                              │
      ▼                                              ▼
 List<SearchResult> ← ← ← ← ← ← ← ← ← ← ← JSON response
      │
      ▼ (user taps a result)
DownloadSubtitle UseCase → SubtitleRepository → OpenSubtitles API
      │                                              │
      ▼                                              ▼
    .srt content  ← ← ← ← ← ← ← ← ← ← ← ← ←  download URL
      │
      ▼
ParseSrt UseCase → SRT parser → List<SubtitleEntry>
      │
      ▼
[Player Screen]
      │
      ▼
PlaySubtitleSequence UseCase → TTS Repository → flutter_tts
      │                                              │
      ▼                                              ▼
  Current subtitle highlighted ← ← ←  utterance callbacks
  Play/pause/seek/speed controls → TTS queue management
```

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Clean Architecture** | Keeps domain (SRT parsing, TTS orchestration) independent from Flutter framework and API details; replaceable datasources |
| **Riverpod** over BLoC | Simpler syntax, compile-safe, better testability for a solo-dev project |
| **Custom SRT parser** over package | SRT format is simple; avoids dependency risk; ~100 lines of code |
| **flutter_tts** | Mature package, wraps both Android TTS and AVSpeechSynthesizer, supports rate/pitch/volume control |
| **OpenSubtitles REST API v2** | Largest subtitle database; free tier available; REST API is straightforward |
| **SRT-timed utterance scheduling** | Calculate delays between subtitle entries from timestamps; pause/resume by tracking current utterance index |

---

## TTS Sync Strategy

Subtitles have `start` and `end` timestamps (HH:MM:SS,mmm). The player works as:

1. Load all subtitle entries in order
2. Start reading at entry N
3. Calculate delay = `entries[N+1].start - entries[N].start`
4. Schedule next utterance after delay
5. On pause: cancel pending utterances, remember current index
6. On resume: replay current entry from `entries[currentIndex].start - currentPosition` remaining time
7. On seek: jump to entry whose `start <= seekPosition < end`

This creates approximate sync with streaming video. User can fine-tune with an offset slider (±5s).

---

## Estimated Effort

| Phase | AI Time | Token Est. | Deliverables |
|-------|---------|------------|--------------|
| Phase 1 (MVP) | ~40-50 hrs | ~2000 tokens | Working app: search + download + read aloud |
| Phase 2 | ~50-70 hrs | ~2500 tokens | Library, language features, background play |

---

## OpenSubtitles API Setup

- Register at https://opensubtitles.com to get an API key
- Free tier: 1000 requests/day, 40 downloads/day
- Search endpoint: `GET /api/v2/subtitles?query={title}&languages={lang}`
- Download endpoint: `POST /api/v2/download` (returns URL to file)
- Auth: API-Key header (no OAuth needed for basic usage)

---

## HITL Workflow

1. ✅ **Architect** produces this plan (you are here)
2. ⏳ **Human** creates `nmwael/subvocal` repo on GitHub
3. ⏳ **Human** reviews and approves this plan
4. ⏳ **Developer** implements Phase 1 MVP
5. ⏳ **Tester** writes and runs tests
6. ⏳ **Security Auditor** reviews for vulnerabilities
