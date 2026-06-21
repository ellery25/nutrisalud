/// Central route table. Paths are the single source of truth;
/// screens navigate with `context.go`/`context.push` + these constants.
abstract final class RoutePaths {
  // Auth / onboarding flow
  static const String welcome = '/welcome';
  static const String login = '/welcome/login';
  static const String register = '/welcome/register';
  static const String onboarding = '/onboarding';

  // Bottom-nav shell branches
  static const String home = '/home';
  static const String discover = '/discover';
  static const String journal = '/journal';
  static const String learn = '/learn';
  static const String community = '/community';

  // Detail / secondary routes
  static const String recipe = '/recipe/:id'; // recipeFor(id)
  static const String favorites = '/discover/favorites';
  static const String goals = '/home/goals';
  static const String profile = '/profile';
  static const String article = '/learn/article/:id'; // articleFor(id)
  static const String specialist = '/learn/specialist/:id';

  static String recipeFor(String id) => '/recipe/$id';
  static String articleFor(String id) => '/learn/article/$id';
  static String specialistFor(String id) => '/learn/specialist/$id';
}
