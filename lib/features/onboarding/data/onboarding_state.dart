import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/key_value_store.dart';

/// Whether the user has completed the intro carousel.
final onboardingDoneProvider =
    NotifierProvider<OnboardingDoneNotifier, bool>(OnboardingDoneNotifier.new);

class OnboardingDoneNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(keyValueStoreProvider).getBool(StorageKeys.onboardingDone) ??
      false;

  Future<void> complete() async {
    state = true;
    await ref
        .read(keyValueStoreProvider)
        .setBool(StorageKeys.onboardingDone, true);
  }
}
