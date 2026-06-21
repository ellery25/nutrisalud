import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisalud/core/storage/key_value_store.dart';
import 'package:nutrisalud/features/journal/data/journal_repository.dart';
import 'package:nutrisalud/features/journal/domain/journal_entry.dart';

import '../helpers/fake_key_value_store.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: [
      keyValueStoreProvider.overrideWithValue(FakeKeyValueStore()),
    ]);
    addTearDown(container.dispose);
  });

  test('week stats count meals, symptom days and per-day buckets', () async {
    final notifier = container.read(journalProvider.notifier);
    final now = DateTime.now();

    await notifier.add(JournalEntry(
      id: '1',
      timestamp: now,
      mealType: MealType.lunch,
      description: 'Lentil soup',
    ));
    await notifier.add(JournalEntry(
      id: '2',
      timestamp: now.subtract(const Duration(days: 1)),
      mealType: MealType.dinner,
      description: 'Pizza',
      symptoms: const [DigestiveSymptom.bloating],
      severity: 2,
    ));
    await notifier.add(JournalEntry(
      id: '3',
      timestamp: now.subtract(const Duration(days: 30)),
      mealType: MealType.breakfast,
      description: 'Old entry outside the window',
    ));

    final stats = container.read(journalWeekStatsProvider);
    expect(stats.mealsLogged, 2);
    expect(stats.symptomDays, 1);
    expect(stats.symptomCounts[DigestiveSymptom.bloating], 1);
    expect(stats.mealsPerDay.last, 1, reason: 'today bucket');
    expect(stats.mealsPerDay.reduce((a, b) => a + b), 2);
  });

  test('entries persist as JSON and reload sorted newest-first', () async {
    final store = FakeKeyValueStore();
    final first = ProviderContainer(overrides: [
      keyValueStoreProvider.overrideWithValue(store),
    ]);
    final notifier = first.read(journalProvider.notifier);
    await notifier.add(JournalEntry(
      id: 'a',
      timestamp: DateTime(2026, 6, 1, 8),
      mealType: MealType.breakfast,
      description: 'Oats',
    ));
    await notifier.add(JournalEntry(
      id: 'b',
      timestamp: DateTime(2026, 6, 2, 13),
      mealType: MealType.lunch,
      description: 'Rice bowl',
    ));
    first.dispose();

    final second = ProviderContainer(overrides: [
      keyValueStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(second.dispose);
    final reloaded = second.read(journalProvider);
    expect(reloaded.map((e) => e.id), ['b', 'a']);
  });
}
