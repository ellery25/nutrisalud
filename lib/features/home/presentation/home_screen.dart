import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/remote_image.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/data/auth_repository.dart';
import '../../journal/data/journal_repository.dart';
import '../../meals/data/mealdb_api.dart';
import '../../meals/domain/meal.dart';
import '../../nutrition/data/goals_repository.dart';

/// Meal inspiration shown on the dashboard.
final _suggestionsProvider = FutureProvider<List<MealSummary>>((ref) async =>
    (await ref.watch(mealDbApiProvider).search(''))
        .map((m) => m.summary)
        .take(10)
        .toList());

const _tips = <String>[
  'Half your plate veggies: an easy rule that covers fiber and vitamins.',
  'Drink a glass of water before each meal to support digestion.',
  'Eat slowly — it takes about 20 minutes to feel full.',
  'Add a protein source to breakfast to stay satisfied longer.',
  'Frozen vegetables are just as nutritious as fresh — and never spoil.',
  'Color counts: aim for three different colors on your plate.',
  'Swap sugary drinks for sparkling water with a squeeze of citrus.',
  'Whole grains keep you fuller than refined ones — try a simple swap.',
  'A handful of nuts is a heart-healthy snack between meals.',
  'Plan tomorrow\'s lunch tonight to avoid last-minute fast food.',
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const _Header(),
            const SizedBox(height: AppSpacing.md),
            const _TipOfTheDayCard(),
            const SizedBox(height: AppSpacing.sm),
            const _GoalsCard(),
            const SizedBox(height: AppSpacing.sm),
            const _JournalPulseCard(),
            const SizedBox(height: AppSpacing.sm),
            SectionHeader(
              title: 'Meal inspiration',
              actionLabel: 'Discover',
              onAction: () => context.go(RoutePaths.discover),
            ),
            SizedBox(
              height: 200,
              child: AsyncView<List<MealSummary>>(
                value: ref.watch(_suggestionsProvider),
                onRetry: () => ref.invalidate(_suggestionsProvider),
                builder: (meals) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: meals.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, index) =>
                      _SuggestionCard(meal: meals[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionProvider);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              Text(
                session?.displayName ?? 'Guest',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: IconButton(
            icon: Icon(Icons.person,
                color: theme.colorScheme.onPrimaryContainer),
            tooltip: 'Profile',
            onPressed: () => context.push(RoutePaths.profile),
          ),
        ),
      ],
    );
  }
}

class _TipOfTheDayCard extends StatelessWidget {
  const _TipOfTheDayCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tip =
        _tips[DateTime.now().difference(DateTime(2026)).inDays % _tips.length];
    return Card(
      color: theme.colorScheme.secondaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline,
                color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tip of the day',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tip,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsCard extends ConsumerWidget {
  const _GoalsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goals = ref.watch(goalsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: "Today's goals",
              actionLabel: 'See all',
              onAction: () => context.push(RoutePaths.goals),
            ),
            if (goals.isEmpty) ...[
              Text(
                'Small habits add up. Pick one daily goal and start building '
                'your streak.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonal(
                onPressed: () => context.push(RoutePaths.goals),
                child: const Text('Set your first goal'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ] else
              for (final goal in goals.take(3)) _GoalRow(goalId: goal.id),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends ConsumerWidget {
  const _GoalRow({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(goalProgressProvider(goalId));
    final goal = progress.goal;
    final ratio =
        (progress.todayCount / goal.dailyTarget).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (progress.streakDays > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _StreakChip(days: progress.streakDays),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: LinearProgressIndicator(value: ratio, minHeight: 6),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${progress.todayCount}/${goal.dailyTarget}',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (progress.doneToday) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.check_circle,
                size: 18, color: theme.colorScheme.primary),
          ],
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department,
              size: 14, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(width: 2),
          Text(
            '$days',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
          ),
        ],
      ),
    );
  }
}

class _JournalPulseCard extends ConsumerWidget {
  const _JournalPulseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(journalWeekStatsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.menu_book_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '${stats.mealsLogged} meals logged · '
                '${stats.symptomDays} symptom days this week',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RoutePaths.journal),
              child: const Text('Open journal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.meal});

  final MealSummary meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(RoutePaths.recipeFor(meal.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: RemoteImage(
                  url: meal.thumbnailUrl,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meal.category != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        meal.category!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
