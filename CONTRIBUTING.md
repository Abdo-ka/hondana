# Contributing to Hondana

First off — thank you for taking the time to contribute! 🎉 Hondana is a
community-driven, open-source manga reader (a Flutter port of
[Mihon](https://github.com/mihonorg/mihon)), and it only gets better with help.

This guide walks you through everything, even if you've never contributed to an
open-source project before. If anything is unclear,
[open a discussion or issue](https://github.com/Abdo-ka/hondana/issues) — no
question is too small.

---

## Table of contents

- [Ways to contribute](#ways-to-contribute)
- [Development setup](#development-setup)
- [Project conventions (read before coding)](#project-conventions-read-before-coding)
- [The quality gate](#the-quality-gate)
- [Branching & workflow](#branching--workflow)
- [Commit messages (Conventional Commits)](#commit-messages-conventional-commits)
- [Opening a pull request](#opening-a-pull-request)
- [Reporting bugs & requesting features](#reporting-bugs--requesting-features)
- [Code of Conduct](#code-of-conduct)

---

## Ways to contribute

You don't have to write code to help:

- 🐛 **Report bugs** — file an [issue](https://github.com/Abdo-ka/hondana/issues/new/choose).
- 💡 **Suggest features** — open a feature request.
- 📖 **Improve docs** — fix a typo, clarify a guide, add examples.
- 🌐 **Add translations** — extend `assets/translations/`.
- 🔌 **Port a source** — add a new manga source under `lib/features/browse/data/source/`.
- 🧑‍💻 **Fix issues** — look for issues labelled
  [`good first issue`](https://github.com/Abdo-ka/hondana/labels/good%20first%20issue).

---

## Development setup

You need [Flutter **3.44**](https://docs.flutter.dev/get-started/install) (stable
channel) and a working iOS/Android toolchain.

```bash
# 1. Fork the repo on GitHub, then clone YOUR fork
git clone https://github.com/<your-username>/hondana.git
cd hondana

# 2. Add the upstream remote so you can stay in sync
git remote add upstream https://github.com/Abdo-ka/hondana.git

# 3. Install dependencies
flutter pub get

# 4. Generate code (routes, DI, database) — required on first run and after
#    changing any @RoutePage / @injectable / drift annotation
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

The project layout and architecture are documented in
[`README.md`](README.md#project-structure) and [`CLAUDE.md`](CLAUDE.md).

---

## Project conventions (read before coding)

Hondana enforces a **strict, consistent style**. Please read these before your
first change — PRs that ignore them will be asked to update:

- [`.github/copilot-instructions.md`](.github/copilot-instructions.md) — the
  **mandatory** rules (the source of truth).
- [`CLAUDE.md`](CLAUDE.md) — architecture, patterns, and day-to-day guidance.
- [`.cursor/rules/`](.cursor/rules/) — focused rule slices per area.

The short version:

- Widget **classes** only — never functions that return a `Widget`.
- No `setState` — use `ValueNotifier` / `ValueListenableBuilder` or a Bloc.
- No `double.infinity`; all sizes via `flutter_screenutil` (`16.w`, `16.h`,
  `12.r`, `12.sp`).
- No hardcoded user-facing strings — use nested `.tr()` keys in
  `assets/translations/en.json`.
- No business logic, network, or database access in page widgets.
- Use the core widgets (`AppScaffold`, `AppAppBar`, `AppText`, …) from
  `package:hondana/core/core.dart`.
- Document new public classes/members with `///` dartdoc.

---

## The quality gate

**Every change must pass this locally before you open a PR** (CI runs the same
checks):

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # if you touched routes/DI/drift/annotations
dart format lib                                            # auto-format
flutter analyze                                            # must print "No issues found!"
flutter test                                              # all tests green
```

If `flutter analyze` reports anything, fix it before pushing.

---

## Branching & workflow

We use a simple fork + feature-branch flow off `main`:

```bash
# Sync your fork's main with upstream
git checkout main
git pull upstream main

# Create a descriptive branch for your work
git checkout -b feat/reader-double-tap-zoom
#            ^type/short-description

# ... make changes, commit ...

# Push to your fork and open a PR against upstream main
git push origin feat/reader-double-tap-zoom
```

Branch-name prefixes mirror the commit types below (`feat/`, `fix/`, `docs/`, …).
Keep one logical change per branch/PR — it's much easier to review.

---

## Commit messages (Conventional Commits)

We follow the [Conventional Commits](https://www.conventionalcommits.org/) format.
It keeps history readable and lets us auto-generate changelogs.

**Format:**

```
type(scope): short summary in the imperative mood

Optional longer body explaining *why* the change was made.

Optional footer (e.g. "Closes #123").
```

**`type`** is one of:

| Type | Use for |
| --- | --- |
| `feat` | a new feature |
| `fix` | a bug fix |
| `docs` | documentation only |
| `style` | formatting/whitespace (no code-behavior change) |
| `refactor` | code change that neither fixes a bug nor adds a feature |
| `perf` | a performance improvement |
| `test` | adding or fixing tests |
| `build` | build system, dependencies, generated code |
| `ci` | CI configuration |
| `chore` | maintenance, tooling, misc |

**`scope`** (optional) is the affected area — usually a feature: `reader`,
`library`, `browse`, `downloads`, `history`, `updates`, `manga`, `settings`,
`core`.

**Examples:**

```
feat(reader): add double-tap to zoom in paged mode
fix(library): keep scroll position after applying a filter
docs(contributing): explain the commit convention
refactor(browse): extract source parsing into HttpSource base
perf(library): cache the filter+sort pipeline result
build(deps): bump drift to 2.22.0
```

Rules of thumb: use the **imperative mood** ("add", not "added"/"adds"), keep the
summary under ~72 characters, and don't end it with a period.

---

## Opening a pull request

1. Push your branch to your fork and open a PR against `main`.
2. Fill in the PR template — describe **what** changed and **why**, and link the
   issue it addresses (`Closes #123`).
3. Make sure the [quality gate](#the-quality-gate) passes — CI will run it too.
4. A maintainer will review. Please be responsive to feedback; small follow-up
   commits are fine (we squash-merge, so history stays clean).
5. Once approved and green, it gets merged. 🎉

**Tips for a smooth review:** keep PRs focused and small, include screenshots or
a short screen recording for UI changes, and update docs/tests alongside code.

---

## Reporting bugs & requesting features

Use the [issue templates](https://github.com/Abdo-ka/hondana/issues/new/choose):

- **Bug report** — include steps to reproduce, expected vs. actual behavior, your
  device/OS, and the app version. Logs or screenshots help a lot.
- **Feature request** — describe the problem you're trying to solve, not just the
  solution. Mention how Mihon handles it if relevant.

Please search existing issues first to avoid duplicates.

---

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By
participating, you agree to uphold it. Be kind and constructive.

Thanks again for contributing to Hondana! 📚
