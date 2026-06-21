# Performance Report — NutriSalud 2.0

## Bottlenecks found in 1.x → fixes shipped in 2.0

| Area | 1.x behavior | 2.0 behavior |
|---|---|---|
| Search | HTTP request per keystroke (`SearchDelegate` rebuilt futures) | 400 ms debounce (`AppConstants.searchDebounce`) + `autoDispose` providers cancel stale work |
| Network fan-out | N+1: one author lookup per tip/comment | Authors deduplicated (`Set` of ids) and fetched concurrently via `Future.wait` — feed with 30 posts by 5 authors: 31 requests → 6 |
| Images | `Image.network` everywhere — refetch on every rebuild | `cached_network_image` behind `RemoteImage` (memory+disk cache, placeholders, error fallback) |
| Startup | `FutureBuilder` wrapping `MaterialApp`; JWT validation network call blocking home render | Single `SharedPreferences.getInstance()` before `runApp`; session restored synchronously; no blocking network on startup |
| Caching | Widgets serialized to GetStorage and re-inflated | Plain data (JSON) persisted; widgets always built from state |
| Rebuilds | Whole-screen `setState` for every change | Riverpod granular `watch`; `select`-ready providers; const widgets throughout |
| Uploads | Full-resolution gallery images base64-encoded | Picker capped at 1280 px, recompressed to quality 70 ≤1024 px before encode |
| Bundle | Unused images/SVGs + double asset registration | 14 unused assets removed; registration deduplicated |

## Measurements (release web build, this machine)

- `flutter analyze`: clean, 1.4 s.
- `flutter test`: 11 tests, ~5 s wall clock.
- `flutter build web --release`: succeeds; main.dart.js ≈ 2.9 MB before gzip
  (typical for Flutter web with this feature set; fonts tree-shaken ~99%).

> Note: real startup/memory numbers must be measured on Android hardware with
> `flutter run --profile` + DevTools. Web build here serves as a compile/size
> smoke check; profile-mode benchmarking is a checklist item below.

## Practices enforced going forward

1. `RemoteImage` (cached) is the only sanctioned way to render network images.
2. List screens use `autoDispose` providers so abandoned searches release memory.
3. `ListView.builder`/slivers for unbounded lists (feed, search results).
4. No synchronous decoding of large payloads in `build()` — base64 decode
   happens once in the repository layer.
5. Animations are opt-in and short (≤300 ms), using implicit animated widgets.

## Benchmark TODO (profile mode, mid-tier Android device)

- [ ] Cold start to first frame (`flutter run --profile --trace-startup`) — target < 2 s
- [ ] Discover scroll jank (DevTools frame chart) — target 0 frames > 16 ms during steady scroll
- [ ] Memory after 5 min browse session — target < 250 MB
- [ ] APK size (`flutter build apk --analyze-size`) — target < 25 MB per-ABI
- [ ] Wire these into CI as regressions guards once a device farm/emulator job exists
