import 'package:limen_domain/limen_domain.dart';
import 'package:test/test.dart';

void main() {
  group('validate — ExactRule', () {
    test('acepta solo igualdad byte a byte', () {
      expect(validate(const ExactRule(), 'LIMEN{ok}', 'LIMEN{ok}'), isTrue);
    });
    test('rechaza si difiere en mayúsculas', () {
      expect(validate(const ExactRule(), 'limen{ok}', 'LIMEN{ok}'), isFalse);
    });
  });

  group('validate — NormalizedRule', () {
    test('acepta ignorando mayúsculas y espacios', () {
      expect(validate(const NormalizedRule(), '  Brutus ', 'brutus'), isTrue);
    });
    test('rechaza respuesta distinta', () {
      expect(validate(const NormalizedRule(), 'cesar', 'brutus'), isFalse);
    });
  });

  group('validate — RegexRule', () {
    test('acepta lo que matchea el patrón', () {
      expect(
        validate(const RegexRule(r'^LIMEN\{[a-z0-9_]+\}$'), 'LIMEN{abc_1}', ''),
        isTrue,
      );
    });
    test('rechaza lo que no matchea', () {
      expect(
        validate(const RegexRule(r'^LIMEN\{[a-z0-9_]+\}$'), 'nope', ''),
        isFalse,
      );
    });
  });

  group('validate — NumericToleranceRule', () {
    test('acepta dentro de la tolerancia', () {
      expect(validate(const NumericToleranceRule(0.5), '41.6', '42'), isTrue);
    });
    test('rechaza fuera de la tolerancia', () {
      expect(validate(const NumericToleranceRule(0.5), '40', '42'), isFalse);
    });
    test('rechaza entrada no numérica', () {
      expect(validate(const NumericToleranceRule(0.5), 'doce', '42'), isFalse);
    });
  });
}
