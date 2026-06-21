# NutriSalud Flutter Integration Plan

**Version:** 1.0  
**Date:** 2026-06-14  
**Status:** Pending implementation  
**Companion document:** `COMPATIBILITY_REPORT.md`

---

## Executive Summary

NutriSalud 2.0 Flutter is a clean-architecture Riverpod app with 5 tabs (Home, Discover, Journal, Learn, Community). Today it calls 6 legacy endpoints at `/api/*`. The modern Flask backend at `/api/v1/*` exposes 35+ endpoints covering journal sync, nutrition goals, notifications, and nutritionist profiles — none of which the Flutter app uses yet.

This plan migrates the client to `/api/v1`, connects the currently local-only features (journal, goals) to the backend, and adds the infrastructure for notifications, subscriptions, and future modules without breaking any existing user flow.

---

## Part 1 — Current State Assessment

### What the Flutter app does today

| Feature | Data source | Backend dependency |
|---|---|---|
| Auth (login/register) | Flask legacy `/api/login`, `/api/users/register` | Yes |
| User display name | Flask legacy `GET /api/users/<id>` | Yes (best-effort) |
| Community feed | Flask legacy `GET/POST/DELETE /api/comments` | Yes |
| Meal discovery | TheMealDB public API | Third-party only |
| Recipe details | TheMealDB public API | Third-party only |
| Favorites | SharedPreferences (local) | None |
| Food/symptom journal | SharedPreferences (local) | None |
| Nutrition goals | SharedPreferences (local) | None |
| Learn hub | Hardcoded in `content_repository.dart` | None |
| Notifications | Stub (no FCM yet) | None |
| Theme/settings | SharedPreferences (local) | None |

### What the modern backend already supports (unused by Flutter)

- `/api/v1/journal/entries` + `/api/v1/journal/stats/weekly`
- `/api/v1/goals` + `/api/v1/goals/<id>/check-in`
- `/api/v1/notifications/devices` + `/api/v1/notifications/preferences`
- `/api/v1/nutritionists` (directory)
- `/api/v1/tips` (nutritionist content)
- `POST /api/v1/auth/refresh` + `POST /api/v1/auth/logout`

---

## Part 2 — Required Frontend Updates

### 2.1 `ApiClient` — no changes needed

The `ApiClient` is already a clean abstraction. The base URL and response parsing are the only things that change.

### 2.2 `AppConstants` — base URL update

```dart
// lib/core/constants/app_constants.dart
static const String nutrisaludApiBase =
    'https://flask-jwt-flutter.onrender.com/api/v1';  // was /api
```

This single change cascades to all repositories via `ApiEnvironment.nutrisaludApiBase`.

### 2.3 `ApiClient` — envelope unwrapping

The modern backend wraps every success response in `{"success": true, "data": ..., "message": "..."}`. Two options:

**Option A (recommended) — unwrap in ApiClient:**
Add an `unwrap` flag to `_send()` that extracts `response['data']` automatically. This keeps all repositories clean.

**Option B — unwrap in each repository:**
Each repository reads `envelope['data']` before processing. More verbose but more explicit.

Option A is preferred to avoid repeating the unwrap in every repository.

```dart
// Proposed change to api_client.dart
Future<dynamic> _send(String method, Uri uri, {
  String? token, Object? body, bool unwrap = true,
}) async {
  // ... existing timeout/error handling ...
  final decoded = jsonDecode(response.body);
  if (unwrap && decoded is Map<String, dynamic> && decoded.containsKey('data')) {
    return decoded['data'];
  }
  return decoded;
}
```

### 2.4 `SecureStore` — add refresh token storage

The modern backend issues refresh tokens. Flutter must store and use them.

```dart
// lib/core/storage/secure_store.dart — add:
Future<void> writeRefreshToken(String token) =>
    _store.write(key: StorageKeys.refreshToken, value: token);

Future<String?> readRefreshToken() =>
    _store.read(key: StorageKeys.refreshToken);

Future<void> clear() async {
  await _store.delete(key: StorageKeys.accessToken);
  await _store.delete(key: StorageKeys.refreshToken);  // add this
}
```

### 2.5 `StorageKeys` — add new keys

```dart
// lib/core/constants/storage_keys.dart — add:
static const String refreshToken = 'ns_refresh_token';
```

---

## Part 3 — New and Updated Repositories

### 3.1 `AuthRepository` — updated (breaking API changes)

**Changes required:**
1. Login path: `/login` → `/auth/login`
2. Login response: read from `data.access_token`, `data.user.id`, `data.user.name`
3. Store `refresh_token` in SecureStore
4. Register path: `/users/register` → `/auth/register`
5. Logout: call `DELETE /api/v1/auth/logout` with refresh token before clearing storage
6. Add `refresh()` method for token rotation

