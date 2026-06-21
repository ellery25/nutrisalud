import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisalud/core/storage/key_value_store.dart';
import 'package:nutrisalud/main.dart';

import 'helpers/fake_key_value_store.dart';

void main() {
  testWidgets('signed-out users land on the welcome screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(FakeKeyValueStore()),
        ],
        child: const NutriSaludApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NutriSalud'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
