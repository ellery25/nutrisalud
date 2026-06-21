# NutriSalud — Backend Compatibility Report

**Generated:** 2026-06-14  
**Scope:** Legacy Flask API (`/api/*`) vs. Modern Flask API (`/api/v1/*`) vs. Flutter client  
**Verdict:** The Flutter app currently consumes the **legacy** API exclusively. The modern API (`/api/v1`) exists but is not yet consumed by Flutter. A migration is required before the legacy API can be decommissioned.

---

## 1. Architecture Reality Check

| Layer | Entry point | URL prefix | Status |
|---|---|---|---|
| Legacy backend | `app.py` | `/api` | **Active — Flutter uses this** |
| Modern backend | `wsgi.py` → `app/__init__.py` | `/api/v1` | Deployed but unused by Flutter |
| Flutter client | `AppConstants.nutrisaludApiBase` | `https://flask-jwt-flutter.onrender.com/api` | Hardcoded to legacy prefix |

The production server on Render (`flask-jwt-flutter.onrender.com`) is running `app.py` (legacy). Any attempt to switch Flutter to `/api/v1` without updating the client will result in 404s on every request.

---

## 2. Flutter API Endpoint Inventory

All network calls from the Flutter app, traced from `lib/features/*/data/*.dart`:

| # | HTTP | Flutter calls | File | Critical |
|---|---|---|---|---|
| 1 | POST | `/api/login` | `auth_repository.dart:68` | Yes |
| 2 | GET | `/api/users/<id>` | `auth_repository.dart:86` | Yes |
| 3 | POST | `/api/users/register` | `auth_repository.dart:113` | Yes |
| 4 | GET | `/api/comments` | `community_repository.dart:46` | Yes |
| 5 | POST | `/api/comments` | `community_repository.dart:96` | Yes |
| 6 | DELETE | `/api/comments/<id>` | `community_repository.dart:113` | Yes |

**Total active endpoints consumed by Flutter: 6**  
The app does NOT call any `/api/v1/*` route, nor any endpoint for journal, goals, nutritionists, tips, or notifications — those features are currently handled client-side (local-first).

---

## 3. Endpoint-by-Endpoint Compatibility Analysis

### 3.1  `POST /api/login`

**Legacy response (current)**
```json
{
  "access_token": "eyJ...",
  "type": "user",
  "user_id": "abc-123"
}
```

**Flutter reads** (`auth_repository.dart:73-74`)
```dart
final token = data['access_token'] as String?;
final userId = data['user_id']?.toString();
```

**Modern equivalent:** `POST /api/v1/auth/login`

**Modern response**
```json
{
  "success": true,
  "message": "Logged in",
  "data": {
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "user": { "id": "abc-123", "name": "Alice", "username": "alice", "role": "user" }
  }
}
```

