import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisalud/core/storage/key_value_store.dart';
import 'package:nutrisalud/features/nutrition/data/goals_repository.dart';
import 'package:nutrisalud/features/nutrition/domain/nutrition_goal.dart';

import '../helpers/fake_key_value_store.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: [
      keyValueStoreProvider.overrideWithValue(FakeKeyValueStore()),
    ]);
    addTearDown(container.dispose);
  });

  test('check-ins accumulate, clamp at zero and complete a goal', () async {
    await container.read(goalsProvider.notifier).add(NutritionGoal(
          id: 'g1',
          type: GoalType.water,
          title: 'Drink water',
          dailyTarget: 2,
          createdAt: DateTime.now(),
        ));

    final checkIns = container.read(checkInsProvider.notifier);
    await checkIns.increment('g1');
    var progress = container.read(goalProgressProvider('g1'));
    expect(progress.todayCount, 1);
    expect(progress.doneToday, isFalse);

    await checkIns.increment('g1');
    progress = container.read(goalProgressProvider('g1'));
    expect(progress.todayCount, 2);
    expect(progress.doneToday, isTrue);
    expect(progress.streakDays, 1);
    expect(progress.weekCompletion.last, 1.0);

    // Decrement never goes below zero.
    await checkIns.increment('g1', delta: -5);
    progress = container.read(goalProgressProvider('g1'));
    expect(progress.todayCount, 0);
  });
}
