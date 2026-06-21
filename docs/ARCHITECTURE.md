# Architecture

NutriSalud 2.0 is a feature-first Clean Architecture Flutter app: each feature owns its `data` / `domain` / `presentation` slices, `core/` provides cross-cutting infrastructure, and Riverpod providers are the wiring between everything.

See also: [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) (how to work in this structure) · [NOTIFICATIONS.md](NOTIFICATIONS.md) (one concrete service swap).

## Layers

```
┌──────────────────────────────────────────────────────────────┐
│ PRESENTATION   screens, widgets, Notifier/FutureProviders    │
│                (lib/features/*/presentation, lib/shared)     │
└───────────────▲──────────────────────────────────────────────┘
                │ watches providers, renders AsyncValue/Result
┌───────────────┴──────────────────────────────────────────────┐
│ DOMAIN         pure models & enums, no Flutter/IO imports    │
│                (lib/features/*/domain: Meal, JournalEntry,   │
│                 NutritionGoal, AuthSession, CommunityPost…)  │
└───────────────▲──────────────────────────────────────────────┘
                │ produced/consumed by
┌───────────────┴──────────────────────────────────────────────┐
│ DATA           repositories & API clients                    │
│                (AuthRepository, CommunityRepository,         │
│                 MealDbApi, JournalNotifier, GoalsNotifier…)  │
└───────────────▲──────────────────────────────────────────────┘
                │ built on
┌───────────────┴──────────────────────────────────────────────┐
│ CORE           ApiClient, SecureStore, KeyValueStore,        │
│                Result, themes, routing, service abstractions │
└──────────────────────────────────────────────────────────────┘
```

**Dependency rule:** presentation → domain ← data. Presentation never touches `http`/`SharedPreferences` directly; data never imports widgets; `core/` has **zero** feature dependencies (verify: nothing under `lib/core/` imports from `lib/features/`). The one deliberate exception to layer purity: small screen-local providers live next to their screen (e.g. `_mealProvider` in `lib/features/recipes/presentation/recipe_details_screen.dart`).

## Folder responsibilities

| Path | Responsibility |
| --- | --- |
| `lib/core/constants/` | `AppConstants` (API bases, timeouts, debounce), `ApiEnvironment` (`--dart-define`), `StorageKeys`, `AppAssets` |
| `lib/core/network/` | `ApiClient` (JSON wrapper over `http`, timeout, bearer token, status mapping), `ApiException` |
| `lib/core/routing/` | `appRouterProvider`, `RoutePaths`, `AppShell` (NavigationBar over `StatefulNavigationShell`) |
| `lib/core/services/` | `NotificationService`, `AnalyticsService`, `RemoteConfigService` + default impls |
| `lib/core/storage/` | `KeyValueStore`/`SharedPreferencesStore`, `SecureStore`/`FlutterSecureStore` |
| `lib/core/themes/` | `AppTheme.light/.dark`, `AppColors`, `AppSpacing`, `AppRadius` |
| `lib/core/utils/` | `Result<T>` (`Ok`/`Err`), `Validators` |
| `lib/features/<f>/data` | Repositories, API clients, persisted Notifiers |
| `lib/features/<f>/domain` | Immutable models, enums, JSON (de)serialization |
| `lib/features/<f>/presentation` | Screens, feature widgets, screen-level providers |
| `lib/shared/widgets/` | `AsyncView`, `EmptyState`/`ErrorState`, `BrandLogo`, `RemoteImage`, `SectionHeader` |

## State management (Riverpod 2, no codegen)

Conventions, all visible in the code:

- **`NotifierProvider`** for mutable, persisted state: `sessionProvider` (`SessionNotifier`), `onboardingDoneProvider`, `themeModeProvider`, `notificationPrefsProvider`, `favoritesProvider`, `journalProvider`, `goalsProvider`, `checkInsProvider`. Each `build()` reads its initial value synchronously from `keyValueStoreProvider` (possible because `SharedPreferences` is awaited once in `main()` and injected via `ProviderScope` override).
- **`FutureProvider`** for async reads: `categoriesProvider`, `featuredMealsProvider`, `communityFeedProvider`. Refresh = `ref.invalidate(...)`.
- **`.autoDispose`** on request-scoped data so caches don't outlive the screen: `searchResultsProvider`, `categoryMealsProvider`, `communityFeedProvider`, `_mealProvider`/`_relatedProvider` in the recipe screen.
- **`.family`** for parameterized reads: `categoryMealsProvider(name)`, `goalProgressProvider(goalId)`, `isFavoriteProvider(mealId)`, `articleByIdProvider(id)`, `articlesByTopicProvider(topic)`.
- **`Provider`** for pure derivations and DI: `journalWeekStatsProvider`, `apiClientProvider`, `contentRepositoryProvider`, etc.
- **`StateProvider`** only for trivial UI state (`searchQueryProvider`, `searchModeProvider`).

**Why no codegen/freezed yet:** the model count is small, hand-written `toJson`/`fromJson` and `copyWith` are short, and avoiding `build_runner` keeps the edit-compile loop instant and onboarding simple. Adopt `riverpod_generator` + `freezed` when (a) models grow unions/deep copy needs, or (b) provider boilerplate starts breeding bugs — both can be introduced incrementally per feature.

