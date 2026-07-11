# Mihon Parity Plan — status & roadmap (iOS-first)

> Where mihonx stands against [Mihon](https://github.com/mihonapp/mihon) feature-by-feature,
> what still needs to sync, and the order to do it in — **targeting iOS as the primary
> platform**. Status audited from the actual code on 2026-07-10.
>
> Legend: ✅ done (Mihon-equivalent) · 🟡 partial (exists, gaps listed) · ❌ missing

---

## 0. Platform direction: iOS

Everything below assumes iOS is the shipping target. The three iOS-defining constraints:

1. **No APK extensions, ever.** Keiyoushi extensions cannot execute on iOS. Native Dart
   source ports (current approach) *are* the extension strategy; a JS/QuickJS runtime is
   the scalable fallback (`docs/SOURCE_SYSTEM_PLAN.md`).
2. **Background work is OS-granted, not owned.** Downloads already ride URLSession
   background sessions (`background_downloader` — zero iOS setup needed, verified).
   Library auto-update must use `BGTaskScheduler` semantics (opportunistic, not exact).
   Force-quitting the app kills background downloads — that is an iOS platform rule.
3. **Distribution is sideload/TestFlight**, not stores. NSFW gating, update checker, and
   extension repos need to assume no Play-style distribution.

### iOS wiring already done
- Podfile at iOS 14 (plugin minimum); `cupertino_http`/native TLS stack for sources.
- Downloads: URLSession background tasks per page; queue persisted + restored at launch
  (`DownloadsBloc` eagerly created in `preInitializations()`); kill-reconciliation from the
  native task DB; serial chapter order.
- Notifications: static-body running notification on iOS (iOS re-issues group
  notifications on text change — dynamic page counters are Android-only); permission
  requested at startup.
- ATS exception (`NSAllowsArbitraryLoads`) for http-only source CDNs.

### iOS work still needed
- [ ] **Device bring-up pass**: build on a real device; verify WebView cookie capture
      (Cloudflare), cached_network_image + cupertino_http, background chapter-chaining
      (next chapter enqueues during the background wake window), notification behavior.
- [ ] Verify download paths survive app updates (container UUID changes — plugin's
      `BaseDirectory.applicationDocuments` handles it; our DB stores only relative ids ✅,
      but `DownloadService._root` caching should be confirmed).
- [ ] `BGTaskScheduler`-based library auto-update (see §2).
- [ ] Signing/TestFlight lane (manual for now; fastlane later if needed).
- [ ] iPad: landscape/`NavigationRail` layout (PageLayoutBuilder desktop branch exists but
      is unused).

---

## 1. Parity matrix

### 1.1 Library — 🟡 strong core, options gap
| | Status |
|---|---|
| Display modes compact/comfortable grid, list; options sheet (Filter/Sort/Display); tri-state filters (downloaded/unread/completed); sort (alpha, unread, dateAdded) asc/desc; title search; categories + tabs; badges (unread+download); selection mode (mark read/unread, set categories, remove); reactive streams; downloaded-only integration | ✅ |
| `lastUpdate` sort | 🟡 **bug: column never written** — write `mangas.lastUpdate` in `LibraryUpdateService` when new chapters insert |
| Set-categories dialog | 🟡 doesn't pre-check current categories |
| Category reorder | 🟡 position column exists, no drag UI |
| Destructive confirmations (remove from library, delete category) | ❌ |
| Cover-only mode, adjustable grid columns, per-category sort/filter, more sort modes (latest chapter, fetch date, last read, random) | ❌ |
| More filters (started, bookmarked, tracked), badge toggles, category unread counts, default category | ❌ |
| Selection: download / delete-downloads / invert / change cover | ❌ |
| Scheduled auto-update (interval + restrictions) | ❌ — iOS: `BGTaskScheduler`; Android: WorkManager |

### 1.2 Updates & History — 🟡
| | Status |
|---|---|
| Updates feed (day headers, covers, download buttons, tap-to-read); manual refresh | ✅ |
| Feed ordering | 🟡 **bug: ordered by `dateUpload`** — newly-added manga's back-catalog floods feed; order by `dateFetch` and only show post-add fetches (Mihon) |
| Update progress/notification, per-manga error report | ❌ |
| Updates multi-select/swipe actions, mark-all-read, jump-to-manga | ❌ |
| History (day groups, resume, per-entry delete, clear all) | ✅ |
| History search, read-duration tracking, confirmations | ❌ |

### 1.3 Browse / Sources / Extensions — 🟡 biggest structural area
| | Status |
|---|---|
| Source seam (Mihon `source-api` mirror), MangaDex (en/ar), Madara engine + 11 sites, LocalSource, pin/language grouping, per-source URL override, catalogue (popular/latest/search/infinite scroll), global search fan-out, WebView Cloudflare cookie replay, extensions catalog (keiyoushi index, installed-first) | ✅ |
| **Themesia / TeamX / Zeist engines: built but NOT registered** (~14 sites dead code in `builtin_source_manager.dart`) | 🟡 register after on-device URL verification — cheapest catalogue win available |
| Source filters | 🟡 model + plumbing exist; every `getFilterList()` returns `[]`, no filter UI, no Group/Sort filter kinds |
| LocalSource archives | 🟡 loose image folders only; CBZ/ZIP promised in plan doc; natural-sort chapter ordering needed |
| Cloudflare | 🟡 manual WebView visit only; no auto 403-challenge detection |
| Extension runtime (install/update real sources at runtime) | ❌ deferred — JS/QuickJS plan in `SOURCE_SYSTEM_PLAN.md`; native Dart ports carry until then |
| Migration (source→source) | ❌ (source ids already keiyoushi-aligned to enable it) |
| NSFW toggle, custom repos, per-source login, saved searches, 'in library' badge on browse covers | ❌ |

### 1.4 Manga details — 🟡
| | Status |
|---|---|
| Header (cover backdrop, favorite, refresh), chapter list (canonical newest-first, sort toggle, per-chapter download button), Mihon download menu (next 1/5/10/25/unread/all in reading order), start-reading FAB (earliest unread), WebView action | ✅ |
| Chapter filters (read/downloaded/bookmarked), chapter selection mode, mark-previous-as-read, bookmark, swipe actions, share, cover edit/save, tracking button, "download custom amount" | ❌ |

### 1.5 Reader — 🟡 core solid after continuous-flow rework
| | Status |
|---|---|
| 4 modes (LTR/RTL/vertical/webtoon), tap zones (RTL-aware), pinch/double-tap zoom (paged), seekbar + RTL slider, page indicator, immersive mode, **continuous chapter flow with transition cards + preload (both modes)**, per-chapter progress/read-marking/history at boundaries, offline-first pages, resume position | ✅ |
| Backward continuity (prepend previous chapter when scrolling up) | 🟡 forward-only; prev button reloads |
| Webtoon zoom | ❌ (no InteractiveViewer in webtoon) |
| Page error retry / transition loading state | 🟡 broken-image icon only, silent preload retry |
| Per-manga reading mode; reader settings surface | ❌ (single global mode is the only reader pref) |
| Image filters (brightness/color), crop borders, rotation lock, keep-screen-on, scale types, webtoon side padding/gap, dual-page/split, tap-layouts (L/Kindle/edge), volume keys (n/a iOS), long-press share/save/set-cover, bookmark from reader, chapter list sheet in overlay, download-ahead | ❌ |

### 1.6 Downloads — ✅ Mihon-equivalent pipeline (post-rework)
| | Status |
|---|---|
| Serial queue in order (ch.1 first), native background per-page tasks, queue persistence + launch resume, kill reconciliation, pause/resume, drag-reorder, cancel-all, per-chapter/group notification, offline reading, `.done`-marker integrity | ✅ |
| Byte-level pause resume | 🟡 pause restarts the in-flight chapter (pages are small; acceptable) |
| Auto-download new chapters (per-category), download-ahead while reading, delete-after-read, Wi-Fi-only restriction, CBZ archiving, storage-usage screen | ❌ |

### 1.7 Settings / More / cross-cutting — ❌ thinnest area
| | Status |
|---|---|
| More tab (downloaded-only, incognito, queue/categories/settings links), theme mode, default reading mode, 5-tab shell, RTL-aware UI kit, DI/routing/drift foundation | ✅ |
| Settings surface | ❌ 3 entries total vs Mihon's 9 categories — needs Appearance / Library / Reader / Downloads / Browse / Data & storage / Security / Advanced screens as features land |
| About screen (version, licenses, update check) | ❌ (dead tile) |
| App language (ar!), locale picker | ❌ en-only — high value given the Arabic source catalog |
| Themes (AMOLED, palette choices) | ❌ single blue seed |
| Security (FaceID app lock, secure screen) | ❌ |
| Backup/restore (`.tachibk`-compatible protobuf) | ❌ deferred pillar |
| Tracking (AniList/MAL/…) | ❌ deferred pillar |
| Statistics, storage screens | ❌ |
| App update checker (GitHub releases) | ❌ |

---

## 2. Roadmap — ordered for iOS shipping

**Phase A — iOS bring-up + correctness (now)**
1. Device pass on iPhone: checklist in §0. Fix whatever breaks (WebView cookies, image
   pipeline, background chaining).
2. Fix inventory-found bugs: `lastUpdate` never written; updates feed → `dateFetch`;
   set-categories pre-population; destructive-action confirmations.
3. Register Themesia/TeamX/Zeist sources behind on-device verification (start with 2–3
   verified sites each; the engines are done).

**Phase B — Reader parity core (highest user-visible value)**
Per-manga reading mode (DB `viewerFlags` column already exists) · webtoon pinch-zoom ·
page tap-to-retry + transition loading/error states · keep-screen-on · bookmark action
(DB column exists) · chapter-list sheet in reader overlay · backward chapter prepend ·
image filters (brightness/color overlay) · crop borders · download-ahead.

**Phase C — Library/Updates parity**
Write-through `lastUpdate` + latest-chapter sorts · per-category sort/filter · selection
download/delete-downloads · adjustable grid columns + cover-only mode · update
progress + summary notification · updates swipe/multi-select actions · scheduled
auto-update (`BGTaskScheduler` iOS / WorkManager Android) with category include/exclude.

**Phase D — Downloads extras**
Auto-download new chapters (per-category) · delete-after-read · Wi-Fi-only · storage
usage screen. (CBZ archiving: skip unless needed — loose files serve the reader fine.)

**Phase E — Settings, appearance, localization**
Real settings tree (grow per phase above) · About screen w/ licenses + update check ·
Arabic app locale + locale picker · theme palettes + AMOLED · FaceID app lock ·
incognito already ✅.

**Phase F — Deferred pillars (unchanged)**
Extension runtime (QuickJS host executing keiyoushi-style JS sources) · backup/restore
(`.tachibk` protobuf compat so users can move from Mihon) · tracking services ·
source migration UI · statistics.

---

## 3. Bugs

### Fixed in the downloads/reader rework (found by adversarial review, 2026-07-11)
- ✅ **Download queue wiped on kill-while-downloading** (was critical): `_reconcile`'s
  emit triggered `onChange` → re-saved a partial queue **before** `_restoreQueue` read it,
  losing every chapter behind the in-flight one. Now the persisted queue is snapshotted
  before any emit.
- ✅ **Reader preload race** (was major): an in-flight next-chapter preload could append
  duplicate/wrong-chapter pages onto a freshly-navigated chapter and corrupt
  `_loadedThrough` (skip a chapter). Fixed with a load-generation token.
- ✅ **Webtoon read-mark miss** (was minor): a fast fling that skipped the exact last-page
  item left the finished chapter unread. Now back-filled on transition cards and forward
  boundary crossings.
- ✅ **`sourceOrder` collision on library update** (was major): `refreshAll` inserted new
  chapters with a bare index that collided with existing rows, breaking the "sourceOrder
  0 = newest, unique" invariant the ordering rework depends on. Now full re-sync.
- ✅ **`mangas.lastUpdate` never written** → lastUpdate sort now works (written in the same
  `refreshAll` fix).
- ✅ Download drain hardening: guaranteed `_ChapterJob.done` completion (try/finally, no
  deadlock), catch `Error` not just `Exception` in the drain, cancel tasks enqueued after
  a pause/cancel landed in the enqueue gap.

### Still open
1. Updates feed ordered by `dateUpload` → back-catalog floods on add (`updates_repository_impl.dart`).
2. Themesia/TeamX/Zeist sources unreachable (not in `builtin_source_manager.dart`).
3. Set-categories dialog ignores existing assignments (`library_selection_app_bar.dart`).
4. No confirmations on remove-from-library / delete-category / clear-history.
5. LocalSource lexicographic chapter order ("Chapter 10" < "Chapter 2").

## 4. Quality gate (unchanged)
`flutter pub get` → `build_runner build` → `flutter analyze` (zero issues) →
`flutter test` — plus, for iOS-phase work, a device smoke test of: add manga → download
3 chapters → airplane mode → read offline → background a long download → relaunch.
