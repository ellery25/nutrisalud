import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/secure_store.dart';
import '../../../core/utils/result.dart';
import '../domain/auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    api: ref.watch(apiClientProvider),
    secureStore: ref.watch(secureStoreProvider),
    kvStore: ref.watch(keyValueStoreProvider),
  ),
);

/// Holds the current session. `null` means signed out.
final sessionProvider = NotifierProvider<SessionNotifier, AuthSession?>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<AuthSession?> {
  @override
  AuthSession? build() {
    final kv = ref.watch(keyValueStoreProvider);
    final userId = kv.getString(StorageKeys.userId);
    final username = kv.getString(StorageKeys.userName);
    if (userId == null || userId.isEmpty || username == null) return null;
    return AuthSession(
      userId: userId,
      username: username,
      displayName: kv.getString(StorageKeys.userDisplayName) ?? username,
    );
  }

  void set(AuthSession? session) => state = session;
}

class AuthRepository {
  AuthRepository({
    required ApiClient api,
    required SecureStore secureStore,
    required KeyValueStore kvStore,
  })  : _api = api,
        _secure = secureStore,
        _kv = kvStore;

  final ApiClient _api;
  final SecureStore _secure;
  final KeyValueStore _kv;

  Uri _uri(String path) => Uri.parse('${ApiEnvironment.nutrisaludApiBase}$path');

  /// Reads the persisted access token for authenticated calls in other repositories.
  Future<String?> readToken() => _secure.readToken();

  Future<Result<AuthSession>> login({
    required String username,
    required String password,
  }) async {
    try {
      // ApiClient unwraps the envelope; data = {access_token, refresh_token, user: {...}}
      final data = await _api.postJson(
        _uri('/auth/login'),
        {'username': username, 'password': password},
      ) as Map<String, dynamic>;

      final token = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      final userId = user?['id']?.toString();
      final displayName = user?['name'] as String? ?? username;

      if (token == null || userId == null) {
        return const Err('Unexpected response from server.');
      }

      await _secure.writeToken(token);
      if (refreshToken != null) await _secure.writeRefreshToken(refreshToken);
      await _kv.setString(StorageKeys.userId, userId);
      await _kv.setString(StorageKeys.userName, username);
      await _kv.setString(StorageKeys.userDisplayName, displayName);

      return Ok(AuthSession(
        userId: userId,
        username: username,
        displayName: displayName,
      ));
    } on ApiException catch (e) {
      return Err(e.statusCode == 401
          ? 'Incorrect username or password.'
          : e.message);
    }
  }

  Future<Result<void>> register({
    required String name,
    required String username,
    required String password,
  }) async {
    try {
      await _api.postJson(_uri('/auth/register'), {
        'name': name,
        'username': username,
        'password': password,
      });
      return const Ok(null);
    } on ApiException catch (e) {
      return Err(e.statusCode == 409 || e.statusCode == 400
          ? 'That username is already taken.'
          : e.message);
    }
  }

  /// Rotates the refresh token on the server, then clears local storage.
  Future<void> logout() async {
    try {
      final refresh = await _secure.readRefreshToken();
      if (refresh != null) {
        await _api.postJson(_uri('/auth/logout'), {}, token: refresh);
      }
    } on ApiException {
      // Non-fatal: always clear local storage even if the server call fails.
    }
    await _secure.clear();
    await _kv.remove(StorageKeys.userId);
    await _kv.remove(StorageKeys.userName);
    await _kv.remove(StorageKeys.userDisplayName);
  }

  /// Silently rotates the access token. Returns `true` on success.
  Future<bool> refresh() async {
    try {
      final refreshToken = await _secure.readRefreshToken();
      if (refreshToken == null) return false;
      final data = await _api.postJson(
        _uri('/auth/refresh'),
        {},
        token: refreshToken,
      ) as Map<String, dynamic>;
      final newAccess = data['access_token'] as String?;
      final newRefresh = data['refresh_token'] as String?;
      if (newAccess == null) return false;
      await _secure.writeToken(newAccess);
      if (newRefresh != null) await _secure.writeRefreshToken(newRefresh);
      return true;
    } on ApiException {
      return false;
    }
  }
}
