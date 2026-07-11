# CLAUDE.md — Hondana (discoverability copy)

> The full project guide lives at the repo root: [`CLAUDE.md`](../CLAUDE.md).
> The strict, non-negotiable rules live at
> [`.github/copilot-instructions.md`](../.github/copilot-instructions.md).
> Per-tool slices live under [`.cursor/rules/`](../.cursor/rules/).
> When these conflict, `.github/copilot-instructions.md` wins.

## Load first, every session

1. **Read `.github/copilot-instructions.md` before writing any code.** It holds
   the mandatory codebase rules (summary below).
2. Read the root `CLAUDE.md` for architecture, patterns, and conventions.
3. Think before coding: state assumptions, keep changes surgical, define a
   verifiable success criterion, and only do what was asked.

## Hard rules (summary)

- Quality gate before "done": `flutter pub get`,
  `dart run build_runner build --delete-conflicting-outputs` (after
  routes/DI/drift/annotation changes), `flutter analyze` (zero issues).
- Never create functions/methods that return `Widget` — make widget classes.
- Never declare variables or run logic inside `build()` or builder callbacks.
- Never use `setState` — use `ValueNotifier` / Bloc.
- Never use `double.infinity` — use `context.width` / `context.height`.
- All sizes via `flutter_screenutil` (`16.w`, `16.h`, `12.r`, `12.sp`).
- No hardcoded user-facing strings — nested `.tr()` keys in
  `assets/translations/en.json`.
- No business logic / network / database access in page widgets.
- Use core widgets (`AppScaffold`, `AppAppBar`, `AppText`, feedback indicators)
  from `package:hondana/core/core.dart`.

Hondana is a Flutter port of [Mihon](https://github.com/mihonorg/mihon) — when
unsure what a feature should do, Mihon is the reference.
