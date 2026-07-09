# Making keiyoushi extensions work on iOS — Plan

## 0. The blunt incompatibility

`index.min.json` describes ~350–400 **Android APKs** (`apk` field). An APK is
compiled Kotlin → Dalvik/ART bytecode. iOS has no JVM/ART, and Apple forbids
downloading + executing bytecode (App Review 2.5.2). **APKs cannot run on iOS —
there is no workaround at the APK level.** Only the *metadata* in the index and
the *source logic* (public Kotlin in `keiyoushi/extensions-source`) are portable.

## 1. What is actually reusable

- **The index as a catalog.** `name / pkg / lang / version / nsfw` + each
  `sources[].{name, lang, id, baseUrl}`. Parseable on any platform today — drives
  the Extensions browse UI (available / installed / update) with zero runtime.
- **The stable source `id`** (64-bit Tachiyomi hash of name+lang+versionId).
  Preserve it so library rows and migrations stay consistent across the Kotlin
  original and any re-implementation.
- **The Kotlin source code** in `keiyoushi/extensions-source` — this is what you
  port, not the APK. Structure: `lib-multisrc/` (shared "theme" engines) +
  individual `src/<lang>/<site>/` sources.

## 2. The distribution truth (decide this first)

No on-device-source manga reader ships on the **App Store** (2.5.2 + content
policy). iOS distribution for this class of app = **sideload**: AltStore /
SideStore, TestFlight, a 7-day self-sign, or an EU alternative marketplace.
Prior art all does this: **Paperback** (iOS, JS/TS sources), **Aidoku** (iOS,
Rust→WASM sources), **Mangayomi** (Flutter, JS sources, iOS), **Suwayomi/
Tachidesk** (server that runs the real APKs, Flutter client "Sorayomi").
→ Confirm sideload distribution is acceptable before investing; it gates everything.

## 3. Three strategies

| # | Strategy | Runs on iOS? | Reuses keiyoushi | Cost / burden | Prior art |
|---|----------|:---:|------|------|-----------|
| **A** | **Server gateway** — a JVM/Android backend loads the real APKs and exposes REST (`/popular /search /details /chapters /pages` + image proxy). App is a thin client. | ✅ (remote) | **Yes, verbatim APKs** | Infra, bandwidth, latency, legal/privacy, single point of failure | Suwayomi/Tachidesk |
| **B** | **On-device JS runtime** — sources as JS run in embedded QuickJS (`flutter_qjs`). Cross-platform, offline, private. | ✅ (local) | No (re-ported to JS) | Per-source porting + bridge maintenance | Mangayomi, Paperback |
| **C** | **Native Dart sources** — hand-port request/parse to Dart `HttpSource`. | ✅ (local) | No | Highest per-source; every site fix = app update | — |

## 4. Recommended architecture — hybrid behind the `Source` seam

The app already codes to `SourceManager` (phase 1). Ship **two interchangeable
backends** behind it; the user picks in Settings:

```
SourceManager (interface, already built)
├── JsRuntimeSourceManager   ← DEFAULT. On-device QuickJS + a JS source repo. Self-contained on iOS.
└── RemoteGatewaySourceManager ← OPTIONAL. Talks to a self-hosted Suwayomi → the LITERAL keiyoushi APKs.
```

`index.min.json` is parsed for the extension browser regardless of backend.
Result: normal users get on-device JS sources; power users who want the exact
keiyoushi Kotlin extensions point the app at their own Suwayomi server.

## 5. The efficiency unlock — port *themes*, not 400 sources

`keiyoushi/extensions-source/lib-multisrc/` is a small set of shared **theme
engines** — `Madara`, `MangaThemesia` (WPMangaStream/Keyoapp), `MangaReader`,
`ZeistManga`, `Iken`, `Peach`, `HeanCms`, etc. A single theme powers **hundreds**
of real sites; an individual "source" is often just `baseUrl` + a few selector
overrides on a theme.

So the porting target is **~15–20 theme engines + per-site config**, not 400
bespoke sources. Port the top themes to JS first and you cover the majority of
the catalog by configuration. Truly bespoke sources (MangaDex, Comick, …) are a
smaller one-off set. (Or bootstrap by adopting Mangayomi's existing JS repos,
which already cover a large overlapping site set.)

## 6. The hard technical pieces (needed by A or B)

- **Cloudflare / WAF challenges** — the recurring pain. On-device: solve via a
  headless `flutter_inappwebview` to obtain `cf_clearance` cookies + UA. Server:
  FlareSolverr / headless Chrome.
- **HTTP layer** — cookie jar, per-source User-Agent, `Referer`, custom headers.
- **HTML parsing** — Dart `html` pkg (already a dep) / a DOM shim inside JS /
  Jsoup on the server.
- **JS-in-source deobfuscation** — some sources run JS to unscramble URLs; free
  in Strategy B, needs `flutter_js` bolted on for C.
- **Image loading** — covers/pages must carry the source's headers/cookies
  (custom `cached_network_image` fetcher). Some readers **scramble page images** →
  per-source canvas unscramble.
- **Source-id parity** — replicate the 64-bit hash so migrations line up.

## 7. Phased implementation

- **Phase 1 (now, cross-platform, no runtime):** Extensions browse UI parses
  `index.min.json` read-only; `ExtensionManager` interface with a stub. *(Already
  in the phase-1 roadmap — Task #3.)*
- **Phase 2 — stand up Strategy B:** embed `flutter_qjs`, build the JS bridge
  (`fetch`, HTML/DOM, crypto), define the JS source contract mirroring
  `HttpSource`. Port the top ~10 multisrc themes → hundreds of sites live. Publish
  a JS source repo the app installs from.
- **Phase 3 — Cloudflare + images + parity:** headless-webview interceptor,
  header-aware image loader, scramble handlers, 64-bit id parity, source updates.
- **Phase 4 — optional Strategy A backend:** `RemoteGatewaySourceManager` +
  Suwayomi setup docs, for users who want the literal keiyoushi APKs.

## 8. Decision needed

1. **Backend to commit to first** — recommend **B (on-device JS runtime)**; add A
   later as an optional power-user backend.
2. **Confirm sideload** is an acceptable iOS distribution channel (App Store is
   effectively closed to this app class).
3. **Bootstrap source set** — adopt Mangayomi's JS repos to start, or port
   keiyoushi themes from scratch for a clean-room, id-compatible set.
