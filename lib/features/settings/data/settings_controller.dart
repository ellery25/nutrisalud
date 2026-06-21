import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/key_value_store.dart';
import 'notification_repository.dart';

/// App theme mode, persisted.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored =
        ref.watch(keyValueStoreProvider).getString(StorageKeys.themeMode);
    return ThemeMode.values.asNameMap()[stored] ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref
        .read(keyValueStoreProvider)
        .setString(StorageKeys.themeMode, mode.name);
  }
}

/// Notification preference toggles, persisted locally and synced to the backend.
final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);

class NotificationPrefs {
  const NotificationPrefs({
    required this.mealReminders,
    required this.hydrationReminders,
  });

  final bool mealReminders;
  final bool hydrationReminders;

  NotificationPrefs copyWith({bool? mealReminders, bool? hydrationReminders}) =>
      NotificationPrefs(
        mealReminders: mealReminders ?? this.mealReminders,
        hydrationReminders: hydrationReminders ?? this.hydrationReminders,
      );
}

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  KeyValueStore get _kv => ref.read(keyValueStoreProvider);

  @override
  NotificationPrefs build() => NotificationPrefs(
        mealReminders:
            _kv.getBool(StorageKeys.mealRemindersEnabled) ?? false,
        hydrationReminders:
            _kv.getBool(StorageKeys.hydrationRemindersEnabled) ?? false,
      );

  Future<void> setMealReminders(bool enabled) async {
    state = state.copyWith(mealReminders: enabled);
    await _kv.setBool(StorageKeys.mealRemindersEnabled, enabled);
    final notifications = ref.read(notificationServiceProvider);
    enabled
        ? await notifications.subscribe(NotificationTopic.mealReminder)
        : await notifications.unsubscribe(NotificationTopic.mealReminder);
    unawaited(ref.read(notificationRepositoryProvider).syncPreferences(
          mealReminders: state.mealReminders,
          hydrationReminders: state.hydrationReminders,
        ));
  }

  Future<void> setHydrationReminders(bool enabled) async {
    state = state.copyWith(hydrationReminders: enabled);
    await _kv.setBool(StorageKeys.hydrationRemindersEnabled, enabled);
    final notifications = ref.read(notificationServiceProvider);
    enabled
        ? await notifications.subscribe(NotificationTopic.hydrationReminder)
        : await notifications.unsubscribe(NotificationTopic.hydrationReminder);
    unawaited(ref.read(notificationRepositoryProvider).syncPreferences(
          mealReminders: state.mealReminders,
          hydrationReminders: state.hydrationReminders,
        ));
  }
}