**Affected screens:** `LoginScreen`, `RegisterScreen`, `ProfileScreen` (logout)

```dart
Future<Result<AuthSession>> login({
  required String username,
  required String password,
}) async {
  try {
    // data is already unwrapped by ApiClient (Option A)
    final data = await _api.postJson(
      _uri('/auth/login'),
      {'username': username, 'password': password},
    ) as Map<String, dynamic>;

    final token = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    final userId = user?['id']?.toString();
    final name = user?['name'] as String? ?? username;

    if (token == null || userId == null) {
      return const Err('Unexpected response from server.');
    }

    await _secure.writeToken(token);
    if (refreshToken != null) await _secure.writeRefreshToken(refreshToken);
    await _kv.setString(StorageKeys.userId, userId);
    await _kv.setString(StorageKeys.userName, username);
    await _kv.setString(StorageKeys.userDisplayName, name);

    return Ok(AuthSession(userId: userId, username: username, displayName: name));
  } on ApiException catch (e) {
    return Err(e.statusCode == 401
        ? 'Incorrect username or password.'
        : e.message);
  }
}

Future<void> logout() async {
  // Server-side token revocation (best-effort)
  try {
    final refresh = await _secure.readRefreshToken();
    if (refresh != null) {
      await _api.postJson(_uri('/auth/logout'), {}, token: refresh);
    }
  } on ApiException {
    // Non-fatal; always clear local storage
  }
  await _secure.clear();
  await _kv.remove(StorageKeys.userId);
  await _kv.remove(StorageKeys.userName);
  await _kv.remove(StorageKeys.userDisplayName);
}

Future<bool> refresh() async {
  try {
    final refreshToken = await _secure.readRefreshToken();
    if (refreshToken == null) return false;
    final data = await _api.postJson(_uri('/auth/refresh'), {}, token: refreshToken)
        as Map<String, dynamic>;
    final newAccess = data['access_token'] as String?;
    final newRefresh = data['refresh_token'] as String?;
    if (newAccess == null) return false;
    await _secure.writeToken(newAccess);
    if (newRefresh != null) await _secure.writeRefreshToken(newRefresh);
    return true;
  } on ApiException {
    return false;
  }
}
```

### 3.2 `CommunityRepository` — updated (path + payload changes)

**Changes required:**
1. All paths: `/comments` → `/community/posts`, `/comments/<id>` → `/community/posts/<id>`
2. Fetch: handle paginated envelope; extract `data.items` instead of casting root as List
3. Author data now embedded — remove N+1 user lookup loop
4. Create post: remove `user_id` and `timestamp` from body (server derives from JWT)
5. Timestamp is now ISO 8601 — Flutter already has the fallback `DateTime.tryParse`

**Affected screens:** `CommunityScreen`

```dart
Future<Result<List<CommunityPost>>> fetchPosts({int page = 1}) async {
  final token = await _auth.readToken();
  if (token == null) return const Err('You need to sign in.');
  try {
    // ApiClient unwraps; data = {items: [...], meta: {...}}
    final data = await _api.getJson(
      _uri('/community/posts?page=$page'),
      token: token,
    ) as Map<String, dynamic>;

    final items = (data['items'] as List).cast<Map<String, dynamic>>();
    final posts = items.map((c) {
      final author = c['author'] as Map<String, dynamic>?;
      return CommunityPost(
        id: c['id'].toString(),
        content: c['content'] as String? ?? '',
        authorId: c['user_id'].toString(),
        authorName: author?['name'] as String? ?? 'Member',
        authorUsername: author?['username'] as String? ?? 'member',
        createdAt: DateTime.tryParse(c['timestamp'] as String? ?? ''),
        photoBytes: _decodePhoto(c['photo'] as String?),
      );
    }).toList();
    return Ok(posts);
  } on ApiException catch (e) {
    return Err(e.message);
  }
}

Future<Result<void>> createPost({
  required String content,
  Uint8List? photoBytes,
}) async {
  final token = await _auth.readToken();
  if (token == null) return const Err('You need to sign in.');
  try {
    await _api.postJson(
      _uri('/community/posts'),
      {
        'content': content,
        if (photoBytes != null) 'photo': base64Encode(photoBytes),
      },
      token: token,
    );
    return const Ok(null);
  } on ApiException catch (e) {
    return Err(e.message);
  }
}
```

### 3.3 `JournalRepository` — sync backend (new capability)

Currently 100% local (SharedPreferences). After this migration it should sync to `/api/v1/journal/entries`.

