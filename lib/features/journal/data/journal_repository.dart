import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/utils/result.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/journal_entry.dart';

final journalProvider =
    NotifierProvider<JournalNotifier, List<JournalEntry>>(JournalNotifier.new);

class JournalNotifier extends Notifier<List<JournalEntry>> {
  KeyValueStore get _kv => ref.read(keyValueStoreProvider);
  ApiClient get _api => ref.read(apiClientProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);

  Uri _uri(String path) =>
      Uri.parse('${ApiEnvironment.nutrisaludApiBase}$path');

  @override
  List<JournalEntry> build() {
    final raw = _kv.getStringList(StorageKeys.journalEntries) ?? const [];
    final entries = <JournalEntry>[];
    for (final item in raw) {
      try {
        entries.add(
            JournalEntry.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } on Object {
        // Skip corrupt entries.
      }
    }
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// POSTs to the backend, uses the server-assigned ID, then updates local state.
  Future<Result<void>> add(JournalEntry entry) async {
    try {
      final token = await _auth.readToken();
      if (token == null) return const Err('You need to sign in.');
      final data = await _api.postJson(
        _uri('/journal/entries'),
        entry.toServerJson(),
        token: token,
      ) as Map<String, dynamic>;
      final serverEntry = JournalEntry.fromServerJson(data);
      state = [serverEntry, ...state];
      await _persist();
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.message);
    }
  }

  /// DELETEs from the backend, then removes from local state.
  Future<Result<void>> remove(String id) async {
    try {
      final token = await _auth.readToken();
      if (token == null) return const Err('You need to sign in.');
      await _api.delete(_uri('/journal/entries/$id'), token: token);
      state = state.where((e) => e.id != id).toList();
      await _persist();
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.message);
    }
  }

  Future<void> _persist() => _kv.setStringList(
        StorageKeys.journalEntries,
        state.map((e) => jsonEncode(e.toJson())).toList(),
      );
}

/// Simple weekly analytics derived from the local journal state.
class JournalWeekStats {
  const JournalWeekStats({
    required this.mealsLogged,
    required this.symptomDays,
    required this.symptomCounts,
    required this.mealsPerDay,
  });

  final int mealsLogged;
  final int symptomDays;

  /// Symptom -> occurrences in the last 7 days.
  final Map<DigestiveSymptom, int> symptomCounts;

  /// Index 0 = six days ago ... index 6 = today.
  final List<int> mealsPerDay;
}

final journalWeekStatsProvider = Provider<JournalWeekStats>((ref) {
  final entries = ref.watch(journalProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekAgo = today.subtract(const Duration(days: 6));

  final lastWeek = entries.where((e) => !e.timestamp.isBefore(weekAgo));
  final symptomCounts = <DigestiveSymptom, int>{};
  final symptomDays = <DateTime>{};
  final mealsPerDay = List<int>.filled(7, 0);

  for (final entry in lastWeek) {
    final day = DateTime(
        entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
    final index = day.difference(weekAgo).inDays;
    if (index >= 0 && index < 7) mealsPerDay[index]++;
    if (entry.hadSymptoms) {
      symptomDays.add(day);
      for (final symptom in entry.symptoms) {
        if (symptom == DigestiveSymptom.none) continue;
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }
  }

  return JournalWeekStats(
    mealsLogged: lastWeek.length,
    symptomDays: symptomDays.length,
    symptomCounts: symptomCounts,
    mealsPerDay: mealsPerDay,
  );
});
