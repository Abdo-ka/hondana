# Hondana — Project Guide

> Single source of truth for this repository. Day-to-day rules for humans and AI
> agents working on Hondana.
>
> A short discoverability copy lives at `.claude/CLAUDE.md`; the strict,
> non-negotiable rule set lives at `.github/copilot-instructions.md`; per-tool
> slices live under `.cursor/rules/`. When any of them conflict,
> `.github/copilot-instructions.md` wins.

## What Hondana is

Hondana is a **Flutter port of [Mihon](https://github.com/mihonorg/mihon)** — an
offline-first manga reader. It browses online sources (extensions), builds a
local **library**, tracks **reading history** and **updates**, **downloads**
chapters for offline reading, and renders them in a configurable **reader**.

The project is a clean-room re-implementation of Mihon's behavior in Dart; when
in doubt about *what* a feature should do, Mihon's behavior is the reference.

## Stack

- **Flutter 3.44** (stable). Commands use plain `flutter` — there is no pinned
  `.fvmrc`, so the ambient SDK is used. (If you manage Flutter with FVM, prefix
  commands with `fvm`; the toolchain is the same.)
- **Language:** Dart, `sdk: ">=3.10.0 <4.0.0"`.
- **State:** `flutter_bloc` + `bloc_concurrency`, one Bloc per feature.
- **DI:** `get_it` + `injectable` (`lib/core/di/`).
- **Routing:** `auto_route` (`lib/core/routing/`).
- **Local database:** `drift` (`lib/core/database/app_database.dart`).
- **Preferences:** `shared_preferences`, wrapped by typed `*Preferences` classes.
- **Networking:** `dio` (+ native adapters) and `http`, in `lib/core/network/`.
- **Images:** `cached_network_image` / `flutter_cache_manager`.
- **Sizing:** `flutter_screenutil` (design size `360×800`).
- **Localization:** `easy_localization` with nested dotted keys in
  `assets/translations/en.json`.
- **Downloads:** `background_downloader`. **Auth/lock:** `local_auth`.
  **Source webviews:** `flutter_inappwebview`.

There is **no Firebase**, **no analytics/crashlytics**, and **no `packages/`
monorepo** — shared UI and utilities live in `lib/core/`, imported through the
`package:hondana/core/core.dart` barrel.

## Quality Gate — run before reporting "done"

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after route/DI/drift/annotation changes
flutter analyze                                             # must be zero issues
```

`flutter analyze` must report **"No issues found!"**. Do not mark work complete
with analyzer errors, stale generated files, or broken imports. For UI or
navigation changes, also launch the app and walk the happy path.

## Architecture — Clean Architecture, Feature-First

```
lib/
├── main.dart              App entry: preInitializations() → EasyLocalization → HondanaApp
├── app.dart               HondanaApp: ScreenUtilInit + MaterialApp.router + theme + AppLockGate
├── initialization.dart    preInitializations(): bindings, easy_localization, DI, drift
│
├── core/                  Cross-feature primitives — imported via core/core.dart
│   ├── config/            AppSettings, advanced/security preference stores
│   ├── database/          drift AppDatabase (+ generated app_database.g.dart)
│   ├── di/                injectable container (+ generated di_container.config.dart)
│   ├── error/             AppException
│   ├── extensions/        context_ext.dart (context.colorScheme / width / isRtl …)
│   ├── network/           app_http.dart (Dio + native adapters)
│   ├── routing/           app_router.dart (+ generated app_router.gr.dart)
│   ├── state/             BlocStatus + StatusBuilder (per-action status pattern)
│   ├── theme/             AppTheme (light / dark / pure-black)
│   ├── utils/             BlocObserver, date helpers, native screen helpers
│   └── widgets/           AppScaffold, AppAppBar, AppText, feedback indicators, …
│
└── features/<feature>/                 Scaffold new ones with `mason make feature`
    ├── data/
    │   ├── data_sources/     <f>_local_datasource.dart, <f>_remote_datasource.dart (@injectable)
    │   └── repositories/     <f>_repository_imp.dart      @Injectable(as: <F>Repository)
    ├── domain/
    │   ├── entities/         <f>_entity.dart               (plain domain models)
    │   └── repositories/     <f>_repository.dart           (abstract interface)
    └── presentation/
        ├── pages/            <f>_page.dart                 @RoutePage wrapper: BlocProvider + PageLayoutBuilder(mobile: …)
        │   └── mobile/       <f>_page_mobile.dart          the actual AppScaffold screen tree
        ├── state/bloc/       <f>_bloc.dart, _event.dart, _state.dart
        └── widgets/          feature widget classes
```

**Features:** `browse` (sources / extensions / global search), `library`,
`manga` (details), `reader`, `downloads`, `history`, `updates`, `more`
(settings), `main` (bottom-nav shell).

### Mandatory feature structure

Every feature follows the layout above — generate it with
`mason make feature --feature_name <name> -o lib/features` (see `bricks/feature/`),
never hand-roll folders. The non-negotiable shape:

- **`data/data_sources/`** — a `@injectable` `<F>LocalDataSource` (drift / prefs)
  and `<F>RemoteDataSource` (network / sources). Local-only features may omit the
  remote one; never invent a data source that does nothing.
- **`data/repositories/<f>_repository_imp.dart`** — `@Injectable(as: <F>Repository)`,
  implements the domain interface, orchestrates the data sources.
- **`domain/entities/`** — plain domain models (`*_entity.dart`); keep drift/DTO
  types out. **`domain/repositories/`** — the abstract `<F>Repository` contract.
- **`presentation/pages/`** holds **two things**: `<f>_page.dart` (the thin
  `@RoutePage` wrapper — provides the Bloc, returns `PageLayoutBuilder(mobile: …)`)
  and `mobile/<f>_page_mobile.dart` (the real screen tree). Blocs live under
  **`presentation/state/bloc/`**; widget classes under `presentation/widgets/`.

Reference implementation to mirror exactly: the `auth` feature in the sibling
`shadows` project.

### File-name stability — do not rename

`lib/main.dart`, `lib/app.dart`, `lib/initialization.dart`, and the generated
files (`*.g.dart`, `*.gr.dart`, `*.config.dart`) keep their names. Internal
structure may change freely.

## Mandatory Rules — non-negotiable

These override any "bias toward doing". Full detail with examples in
`.github/copilot-instructions.md`.

1. **No widget-returning functions.** Always a `StatelessWidget` /
   `StatefulWidget` class with a `const` constructor. Never `Widget _buildX() =>
   …`.
2. **No locals/logic between `build(` and `return`.** The only statements
   allowed in a `build` body are context reads (`context.colorScheme`,
   `context.width`, `Theme.of(context)`) used inside the returned tree, and
   `LayoutBuilder` constraints inside its own callback. Everything else is a
   constructor parameter or a class field.
3. **No computation inside builder callbacks** (`itemBuilder`, `BlocBuilder`,
   `ValueListenableBuilder`, …) — inline expressions only. Pre-compute in the
   Bloc state or a `ValueNotifier`.
4. **No `setState`.** `ValueNotifier` + `ValueListenableBuilder` /
   `ListenableBuilder` for local widget state; Bloc for feature state.
5. **No `double.infinity` for sizing.** Use `context.width` / `context.height`.
6. **All sizes responsive via `flutter_screenutil`.** `12.w`, `12.h`, `12.r`,
   `12.sp`, `12.verticalSpace`, `12.horizontalSpace`. Banned raw literals:
   `width: 12`, `height: 12`, `BorderRadius.circular(12)`, `EdgeInsets.all(12)`,
   `fontSize: 12`, `SizedBox(height: 12)`. Permitted unscaled: `0`, hairline
   `1`, and integer counts/durations that are not lengths (`maxLines: 1`,
   `Duration(milliseconds: 250)`).
7. **No hardcoded user-facing strings.** Route every visible string through
   `easy_localization`: a dotted key defined in `assets/translations/en.json`,
   used as `'library.search_hint'.tr()` or `AppText.titleLarge('nav.library')`
   (`AppText` translates its key internally). Never a bare literal like
   `Text('Library')`.
8. **No business logic in pages.** Pages compose Bloc + UI. Auth checks, timers,
   navigation decisions, downloads orchestration → a service under
   `data/` / `domain/` or `presentation/` wired through the Bloc.
9. **No network calls in presentation.** Sources/repositories fetch; Blocs call
   them and expose `BlocStatus`; pages render state.
10. **RTL via `context.isRtl`** (`Directionality.of(context) == rtl`), never by
    comparing locale strings.

## State — Bloc + BlocStatus

- **One Bloc per feature, many actions.** Each async action owns its own
  `BlocStatus` field on the state (`loadStatus`, `refreshStatus`, …) — not its
  own Bloc.
- State classes carry an explicit `copyWith` and value equality; events are a
  `sealed`/`final` class hierarchy.
- Concurrency (`bloc_concurrency`): list/stream subscriptions → `restartable()`;
  pull-to-refresh and one-shot mutations → `droppable()` / default sequential.
- **`BlocStatus`** (`lib/core/state/bloc_status.dart`) is the per-action status:
  `initial / loading / success / empty / failure`. Emit `BlocStatus.empty()`
  when a loaded list is empty so the UI can show an empty illustration.
- **UI:** prefer `StatusBuilder<Bloc, State>(statusSelector: (s) => s.xStatus,
  onSuccess: …)`. Drop to `BlocBuilder` only for multi-status or when the builder
  needs state data. Pass `emptyMessage:` (a translated key) so the empty branch
  renders `AppEmptyIndicator`.

## UI conventions

- **Use core widgets, not raw Material.** `AppScaffold` not `Scaffold`,
  `AppAppBar` not `AppBar`, `AppText.<style>('key')` not `Text`, and the feedback
  indicators (`AppLoadingIndicator`, `AppEmptyIndicator`, `AppFailureIndicator`)
  for load states. Import them from `package:hondana/core/core.dart`.
- **Pages are thin.** A page wraps its content in `PageLayoutBuilder(mobile: …)`,
  provides its Bloc, and returns `AppScaffold(appBar: …, body: …)` whose body is
  a composition of **extracted widget classes** from `presentation/widgets/`.
  Extract a section to its own class when it is reused, substantial (its own
  layout/state), or needed to keep a page readable — otherwise keep it as a
  private `_Widget` class in the same file. Don't explode a screen into dozens
  of micro-widget files.
- **Colors come from the theme.** `context.colorScheme.*` — never hardcoded hex
  in shared widgets. Dark mode has a pure-black variant (`AppTheme.dark(pureBlack:
  …)`) driven by `AppSettings.pureBlackNotifier`.
- **Lists/grids** use `ListView`/`GridView` builders; never fake a grid with
  `Row`s of `Expanded` + spacers.

## Localization

- Single bundle today: `assets/translations/en.json`, nested by feature
  (`library.*`, `nav.*`, `reader.*`, …). Add a key there, then use
  `'feature.key'.tr()` or `AppText.<style>('feature.key')`.
- The app is wired for more locales via `EasyLocalization` in `main.dart`; add a
  `<locale>.json` with the same key shape to introduce one. No code generation
  step — keys are looked up at runtime, so there is no `LocaleKeys` file.

## Persistence & preferences

- **drift** is the local database (`lib/core/database/app_database.dart`), holding
  manga, chapters, categories, history, etc. Repositories expose `Stream`s the
  Blocs subscribe to; keep drift types out of `domain/` — map rows to domain
  entities (see `Manga.fromData`).
- **Typed preference stores** wrap `shared_preferences` — one class per concern
  (`LibraryPreferences`, `ReaderPreferences`, `DownloadPreferences`,
  `SecurityPreferences`, `AdvancedPreferences`), registered in DI and injected.
  Reactive settings expose a `ValueNotifier` (see `AppSettings`).

## Sources & extensions (browse)

Mihon's source system is ported under `features/browse/`:

- `domain/source/` defines the `Source` abstraction and models (`SManga`,
  `SChapter`, `MangasPage`, `Filter`, `MangaStatus`).
- `data/source/` holds concrete sources — `HttpSource` base, a `LocalSource`,
  and site families (`madara`, `mangadex`, `teamx`, `themesia`, `zeist`).
- `SourceManager` resolves a source by id; `builtin_source_manager.dart`
  registers the bundled ones. HTML sources parse with `package:html`.

## Dependency Injection

```dart
@injectable            // new instance each resolve
@lazySingleton         // lazy singleton
@Injectable(as: Repo)  // register an implementation behind its interface
```

Resolve via `getIt<X>()` at composition points (page/Bloc creation) — never call
`getIt` from inside `build()`. Run `build_runner` after adding or changing an
`@injectable`, `@RoutePage`, or drift annotation.

## Routing

`auto_route`. Pages are annotated `@RoutePage()`; the route tree is in
`lib/core/routing/app_router.dart` (generated `app_router.gr.dart`). Navigate
with `context.router` / `context.pushRoute(...)`. Run `build_runner` after
adding a route.

## Scope discipline

Do only what was asked. Treat described-but-not-requested changes as context, not
a work order — surface them, don't silently implement them. No "while I'm here"
cleanups, no regenerating code whose inputs you didn't touch. Mark conscious
deferrals with `// TODO: <what> — skipped because <why>` and list them at the end
of a task.

## Documentation style (this repo is public)

Hondana is published on GitHub, so the code is documented for readers:

- Every public class, and every non-trivial public member, gets a `///` dartdoc
  comment. Lead with what it *is* / what it *does* in one line, then the *why* or
  a caveat if it isn't obvious. Match the existing terse voice (see `Manga`,
  `BlocStatus`, `StatusBuilder`).
- Reference Mihon behavior in a comment when a rule is non-obviously ported
  ("Mihon behavior: …").
- Comment intent, not syntax. Don't narrate what the code plainly says.

## Git & contribution conventions

Git is the user's domain — don't commit, push, branch, merge, or rewrite history
unless explicitly asked. When you do, follow the project conventions (full detail
in [`CONTRIBUTING.md`](CONTRIBUTING.md)):

- **Branches:** `feature/<name>` for new work, `fix/<issue-or-name>` for bug
  fixes (also `docs/`, `chore/`). One logical change per branch/PR.
- **Commits:** Conventional Commits — `type(scope): imperative summary`, where
  `type` ∈ `feat, fix, docs, style, refactor, perf, test, build, ci, chore` and
  `scope` is usually the feature. PR titles are CI-linted to this shape and PRs
  are squash-merged.