## Routing (go_router 14)

Defined in `lib/core/routing/app_router.dart`; paths centralized in `RoutePaths` (`lib/core/routing/route_paths.dart`) with helpers `recipeFor(id)`, `articleFor(id)`, `specialistFor(id)`. The router is a provider that watches `sessionProvider` and `onboardingDoneProvider`, so redirects re-evaluate on state change.

| Condition | Redirect |
| --- | --- |
| `session == null` and not under `/welcome` | → `/welcome` |
| `session == null` and under `/welcome` (login/register) | stay |
| signed in, `!onboardingDone`, not on `/onboarding` | → `/onboarding` |
| signed in, `onboardingDone`, on `/welcome*` or `/onboarding` | → `/home` |
| otherwise | no redirect |

`StatefulShellRoute.indexedStack` hosts 5 branches (each keeps its own navigation stack): `/home` (+`goals`), `/discover` (+`favorites`), `/journal`, `/learn` (+`article/:id`, `specialist/:id`), `/community`. `/recipe/:id` and `/profile` sit outside the shell so they push over the tabs full-screen.

## Data flow example: Discover search

1. User types in `DiscoverScreen` (`lib/features/meals/presentation/discover_screen.dart`); a 400 ms `Timer` (`AppConstants.searchDebounce`) debounces input.
2. On fire, the screen writes `searchQueryProvider` (StateProvider).
3. `searchResultsProvider` (`FutureProvider.autoDispose` in `lib/features/meals/presentation/providers.dart`) watches query + `searchModeProvider` and calls `MealDbApi.search` or `filterByIngredient`.
4. `MealDbApi` (`lib/features/meals/data/mealdb_api.dart`) builds the TheMealDB URL and delegates to `ApiClient.getJson`.
5. `ApiClient` (`lib/core/network/api_client.dart`) applies the 20 s timeout, decodes JSON, throws `ApiException` on failure.
6. The screen renders `ref.watch(searchResultsProvider)` through `AsyncView`, which maps loading → spinner, error → `ErrorState` with retry (`ref.invalidate`), data → meal grid.

## Error handling

- The network layer throws exactly one type: `ApiException` (message + optional status code, `lib/core/network/api_exception.dart`).
- Repositories with user-initiated writes (auth, community) catch it and return `Result<T>` (`Ok`/`Err`, `lib/core/utils/result.dart`) with a user-readable message — presentation never catches raw exceptions. Screens surface `Err` via `SnackBar` (see `community_screen.dart`, `login_screen.dart`).
- Read paths exposed as `FutureProvider`s surface failures as `AsyncValue.error`, rendered uniformly by `AsyncView` (`lib/shared/widgets/async_view.dart`) with a retry button.

## Storage strategy

| Data | Where | Why |
| --- | --- | --- |
| JWT access token | `flutter_secure_storage` via `SecureStore` (`StorageKeys.accessToken`) | Sensitive; platform keystore/keychain |
| User id/username/display name, onboarding flag, theme mode, reminder toggles | `SharedPreferences` via `KeyValueStore` | Non-sensitive, needed synchronously at startup |
| Favorites, journal entries, goals, check-ins | `SharedPreferences` (JSON string lists, versioned keys like `journal_entries_v1`) | Local-first product data; small volumes |
| Search query/mode, selected category, feed cache | Riverpod state in memory | Ephemeral UI/session state |

All keys live in `lib/core/constants/storage_keys.dart` — never inline keys at call sites.

## Service abstractions

`NotificationService`, `AnalyticsService` and `RemoteConfigService` are `abstract interface class`es in `lib/core/services/`, each with a shipping default (`NoopNotificationService`, `DebugAnalyticsService`, `InMemoryRemoteConfig`) and a provider (`notificationServiceProvider`, `analyticsProvider`, `remoteConfigProvider`). To swap an implementation, override the provider — no feature code changes:

```dart
ProviderScope(overrides: [
  notificationServiceProvider.overrideWithValue(FcmNotificationService()),
], child: const NutriSaludApp())
```

Feature flags ship in `ConfigFlags` (`premium_enabled`, `community_enabled`, `specialists_booking_enabled`); `SpecialistScreen` already gates booking UI on `specialistsBookingEnabled`.

## Backend readiness

- **Auth & community** already go through repositories (`AuthRepository`, `CommunityRepository`) that build URLs from `ApiEnvironment.nutrisaludApiBase` (a `String.fromEnvironment('NUTRISALUD_API_BASE')`). Pointing at a new backend = pass the dart-define; changing the contract = edit only the repository, since screens consume `Result`/domain models.
- **Journal/goals/favorites** are local-first Notifiers that own their persistence (`_persist()` inside `JournalNotifier`, `GoalsNotifier`, `CheckInsNotifier`, `FavoritesNotifier`). To add sync: extract the read/write pairs into a repository with a remote + local source, keep the Notifier API identical, and reconcile on login (entries already carry ids and ISO-8601 timestamps, which is what a last-write-wins sync needs).
- **Learn hub** consumes the `ContentRepository` interface (`lib/features/educational_content/data/content_repository.dart`); replace `CuratedContentRepository` behind `contentRepositoryProvider` to serve articles/specialists from a CMS or verified directory.
