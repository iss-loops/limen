import 'package:limen_domain/limen_domain.dart';

import '../../../core/network/limen_gateway.dart';
import 'local_seeds.dart';

/// Implementación offline de [LimenGateway]: valida en proceso contra seeds
/// embebidos, reutilizando la lógica del dominio (`validate`, `isUnlocked`).
///
/// ⚠️ Sin autoridad server-side (ver [localNodeSeeds]). Solo modo demo.
class LocalGateway implements LimenGateway {
  final Set<String> _solved = {};

  @override
  Future<Result<String>> createSession() async => const Ok('local-session');

  @override
  Future<Result<NodeContent>> getNode(String token, String id) async {
    final seed = localNodeSeeds[id];
    if (seed == null) {
      return const Err(ApiErrorCode.notFound, 'Ese nodo no existe.');
    }
    if (!isUnlocked(id, _solved, localEdges)) {
      return const Err(ApiErrorCode.nodeLocked, 'Aún no es tu turno.');
    }
    return Ok(seed.content);
  }

  @override
  Future<Result<SubmitResult>> submit(String token, SubmitRequest req) async {
    final seed = localNodeSeeds[req.nodeId];
    if (seed == null) {
      return const Err(ApiErrorCode.notFound, 'Ese nodo no existe.');
    }
    if (!isUnlocked(req.nodeId, _solved, localEdges)) {
      return const Err(ApiErrorCode.nodeLocked, 'Aún no es tu turno.');
    }
    final correct = validate(const NormalizedRule(), req.answer, seed.solution);
    if (correct) _solved.add(req.nodeId);
    return Ok(SubmitResult(
      correct: correct,
      nextNodeId: correct ? seed.nextNodeId : null,
      narrative: correct ? seed.narrative : null,
    ));
  }
}
