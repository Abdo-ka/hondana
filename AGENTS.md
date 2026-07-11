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

## Feature structure (mandatory)

Every feature follows Clean Architecture, feature-first. Generate new ones with
Mason — never hand-roll folders:

```bash
mason make feature --feature_name <name> -o lib/features
```

```
features/<name>/
├── data/
│   ├── data_sources/   <name>_local_datasource.dart, <name>_remote_datasource.dart  (@injectable)
│   └── repositories/   <name>_repository_imp.dart      (@Injectable(as: <Name>Repository))
├── domain/
│   ├── entities/       <name>_entity.dart               (plain models)
│   └── repositories/   <name>_repository.dart           (abstract interface)
└── presentation/
    ├── pages/          <name>_page.dart                 (@RoutePage wrapper)
    │   └── mobile/     <name>_page_mobile.dart          (the screen tree)
    ├── state/bloc/     <name>_bloc.dart, _event.dart, _state.dart
    └── widgets/        <name>_widget.dart
```

`pages/` always holds two things: the thin `@RoutePage` wrapper and its `mobile/`
implementation. Mirror the `auth` feature in the sibling `shadows` project.

## Branch & commit conventions

- Branches: `feature/<name>` (new work), `fix/<issue-or-name>` (bug fixes), also
  `docs/`, `chore/`.
- Commits & PR titles: Conventional Commits — `type(scope): imperative summary`
  (`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`,
  `chore`). CI lints PR titles; PRs are squash-merged. See `CONTRIBUTING.md`.

## Daily commands

```bash
flutter pub get
flutter run
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Hondana is a Flutter port of [Mihon](https://github.com/mihonorg/mihon).
