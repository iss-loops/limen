import 'package:limen_domain/limen_domain.dart';

/// Puerta de entrada al backend de LIMEN. Dos implementaciones:
///  - [LimenApiClient]: HTTP real (autoridad server-side, modo producción).
///  - LocalGateway: en proceso con seeds embebidos (modo demo offline).
///
/// La app depende solo de esta interfaz; la implementación se elige en
/// [gatewayProvider].
abstract interface class LimenGateway {
  Future<Result<String>> createSession();
  Future<Result<NodeContent>> getNode(String token, String id);
  Future<Result<SubmitResult>> submit(String token, SubmitRequest req);
}
