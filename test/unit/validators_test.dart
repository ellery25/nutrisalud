import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisalud/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('requiredField rejects empty and whitespace', () {
      expect(Validators.requiredField(null), isNotNull);
      expect(Validators.requiredField('   '), isNotNull);
      expect(Validators.requiredField('ok'), isNull);
    });

    test('username enforces length and charset', () {
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('has space'), isNotNull);
      expect(Validators.username('ellery_25'), isNull);
    });

    test('password requires 8+ characters', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('longenough'), isNull);
    });
  });
}
