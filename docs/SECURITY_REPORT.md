# Security Report — NutriSalud 2.0

## Findings in 1.x and their resolution

| # | Finding (1.x) | Risk | Resolution (2.0) |
|---|---|---|---|
| 1 | JWT stored in plain `SharedPreferences` | Token theft via backup extraction / rooted device | Token moved to `flutter_secure_storage` (Android Keystore / iOS Keychain) — `core/storage/secure_store.dart`; only non-sensitive profile fields remain in SharedPreferences |
| 2 | `password` field on `User`/`Nutritionist` models, hydrated from API responses | Credential exposure in memory/logs; implies backend returns password material | Field removed from all client models. **Backend action still required** — see "Server-side follow-ups" |
| 3 | Logout overwrote keys with `""` instead of deleting | Stale token lingering | `AuthRepository.logout()` deletes the secure token and removes session keys |
| 4 | 40+ `print()` incl. tokens & full response bodies → logcat | Info disclosure on shared devices | No `print()` in 2.0 (`flutter analyze` enforces via lints); only `debugPrint` in debug-only service stubs |
| 5 | Form validators declared but never executed (no `Form.validate()`) | Garbage-in to API; weak passwords | `Form` + `GlobalKey` wired on every form; `Validators.username/password` enforce charset & ≥8 chars on registration |
| 6 | Hardcoded backend URL in ~20 call sites | No way to rotate endpoints | Single `ApiEnvironment.nutrisaludApiBase`, overridable via `--dart-define=NUTRISALUD_API_BASE=...` (no secrets in source) |
| 7 | No HTTP timeouts | Hung requests, resource exhaustion | `ApiClient` enforces a 20 s timeout and typed error mapping |
| 8 | Unbounded base64 photo uploads | Memory abuse / oversized payloads | Picker capped at 1280 px + recompressed (quality 70, ≤1024 px) before upload |
| 9 | `READ_EXTERNAL_STORAGE` requested on all API levels | Over-permissioning | Scoped with `maxSdkVersion="32"`; modern photo picker needs no permission |

## Current posture

- **API keys**: none in the repo. TheMealDB free tier uses the public key `1`
  embedded in the URL (public by design). Backend URL is config, not secret.
- **Transport**: all endpoints HTTPS; cleartext traffic is not enabled.
- **Local data**: journal/goals/favorites are non-sensitive by classification
  today, stored unencrypted in SharedPreferences. If journal data is ever
  classified as health data for compliance (GDPR/HIPAA-adjacent), move it to
  an encrypted store (e.g. `drift` + SQLCipher) — tracked in ROADMAP.
- **Auth readiness**: JWT validated lazily (401 → `ApiException.isUnauthorized`);
  no refresh-token flow exists on the legacy backend.

## Server-side follow-ups (out of app scope, blocking for production)

1. Stop returning password material from any endpoint; hash with bcrypt/argon2.
2. Add token expiry + refresh; current tokens appear long-lived.
3. Rate-limit `/login` and `/users/register`.
4. The community endpoint accepts arbitrary `user_id` on post creation —
   derive the author from the JWT server-side (client-supplied identity is
   spoofable).
5. Add CORS + payload-size limits for the base64 photo field.

## Checklist for release

- [x] Secrets out of source control
- [x] Secure token storage
- [x] Input validation
- [x] No sensitive logging
- [x] HTTPS-only
- [ ] Backend hardening items above
- [ ] Dependency audit automation (`dart pub outdated` in CI; Dependabot)
- [ ] Privacy policy & data-deletion flow before store submission
