# Roadmap

Phased plan for NutriSalud after the 2.0 rebuild. Product rationale: [PRODUCT.md](PRODUCT.md). Effort: S (< 1 week), M (1–3 weeks), L (> 3 weeks). Value: product impact, High/Med.

## Now — shipped in 2.0

| Item | Notes |
| --- | --- |
| Feature-first Clean Architecture rebuild | Riverpod 2 (Notifier API), go_router 14, Material 3 |
| Meal discovery + recipe center | TheMealDB; name/ingredient search, categories, related meals |
| Favorites (local, offline) | Stored as meal summaries in SharedPreferences |
| Food & symptom journal + weekly stats | Local-first, 7-day chart, symptom counts |
| Nutrition goals, check-ins, streaks | Local-first, surfaced on Home |
| Digestive Health Center (Learn hub) | Curated articles + educational specialist profiles, replaces legacy "Doctors" |
| Community feed (legacy Flask backend) | Posts with photos, behind `CommunityRepository` |
| Auth + onboarding with route guards | JWT in secure storage, redirect logic in `appRouterProvider` |
| Light + dark M3 themes, brand refresh | Seeded from `#3E7C3A`; see [BRANDING.md](BRANDING.md) |
| Service abstractions | `NotificationService` (noop), `AnalyticsService` (debug), `RemoteConfigService` (in-memory) |
| Unit + widget smoke tests | `test/unit/*`, `test/widget_test.dart` |
| Static landing page | `landing/index.html` |

## Next — 0–3 months

| Item | Effort | Value | Notes |
| --- | --- | --- | --- |
| FCM push + `flutter_local_notifications` reminders | M | High | Interface and topic enum already exist — see [NOTIFICATIONS.md](NOTIFICATIONS.md) |
| Journal insights: food ↔ symptom correlations | M | High | Builds on `journalWeekStatsProvider`; the differentiating feature for the digestive niche |
| Recipe collections (user-defined lists) | S | Med | Extends the favorites pattern |
| Offline cache for Discover (drift or isar) | M | Med | Cache TheMealDB responses; first step toward full offline |
| iOS target + Info.plist permissions | M | High | Currently Android/web/Windows scaffolds only; photo-library/camera usage strings needed |
| Real backend v1 (auth hardening, refresh tokens) | L | High | Replace Render-hosted legacy Flask; repositories + `NUTRISALUD_API_BASE` make the swap contained |
| CI: GitHub Actions (analyze + test + build) | S | High | Gate PRs on `flutter analyze` and `flutter test` |

## Later — 3–12 months

| Item | Effort | Value | Notes |
| --- | --- | --- | --- |
| Verified specialist directory + booking | L | High | `ContentRepository` interface + `specialists_booking_enabled` flag already in place |
| Premium subscription (RevenueCat) | M | High | `premium_enabled` flag exists; pick premium surface from journal insights/collections |
| Barcode scanning via Open Food Facts | M | Med | Fast journal entry for packaged foods |
| USDA FoodData Central nutrition facts per recipe | M | Med | Macro/micro data TheMealDB lacks |
| Embedded video player for recipe videos | S | Med | Recipes already carry `youtubeUrl`; currently opens externally |
| Localization — Spanish first | M | High | Original 1.x app shipped Spanish strings; the audience is there |
| Accessibility audit | S | High | Verify against commitments in [BRANDING.md](BRANDING.md) |
| Social features v2 (reactions, comments, moderation) | L | Med | Requires real backend v1 first |
