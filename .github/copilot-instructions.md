# GitHub Copilot Instructions — Hondana

> The **primary, strict** rule source for this repository. If any other guide
> (`CLAUDE.md`, `.cursor/rules/*`, `AGENTS.md`) conflicts with this file, this
> file wins. Read it before writing any code.

Hondana is a **Flutter port of [Mihon](https://github.com/mihonorg/mihon)**, an
offline-first manga reader (library, sources/extensions, reader, downloads,
history, updates). When unsure what a feature should *do*, Mihon is the reference.

---

## CRITICAL: Quality Gate

**No change is complete until the project validates locally.**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # when routes, DI, drift, or annotations change
flutter analyze                                            # must print "No issues found!"
```

Fix every failure before reporting completion. Never mark work done with analyzer
errors, stale generated files, broken imports, or missing route classes.

---

## Strict codebase rules

- Never leave stale generated files after route, DI, drift, or annotation changes.
- Never create placeholder routes that reference missing pages.
- Never add hardcoded user-facing text — route it through `easy_localization`.
- Never put network calls, database access, or navigation orchestration inside
  page widgets.
- Never hardcode colors in shared widgets — use `context.colorScheme.*`.
- Never mark work complete if `flutter analyze` reports any issue.

---

## NEVER create functions that return widgets

**Mandatory — no exceptions.**

```dart
// WRONG
Widget _buildHeader() => Container(...);

// CORRECT
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});
  @override
  Widget build(BuildContext context) => Container(...);
}
```

Always create widget classes with `const` constructors. This includes filter /
wrapper helpers — a method like `Widget _filtered(Widget child)` must become a
widget class that takes the child.

---

## NEVER declare variables or run logic inside build()

```dart
// WRONG
@override
Widget build(BuildContext context) {
  final color = Colors.red;   // NO
  bool isOpen = check();      // NO
  return Container(color: color);
}

// CORRECT — declare as class fields / constructor params
class MyWidget extends StatelessWidget {
  final Color color;
  const MyWidget({super.key, required this.color});
  @override
  Widget build(BuildContext context) => Container(color: color);
}
```

**Allowed inside build(), only when used in the returned tree:**

```dart
final theme = Theme.of(context);
final scheme = context.colorScheme;
final w = context.width;
// and constraints inside a LayoutBuilder's own callback
```

---

## NEVER compute data inside builder callbacks

Applies to `itemBuilder`, and `builder` in `ValueListenableBuilder`,
`ListenableBuilder`, `BlocBuilder`, `ListView.builder`, `PageView.builder`,
`AnimatedBuilder`, etc. No variable declarations, no helper calls, no
transformations — only a returned widget with inline expressions.

```dart
// WRONG
itemBuilder: (context, i) {
  final manga = library[i];       // NO
  return MangaCover(manga: manga);
}

// CORRECT — inline, or pass raw data to the child
itemBuilder: (context, i) => MangaCover(manga: library[i])
```

If the builder needs computed/sorted/filtered data, produce it in the Bloc state
or a `ValueNotifier` first (see `LibraryBloc._pipeline` for the pattern).

---

## NEVER use setState

Use `ValueNotifier` + `ValueListenableBuilder` / `ListenableBuilder` for local
widget state, and Bloc for feature state.

```dart
// WRONG
setState(() => _progress = p);

// CORRECT
final ValueNotifier<double> _progress = ValueNotifier(0);
_progress.value = p;

ValueListenableBuilder<double>(
  valueListenable: _progress,
  builder: (context, progress, _) => LinearProgressIndicator(value: progress),
)
```

---

## NEVER use double.infinity for sizing

```dart
// WRONG
Container(width: double.infinity)

