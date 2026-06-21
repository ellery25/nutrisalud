# Production Readiness Checklist — NutriSalud 2.0

Status legend: ✅ done in 2.0 · 🔶 partial / action required · ⬜ not started

## App quality
- ✅ `flutter analyze` clean (lints v5)
- ✅ Test suite green (unit + widget smoke); release build compiles
- ✅ Material 3, light + dark mode, responsive layouts
- ✅ Empty/loading/error states on every async screen
- ✅ Medical disclaimer surfaced (welcome, learn, articles, profile)
- 🔶 Accessibility: contrast + touch targets by design; needs a TalkBack/VoiceOver pass
- ⬜ Localization (es/en) — original audience is Spanish-speaking; strings are EN-only today

## Identity & store
- 🔶 `applicationId` is still `com.example.nutrisalud` — **must change before Play upload** (e.g. `app.nutrisalud.android`)
- ⬜ Release signing config (keystore + `key.properties`, never committed)
- ⬜ Play listing: screenshots, feature graphic, privacy policy URL, data-safety form (declares journal data stays on device)
- ⬜ iOS target (no `ios/` folder yet) + `NSPhotoLibraryUsageDescription`
- ✅ Launcher icon + native splash (light/dark) configured

## Backend & data
- 🔶 Legacy Render backend: free tier sleeps (~30 s cold start) — upgrade plan or migrate (see SECURITY_REPORT server-side items)
- ⬜ Token refresh flow
- ⬜ Account deletion endpoint (store requirement)
- ✅ Backend URL injectable via `--dart-define` per environment

## Services
- 🔶 Notifications: abstraction + prefs shipped; FCM wiring pending (docs/NOTIFICATIONS.md)
- 🔶 Analytics: abstraction shipped; pick vendor + consent banner pending
- 🔶 Remote config / feature flags: in-memory defaults shipped; remote source pending
- ⬜ Crash reporting (Crashlytics/Sentry) — recommended before launch

## Engineering process
- ⬜ CI: GitHub Actions running analyze + test + build on PRs
- ⬜ Dependabot / `dart pub outdated` automation
- ⬜ LICENSE file + CONTRIBUTING.md
- ✅ Documentation set in `docs/`
- ✅ Landing page (`landing/`) ready to deploy to any static host

## Suggested launch order
1. Change applicationId + signing → internal testing track
2. Crashlytics + FCM
3. Backend hardening (or v1 replacement) + account deletion
4. Privacy policy + data-safety form → closed beta
5. Localization (es) → production rollout
