import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:limen_domain/limen_domain.dart';

import '../../../core/providers.dart';
import '../../session/session_controller.dart';

/// Falla al cargar un nodo; [code] distingue bloqueado / red / no encontrado.
class NodeException implements Exception {
  final String code;
  final String message;
  const NodeException(this.code, this.message);
  @override
  String toString() => message;
}

/// Carga el contenido de un nodo desde el servidor (autorizado por progreso).
/// El payload se cachea por Riverpod para lectura del nodo actual.
final nodeProvider = FutureProvider.family<NodeContent, String>((ref, id) async {
  final token = await ref.watch(sessionProvider.future);
  final api = ref.read(apiClientProvider);
  final res = await api.getNode(token, id);
  switch (res) {
    case Ok(:final value):
      return value;
    case Err(:final code, :final message):
      throw NodeException(code, message);
  }
});
