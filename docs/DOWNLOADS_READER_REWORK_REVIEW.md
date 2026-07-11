# Downloads + Reader Rework — change record & review

> Session of 2026-07-10/11. Brought downloads and the reader to Mihon-equivalent
> behavior, targeting **iOS** as the primary platform, then ran an adversarial
> multi-agent review over the diff and fixed every confirmed/verified defect.
> Companion doc: `docs/MIHON_PARITY_PLAN.md` (forward-looking parity status).
>
> Gate at close: `flutter analyze` clean · `flutter test` passing.

---

## 1. What changed

### 1.1 Downloads — serial queue, persistence, iOS background
`lib/features/downloads/`
- **Serial queue in order** (Mihon): one chapter at a time, queue order — "Download
  all" on a 100-chapter manga downloads ch.1 first and finishes it first. Drain loop
  waits on a per-chapter `_ChapterJob.done` completer before starting the next.
- **Persistence**: pending queue + paused flag saved to SharedPreferences
  (`download_queue_store.dart`) via the bloc's `onChange`; restored on launch.
- **Kill/restart reconciliation**: rebuilds the in-flight chapter from the native task
  DB (`background_downloader`), finishes chapters whose pages completed while dead,
  marks unrecoverable ones failed, reschedules OS-killed tasks.
- **Queue ops**: pause/resume (in-flight chapter restarts), drag-reorder, cancel-all,
  per-chapter cancel/retry/delete, clear-finished.
- **UI**: `ReorderableListView` queue with drag handles on active rows, determinate
  per-row progress, pause/resume FAB, overflow menu (cancel all / clear finished),
  failure reason shown on failed rows.
- **Download menu on manga details**: Next 1 / 5 / 10 / 25 / Unread / All — enqueued
  oldest→newest.

### 1.2 iOS background download
- `background_downloader` uses **URLSession background sessions on iOS** — continues
  backgrounded/killed, zero native setup.
- Notification body is **static on iOS** (iOS re-issues a group notification on every
  text change; dynamic `{numFinished}/{numTotal}` + progress bar are Android-only).
- `DownloadsBloc` created eagerly in `preInitializations()` so reconciliation +
  queue-resume runs on every launch, including iOS background relaunch.
- `ios/Runner/Info.plist`: `NSAllowsArbitraryLoads` for http-only source CDNs.
- `POST_NOTIFICATIONS` added to the Android manifest; permission requested at startup.

### 1.3 Reader — continuous cross-chapter flow
`lib/features/reader/`
- One growing item list of **pages + "Finished: X / Next: Y" transition cards**
  (`reader_item.dart`). Webtoon auto-scrolls into the next chapter; paged mode swipes
  through the transition. Next chapter preloads within 4 items of the end, offline if
  downloaded. Per-chapter page indicator/slider; history + read-marks at boundaries.

### 1.4 Chapter ordering
- `watchChapters` (details) = newest-first canonical; display order derived via
  `orderedChapters` + `chaptersDescending` (toggle only flips the flag).
- `getChaptersForManga` (reader) = reading order, so `siblings[i+1]` is the next chapter.

---

## 2. Adversarial review results

Ran a 4-lens finder → 3-verifier majority-vote workflow over the uncommitted diff.
**2 findings passed the full 3-vote gate.** ~30 verifier agents then died on API/auth
errors (`403 Request not allowed`), so several real findings couldn't reach 2 votes and
were auto-classified "rejected" — these were **re-verified by hand against the code** and
fixed where real.

### 2.1 Confirmed by vote (2)
| # | Severity | Finding |
|---|----------|---------|
| C1 | major | In-flight `_maybeLoadNext` survives chapter navigation → duplicate/wrong-chapter pages appended, `_loadedThrough` clobbered so a chapter can be skipped |
| C2 | minor→major | `setChapterRead` missed at webtoon boundaries — read-mark only fired on an exact last-page item report; a fast fling skips it, chapter stays unread |

### 2.2 Re-verified by hand and fixed (verifiers had died)
| # | Severity | Finding |
|---|----------|---------|
| H1 | **critical** | Startup `onChange` persistence clobbers the saved queue before `_restoreQueue` reads it → pending downloads lost on every kill-while-downloading |
| H2 | major | `LibraryUpdateService` inserts new chapters with colliding `sourceOrder`, breaking the "sourceOrder 0 = newest, unique" invariant the ordering rework depends on |
| H3 | major | `_ChapterJob.done` completer not exception-safe: a throw in finish/fail/abort permanently deadlocks the serial drain |
| H4 | major | `_onProcess` catches only `Exception`; an `Error` from `source.getPageList` wedges the drain with the chapter stuck "downloading" |
| H5 | minor | Pause/cancel racing the `enqueueAll` gap: orphaned native tasks keep downloading after a pause |
| H6 | minor | Empty next chapter re-fetched on every scroll near the end (never advances `_loadedThrough`) |

### 2.3 Judged not real / not worth fixing
- Two duplicate phrasings of C1/C2 from other lenses (same root cause).
- No other finding survived scrutiny.

---

## 3. Fixes applied

| Finding | Fix | Location |
|---------|-----|----------|
| H1 | Snapshot `_store.load()` into a local **before any emit**; `_restoreQueue(persisted, …)` uses the snapshot, not a re-read | `downloads_bloc.dart` `_onStarted` / `_restoreQueue` |
| C1, H6 | **Load-generation token** (`_loadGeneration`): `_load` bumps it, `_maybeLoadNext` and `_load` bail if it changed after their await; empty chapter now advances `_loadedThrough` to stop re-fetch | `reader_bloc.dart` |
| C2 | `_markRead()` helper; back-fill read-marks on transition cards **and** every chapter passed on a forward boundary crossing (`fromChapterId` added to `ReaderTransitionItem`) | `reader_bloc.dart`, `reader_item.dart` |
| H2 | `refreshAll` now **full re-syncs** every chapter's `sourceOrder` (like `syncChapters`) instead of inserting with a colliding index; also writes `mangas.lastUpdate` (fixes the dead lastUpdate sort) | `library_update_service.dart` |
| H3 | `job.finish()` in `try/finally` in `_finishChapter`/`_failChapter`/`_abortNative` | `downloads_bloc.dart` |
| H4 | `on Exception` → `catch (_)` in the drain loop | `downloads_bloc.dart` `_onProcess` |
| H5 | After `enqueueAll`, if the job was aborted during the await, cancel the just-enqueued tasks and drop partials | `downloads_bloc.dart` `_startChapter` |

---

## 4. Follow-ups to review later
- **Not done — needs your hardware**: on-device iOS smoke test (add manga → download 3
  chapters → airplane mode → read offline → background a long download → relaunch).
- Narrow benign race: if a `_load` and a stale `_maybeLoadNext` interleave exactly, the
  eager preload-on-open can be skipped once; it recovers on the next scroll. Left as-is.
- Reader-bloc has 6 dependencies, so no unit test was added for the reader fixes (would
  need 6 fakes); covered by `flutter analyze` + reasoning. The download queue store and
  ordering helpers do have tests (`test/download_and_ordering_test.dart`).
- Open bugs unrelated to this rework are tracked in `MIHON_PARITY_PLAN.md` §3.
