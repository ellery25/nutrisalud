# NutriSalud 1.x → 2.0 Migration Plan (executed)

This documents the migration strategy and the old→new mapping. The legacy
implementation is preserved in git history (`git log` before the 2.0 commit).

## Strategy

Because 1.x had no separable layers (UI, HTTP and storage interleaved), an
in-place refactor would have cost more than a structured rewrite that ports
behavior feature by feature. The rewrite kept: the backend API contracts, the
TheMealDB integration, all product capabilities, and the brand's green
identity. Everything else was rebuilt on new rails.

## Phases

1. **Foundations** — new `pubspec` (see dependency table below), `core/`
   (network, storage, themes, routing, services), `shared/` widgets.
2. **Contracts** — domain models + repositories per feature (data layer first,
   so UI work could be parallelized safely).
3. **Features** — auth, onboarding, home, meals/recipes, journal, goals,
   learn (educational content), community, profile/settings.
4. **Verification** — `flutter analyze` clean, unit + widget tests green,
   release web build compiles.
5. **Docs & landing** — this docs set + `landing/index.html`.

## Old → new mapping

| Legacy (1.x) | 2.0 replacement |
|---|---|
| `Providers/users_providers.dart` (model+HTTP God object) | `features/auth/{domain/auth_session,data/auth_repository}.dart` |
| `Providers/meals_providers.dart` | `features/meals/{domain/meal,data/mealdb_api}.dart` |
| `Providers/comments_providers.dart` | `features/community/{domain/post,data/community_repository}.dart` |
| `Providers/nutritionists_providers.dart`, `Nutritionists.dart`, `NutriCard.dart` | `features/educational_content/` (Learn hub — curated profiles + articles) |
| `Providers/protips_provider.dart` | Tips merged into Home "Tip of the day" + Learn articles |
| `Providers/validate_jwt.dart` | Token validated lazily on first authenticated request (401 → re-auth) |
| `Preferences/save_load.dart` (raw SharedPreferences) | `core/storage/key_value_store.dart` (interface) + `secure_store.dart` (JWT in Keychain/Keystore) |
| `Helpers/colors_codes.dart` (3 const colors) | `core/themes/` — full M3 light+dark `ThemeData` |
| `Helpers/app_routes.dart` + `Navigator.pushNamed` | `core/routing/` — go_router, typed paths, auth/onboarding redirects, tab shell |
| `main.dart` FutureBuilder-around-MaterialApp | async init in `main()` + router redirect |
| `searching_delegate.dart` (no debounce, 40-param details) | `features/meals/presentation/discover_screen.dart` (debounced) + `features/recipes/.../recipe_details_screen.dart` (fetch by id) |
| `recipe_details.dart` (ingredient1..20) | `Meal.ingredients: List<MealIngredient>` parsed once in the model |
| GetStorage widget-serialization cache | Typed repositories persisting **data** (JSON) not widgets |
| `widget_test.dart` (broken counter test) | `test/unit/*` + `test/widget_test.dart` smoke test (11 tests) |
| Dual user/nutritionist registration | Single user account; professional accounts deferred to the verified directory (roadmap) |
| — (didn't exist) | Journal, Goals/streaks, Favorites, Settings (theme/notifications), Notification/Analytics/RemoteConfig services, landing page |

## Dependency migration

| Removed | Added | Upgraded |
|---|---|---|
| `get`, `get_storage` | `flutter_riverpod` | `http` 0.13 → 1.3 |
| `flip_card` | `go_router` | `flutter_svg` 1.0 → 2.0 |
| `page_view_dot_indicator` | `flutter_secure_storage` | `intl` 0.19 → 0.20 |
| `introduction_screen` | `cached_network_image` | `flutter_lints` 3 → 5 |
| `font_awesome_flutter` | | SDK floor 3.0 → 3.8 |

Deliberately **not** adopted yet (documented in
[ARCHITECTURE.md](ARCHITECTURE.md)): `freezed`/`json_serializable` (codegen
overhead not justified at current model count), `dio` (plain `http` suffices
behind `ApiClient`), `fl_chart` (custom 60-line bar chart instead).

## Data migration

1.x stored: `userId`, `access_token`, `type`, `username`, `isFirstTime` in
SharedPreferences plus GetStorage caches. 2.0 uses new keys
(`core/constants/storage_keys.dart`); old keys are simply orphaned — users
re-authenticate once after updating. Acceptable at the current install base;
a key-migration shim was considered and skipped deliberately.

## Rollback

`git revert` of the 2.0 commit restores 1.x wholesale; no destructive backend
or schema changes were made.
