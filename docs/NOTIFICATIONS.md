# Notifications

How notifications work today and how to wire up Firebase Cloud Messaging (FCM) when credentials are provisioned. Service-swap pattern: [ARCHITECTURE.md](ARCHITECTURE.md#service-abstractions).

## Current state

Everything lives behind an interface in `lib/core/services/notification_service.dart`:

- **`NotificationService`** — `initialize()`, `requestPermission()`, `subscribe(topic)`, `unsubscribe(topic)`.
- **`NotificationTopic` enum** — `mealReminder`, `hydrationReminder`, `habitReminder`, `educationalContent`, `weeklyReport`. Adding a category is a one-line enum change.
- **`NoopNotificationService`** — the shipping implementation; logs intent via `debugPrint` so flows stay testable without credentials.
- **`notificationServiceProvider`** — the swap point.

User preferences: `NotificationPrefsNotifier` (`lib/features/settings/data/settings_controller.dart`) persists the meal/hydration toggles to SharedPreferences (`StorageKeys.mealRemindersEnabled` / `hydrationRemindersEnabled`) and forwards each change to the service as `subscribe`/`unsubscribe` calls. The Profile screen exposes the switches. `initialize()` is already called once at startup in `main.dart`. No feature code knows which transport is behind the interface.

## FCM integration guide

1. **Create a Firebase project** at console.firebase.google.com; add an Android app with the final application id (change `com.example.nutrisalud` first — see [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md#deployment-notes)).
2. **Configure with FlutterFire:**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure        # generates lib/firebase_options.dart
   ```
3. **Add dependencies:** `flutter pub add firebase_core firebase_messaging`.
4. **Android config:** `flutterfire configure` places `google-services.json` under `android/app/` and wires the Google Services Gradle plugin — verify both.
5. **Implement `FcmNotificationService`** (suggested location: `lib/core/services/fcm_notification_service.dart`):
   ```dart
   class FcmNotificationService implements NotificationService {
     @override
     Future<void> initialize() async {
       await Firebase.initializeApp(
           options: DefaultFirebaseOptions.currentPlatform);
       FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
     }

     @override
     Future<bool> requestPermission() async {
       final settings = await FirebaseMessaging.instance.requestPermission();
       return settings.authorizationStatus == AuthorizationStatus.authorized;
     }

     @override
     Future<void> subscribe(NotificationTopic topic) =>
         FirebaseMessaging.instance.subscribeToTopic(topic.name);

     @override
     Future<void> unsubscribe(NotificationTopic topic) =>
         FirebaseMessaging.instance.unsubscribeFromTopic(topic.name);
   }
   ```
   Map FCM topics 1:1 to `NotificationTopic.name` (`mealReminder`, `hydrationReminder`, …) so server-side sends target `/topics/mealReminder` etc.
6. **Override the provider** in `main.dart` — the only app change needed:
   ```dart
   ProviderScope(
     overrides: [
       keyValueStoreProvider.overrideWithValue(SharedPreferencesStore(prefs)),
       notificationServiceProvider.overrideWithValue(FcmNotificationService()),
     ],
     child: const NutriSaludApp(),
   )
   ```
7. **Android 13+ runtime permission:** add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` to `AndroidManifest.xml` and call `requestPermission()` from a contextual moment (e.g. when the user first enables a reminder toggle in Profile), not cold start.
8. **Background handler caveats:** the `onBackgroundMessage` callback must be a **top-level or static function** annotated `@pragma('vm:entry-point')`; it runs in a separate isolate with no access to Riverpod state or plugins that require UI. Keep it minimal (data sync, local notification display).

## Local scheduled reminders (alternative/complement)

Meal & hydration reminders are time-based, so they don't strictly need a server: add `flutter_local_notifications` (+ `timezone`) and schedule with `zonedSchedule` when a toggle flips on, cancel on off — implemented as another `NotificationService` (or combined with FCM in one composite implementation). Tradeoff: precise firing on Android 12+ requires the `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` permission, which Play reviews strictly; inexact scheduling (default) is battery-friendly and usually fine for "around lunchtime" reminders. Start inexact.

## Recommended payload contract

Use data messages so taps can deep-link through the existing router (`RoutePaths`, `lib/core/routing/route_paths.dart`):

```json
{
  "topic": "educationalContent",
  "title": "New in the Digestive Health Center",
  "body": "A gentle introduction to the low-FODMAP approach",
  "deeplink": "/learn/article/art-2"
}
```

- `topic` — a `NotificationTopic.name`; lets the client route/filter and analytics segment.
- `deeplink` — a valid app path: `/journal`, `/home/goals`, `/learn/article/:id`, `/recipe/:id`… On tap, call `router.go(deeplink)`; the existing redirect logic safely bounces signed-out users to `/welcome`.

## Testing tips

- **FCM console** (Messaging → New campaign → send test message to a device token) for end-to-end checks; for topics, send from the console to the topic name and confirm the subscribe path.
- **Dry-run sends** via the HTTP v1 API with `"validate_only": true` to validate payloads without delivering.
- Verify all four states: foreground (you must display data messages yourself), background, terminated, and tap-to-deep-link.
- Until FCM lands, flip the Profile toggles and watch `[notifications] subscribe mealReminder (noop)` logs to confirm the preference→service wiring.