// CORRECT
Container(width: context.width)
```

---

## ALL sizes go through flutter_screenutil

The app is wired with `ScreenUtilInit(designSize: Size(360, 800))`, so every
length must be scaled.

```dart
// WRONG                                  // CORRECT
SizedBox(height: 16)                      SizedBox(height: 16.h)
EdgeInsets.all(12)                        EdgeInsets.all(12.r)
EdgeInsets.symmetric(horizontal: 16)      EdgeInsets.symmetric(horizontal: 16.w)
BorderRadius.circular(12)                 BorderRadius.circular(12.r)
TextStyle(fontSize: 12)                   TextStyle(fontSize: 12.sp)
Badge(smallSize: 8)                       Badge(smallSize: 8.r)
```

Also available: `16.verticalSpace`, `16.horizontalSpace`. **Permitted unscaled:**
`0`, hairline border `1`, and integer counts/durations that are not lengths
(`maxLines: 1`, `Duration(milliseconds: 250)`, `crossAxisCount: 2`). When you
convert a value to `.h`/`.w`/`.r`/`.sp`, the enclosing widget is no longer `const`
— remove `const` accordingly, and add
`import 'package:flutter_screenutil/flutter_screenutil.dart';`.

---

## Localization — no hardcoded strings

All user-facing text goes through `easy_localization` with a **nested dotted key**
defined in `assets/translations/en.json`. There is **no** generated `LocaleKeys`
file — keys are resolved at runtime.

```dart
// WRONG
Text('Library')
AppText.titleLarge('Library')

// CORRECT
Text('nav.library'.tr())
AppText.titleLarge('nav.library')          // AppText translates its key internally
'library.removed_count'.tr(namedArgs: {'count': '$n'})
```

To add a string: add the key/value to `assets/translations/en.json` under the
right feature namespace, then reference it. Brand/source names that are proper
nouns (e.g. "MangaDex") are not translated.

---

## Architecture: Clean Architecture, Feature-First

```
lib/
├── main.dart / app.dart / initialization.dart   # entry, MaterialApp, bootstrap
├── core/            # DI, config, database, network, routing, state, theme, widgets
├── services/        # cross-cutting app services (downloads, live activity, library updates, …)
└── features/<feature>/                           # scaffold via `mason make feature`
    ├── data/
    │   ├── data_sources/   <f>_local_datasource.dart + <f>_remote_datasource.dart  (@injectable)
    │   └── repositories/   <f>_repository_imp.dart   @Injectable(as: <F>Repository)
    ├── domain/
    │   ├── entities/       <f>_entity.dart            (plain models — no drift/DTO types)
    │   └── repositories/   <f>_repository.dart        (abstract interface)
    └── presentation/
        ├── pages/          <f>_page.dart              @RoutePage wrapper (BlocProvider + PageLayoutBuilder)
        │   └── mobile/     <f>_page_mobile.dart       the actual AppScaffold screen tree
        ├── state/bloc/     <f>_bloc.dart, _event.dart, _state.dart
        └── widgets/        feature widget classes
