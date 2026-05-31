/// Dominio compartido de LIMEN.
///
/// Contiene la *lógica* de validación, normalización y desbloqueo del grafo,
/// más los DTOs del contrato de API. **Nunca** contiene valores de solución:
/// esos viven solo en los seeds del servidor.
library;

export 'src/result.dart';
export 'src/normalize.dart';
export 'src/validation_rule.dart';
export 'src/validate.dart';
export 'src/answer_hash.dart';
export 'src/graph.dart';
export 'src/puzzle_node.dart';
export 'src/dto.dart';
