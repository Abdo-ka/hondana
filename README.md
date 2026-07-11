# Hondana

[![CI](https://github.com/Abdo-ka/hondana/actions/workflows/ci.yml/badge.svg)](https://github.com/Abdo-ka/hondana/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B.svg?logo=flutter)](https://flutter.dev)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**Hondana** is an offline-first manga reader for mobile, built with **Flutter** —
a clean-room port of [**Mihon**](https://github.com/mihonorg/mihon) (the Android
manga reader, formerly Tachiyomi) to Dart/Flutter.

Browse online sources, build a personal library, read online or offline, and keep
track of your history and updates — all from a single cross-platform app.

> Status: early development (`0.1.0`). Core reading, library, and source flows are
> in place; expect rapid change.

---

## Features

- **Library** — organize saved manga into categories, with sort (title, unread,
  date added, last update), tri-state filters (unread / completed / downloaded),
  grid & list display modes, search, and multi-select actions.
- **Browse** — install and browse online **sources** (extensions), run a
  **global search** across sources, and open a source's site in an in-app
  WebView. Bundled source families include Madara, MangaDex, TeamX, Themesia, and
  Zeist, plus a local source.
- **Manga details** — cover, metadata, description, genres, and the chapter list
  with per-chapter download and read state.
- **Reader** — paged and continuous (webtoon) reading with configurable color
  filters, grayscale, inversion, and blend modes (ported from Mihon).
- **Downloads** — queue chapters for offline reading via a background download
  service, with a downloads manager and per-chapter controls.
- **History** — recently read chapters, resume where you left off.
- **Updates** — new chapters detected by library update runs (with a Wi-Fi-only
  option).
- **Settings** — appearance (theme + pure-black dark mode), reader, library,
  downloads, browse, data & storage, security (Face ID / Touch ID **app lock**),
  advanced, and about.

---

## Tech stack

| Concern | Choice |
| --- | --- |
| Framework | Flutter 3.44 (stable), Dart 3.10+ |
| State management | `flutter_bloc` + `bloc_concurrency` (one Bloc per feature) |
| Dependency injection | `get_it` + `injectable` |
| Routing | `auto_route` |
| Local database | `drift` (SQLite) |
| Preferences | `shared_preferences` (typed stores) |
| Networking | `dio` (native adapters) + `http` |
| Images | `cached_network_image` / `flutter_cache_manager` |
| Responsive sizing | `flutter_screenutil` |
| Localization | `easy_localization` |
| Downloads | `background_downloader` |
| Source WebViews | `flutter_inappwebview` |
| Biometric lock | `local_auth` |

There is no Firebase, analytics, or crashlytics — Hondana keeps your reading local.

---

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) **3.44** (stable
  channel) and a working iOS/Android toolchain.

### Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (routes, DI, drift) — required on first run and after
#    changing any @RoutePage / @injectable / drift annotation
dart run build_runner build --delete-conflicting-outputs

# 3. Launch on a connected device or simulator
flutter run
```

### Validate

```bash
flutter analyze   # must report "No issues found!"
flutter test
```

---

## Project structure

Hondana follows **Clean Architecture** with a **feature-first** layout:

```
lib/
├── main.dart              # entry: bootstrap → EasyLocalization → HondanaApp
├── app.dart               # ScreenUtilInit + MaterialApp.router + theme + app lock
├── initialization.dart    # preInitializations(): bindings, localization, DI, drift
│
├── core/                  # cross-feature primitives (import via core/core.dart)
│   ├── config/            #   settings + preference stores
│   ├── database/          #   drift database
│   ├── di/                #   injectable container
│   ├── error/             #   AppException
│   ├── extensions/        #   context.colorScheme / width / isRtl …
│   ├── network/           #   Dio + native adapters
│   ├── routing/           #   auto_route tree
│   ├── state/             #   BlocStatus + StatusBuilder
│   ├── theme/             #   light / dark / pure-black themes
│   ├── utils/             #   observers, date & screen helpers
│   └── widgets/           #   AppScaffold, AppAppBar, AppText, feedback indicators
│
└── features/<feature>/
    ├── data/              # sources, repository implementations, services
    ├── domain/            # entities, models, repository interfaces, preferences
    └── presentation/
        ├── bloc/          # <feature>_bloc.dart, _event.dart, _state.dart
        ├── pages/         # @RoutePage screens (thin composition)
        └── widgets/       # feature widget classes
```

Features: `browse`, `library`, `manga`, `reader`, `downloads`, `history`,
`updates`, `more` (settings), `main` (bottom-nav shell).

---

## Conventions

Hondana enforces a strict, consistent codebase. Before contributing, read:

- [`.github/copilot-instructions.md`](.github/copilot-instructions.md) — the
  strict, mandatory rules (the source of truth).
- [`CLAUDE.md`](CLAUDE.md) — architecture, patterns, and day-to-day guidance.
- [`.cursor/rules/`](.cursor/rules/) — focused, always-applied rule slices.

Highlights: widget **classes** only (no widget-returning functions), no
`setState` (use `ValueNotifier` / Bloc), all sizes via `flutter_screenutil`, no
hardcoded user-facing strings (localized `.tr()` keys), and no business logic in
page widgets.

---

## Contributing

Contributions are welcome, whether it's code, docs, translations, or a new
source! Please read **[CONTRIBUTING.md](CONTRIBUTING.md)** for the development
setup, coding conventions, commit format (Conventional Commits), and pull-request
process. By participating you agree to our [Code of Conduct](CODE_OF_CONDUCT.md).

- 🐛 [Report a bug or request a feature](../../issues/new/choose)
- 🔒 Found a vulnerability? See [SECURITY.md](SECURITY.md)
- 📋 Coding rules live in [`.github/copilot-instructions.md`](.github/copilot-instructions.md)

## Acknowledgements

Hondana is a Flutter port and would not exist without the work of the
[**Mihon**](https://github.com/mihonorg/mihon) project and the broader
Tachiyomi/Mihon community. When a behavior is ambiguous, Mihon is the reference.

## License

Hondana is licensed under the [Apache License 2.0](LICENSE) — the same license as
the upstream [Mihon](https://github.com/mihonorg/mihon/blob/main/LICENSE) project.
See [NOTICE](NOTICE) for attribution.