```

**This structure is mandatory** — generate features with
`mason make feature --feature_name <name> -o lib/features` (brick in
`bricks/feature/`), never by hand. `pages/` always holds two things: the thin
`@RoutePage` wrapper and its `mobile/` implementation. The repository interface
lives in `domain/repositories/`; its `@Injectable(as: …)` implementation and the
local/remote data sources live under `data/`. Mirror the `auth` feature in the
sibling `shadows` project exactly. Local-only features may omit the remote data
source — don't create one that does nothing.

Shared UI/utilities live in `lib/core/` and are imported via
`package:hondana/core/core.dart`. There is no `packages/` monorepo and no Firebase.

- **No business logic in pages.** Pages compose a Bloc and UI only. Put
  orchestration (downloads, auth/lock, library updates, source resolution) in
  `data/`/`domain/` services wired through the Bloc.
- **Keep drift out of `domain/`.** Map database rows to domain entities at the
  data boundary (`Manga.fromData(...)`).

---

## State management

One Bloc per feature; each async action owns a `BlocStatus` field on the state.

```dart
@injectable
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._repo) : super(const LibraryState()) {
    on<LibrarySubscribed>(_onSubscribe, transformer: restartable());
    on<LibraryRefreshRequested>(_onRefresh, transformer: droppable());
  }

  Future<void> _onSubscribe(LibrarySubscribed e, Emitter<LibraryState> emit) async {
    emit(state.copyWith(loadStatus: const BlocStatus.loading()));
    await emit.forEach(
      _repo.watchLibrary(),
      onData: (list) => state.copyWith(
        manga: list,
        loadStatus: list.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
      ),
      onError: (err, st) => state.copyWith(
        loadStatus: BlocStatus.failure(AppException.from(err, st)),
      ),
    );
  }
}
```

Render with `StatusBuilder` (preferred) or `BlocBuilder`:

```dart
StatusBuilder<LibraryBloc, LibraryState>(
  statusSelector: (s) => s.loadStatus,
  emptyMessage: 'library.empty'.tr(),
  onSuccess: (context) => const LibraryGrid(),
)
```

---

## Core widgets & context extensions

Import everything from the barrel:

```dart
import 'package:hondana/core/core.dart';

// Widgets                              // Extensions (context_ext.dart)
AppScaffold(appBar: ..., body: ...)     context.colorScheme.primary
AppAppBar(...)                          context.textTheme.bodyLarge
AppText.titleLarge('nav.library')       context.width / context.height
AppLoadingIndicator()                   context.isDark
AppEmptyIndicator(message: ...)         context.isRtl
AppFailureIndicator(message: ..., onRetry: ...)
PageLayoutBuilder(mobile: ...)          // + screenutil: 16.w / 16.h / 16.r / 16.sp
```

Use `AppScaffold`/`AppAppBar`/`AppText` instead of raw `Scaffold`/`AppBar`/`Text`.

---

## Dependency Injection

```dart
@injectable            // new instance each resolve
@lazySingleton         // lazy singleton
@Injectable(as: Repo)  // register an implementation behind its interface

final bloc = getIt<LibraryBloc>();  // resolve at page/Bloc creation, never in build()
```

Run `dart run build_runner build --delete-conflicting-outputs` after adding an
`@injectable`, `@RoutePage`, or drift table/annotation.

---

## Routing

```dart
@RoutePage()
class LibraryPage extends StatelessWidget { ... }
```

Route tree in `lib/core/routing/app_router.dart` (generated
`app_router.gr.dart`). Navigate with `context.router` / `context.pushRoute(...)`.

---

## Persistence

- **drift** — `lib/core/database/app_database.dart`. Repositories expose `Stream`s
  the Blocs subscribe to.
- **Preferences** — one typed store per concern wrapping `shared_preferences`
  (`LibraryPreferences`, `ReaderPreferences`, …). Reactive ones expose a
  `ValueNotifier` (`AppSettings`).

---

## Error handling

Wrap failures in `AppException` (`lib/core/error/app_exception.dart`) and surface
them through `BlocStatus.failure(...)`:

```dart
try {
  await _updater.refreshAll();
  emit(state.copyWith(refreshStatus: const BlocStatus.success()));
} catch (err, st) {
  emit(state.copyWith(refreshStatus: BlocStatus.failure(AppException.from(err, st))));
}
```

---

## Documentation (public repo)

Every public class and non-trivial public member gets a `///` dartdoc comment:
one line on what it is/does, then a *why* or caveat if not obvious. Note ported
Mihon behavior explicitly ("Mihon behavior: …"). Comment intent, not syntax.

---

## General tips

- `const` constructors everywhere possible.
- File naming: `*_page.dart`, `*_bloc.dart`, `*_event.dart`, `*_state.dart`,
  `*_repository.dart`, `*_source.dart`.
- Keep widget files flat under `presentation/widgets/`.
- Git is the user's domain — do not commit/push/branch unless asked.
