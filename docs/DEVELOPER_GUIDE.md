# Developer Guide

How to build, run, test and extend NutriSalud 2.0. Architecture rationale lives in [ARCHITECTURE.md](ARCHITECTURE.md); product context in [PRODUCT.md](PRODUCT.md).

## Prerequisites

- Flutter ≥ 3.32 (the project requires Dart SDK ≥ 3.8, see `pubspec.yaml`)
- Android SDK (min SDK 21) for Android builds; Chrome for web
- No API keys required: TheMealDB uses the free public key and the legacy backend is public

## Setup

```bash
git clone https://github.com/ellery25/nutrisalud
cd nutrisalud
flutter pub get
```

## Run

```bash
flutter run                 # debug, default device
flutter run -d chrome       # web
```

There are no build flavors yet — environment switching is done with `--dart-define`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `NUTRISALUD_API_BASE` | `https://flask-jwt-flutter.onrender.com/api` | Auth/community backend base URL (read by `ApiEnvironment` in `lib/core/constants/app_constants.dart`) |

```bash
flutter run --dart-define=NUTRISALUD_API_BASE=https://staging.example.com/api
```

## Test, analyze, format

```bash
flutter test                          # all tests (test/unit + widget smoke test)
flutter test test/unit/goals_progress_test.dart   # single file
flutter analyze
dart format lib test
```

Test helpers: `test/helpers/fake_key_value_store.dart` provides an in-memory `KeyValueStore`; override `keyValueStoreProvider` with it in any test (see `test/widget_test.dart`).

## Build

```bash
flutter build apk --release
flutter build appbundle --release     # Play Store
flutter build web --release           # output in build/web
```

## Splash & launcher icon regeneration

Source images: `assets/imgs/splashNutrisalud.png` and `assets/imgs/launcherIcon.png`; config in `pubspec.yaml`.

```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

## Project conventions

- **Relative imports** within `lib/` (`import '../../../core/utils/result.dart';`), matching the existing code.
- **No `print`** — use `debugPrint` (already the pattern in services) or route through `AnalyticsService`.
- **No hardcoded colors or magic numbers** in widgets: colors come from `Theme.of(context).colorScheme` (brand constants only inside `lib/core/themes/app_colors.dart`); spacing/radii from `AppSpacing`/`AppRadius` (`lib/core/themes/app_spacing.dart`).
- **Storage keys** only via `StorageKeys` (`lib/core/constants/storage_keys.dart`); **routes** only via `RoutePaths`.
- **Errors**: network code throws `ApiException`; repositories with writes return `Result<T>`; screens render reads with `AsyncView` and show `Err` messages in a `SnackBar`.
- **New features** get their own folder:

```
lib/features/<feature>/
├── data/          # repository / API client / persisted Notifier
├── domain/        # models + enums, no Flutter imports
└── presentation/  # screens, widgets/, screen-local providers
```

## Adding a new screen + route

1. Create the screen under `lib/features/<feature>/presentation/`.
2. Add the path constant (and an id helper if parameterized) to `RoutePaths` in `lib/core/routing/route_paths.dart`.
3. Register a `GoRoute` in `lib/core/routing/app_router.dart` — as a sub-route of a `StatefulShellBranch` if it belongs inside a tab's stack, or top-level (like `/recipe/:id`) if it should cover the bottom bar.
4. Navigate with `context.push(RoutePaths.yourPath)` (push keeps back behavior) or `context.go` for redirects.
5. If the screen must be visible while signed out, account for the redirect rules in `appRouterProvider` (anything outside `/welcome*` redirects to `/welcome` when there is no session).

## Adding a new storage key

1. Add the constant to `StorageKeys`. Suffix versioned JSON payloads (`_v1`) so future migrations can detect old formats.
2. Sensitive value → extend `SecureStore` (`lib/core/storage/secure_store.dart`); non-sensitive → read/write through `keyValueStoreProvider`.
3. Persisted UI state should follow the existing `Notifier` pattern: read in `build()`, write in the mutation method (see `ThemeModeNotifier` in `lib/features/settings/data/settings_controller.dart`).

## Deployment notes

**Play Store (outline):**

1. Change the application id — it is still `com.example.nutrisalud` in `android/app/build.gradle` (Play rejects `com.example.*`). Update `namespace`/package references consistently.
2. Create an upload keystore and a `key.properties`; wire a release `signingConfig` in `android/app/build.gradle` (**TODO — currently unsigned/debug-signed**).
3. Bump `version:` in `pubspec.yaml` (build number must increase per upload; currently `2.0.0+2`).
4. `flutter build appbundle --release`, upload to Play Console, complete Data Safety + Health apps declarations (the app stores health-adjacent journal data locally).

**Web:** `flutter build web --release` and serve `build/web/` from any static host (Netlify/Vercel/Firebase Hosting). The static marketing page in `landing/` is separate and can be hosted at the root domain.

## Troubleshooting

- **First login/community load hangs ~30 s** — the legacy Flask backend runs on Render's free tier and cold-starts after idle. `ApiClient` times out at 20 s, so the very first request may fail with "The server took too long to respond."; retry once the dyno is warm. Mitigation options: a ping on app start, raising `AppConstants.httpTimeout`, or moving off the free tier.
- **Stale splash/icon** after changing brand assets — re-run the generation commands above and reinstall the app.
- **Provider "Override in ProviderScope" error in tests** — you forgot to override `keyValueStoreProvider`; use `FakeKeyValueStore`.