**Strategy:** Keep local-first, sync on background. Local state is the source of truth for display; background sync writes to server and pulls remote entries on login.

```dart
// lib/features/journal/data/journal_repository.dart — add to existing class:

Future<Result<void>> syncToServer(String token) async {
  try {
    final localEntries = _loadAll();
    // POST each unsynced entry
    for (final entry in localEntries.where((e) => !e.synced)) {
      await _api.postJson(
        _uri('/journal/entries'),
        {
          'meal_type': entry.mealType.name,
          'description': entry.mealLabel,
          'symptoms': entry.symptoms.map((s) => s.name).toList(),
          'severity': entry.severity,
          'notes': entry.notes ?? '',
          'logged_at': entry.loggedAt.toUtc().toIso8601String(),
        },
        token: token,
      );
    }
    return const Ok(null);
  } on ApiException catch (e) {
    return Err(e.message);
  }
}
```

**Affected screens:** `JournalScreen`

### 3.4 `GoalsRepository` — sync backend (new capability)

Same pattern as journal: local-first with background sync to `/api/v1/goals`.

### 3.5 `NotificationRepository` — new (device token registration)

```dart
// lib/features/settings/data/notification_repository.dart — new file:

class NotificationRepository {
  Future<void> registerDevice(String fcmToken, String accessToken) async {
    await _api.postJson(
      _uri('/notifications/devices'),
      {'token': fcmToken, 'platform': Platform.isIOS ? 'ios' : 'android'},
      token: accessToken,
    );
  }

  Future<void> syncPreferences(bool mealReminders, bool hydrationReminders,
      String accessToken) async {
    await _api.putJson(
      _uri('/notifications/preferences'),
      {
        'meal_reminders': mealReminders,
        'hydration_reminders': hydrationReminders,
      },
      token: accessToken,
    );
  }
}
```

**Affected screens:** `ProfileScreen` (notification toggles)

---

## Part 4 — New Models

### 4.1 `JournalEntry` — add `synced` flag

```dart
// lib/features/journal/domain/journal_entry.dart — add:
final bool synced;
final String? serverId;  // assigned by backend after sync
```

### 4.2 `NutritionGoal` — add `serverId`

```dart
// lib/features/nutrition/domain/nutrition_goal.dart — add:
final String? serverId;
final bool synced;
```

### 4.3 `UserProfile` — full profile model

```dart
// lib/features/profile/domain/user_profile.dart — new:
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    this.createdAt,
  });

  final String id;
  final String name;
  final String username;
  final String role;
  final DateTime? createdAt;
}
```

### 4.4 `DeviceToken` model

```dart
// lib/features/settings/domain/device_token.dart — new:
class DeviceToken {
  const DeviceToken({required this.token, required this.platform});
  final String token;
  final String platform;
}
```

---

## Part 5 — New Screens

### 5.1 Token Expiry Handler

Access tokens now expire in 30 minutes. The app needs to handle 401 responses by attempting a refresh before forcing re-login.

**Implementation:** Intercept 401 in `ApiClient`, call `AuthRepository.refresh()`, retry the request once. If refresh fails, clear session and redirect to Welcome.

```dart
// Proposed interceptor in ApiClient:
if (response.statusCode == 401 && token != null && onRefresh != null) {
  final refreshed = await onRefresh();
  if (refreshed) {
    // retry with new token
  }
}
```

Alternatively: a `TokenRefreshNotifier` that watches the session and proactively refreshes before expiry.

### 5.2 Nutritionist Directory Screen (new tab or Learn sub-screen)

The modern backend has a full nutritionists module (`GET /api/v1/nutritionists`). The legacy "Doctors" section was removed in 2.0 but the backend data exists.

**Recommended placement:** Add as a sub-section within the Learn hub (alongside the curated `SpecialistProfile` cards), replacing the hardcoded specialist data with real backend data.

### 5.3 Subscription / Plan Screen (future)

See Part 8 (Premium Architecture).

---

## Part 6 — State Management Recommendations

### 6.1 Existing approach — keep

Riverpod 2 Notifier API without codegen is clean and appropriate for this app size. No changes to the pattern.

### 6.2 Token refresh — add `AuthInterceptor` pattern

Instead of duplicating refresh logic across repositories, wire refresh into the `ApiClient`:

```dart
// lib/core/network/api_client.dart
class ApiClient {
  ApiClient(this._client, {this.onTokenExpired});

  final Future<String?> Function()? onTokenExpired;

  Future<dynamic> _send(String method, Uri uri, {String? token, Object? body}) async {
    // ... existing impl ...
    if (response.statusCode == 401 && onTokenExpired != null) {
      final newToken = await onTokenExpired!();
      if (newToken != null) {
        // retry once with new token
        return _send(method, uri, token: newToken, body: body);
      }
    }
    // ... throw ApiException ...
  }
}
```

