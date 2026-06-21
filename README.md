# NutriSalud 2.0

Your personal nutrition companion — meal discovery, digestive health education, food journaling and nutrition goals in one Flutter app.

## What is NutriSalud

NutriSalud helps people eat better and understand their digestion, with a particular focus on those living with digestive discomfort (IBS, reflux, intolerances). It combines practical meal discovery with a food & symptom journal, habit-based nutrition goals, and a curated Digestive Health Center written in plain language. Everything personal — journal entries, goals, favorites — is stored locally first, so the core experience works without an account-heavy backend. Version 2.0 is a full rebuild: feature-first Clean Architecture, Riverpod 2, go_router 14 and Material 3.

## Features

- **Meal discovery** — search TheMealDB by name or ingredient, browse categories and featured meals (Discover tab)
- **Recipe center** — full recipes with ingredients, step-by-step instructions, related meals, YouTube/source links
- **Favorites** — meals saved locally, available offline
- **Food & symptom journal** — log meals with digestive symptoms and severity; weekly stats and bar chart
- **Nutrition goals & streaks** — daily habit targets (water, fruits & veg, home-cooked meals, custom) with check-ins, streaks and weekly completion
- **Digestive Health Center (Learn hub)** — curated, evidence-aligned articles and educational specialist profiles; replaces the legacy "Doctors" section
- **Community** — post text + photos to a shared feed (legacy Flask backend)
- **Auth & onboarding** — JWT login/register, intro carousel, route guards
- **Dark mode** — full Material 3 light/dark themes seeded from the brand green, persisted theme preference
- **Notification preferences** — meal/hydration reminder toggles wired to a pluggable `NotificationService` (FCM-ready)

## Screenshots

> Placeholder — add screenshots of Home, Discover, Recipe, Journal, Learn and Community here.

## Quick start

```bash
flutter pub get
flutter run
```

Point auth/community at a different backend without touching source:

```bash
flutter run --dart-define=NUTRISALUD_API_BASE=https://your-backend.example.com/api
```

> The default backend (Render free tier) cold-starts; the first request can take ~30 s. See [Troubleshooting](docs/DEVELOPER_GUIDE.md#troubleshooting).

## Architecture summary

```
lib/
├── main.dart                 # ProviderScope bootstrap, MaterialApp.router
├── core/                     # No feature dependencies
│   ├── constants/            # AppConstants, StorageKeys, AppAssets
│   ├── network/              # ApiClient (http wrapper), ApiException
│   ├── routing/              # appRouterProvider, RoutePaths, AppShell (5-tab NavigationBar)
│   ├── services/             # NotificationService, AnalyticsService, RemoteConfigService abstractions
│   ├── storage/              # KeyValueStore (SharedPreferences), SecureStore (keychain/keystore)
│   ├── themes/               # AppTheme (M3 light+dark), AppColors, AppSpacing/AppRadius
│   └── utils/                # Result<T>, Validators
├── features/                 # One folder per feature: data / domain / presentation
│   ├── auth/                 # Login, register, session (JWT in secure storage)
│   ├── community/            # Feed against legacy Flask API
│   ├── educational_content/  # Learn hub: articles + specialist profiles
│   ├── home/                 # Dashboard: greeting, suggestions, goals, journal summary
│   ├── journal/              # Food & symptom journal (local-first)
│   ├── meals/                # Discover, favorites, TheMealDB client
│   ├── nutrition/            # Goals, check-ins, streaks (local-first)
│   ├── onboarding/           # Intro carousel + completion flag
│   ├── profile/              # Settings, theme, notification toggles, logout
│   ├── recipes/              # Recipe details screen
│   └── settings/             # Theme mode + notification prefs controllers
└── shared/widgets/           # AsyncView, EmptyState/ErrorState, BrandLogo, RemoteImage, SectionHeader
```

Full details: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Tech stack

| Package | Purpose |
| --- | --- |
| `flutter_riverpod` ^2.6 | State management (Notifier API, no codegen) |
| `go_router` ^14.8 | Declarative routing, auth/onboarding redirects, `StatefulShellRoute` tabs |
| `http` ^1.3 | HTTP, wrapped by `ApiClient` |
| `flutter_secure_storage` ^9.2 | JWT in platform keystore/keychain |
| `shared_preferences` ^2.5 | Non-sensitive persistence behind `KeyValueStore` |
| `cached_network_image` ^3.4 | Recipe/category image caching |
| `flutter_svg` ^2.0 | Brand logo rendering |
| `image_picker` + `flutter_image_compress` | Community photo posts |
| `url_launcher` ^6.3 | External recipe/YouTube links |
| `intl` ^0.20 | Date parsing/formatting (legacy API timestamps) |
| `flutter_native_splash`, `flutter_launcher_icons` | Splash & launcher icon generation |

## Testing

```bash
flutter test
```

Unit tests (`test/unit/`: goal progress, journal stats, meal model, validators) plus a widget smoke test (`test/widget_test.dart`) that boots the app with a `FakeKeyValueStore` and asserts the signed-out redirect to Welcome.

## Documentation

| Doc | Contents |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Layers, dependency rule, state, routing, error handling, storage, backend readiness |
| [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) | Setup, run/test/build, conventions, deployment, troubleshooting |
| [docs/PRODUCT.md](docs/PRODUCT.md) | Vision, personas, feature flows, monetization readiness, KPIs |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Now / Next / Later with effort and value |
| [docs/BRANDING.md](docs/BRANDING.md) | Palette, typography, tokens, component and voice rules |
| [docs/NOTIFICATIONS.md](docs/NOTIFICATIONS.md) | Notification abstraction + FCM integration guide |
| [docs/AUDIT_REPORT.md](docs/AUDIT_REPORT.md) | Legacy codebase audit |
| [docs/MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md) | 1.x → 2.0 migration plan |
| [docs/SECURITY_REPORT.md](docs/SECURITY_REPORT.md) | Security review |
| [docs/PERFORMANCE_REPORT.md](docs/PERFORMANCE_REPORT.md) | Performance review |
| [docs/PRODUCTION_CHECKLIST.md](docs/PRODUCTION_CHECKLIST.md) | Pre-release checklist |

## Landing page

A static marketing page lives in [`landing/`](landing/) (`index.html`, no build step) — SEO/Open Graph metadata, brand palette, deployable to any static host.

## Medical disclaimer

NutriSalud provides educational content only. It is not a medical device and does not diagnose, treat or prevent any condition. Content in the Learn hub carries an explicit disclaimer; users with persistent symptoms are directed to qualified healthcare professionals.

## License

All rights reserved (no license file yet).
