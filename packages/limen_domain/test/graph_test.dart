import 'package:limen_domain/limen_domain.dart';
import 'package:test/test.dart';

void main() {
  const edges = [
    NodeEdge('node0', 'node1'),
    NodeEdge('node1', 'node2'),
  ];

  group('isUnlocked', () {
    test('un nodo sin prerrequisitos siempre está desbloqueado', () {
      expect(isUnlocked('node0', {}, edges), isTrue);
    });

    test('bloqueado si el prerrequisito no está resuelto', () {
      expect(isUnlocked('node1', {}, edges), isFalse);
    });

    test('desbloqueado cuando el prerrequisito está resuelto', () {
      expect(isUnlocked('node1', {'node0'}, edges), isTrue);
    });

    test('bloqueado en cadena si falta un eslabón intermedio', () {
      expect(isUnlocked('node2', {'node0'}, edges), isFalse);
    });

    test('requiere TODOS los prerrequisitos', () {
      const fanIn = [NodeEdge('a', 'c'), NodeEdge('b', 'c')];
      expect(isUnlocked('c', {'a'}, fanIn), isFalse);
      expect(isUnlocked('c', {'a', 'b'}, fanIn), isTrue);
    });
  });
}
