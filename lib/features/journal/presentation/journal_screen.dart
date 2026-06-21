import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_spacing.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';
import 'widgets/week_bar_chart.dart';

/// Food & symptom journal (Phase 5).
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);
    final stats = ref.watch(journalWeekStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLogSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Log meal'),
      ),
      body: entries.isEmpty
          ? EmptyState(
              icon: Icons.book_outlined,
              title: 'Your journal is empty',
              message:
                  'Log meals and how they make you feel to spot patterns.',
              action: FilledButton(
                onPressed: () => _openLogSheet(context),
                child: const Text('Log a meal'),
              ),
            )
          : _JournalList(entries: entries, stats: stats),
    );
  }
}

void _openLogSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => const _LogMealSheet(),
  );
}

class _JournalList extends StatelessWidget {
  const _JournalList({required this.entries, required this.stats});

  final List<JournalEntry> entries;
  final JournalWeekStats stats;

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[_WeekStatsCard(stats: stats)];

    DateTime? currentDay;
    for (final entry in entries) {
      final day = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      if (day != currentDay) {
        currentDay = day;
        children.add(Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            _dayLabel(day),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ));
      }
      children.add(_EntryCard(entry: entry));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl * 2,
      ),
      children: children,
    );
  }
}

class _WeekStatsCard extends StatelessWidget {
  const _WeekStatsCard({required this.stats});

  final JournalWeekStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxMeals = stats.mealsPerDay.fold(0, math.max);
    final values = stats.mealsPerDay
        .map((m) => m / math.max(1, maxMeals))
        .toList(growable: false);
    final sortedSymptoms = stats.symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This week', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    value: '${stats.mealsLogged}',
                    label: 'Meals logged',
                  ),
                ),
                Expanded(
                  child: _StatTile(
                    value: '${stats.symptomDays}',
                    label: 'Symptom days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            WeekBarChart(values: values),
            if (sortedSymptoms.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final item in sortedSymptoms)
                    Chip(
                      label: Text('${item.key.label} ×${item.value}'),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EntryCard extends ConsumerWidget {
  const _EntryCard({required this.entry});

  final JournalEntry entry;

  IconData get _mealIcon => switch (entry.mealType) {
        MealType.breakfast => Icons.free_breakfast,
        MealType.lunch => Icons.lunch_dining,
        MealType.dinner => Icons.dinner_dining,
        MealType.snack => Icons.cookie,
      };

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This journal entry will be removed.'),
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
    final result = await ref.read(journalProvider.notifier).remove(entry.id);
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
    final symptoms =
        entry.symptoms.where((s) => s != DigestiveSymptom.none).toList();
    final subtitle = [
      DateFormat.jm().format(entry.timestamp),
      if (entry.notes.isNotEmpty) entry.notes,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () => _confirmDelete(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    child: Icon(_mealIcon, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.description,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (entry.hadSymptoms) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _SeverityDot(severity: entry.severity),
                  ],
                  PopupMenuButton<String>(
                    onSelected: (_) => _confirmDelete(context, ref),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              if (symptoms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final symptom in symptoms)
                        Chip(
                          label: Text(symptom.label),
                          labelStyle: theme.textTheme.labelSmall,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                        ),
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

class _SeverityDot extends StatelessWidget {
  const _SeverityDot({required this.severity});

  final int severity;

  @override
  Widget build(BuildContext context) {
    // Severity scale colors are intentional signal colors, not theme-driven.
    final (color, label) = switch (severity) {
      1 => (Colors.amber, 'Mild'),
      2 => (Colors.orange, 'Moderate'),
      _ => (Theme.of(context).colorScheme.error, 'Severe'),
    };
    return Tooltip(
      message: label,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Bottom sheet form to log a meal.
class _LogMealSheet extends ConsumerStatefulWidget {
  const _LogMealSheet();

  @override
  ConsumerState<_LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends ConsumerState<_LogMealSheet> {
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  MealType _mealType = MealType.breakfast;
  final Set<DigestiveSymptom> _symptoms = {};
  int _severity = 1;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _mealLabel(MealType type) =>
      type.name[0].toUpperCase() + type.name.substring(1);

  String get _severityLabel => switch (_severity) {
        0 => 'None',
        1 => 'Mild',
        2 => 'Moderate',
        _ => 'Severe',
      };

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(journalProvider.notifier).add(JournalEntry(
          id: '',
          timestamp: DateTime.now(),
          mealType: _mealType,
          description: _descriptionController.text.trim(),
          symptoms: _symptoms.toList(),
          severity: _symptoms.isEmpty ? 0 : _severity,
          notes: _notesController.text.trim(),
        ));
    if (!mounted) return;
    result.when(
      ok: (_) {
        navigator.pop();
        messenger.showSnackBar(const SnackBar(content: Text('Meal logged')));
      },
      err: (msg) => messenger.showSnackBar(SnackBar(content: Text(msg))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = _descriptionController.text.trim().isNotEmpty;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log a meal', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Logged for ${DateFormat.MMMEd().add_jm().format(DateTime.now())}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<MealType>(
              segments: [
                for (final type in MealType.values)
                  ButtonSegment(value: type, label: Text(_mealLabel(type))),
              ],
              selected: {_mealType},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _mealType = selection.first),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What did you eat?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('How did it feel?', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final symptom in DigestiveSymptom.values
                    .where((s) => s != DigestiveSymptom.none))
                  FilterChip(
                    label: Text(symptom.label),
                    selected: _symptoms.contains(symptom),
                    onSelected: (selected) => setState(() {
                      selected
                          ? _symptoms.add(symptom)
                          : _symptoms.remove(symptom);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _severity.toDouble(),
                    max: 3,
                    divisions: 3,
                    label: _severityLabel,
                    onChanged: _symptoms.isEmpty
                        ? null
                        : (value) =>
                            setState(() => _severity = value.round()),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    _symptoms.isEmpty ? '—' : _severityLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
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
