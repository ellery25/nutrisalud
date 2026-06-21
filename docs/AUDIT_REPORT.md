# NutriSalud 1.x — Full Project Audit

Audit of the codebase as of commit `50b4271` (before the 2.0 migration).
Scope: all 30 Dart files (~5,300 LOC), `pubspec.yaml`, platform folders, assets, tests.

## 1. Architecture

**Pattern found: none.** The folder names suggested MVC-ish intent
(`Screens/`, `Widgets/`, `Providers/`, `Helpers/`, `Preferences/`) but:

- `Providers/` did not contain state providers — each file was a **model class
  with static HTTP methods glued on** (`User`, `Nutritionist`, `Comment`,
  `ProTip`, `Meal`). Networking, serialization and domain were one God object.
- Screens performed session handling, HTTP orchestration, caching, date
  parsing and UI in the same `State` classes (`main_page.dart`: 522 lines).
- **Widgets were used as data**: `ProfessionalTipsBlock` had `toJson`/`fromJson`
  and serialized *widget instances* into `GetStorage` as a caching strategy.
- Two widgets (`SetPageNutricionist`, `CheckingProfile`) wrapped themselves in a
  **nested `MaterialApp`**, breaking theming, navigation stack and back behavior.
- No dependency inversion anywhere; swapping the backend required editing
  every static method (base URL hardcoded in ~20 call sites).

## 2. Concrete defects found

| Severity | Location | Issue |
|---|---|---|
| High | `recipe_details.dart` | **40 constructor parameters** (`ingredient1..20`, `measure1..20`) + 20 copy-pasted render blocks |
| High | `searching_delegate.dart` | Network request fired **on every keystroke**, no debounce, duplicated ~150-line `RecipeDetails(...)` call in both `buildResults` and `buildSuggestions` |
| High | `main_page.dart`, `Community.dart` | **N+1 requests**: one `GET /users/:id` or `/nutritionists/:id` per tip/comment |
| High | `test/widget_test.dart` | Default counter test referencing a counter that never existed — test suite failed |
| High | `README.md` | Unresolved git merge conflict markers committed to `main` |
| Med | `Nutritionists.dart:53` | `nutricionista.website!` — crash on null website |
| Med | `Community.dart:157` | `formattedDate!` — crash when date parsing failed |
| Med | `main.dart` | `FutureBuilder` *around* `MaterialApp` — whole app tree rebuilt to decide initial route; loading spinner rendered with no `Directionality` |
| Med | `Login/Register` | Form fields had `validator:` but no `Form`/`_formKey.validate()` call — validators never executed |
| Med | `community_post.dart` | `get` (GetX) imported solely for one `Get.snackbar` without GetMaterialApp (no-op/risk) |
| Low | everywhere | 40+ `print()` calls in production paths, incl. full API response bodies |
| Low | `meals_providers.dart` | `print(response.body)` of entire payload on every fetch |

## 3. Dead code & unused assets

- `CheckingProfile` widget: unreachable from any route.
- Routes declared but never registered/used: `search`, `postCommunity`,
  `postProTip`, `recipeDetails`.
- Unused assets shipped in the bundle: `dr_1..4.jpg`, `post_1.jpg`,
  `post_2.jpg`, `gmail.svg`, `meta.svg`, `twitter.svg`, `github.svg`,
  `edit.svg` (and `bulb/comment/bx-image.svg` only marginally used).
- `pubspec.yaml` registered the whole `assets/` root **and** subfolders
  (duplicate registration).

## 4. Dependency audit (1.x)

| Package | State | Verdict |
|---|---|---|
| `http ^0.13.5` | 2+ majors behind (1.x current) | **Upgrade** |
| `flutter_svg ^1.0.3` | 2 majors behind, deprecated API (`color:`) | **Upgrade** |
| `get ^4.6.6` | Used for exactly one snackbar | **Remove** |
| `get_storage ^2.1.1` | Used to cache serialized widgets | **Remove** (replaced by typed repositories over SharedPreferences) |
| `flip_card`, `page_view_dot_indicator`, `introduction_screen`, `font_awesome_flutter` | Single-use UI candy, replaceable with ~30 lines each | **Remove** |
| `shared_preferences` | Fine | Keep (behind interface) |
| `intl ^0.19` | OK | Upgrade to 0.20 |
| `flutter_lints ^3` | Behind | Upgrade to 5 |
| Missing | — | No router, no state management, no secure storage, no image caching |

## 5. Security findings

See [SECURITY_REPORT.md](SECURITY_REPORT.md) for full detail. Headlines:

1. **JWT stored in plain SharedPreferences** (readable on rooted devices/backups).
2. **Password field on the `User`/`Nutritionist` models**, populated from API
   responses — passwords round-tripped to the client.
3. "Logout" wrote empty strings over keys instead of deleting them.
4. No input validation actually enforced (validators never wired).
5. Tokens and full API responses printed to logcat.

## 6. Performance findings

See [PERFORMANCE_REPORT.md](PERFORMANCE_REPORT.md). Headlines: N+1 request
patterns, no image caching (`Image.network` everywhere), no search debounce,
serialized-widget cache, base64 photos decoded on the UI thread on every build,
whole-app `setState` patterns.

## 7. Scalability limitations

- Dual account model (user vs. nutritionist) hardcoded as string compares
  (`isNutricionist == "true"`) threaded through UI.
- The "Doctors" section depended on self-registered, unverified nutritionist
  accounts — a liability for a health product (resolved in 2.0 by the Learn
  hub; see [PRODUCT.md](PRODUCT.md)).
- No abstraction for notifications, analytics, config, or premium gating.
- Free-tier Render backend sleeps; every cold start blocked the home screen
  JWT validation with no offline path.

## 8. What was done about it

Every item above was addressed in the 2.0 migration —
see [MIGRATION_PLAN.md](MIGRATION_PLAN.md) for the old→new mapping.