**Breaking changes:**
- `access_token` moves from root → `data.access_token`
- `user_id` disappears → `data.user.id`
- `type` disappears → `data.user.role`
- New `refresh_token` field (Flutter doesn't use it yet but must store it for `/logout` and `/refresh`)
- Response is now wrapped in an envelope

**Severity:** CRITICAL — login breaks entirely without client changes.

---

### 3.2  `GET /api/users/<id>`

**Legacy response (current)**
```json
{
  "id": "abc-123",
  "name": "Alice",
  "username": "alice",
  "password": "plaintext_or_hash",
  "type": "user"
}
```

**Flutter reads** (`auth_repository.dart:88`)
```dart
if (user is Map<String, dynamic> && user['name'] is String) {
  displayName = user['name'] as String;
}
```

**Modern equivalent:** `GET /api/v1/users/<id>`

**Modern response**
```json
{
  "success": true,
  "message": "OK",
  "data": { "id": "abc-123", "name": "Alice", "username": "alice" }
}
```

**Breaking changes:**
- `name` moves from root → `data.name`
- `password` and `type` removed (security improvement)
- Envelope wrapper added

**Security note (legacy):** The legacy endpoint returns the `password` field (plaintext or hash) to every authenticated caller. This is a **critical security vulnerability** that must be fixed regardless of migration timing.

**Severity:** HIGH — display name falls back to username silently (non-fatal in Flutter), but the password leak is a critical security issue that requires immediate patching.

---

### 3.3  `POST /api/users/register`

**Legacy body (Flutter sends)**
```json
{ "name": "Alice", "username": "alice", "password": "secret123" }
```

**Legacy route:** `POST /api/users/register`  
**Modern equivalent:** `POST /api/v1/auth/register`

**Breaking changes:**
- Path changes completely: `/users/register` → `/auth/register`
- Modern validates password min 8 chars (legacy has no validation)
- Modern returns envelope; Flutter ignores the success body so this is non-breaking on the response side

**Flutter behavior on error:** Only checks `statusCode == 409 || statusCode == 400` to show "username already taken". This still works with the modern 409 response.

**Severity:** HIGH — path change breaks registration.

---

### 3.4  `GET /api/comments`

**Legacy response (current)**
```json
[
  {
    "id": "uuid",
    "content": "Hello community!",
    "photo": "base64string_or_empty",
    "timestamp": "Wed, 21 Feb 2024 18:01:55 GMT",
    "user_id": "user-uuid"
  }
]
```

**Flutter reads** (`community_repository.dart:46-75`)
```dart
final data = await _api.getJson(_uri('/comments'), token: token);
final comments = (data as List).cast<Map<String, dynamic>>();
// Then resolves each user_id separately via GET /api/users/<id>
```

**Modern equivalent:** `GET /api/v1/community/posts`

**Modern response**
```json
{
  "success": true,
  "message": "OK",
  "data": {
    "items": [
      {
        "id": "uuid",
        "content": "Hello community!",
        "photo": "base64string",
        "timestamp": "2024-02-21T18:01:55.000000",
        "user_id": "user-uuid",
        "author": { "id": "user-uuid", "name": "Alice", "username": "alice" }
      }
    ],
    "meta": { "page": 1, "per_page": 20, "total": 42, "pages": 3 }
  }
}
```

**Breaking changes:**
- Response changes from flat array to paginated envelope — `(data as List)` cast fails entirely
- Timestamp format changes from `"Wed, 21 Feb 2024 18:01:55 GMT"` → ISO 8601 (Flutter handles both via fallback, so non-breaking)
- `author` object is now embedded (eliminates N+1 user lookup calls — improvement)
- Pagination added (Flutter currently loads all posts — N+1 issue)

**Severity:** CRITICAL — the `(data as List)` cast throws immediately, breaking the entire community feed.

---

### 3.5  `POST /api/comments`

**Legacy body (Flutter sends)** (`community_repository.dart:97-103`)
```json
{
  "content": "Hello!",
  "photo": "base64string_or_empty_string",
  "timestamp": "2024-02-21T18:01:55.000000Z",
  "user_id": "user-uuid"
}
```

**Modern equivalent:** `POST /api/v1/community/posts`

**Modern body expected:**
```json
{ "content": "Hello!", "photo": "base64string" }
```

**Breaking changes:**
- `user_id` is now **rejected** (modern derives it from JWT) — Marshmallow schema uses `unknown=RAISE` so extra fields will cause 422 errors
- `timestamp` is also now rejected for the same reason
- `photo` should be omitted rather than sent as an empty string (the schema validates length, empty string passes, but is cleaner omitted)

**Security improvement:** Modern backend prevents user_id spoofing — Flutter could previously post on behalf of another user by injecting a different `user_id`.

**Severity:** CRITICAL — the 422 error on unknown fields (`user_id`, `timestamp`) breaks post creation.

---

### 3.6  `DELETE /api/comments/<id>`

**Legacy route:** `DELETE /api/comments/<id>`  
**Modern equivalent:** `DELETE /api/v1/community/posts/<id>`

**Breaking changes:**
- Path changes: `/comments/<id>` → `/community/posts/<id>`
- Modern response is wrapped: `{"success": true, "message": "Post deleted", "data": null}` (Flutter ignores body on delete — non-breaking)

**Severity:** HIGH — path change breaks delete.

---

## 4. Response Structure Comparison Matrix

| Field | Legacy (flat) | Modern (envelope) | Flutter handles |
|---|---|---|---|
| `access_token` | Root | `data.access_token` | Root only |
| `user_id` | Root | `data.user.id` | Root only |
| `name` (user) | Root | `data.name` | Root only |
| Community posts | Flat array | `data.items` array | Flat array only |
| Error message | `error` or `message` key | `message` key | Both (`error` or `message`) |
| HTTP status on error | 400/401/404 | 400/401/404/422 | 401 → "wrong password" |

---

## 5. Security Issues in the Legacy Backend

These exist **right now** in production and must be addressed regardless of migration:

| Severity | Issue | Location |
|---|---|---|
| CRITICAL | `User.serialize()` returns the `password` field to all callers | `models/user.py:16` |
| CRITICAL | Passwords stored as plaintext (no hashing) | `models/user.py`, `routes/auth_routes.py:22-27` |
| HIGH | `Comment.__init__` accepts `**data` (mass-assignment) | `routes/comment_routes.py:36` |
| HIGH | `GET /api/comments` has no JWT protection (public) | `routes/comment_routes.py:12` |
| HIGH | CORS set to `*` for all origins, all methods | `db/db.py:8` |
| MEDIUM | No rate limiting on login endpoint | `routes/auth_routes.py` |
| MEDIUM | No input validation on any legacy route | `routes/*.py` |
| LOW | Tokens never expire (legacy JWT config) | `config.py` |

---

## 6. Feature Gap: Modern Backend vs. Flutter

The modern `/api/v1` backend has modules that the Flutter app doesn't use yet:

| Module | Endpoints | Flutter feature | Status |
|---|---|---|---|
| `journal` | CRUD entries + weekly stats | Journal (local-first) | Not connected |
| `goals` | CRUD goals + check-ins | Goals (local-first) | Not connected |
| `notifications` | Device tokens + preferences | Notification prefs (local) | Not connected |
| `nutritionists` | CRUD profiles | Legacy "Doctors" removed | Not connected |
| `tips` | CRUD tips (nutritionist role) | Removed in 2.0 | Not connected |
| `auth/refresh` | Refresh token rotation | Not implemented | Missing in Flutter |
| `auth/logout` | Token revocation | Clears storage only | No server-side revocation |

---

## 7. Breaking Change Risk Summary

| Change | Risk | Blocking Migration | Flutter Impact |
|---|---|---|---|
| Login response structure | CRITICAL | YES | App cannot log in |
| Register endpoint path | HIGH | YES | Registration broken |
| User profile response structure | HIGH | SILENT | Display name falls back to username |
| Community posts endpoint path | CRITICAL | YES | Feed empty |
| Community posts response structure | CRITICAL | YES | Cast exception crashes feed |
| Create post body schema | CRITICAL | YES | 422 on every post |
| Delete post path | HIGH | YES | Delete fails |
| JWT token expiry (legacy = never) | MEDIUM | NO | Access tokens now expire in 30 min — users get logged out |
| Refresh token required for logout | MEDIUM | NO | Logout only clears storage today; server-side revocation is new |

---

## 8. Migration Strategy

### Phase 1 — Immediate Security Patches (Legacy, no client changes)
1. Remove `password` from `User.serialize()` → return `{id, name, username, type}`
2. Hash all plaintext passwords on next login (already in modern backend — backport or enable modern backend)
3. Add `@jwt_required()` to `GET /api/comments`
4. Add rate limiting to `POST /api/login`

### Phase 2 — Backward-Compatible Bridge (no client changes required)
Teach the modern `/api/v1` endpoints to also accept requests in the legacy format, OR add thin legacy-shape aliases at `/api/*` that proxy to modern controllers. Recommended: **keep legacy routes serving the current Flutter app** while building the v1 client migration.

### Phase 3 — Flutter Client Migration
Update Flutter to call `/api/v1/*`. Per-endpoint changes documented in Section 9.

### Phase 4 — Legacy Decommission
Once 100% of active Flutter clients (tracked via analytics) are on the new API, shut down legacy routes.

---

## 9. Required Flutter Code Changes per Endpoint

### Auth — login (`auth_repository.dart`)
```dart
// BEFORE (legacy)
final token = data['access_token'] as String?;
final userId = data['user_id']?.toString();

// AFTER (modern /api/v1/auth/login)
final payload = data['data'] as Map<String, dynamic>;
final token = payload['access_token'] as String?;
final refreshToken = payload['refresh_token'] as String?;
final userId = (payload['user'] as Map<String, dynamic>?)?['id']?.toString();
// also store refreshToken in SecureStore for logout/refresh calls
```

### Auth — register (`auth_repository.dart`)
```dart
// BEFORE (legacy path)
await _api.postJson(_uri('/users/register'), {...});

// AFTER (modern path)
await _api.postJson(_uri('/auth/register'), {...});
```

### User profile (`auth_repository.dart`)
```dart
// BEFORE (legacy)
final user = await _api.getJson(_uri('/users/$userId'), token: token);
if (user is Map<String, dynamic> && user['name'] is String) {
  displayName = user['name'] as String;
}

// AFTER (modern envelope)
final envelope = await _api.getJson(_uri('/users/$userId'), token: token);
final user = envelope['data'] as Map<String, dynamic>?;
if (user != null && user['name'] is String) {
  displayName = user['name'] as String;
}
```

### Community — fetch posts (`community_repository.dart`)
```dart
// BEFORE (legacy flat array)
final data = await _api.getJson(_uri('/comments'), token: token);
final comments = (data as List).cast<Map<String, dynamic>>();
// + N parallel user lookups

// AFTER (modern paginated envelope, author embedded)
final envelope = await _api.getJson(_uri('/community/posts'), token: token);
final comments = ((envelope['data']['items']) as List).cast<Map<String, dynamic>>();
// Author is now in c['author'] — no separate user lookups needed
```

### Community — create post (`community_repository.dart`)
```dart
// BEFORE (legacy: sends user_id and timestamp)
await _api.postJson(
  _uri('/comments'),
  {
    'content': content,
    'photo': photoBytes == null ? '' : base64Encode(photoBytes),
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'user_id': userId,  // ← rejected by modern with 422
  },
  token: token,
);

// AFTER (modern: server derives user_id and timestamp from JWT)
await _api.postJson(
  _uri('/community/posts'),
  {
    'content': content,
    if (photoBytes != null) 'photo': base64Encode(photoBytes),
  },
  token: token,
);
```

### Community — delete post (`community_repository.dart`)
```dart
// BEFORE
await _api.delete(_uri('/comments/$postId'), token: token);

// AFTER
await _api.delete(_uri('/community/posts/$postId'), token: token);
```

---

## 10. Validation Checklist (after migration)

- [ ] Login with valid credentials returns session + token
- [ ] Login with invalid credentials returns 401 with "Incorrect username or password"
- [ ] Register with new username succeeds
- [ ] Register with duplicate username returns 409
- [ ] Display name shows full name (not username) after login
- [ ] Community feed loads with posts
- [ ] Post author names are shown correctly
- [ ] Creating a post succeeds and appears in feed
- [ ] Deleting own post removes it from feed
- [ ] After 30 minutes, access token expires and app prompts re-login (new behavior)
- [ ] Logout clears local session
- [ ] All existing features (Journal, Goals, Discover, Learn) continue working (no backend dependency)