### 6.3 Community pagination — add cursor/page state

The feed currently loads all posts in one request. The modern backend is paginated.

```dart
// lib/features/community/presentation/community_screen.dart
// Add a StateProvider<int> for current page and load-more trigger.
final communityPageProvider = StateProvider<int>((ref) => 1);
```

### 6.4 Offline-first sync queue (future)

For journal and goals, add a background sync queue using `WorkManager` (Android) / `BGTaskScheduler` (iOS) to batch-sync entries when the device is online.

---

## Part 7 — Notification Integration Strategy

### Phase 7.1 — Firebase Setup (prerequisite)
1. Create Firebase project (or use existing)
2. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Add `firebase_core` + `firebase_messaging` to `pubspec.yaml`

### Phase 7.2 — NotificationService Implementation

Replace the current stub with a real FCM implementation:

```dart
// lib/core/services/notification_service.dart — replace stub:
class FcmNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) _registerToken(token);

    // Listen for token refresh
    messaging.onTokenRefresh.listen(_registerToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  Future<void> _registerToken(String token) async {
    // POST to /api/v1/notifications/devices
  }
}
```

### Phase 7.3 — Backend-Driven Reminders

The backend's notification preferences (`meal_reminders`, `hydration_reminders`) should drive scheduled FCM pushes. This requires a backend job scheduler (Celery + Redis, or APScheduler) — not yet implemented in the Flask app.

**Recommended:** Add `celery` task in the Flask backend that:
1. Queries users with `meal_reminders = true`
2. Sends FCM notification at configured meal times
3. Logs delivery in `notifications` table

### Phase 7.4 — Weekly Report Push

Send a weekly summary of journal stats and goal completion via FCM.

---

## Part 8 — Premium / Subscription Architecture

### 8.1 Feature Flags (backend)

The `RemoteConfigService` stub is already wired. Plug in Firebase Remote Config:

```dart
class FirebaseRemoteConfigService implements RemoteConfigService {
  @override
  bool isEnabled(String feature) =>
      FirebaseRemoteConfig.instance.getBool(feature);
}
```

Gate premium features with:
```dart
final isEnabled = ref.watch(remoteConfigProvider).isEnabled('premium_goals');
```

### 8.2 User Plan Model

Add `plan` field to the backend `User` model:

```python
# app/modules/users/models.py — add:
plan = db.Column(db.String(20), nullable=False, default="free", server_default="free")
# values: "free", "premium", "pro"
```

Include in `profile_dict()` and surface in Flutter's `AuthSession`.

### 8.3 Subscription Screen

```dart
// lib/features/subscription/presentation/subscription_screen.dart — new:
// Shows plan comparison (Free / Premium / Pro)
// Integrates with in_app_purchase package
// On purchase success: calls PUT /api/v1/users/<id> with plan update
```

### 8.4 Feature Flag Enforcement (Flutter)

```dart
// lib/shared/widgets/premium_gate.dart — new:
class PremiumGate extends ConsumerWidget {
  const PremiumGate({required this.feature, required this.child, super.key});
  final String feature;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(remoteConfigProvider).isEnabled(feature);
    if (!enabled) return const UpgradePrompt();
    return child;
  }
}
```

---

## Part 9 — API Migration Plan

### Migration phases

```
Phase 1 (security patches, no client changes)       ← DO NOW
  └── Fix password exposure in User.serialize()
  └── Add @jwt_required to GET /api/comments
  └── Add rate limit to POST /api/login

Phase 2 (update Flutter base URL + auth paths)      ← Sprint 1
  └── AppConstants.nutrisaludApiBase → /api/v1
  └── ApiClient: add envelope unwrapping
  └── AuthRepository: new login/register/logout paths
  └── SecureStore: add refresh token storage
  └── CommunityRepository: new paths + payload changes
  └── Test: all 6 existing flows pass

Phase 3 (connect journal + goals to backend)        ← Sprint 2
  └── JournalRepository: background sync to /api/v1/journal/entries
  └── GoalsRepository: background sync to /api/v1/goals
  └── Add synced flag to domain models
  └── Weekly stats from server (replaces local computation)

Phase 4 (notifications + device registration)       ← Sprint 3
  └── Firebase FCM setup
  └── NotificationService implementation
  └── NotificationRepository (device token + prefs sync)
  └── Server-side reminder job scheduler

Phase 5 (nutritionists + tips)                      ← Sprint 4
  └── NutritionistRepository (GET /api/v1/nutritionists)
  └── Replace hardcoded specialists in content_repository.dart
  └── Tips feed in Learn hub (GET /api/v1/tips)

Phase 6 (premium + web + admin)                     ← Future
  └── Subscription screen + in_app_purchase
  └── User plan on backend
  └── Feature flag enforcement
  └── Admin dashboard (separate app)
  └── Flutter Web build
```

