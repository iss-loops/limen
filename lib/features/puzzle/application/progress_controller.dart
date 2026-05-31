import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/arc.dart';

/// Espejo de progreso en el cliente (la autoridad sigue siendo el servidor).
///
/// Solo guarda qué nodos están resueltos/desbloqueados para las guards de
/// routing; nunca soluciones ni contenido de nodos futuros.
class ProgressState {
  final Set<String> solved;
  final Set<String> unlocked;

  const ProgressState({required this.solved, required this.unlocked});

  bool isUnlocked(String nodeId) => unlocked.contains(nodeId);
}

class ProgressController extends Notifier<ProgressState> {
  @override
  ProgressState build() => const ProgressState(
        solved: {},
        unlocked: {kEntryNodeId},
      );

  /// Marca un nodo resuelto y desbloquea el siguiente que indica el servidor.
  void onSolved(String nodeId, String? nextNodeId) {
    state = ProgressState(
      solved: {...state.solved, nodeId},
      unlocked: {...state.unlocked, if (nextNodeId != null) nextNodeId},
    );
  }

  void reset() => state = build();
}

final progressProvider =
    NotifierProvider<ProgressController, ProgressState>(ProgressController.new);
