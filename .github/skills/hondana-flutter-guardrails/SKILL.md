---
name: hondana-flutter-guardrails
description: "Use when working in the Hondana Flutter app to enforce the project workflow: no widget-returning helper functions, no variables/logic in build or builder callbacks, no setState, no double.infinity, flutter_screenutil for all sizes, localization through nested .tr() keys, Bloc + BlocStatus state, core widgets from package:hondana/core/core.dart, and build_runner + flutter analyze validation."
---

# Hondana Flutter Guardrails

Use this skill when implementing or reviewing code in the Hondana Flutter app
(a port of [Mihon](https://github.com/mihonorg/mihon)).

## What to do first

1. Read `.github/copilot-instructions.md` (the strict rule source) and the
   relevant `.cursor/rules/*.mdc` slice for the area you're touching.
2. Inspect the relevant file(s) and understand the current feature flow.
3. Identify whether the change touches UI composition, state, localization,
   generated code, or an architecture boundary.
4. Apply the repo guardrails before editing anything.

## Required rules

- Never create a function or method that returns a widget — widget classes only,
  with `const` constructors.
- Never declare variables or run logic inside `build()`; only context reads used
  in the returned tree are allowed.
- Never declare variables, call helpers, or compute data inside builder callbacks
  (`itemBuilder`, `BlocBuilder`, `ValueListenableBuilder`, …).
- Never use `setState` — use `ValueNotifier` + `ValueListenableBuilder` /
  `ListenableBuilder`, or Bloc for feature state.
- Never use `double.infinity` for sizing — use `context.width` / `context.height`.
- All lengths go through `flutter_screenutil` (`16.w`, `16.h`, `12.r`, `12.sp`).
- All user-facing strings use nested dotted `.tr()` keys defined in
  `assets/translations/en.json`.
- Keep business logic, network calls, and database access out of page widgets.

## Preferred implementation pattern

- Put reusable UI in dedicated `StatelessWidget` / `StatefulWidget` classes.
- Put local widget state in `ValueNotifier`; feature state in a Bloc with a
  `BlocStatus` field per async action; render with `StatusBuilder`.
- Keep builder callbacks to inline expressions; pre-compute in Bloc/ValueNotifier.
- Use core widgets and `context` extensions from `package:hondana/core/core.dart`.
- Map drift rows to domain entities at the data boundary; keep drift out of
  `domain/` and presentation.

## Before you finish

- Confirm no widget-returning functions, no `setState`, no `double.infinity`, no
  raw size literals, no hardcoded strings.
- If routes / DI / drift annotations changed, run
  `dart run build_runner build --delete-conflicting-outputs`.
- Run `flutter analyze` — it must report "No issues found!".

## Good prompts for this skill

- Fix this page without using helper widget functions.
- Refactor this builder callback to comply with the Hondana guardrails.
- Convert these raw size literals to flutter_screenutil.
- Review this feature for guardrail violations.
