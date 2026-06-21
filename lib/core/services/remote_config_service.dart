import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote configuration abstraction (feature flags, premium gating).
/// Backed by in-memory defaults today; swap for Firebase Remote Config
/// or a custom flags endpoint without touching feature code.
abstract interface class RemoteConfigService {
  bool getBool(String key, {bool fallback = false});
  String getString(String key, {String fallback = ''});
}

/// Known flag keys.
abstract final class ConfigFlags {
  static const String premiumEnabled = 'premium_enabled';
  static const String communityEnabled = 'community_enabled';
  static const String specialistsBookingEnabled = 'specialists_booking_enabled';
}

class InMemoryRemoteConfig implements RemoteConfigService {
  const InMemoryRemoteConfig([this._values = _defaults]);

  static const Map<String, Object> _defaults = {
    ConfigFlags.premiumEnabled: false,
    ConfigFlags.communityEnabled: true,
    ConfigFlags.specialistsBookingEnabled: false,
  };

  final Map<String, Object> _values;

  @override
  bool getBool(String key, {bool fallback = false}) =>
      _values[key] as bool? ?? fallback;

  @override
  String getString(String key, {String fallback = ''}) =>
      _values[key] as String? ?? fallback;
}

final remoteConfigProvider =
    Provider<RemoteConfigService>((ref) => const InMemoryRemoteConfig());
