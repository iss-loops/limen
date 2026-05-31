import 'package:limen_domain/limen_domain.dart';
import 'package:test/test.dart';

void main() {
  group('hashAnswer', () {
    test('es determinista para misma respuesta y sal', () {
      expect(hashAnswer('brutus', 'sal0'), hashAnswer('brutus', 'sal0'));
    });

    test('cambia con la sal (la sal por-nodo importa)', () {
      expect(hashAnswer('brutus', 'sal0'),
          isNot(hashAnswer('brutus', 'sal1')));
    });

    test('cambia con la respuesta', () {
      expect(hashAnswer('brutus', 'sal0'),
          isNot(hashAnswer('cesar', 'sal0')));
    });

    test('produce hex de 64 chars (SHA-256)', () {
      expect(hashAnswer('x', 's'), matches(RegExp(r'^[0-9a-f]{64}$')));
    });
  });

  group('constantTimeEquals', () {
    test('verdadero para hashes iguales', () {
      final h = hashAnswer('a', 's');
      expect(constantTimeEquals(h, h), isTrue);
    });
    test('falso para hashes distintos', () {
      expect(constantTimeEquals(hashAnswer('a', 's'), hashAnswer('b', 's')),
          isFalse);
    });
    test('falso si difieren en longitud', () {
      expect(constantTimeEquals('abc', 'abcd'), isFalse);
    });
  });
}
