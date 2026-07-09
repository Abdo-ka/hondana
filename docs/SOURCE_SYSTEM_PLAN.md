# Source / Extension System — Plan (DEFERRED to the iOS phase)

> Phase 1 builds the **entire app against a `Source` interface** and ships a real
> `LocalSource` so everything is usable. The concrete *extension runtime* (how
> remote sources are actually fetched/parsed) is the only thing deferred here.
> Swapping the runtime in later touches **zero** feature code.

## 1. Why this can be skipped cleanly

Mihon never calls an extension directly. Every feature depends on an abstract
`Source`:

- Browse catalogue  → `CatalogueSource.getPopularManga / getLatestUpdates / getSearchManga`
- Global search     → same, fanned across sources
- Manga details     → `Source.getMangaDetails`
- Chapter list      → `Source.getChapterList`
- Reader page list  → `Source.getPageList` + `getImage`
- Library refresh    → `getMangaDetails` + `getChapterList`
- Downloads          → `getPageList` + `getImage`
- Migration          → `getSearchManga` on the target source

So we define this same interface in Dart, and **all of phase 1 codes to it.**

## 2. The Dart seam (built in phase 1)

Mirrors tachiyomi/Mihon `source-api`:

```
Source                 { int id; String name; String lang; }
CatalogueSource : Source {
  Future<MangasPage> getPopularManga(int page);
  Future<MangasPage> getLatestUpdates(int page);
  Future<MangasPage> getSearchManga(int page, String query, FilterList filters);
  FilterList getFilterList();
}
HttpSource : CatalogueSource {         // remote sources
  Future<SManga>       getMangaDetails(SManga manga);
  Future<List<SChapter>> getChapterList(SManga manga);
  Future<List<Page>>   getPageList(SChapter chapter);
  Future<String>       getImageUrl(Page page);   // + getImage(Page)
}

// models
SManga { url, title, artist, author, description, genre, status, thumbnailUrl, ... }
SChapter { url, name, dateUpload, chapterNumber, scanlator, ... }
Page { index, url, imageUrl, ... }
MangasPage { List<SManga> mangas; bool hasNextPage; }
Filter / FilterList     // header, select, sort, text, checkbox, group, tri-state

SourceManager      { Source? get(int id); List<CatalogueSource> getCatalogueSources(); }
ExtensionManager   { available / installed / updates; install / uninstall / update }
```

Phase-1 backing:
- `SourceManager` → **`StubSourceManager`**: returns `LocalSource` (+ optional demo source).
- `LocalSource` → **real, fully working**: reads manga from device storage
  (folder of images / CBZ / ZIP). No network, no runtime needed. This is what
  makes the library + reader + downloads demoable in phase 1. Mihon ships this too.
- `ExtensionManager` → **stub**: the Extensions **UI is fully built**, and it can
  even parse the real keiyoushi `index.min.json` to populate the browse list
  (read-only) — but install/run is a no-op until the iOS-phase runtime lands.

## 3. The deferred runtime — options (decide at iOS phase)

The blunt fact: **keiyoushi `index.min.json` lists Android APKs. APKs cannot run
on iOS.** So the execution engine must change; the metadata (names, langs, icons,
versions) in that index stays useful for the extension-browser UI regardless.

| Option | How | iOS? | Cost | Consumes keiyoushi? |
|---|---|---|---|---|
| **A. JS runtime** (recommended) | `flutter_js`/QuickJS runs source modules written in JS; same `HttpSource` surface. This is the proven Mangayomi/Aniyomi model. | ✅ | Med — needs a JS-source repo; port keiyoushi Kotlin→JS (manual or codegen). | Indirectly (re-ported) |
| **B. Native Dart sources** | Hand-port each source's request/parse to a Dart `HttpSource` subclass. | ✅ | High — every source is manual; no existing repo. | No |
| **C. Server proxy** | Host the Kotlin extensions server-side, expose REST; the app stays a thin client. | ✅ | Med client / High infra — backend, hosting, latency, single point of failure. | ✅ directly |

Recommendation: **A (JS runtime)** — cross-platform from one codebase, reuses an
existing extension ecosystem, and matches the app that already proves iOS works
(Mangayomi). Keep `index.min.json` parsing for the extension catalog UI.

## 4. What the iOS phase actually does

1. Implement `ExtensionManager` + a concrete `Source` factory over the chosen runtime (A/B/C).
2. Point it at a source repo (JS repo for A; server for C).
3. Everything else — browse, search, library, reader, downloads, migration — already
   works against the interface and needs no change.
