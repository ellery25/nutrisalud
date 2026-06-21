import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product analytics abstraction (Phase 9: backend readiness).
/// Swap [DebugAnalyticsService] for Firebase Analytics / Amplitude / PostHog
/// by providing another implementation — feature code never changes.
abstract interface class AnalyticsService {
  void logEvent(String name, [Map<String, Object?> parameters = const {}]);
  void setUserId(String? id);
}

class DebugAnalyticsService implements AnalyticsService {
  const DebugAnalyticsService();

  @override
  void logEvent(String name, [Map<String, Object?> parameters = const {}]) {
    if (kDebugMode) {
      debugPrint('[analytics] $name $parameters');
    }
  }

  @override
  void setUserId(String? id) {
    if (kDebugMode) {
      debugPrint('[analytics] user=$id');
    }
  }
}

final analyticsProvider =
    Provider<AnalyticsService>((ref) => const DebugAnalyticsService());
