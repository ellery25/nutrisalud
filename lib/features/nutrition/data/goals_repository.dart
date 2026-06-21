import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/utils/result.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/nutrition_goal.dart';

final goalsProvider =
    NotifierProvider<GoalsNotifier, List<NutritionGoal>>(GoalsNotifier.new);

final checkInsProvider =
    NotifierProvider<CheckInsNotifier, List<GoalCheckIn>>(CheckInsNotifier.new);

class GoalsNotifier extends Notifier<List<NutritionGoal>> {
  KeyValueStore get _kv => ref.read(keyValueStoreProvider);
  ApiClient get _api => ref.read(apiClientProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);

  Uri _uri(String path) =>
      Uri.parse('${ApiEnvironment.nutrisaludApiBase}$path');

  @override
  List<NutritionGoal> build() {
    final raw = _kv.getStringList(StorageKeys.nutritionGoals) ?? const [];
    final goals = <NutritionGoal>[];
    for (final item in raw) {
      try {
        goals.add(
            NutritionGoal.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } on Object {
        // Skip corrupt entries.
      }
    }
    return goals;
  }

  /// POSTs to the backend, uses the server-assigned ID, then updates local state.
  Future<Result<void>> add(NutritionGoal goal) async {
    try {
      final token = await _auth.readToken();
      if (token == null) return const Err('You need to sign in.');
      final data = await _api.postJson(
        _uri('/goals'),
        goal.toServerJson(),
        token: token,
      ) as Map<String, dynamic>;
      final serverGoal = NutritionGoal.fromServerJson(data);
      state = [...state, serverGoal];
      await _persist();
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.message);
    }
  }

  /// DELETEs from the backend, cleans up local check-ins, then removes from local state.
  Future<Result<void>> remove(String id) async {
    try {
      final token = await _auth.readToken();
      if (token == null) return const Err('You need to sign in.');
      await _api.delete(_uri('/goals/$id'), token: token);
      state = state.where((g) => g.id != id).toList();
      await _persist();
      await ref.read(checkInsProvider.notifier).removeForGoal(id);
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.message);
    }
  }

  Future<void> _persist() => _kv.setStringList(
        StorageKeys.nutritionGoals,
        state.map((g) => jsonEncode(g.toJson())).toList(),
      );
}

class CheckInsNotifier extends Notifier<List<GoalCheckIn>> {
  KeyValueStore get _kv => ref.read(keyValueStoreProvider);
  ApiClient get _api => ref.read(apiClientProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);

  Uri _uri(String path) =>
      Uri.parse('${ApiEnvironment.nutrisaludApiBase}$path');

  @override
  List<GoalCheckIn> build() {
    final raw = _kv.getStringList(StorageKeys.goalCheckIns) ?? const [];
    final checkIns = <GoalCheckIn>[];
    for (final item in raw) {
      try {
        checkIns.add(
            GoalCheckIn.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } on Object {
        // Skip corrupt entries.
      }
    }
    return checkIns;
  }

  /// Updates local state optimistically, then syncs to the backend.
  /// The server's authoritative count corrects the local value on success.
  Future<void> increment(String goalId, {int delta = 1}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing =
        state.indexWhere((c) => c.goalId == goalId && _sameDay(c.day, today));

    final optimistic = existing >= 0
        ? (state[existing].count + delta).clamp(0, 999)
        : delta.clamp(0, 999);

    if (existing >= 0) {
      state = [...state]..[existing] =
          GoalCheckIn(goalId: goalId, day: today, count: optimistic);
    } else if (delta > 0) {
      state = [...state, GoalCheckIn(goalId: goalId, day: today, count: optimistic)];
    }
    await _persist();

    // Sync to server; correct local count with the authoritative value.
    try {
      final token = await _auth.readToken();
      if (token == null) return;
      final data = await _api.postJson(
        _uri('/goals/$goalId/check-in'),
        {'delta': delta},
        token: token,
      ) as Map<String, dynamic>;
      final serverCount = data['count'] as int?;
      if (serverCount != null) {
        final idx = state
            .indexWhere((c) => c.goalId == goalId && _sameDay(c.day, today));
        if (idx >= 0) {
          state = [...state]..[idx] =
              GoalCheckIn(goalId: goalId, day: today, count: serverCount);
          await _persist();
        }
      }
    } on ApiException {
      // Optimistic count stands until next successful sync.
    }
  }

  /// Removes all check-ins for [goalId] from local state (called on goal deletion).
  Future<void> removeForGoal(String goalId) async {
    state = state.where((c) => c.goalId != goalId).toList();
    await _persist();
  }

  Future<void> _persist() => _kv.setStringList(
        StorageKeys.goalCheckIns,
        state.map((c) => jsonEncode(c.toJson())).toList(),
      );

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Progress view-model for a goal.
class GoalProgress {
  const GoalProgress({
    required this.goal,
    required this.todayCount,
    required this.streakDays,
    required this.weekCompletion,
  });

  final NutritionGoal goal;
  final int todayCount;

  /// Consecutive days (ending today or yesterday) where the target was met.
  final int streakDays;

  /// 7 values, 0..1, oldest first — completion ratio per day.
  final List<double> weekCompletion;

  bool get doneToday => todayCount >= goal.dailyTarget;
}

final goalProgressProvider =
    Provider.family<GoalProgress, String>((ref, goalId) {
  final goal = ref.watch(goalsProvider).firstWhere((g) => g.id == goalId);
  final checkIns =
      ref.watch(checkInsProvider).where((c) => c.goalId == goalId).toList();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int countOn(DateTime day) => checkIns
      .where((c) => CheckInsNotifier._sameDay(c.day, day))
      .fold(0, (sum, c) => sum + c.count);

  final todayCount = countOn(today);

  var streak = 0;
  var cursor = todayCount >= goal.dailyTarget
      ? today
      : today.subtract(const Duration(days: 1));
  while (countOn(cursor) >= goal.dailyTarget) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  final week = List<double>.generate(7, (i) {
    final day = today.subtract(Duration(days: 6 - i));
    return (countOn(day) / goal.dailyTarget).clamp(0.0, 1.0);
  });

  return GoalProgress(
    goal: goal,
    todayCount: todayCount,
    streakDays: streak,
    weekCompletion: week,
  );
});
