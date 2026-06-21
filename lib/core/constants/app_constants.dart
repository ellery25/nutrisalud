/// Global, environment-independent application constants.
abstract final class AppConstants {
  static const String appName = 'NutriSalud';
  static const String appTagline = 'Your personal nutrition companion';

  /// NutriSalud backend — modern v1 API.
  static const String nutrisaludApiBase =
      'https://flask-jwt-flutter.onrender.com/api/v1';

  /// TheMealDB public API (free tier, key "1").
  static const String mealDbApiBase =
      'https://www.themealdb.com/api/json/v1/1';

  static const String projectRepoUrl =
      'https://github.com/ellery25/nutrisalud';

  static const Duration httpTimeout = Duration(seconds: 20);
  static const Duration searchDebounce = Duration(milliseconds: 400);
}

/// Placeholder for environment switching (dev/staging/prod).
/// Reads from --dart-define so secrets never live in source control.
abstract final class ApiEnvironment {
  static const String nutrisaludApiBase = String.fromEnvironment(
    'NUTRISALUD_API_BASE',
    defaultValue: AppConstants.nutrisaludApiBase,
  );
}
