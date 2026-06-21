import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Sensitive credentials live in the platform keystore/keychain,
/// never in SharedPreferences.
abstract interface class SecureStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clear();
}

class FlutterSecureStore implements SecureStore {
  const FlutterSecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: StorageKeys.accessToken);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  @override
  Future<String?> readRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  @override
  Future<void> clear() => Future.wait([
        _storage.delete(key: StorageKeys.accessToken),
        _storage.delete(key: StorageKeys.refreshToken),
      ]);
}

final secureStoreProvider =
    Provider<SecureStore>((ref) => const FlutterSecureStore());
