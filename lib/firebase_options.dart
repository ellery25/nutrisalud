// PLACEHOLDER — overwrite this file by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Until then the app silently falls back to NoopNotificationService and push
// notifications are disabled. Everything else continues to work normally.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
        'Run `flutterfire configure` to generate firebase_options.dart '
        'for your Firebase project, then rebuild the app.',
      );
}
