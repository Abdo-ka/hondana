# AI Agent Guide — Hondana

This repository defines strict, mandatory conventions. Any AI agent (Cursor,
Copilot, Claude, …) must follow them.

## Documentation precedence

1. **`.github/copilot-instructions.md`** — the primary, strict rule source. Read
   it before implementing, refactoring, or reviewing code.
2. **`CLAUDE.md`** (repo root) — architecture, patterns, and day-to-day guidance.
3. **`.cursor/rules/*.mdc`** — focused, always-applied slices:
   - `flutter-guardrails.mdc` — widget/build guardrails
   - `flutter-architecture.mdc` — clean architecture + layering
   - `flutter-state-and-patterns.mdc` — Bloc / BlocStatus / ValueNotifier
   - `flutter-ui-conventions.mdc` — core widgets, sizing, theming, localization
   - `flutter-workflow.mdc` — build, codegen, DI, routing, persistence
4. **`README.md`** — project overview and setup.

If any documentation conflicts, `.github/copilot-instructions.md` takes
precedence. Do not start code changes until the relevant rules are reviewed.

## Non-negotiables (quick list)

- No widget-returning functions — widget classes only.
- No variables/logic in `build()` or builder callbacks.
- No `setState`; use `ValueNotifier` / Bloc.
- No `double.infinity`; all sizes via `flutter_screenutil`.
- No hardcoded user-facing strings; nested `.tr()` keys.
- No business logic / network / database access in pages.

## Daily commands

```bash
flutter pub get
flutter run
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Hondana is a Flutter port of [Mihon](https://github.com/mihonorg/mihon).
