// Verifica el modo demo offline: el recorrido completo del Arco 0 contra los
// seeds embebidos, reutilizando la lógica del dominio.
import 'package:flutter_test/flutter_test.dart';
import 'package:iss/features/puzzle/data/local_gateway.dart';
import 'package:limen_domain/limen_domain.dart';

void main() {
  late LocalGateway gw;
  setUp(() => gw = LocalGateway());

  test('node1 está bloqueado hasta resolver node0', () async {
    expect(await gw.getNode('t', 'node1'), isA<Err<NodeContent>>());
  });

  test('respuesta incorrecta no desbloquea', () async {
    final r = await gw.submit('t', const SubmitRequest(nodeId: 'node0', answer: 'x'));
    expect((r as Ok<SubmitResult>).value.correct, isFalse);
    expect(await gw.getNode('t', 'node1'), isA<Err<NodeContent>>());
  });

  test('recorrido completo node0 → node1 → node2 → cierre', () async {
    final s0 = await gw.submit('t', const SubmitRequest(nodeId: 'node0', answer: ' VISTO '));
    expect((s0 as Ok<SubmitResult>).value.nextNodeId, 'node1');
    expect(await gw.getNode('t', 'node1'), isA<Ok<NodeContent>>());

    final s1 = await gw.submit('t', const SubmitRequest(nodeId: 'node1', answer: 'umbral'));
    expect((s1 as Ok<SubmitResult>).value.nextNodeId, 'node2');

    final s2 = await gw.submit('t', const SubmitRequest(nodeId: 'node2', answer: 'LIMEN{te_veo}'));
    final closing = (s2 as Ok<SubmitResult>).value;
    expect(closing.correct, isTrue);
    expect(closing.nextNodeId, isNull);
    expect(closing.narrative, 'has sido visto.');
  });
}
