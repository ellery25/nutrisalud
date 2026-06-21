import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/state_views.dart';
import '../../journal/presentation/widgets/week_bar_chart.dart';
import '../data/goals_repository.dart';
import '../domain/nutrition_goal.dart';

/// Daily nutrition habit goals (Phase 5).
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewGoalSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: goals.isEmpty
          ? EmptyState(
              icon: Icons.flag_outlined,
              title: 'No goals yet',
              message: 'Daily habits compound. Start with one small goal.',
              action: FilledButton(
                onPressed: () => _openNewGoalSheet(context),
                child: const Text('Create a goal'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xxl * 2,
              ),
              children: [
                _WeeklyReportCard(goals: goals),
                const SizedBox(height: AppSpacing.md),
                for (final goal in goals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _GoalCard(goalId: goal.id),
                  ),
              ],
            ),
    );
  }
}

void _openNewGoalSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const _NewGoalSheet(),
  );
}

class _WeeklyReportCard extends ConsumerWidget {
  const _WeeklyReportCard({required this.goals});

  final List<NutritionGoal> goals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final values = <double>[
      for (final goal in goals)
        ...ref.watch(goalProgressProvider(goal.id)).weekCompletion,
    ];
    final average = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;
    final copy = average >= 0.7
        ? 'Great week!'
        : average >= 0.3
            ? 'Keep building'
            : 'Fresh start';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(
              '${(average * 100).round()}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(copy, style: theme.textTheme.titleMedium),
                  Text(
                    'Average completion across your goals this week',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goalId});

  final String goalId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete goal?'),
        content: const Text('The goal and its progress will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(goalsProvider.notifier).remove(goalId);
    if (context.mounted) {
      result.when(
        ok: (_) {},
        err: (msg) => messenger.showSnackBar(SnackBar(content: Text(msg))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(goalProgressProvider(goalId));
    final goal = progress.goal;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        goal.type.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress.streakDays > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _StreakBadge(days: progress.streakDays),
                ],
                PopupMenuButton<String>(
                  onSelected: (_) => _confirmDelete(context, ref),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${progress.todayCount} / '
                              '${goal.dailyTarget} ${goal.type.unit}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (progress.doneToday) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: (progress.todayCount / goal.dailyTarget)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    onPressed: progress.todayCount == 0
                        ? null
                        : () => ref
                            .read(checkInsProvider.notifier)
                            .increment(goal.id, delta: -1),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => ref
                        .read(checkInsProvider.notifier)
                        .increment(goal.id),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: WeekBarChart(values: progress.weekCompletion, height: 64),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${days}d',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet form to create a goal.
class _NewGoalSheet extends ConsumerStatefulWidget {
  const _NewGoalSheet();

  @override
  ConsumerState<_NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends ConsumerState<_NewGoalSheet> {
  GoalType _type = GoalType.water;
  late final TextEditingController _titleController =
      TextEditingController(text: _type.label);
  late int _target = _defaultTarget(_type);

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  static int _defaultTarget(GoalType type) =>
      type == GoalType.water ? 8 : 3;

  void _selectType(GoalType type) {
    setState(() {
      // Keep user edits; only refresh prefills that were untouched.
      final text = _titleController.text.trim();
      if (text.isEmpty || text == _type.label) {
        _titleController.text = type.label;
      }
      if (_target == _defaultTarget(_type)) {
        _target = _defaultTarget(type);
      }
      _type = type;
    });
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(goalsProvider.notifier).add(NutritionGoal(
          id: '',
          type: _type,
          title: _titleController.text.trim(),
          dailyTarget: _target,
          createdAt: DateTime.now(),
        ));
    if (!mounted) return;
    result.when(
      ok: (_) {
        navigator.pop();
        messenger.showSnackBar(const SnackBar(content: Text('Goal created')));
      },
      err: (msg) => messenger.showSnackBar(SnackBar(content: Text(msg))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _titleController.text.trim().isNotEmpty;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New goal', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final type in GoalType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: _type == type,
                    onSelected: (_) => _selectType(type),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Daily target (${_type.unit})',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _target <= 1
                      ? null
                      : () => setState(() => _target--),
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: AppSpacing.xl,
                  child: Text(
                    '$_target',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _target >= 20
                      ? null
                      : () => setState(() => _target++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSave ? _save : null,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
