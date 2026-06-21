import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/educational_content/presentation/article_screen.dart';
import '../../features/educational_content/presentation/learn_screen.dart';
import '../../features/educational_content/presentation/specialist_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/meals/presentation/discover_screen.dart';
import '../../features/meals/presentation/favorites_screen.dart';
import '../../features/nutrition/presentation/goals_screen.dart';
import '../../features/onboarding/data/onboarding_state.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/recipes/presentation/recipe_details_screen.dart';
import 'app_shell.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-evaluate redirects when auth/onboarding state changes.
  final session = ref.watch(sessionProvider);
  final onboardingDone = ref.watch(onboardingDoneProvider);

  return GoRouter(
    initialLocation: RoutePaths.home,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final inAuthFlow = location.startsWith(RoutePaths.welcome);

      if (session == null) {
        return inAuthFlow ? null : RoutePaths.welcome;
      }
      if (!onboardingDone && location != RoutePaths.onboarding) {
        return RoutePaths.onboarding;
      }
      if (onboardingDone &&
          (inAuthFlow || location == RoutePaths.onboarding)) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.welcome,
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.recipe,
        builder: (context, state) =>
            RecipeDetailsScreen(mealId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'goals',
                  builder: (context, state) => const GoalsScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.discover,
              builder: (context, state) => const DiscoverScreen(),
              routes: [
                GoRoute(
                  path: 'favorites',
                  builder: (context, state) => const FavoritesScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.journal,
              builder: (context, state) => const JournalScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.learn,
              builder: (context, state) => const LearnScreen(),
              routes: [
                GoRoute(
                  path: 'article/:id',
                  builder: (context, state) =>
                      ArticleScreen(articleId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'specialist/:id',
                  builder: (context, state) => SpecialistScreen(
                      specialistId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.community,
              builder: (context, state) => const CommunityScreen(),
            ),
          ]),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