### Version coexistence table

| Client | Uses | Notes |
|---|---|---|
| Flutter app ≤ current release | `/api` (legacy) | Must keep working through Phase 2 rollout |
| Flutter app after Phase 2 | `/api/v1` | Default for all new installs |
| Future web app | `/api/v1` | |
| Admin dashboard | `/api/v1` | Requires `admin` role endpoints |
| Legacy routes | `/api` | Decommission after 90-day migration window |

---

## Part 10 — Estimated Migration Effort

| Phase | Work item | Effort |
|---|---|---|
| 1 | Security patches (backend) | 2 hours |
| 2 | ApiClient envelope unwrap | 1 hour |
| 2 | AuthRepository rewrite | 3 hours |
| 2 | CommunityRepository rewrite | 2 hours |
| 2 | SecureStore refresh token | 1 hour |
| 2 | End-to-end test pass | 2 hours |
| 3 | JournalRepository sync | 4 hours |
| 3 | GoalsRepository sync | 3 hours |
| 3 | Domain model sync flags | 1 hour |
| 4 | Firebase FCM setup | 2 hours |
| 4 | NotificationService impl | 3 hours |
| 4 | Backend reminder scheduler | 6 hours |
| 5 | NutritionistRepository | 2 hours |
| 5 | Replace hardcoded specialists | 2 hours |
| 6 | Premium architecture | 10+ hours |

**Phase 1+2 total: ~12 hours** — minimum to migrate away from the broken legacy API.

---

## Part 11 — Full Ecosystem Architecture (Future)

```
┌─────────────────────────────────────────────────────────┐
│                   NutriSalud Platform                   │
│                                                         │
│  Flutter Mobile ──────────────────────┐                 │
│  Flutter Web ─────────────────────────┤                 │
│  Admin Dashboard ─────────────────────┤                 │
│                                       ▼                 │
│                              Flask API /api/v1          │
│                              ┌─────────────────┐        │
│                              │  Auth / Users   │        │
│                              │  Community      │        │
│                              │  Journal        │        │
│                              │  Goals          │        │
│                              │  Nutritionists  │        │
│                              │  Tips           │        │
│                              │  Notifications  │        │
│                              │  Subscriptions  │        │
│                              └────────┬────────┘        │
│                                       │                 │
│                              PostgreSQL (Render)        │
│                              Redis (rate limit cache)   │
│                              Celery (scheduled jobs)    │
│                                                         │
│  Landing Page (static HTML) ──────────────────────────  │
│  Firebase (FCM + Remote Config + Analytics) ─────────── │
│  TheMealDB (public, third-party) ────────────────────── │
└─────────────────────────────────────────────────────────┘
```

---

## Appendix A — Files to Change (Phase 1+2)

| File | Change type |
|---|---|
| `lib/core/constants/app_constants.dart` | Change base URL to `/api/v1` |
| `lib/core/constants/storage_keys.dart` | Add `refreshToken` key |
| `lib/core/network/api_client.dart` | Add envelope unwrapping |
| `lib/core/storage/secure_store.dart` | Add refresh token read/write/clear |
| `lib/features/auth/data/auth_repository.dart` | New login/register/logout logic |
| `lib/features/community/data/community_repository.dart` | New paths, payload, response parsing |
| `Flask-JWT-Flutter/models/user.py` | Remove `password` from `serialize()` |
| `Flask-JWT-Flutter/routes/comment_routes.py` | Add `@jwt_required()` to GET |
| `Flask-JWT-Flutter/routes/auth_routes.py` | Add rate limiting |

## Appendix B — New Files to Create (Phase 3+)

| File | Purpose |
|---|---|
| `lib/features/settings/data/notification_repository.dart` | FCM token + prefs sync |
| `lib/features/profile/domain/user_profile.dart` | Full user profile model |
| `lib/shared/widgets/premium_gate.dart` | Feature flag gating widget |
| `lib/features/subscription/presentation/subscription_screen.dart` | Plan selection UI |
| `Flask-JWT-Flutter/app/modules/users/models.py` | Add `plan` field |
| `Flask-JWT-Flutter/app/tasks/reminders.py` | Celery reminder tasks |
