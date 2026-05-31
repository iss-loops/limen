import 'package:limen_domain/limen_domain.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeAnswer', () {
    test('recorta espacios de los extremos', () {
      expect(normalizeAnswer('  hola  '), 'hola');
    });

    test('colapsa espacios internos repetidos', () {
      expect(normalizeAnswer('uno   dos\t tres'), 'uno dos tres');
    });

    test('pasa a minúsculas', () {
      expect(normalizeAnswer('LIMEN'), 'limen');
    });

    test('aplica forma unicode NFC (combinada == precompuesta)', () {
      // 'é' precompuesto (U+00E9) vs 'e' + acento combinante (U+0065 U+0301)
      expect(normalizeAnswer('café'), normalizeAnswer('café'));
    });

    test('cadena vacía o de solo espacios → vacía', () {
      expect(normalizeAnswer('   '), '');
    });
  });
}
