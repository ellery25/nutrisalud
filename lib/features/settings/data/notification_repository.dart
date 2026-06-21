import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(
    api: ref.watch(apiClientProvider),
    auth: ref.watch(authRepositoryProvider),
  ),
);

/// Syncs device tokens and notification preferences with the backend.
///
/// All methods are fire-and-forget safe: they silently absorb [ApiException]
/// so callers never need to guard against network errors from notification
/// side-effects.
class NotificationRepository {
  const NotificationRepository({
    required ApiClient api,
    required AuthRepository auth,
  })  : _api = api,
        _auth = auth;

  final ApiClient _api;
  final AuthRepository _auth;

  Uri _uri(String path) =>
      Uri.parse('${ApiEnvironment.nutrisaludApiBase}$path');

  String get _platform {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }

  /// Registers [fcmToken] with the backend for the current user.
  Future<void> registerDevice(String fcmToken) async {
    try {
      final token = await _auth.readToken();
      if (token == null) return;
      await _api.postJson(
        _uri('/notifications/devices'),
        {'token': fcmToken, 'platform': _platform},
        token: token,
      );
    } on ApiException {
      // Non-fatal — registration retried on next login.
    }
  }

  /// Removes [fcmToken] from the backend (called on logout).
  Future<void> unregisterDevice(String fcmToken) async {
    try {
      final token = await _auth.readToken();
      if (token == null) return;
      await _api.deleteJson(
        _uri('/notifications/devices'),
        {'token': fcmToken},
        token: token,
      );
    } on ApiException {
      // Non-fatal on logout.
    }
  }

  /// Persists the current preference state to the backend.
  Future<void> syncPreferences({
    required bool mealReminders,
    required bool hydrationReminders,
  }) async {
    try {
      final token = await _auth.readToken();
      if (token == null) return;
      await _api.putJson(
        _uri('/notifications/preferences'),
        {
          'meal_reminders': mealReminders,
          'hydration_reminders': hydrationReminders,
        },
        token: token,
      );
    } on ApiException {
      // Non-fatal — local pref is authoritative for UX.
    }
  }
}
