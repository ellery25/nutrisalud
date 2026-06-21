/// Centralised storage keys. Never inline string keys at call sites.
abstract final class StorageKeys {
  // Secure storage (sensitive)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  // Key-value storage (non-sensitive)
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userDisplayName = 'user_display_name';
  static const String onboardingDone = 'onboarding_done';
  static const String themeMode = 'theme_mode';
  static const String mealRemindersEnabled = 'meal_reminders_enabled';
  static const String hydrationRemindersEnabled = 'hydration_reminders_enabled';
  static const String favoriteMealIds = 'favorite_meal_ids';
  static const String journalEntries = 'journal_entries_v1';
  static const String nutritionGoals = 'nutrition_goals_v1';
  static const String goalCheckIns = 'goal_check_ins_v1';
}
