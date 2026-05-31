import 'package:dio/dio.dart';
import 'package:limen_domain/limen_domain.dart';

import 'limen_gateway.dart';

/// Base de la API. Override en build:  --dart-define=LIMEN_API=https://...
const String kApiBaseUrl = String.fromEnvironment(
  'LIMEN_API',
  defaultValue: 'http://localhost:8080/api/v1',
);

/// Código de error sintético para fallos de red (la señal no llega).
const String kNetworkErrorCode = 'NETWORK';

/// Cliente de la API de LIMEN. Mapea el contrato (§7) a [Result] tipado.
///
/// La validación es siempre server-side: este cliente nunca decide si una
/// respuesta es correcta, solo transporta.
class LimenApiClient implements LimenGateway {
  final Dio _dio;

  LimenApiClient(this._dio);

  @override
  Future<Result<String>> createSession() => _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>('/session');
        final env = _envelope(res);
        return env.when(
          ok: (data) => Ok(SessionResponse.fromJson(data).token),
          err: (code, message) => Err(code, message),
        );
      });

  @override
  Future<Result<NodeContent>> getNode(String token, String id) =>
      _guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/node/$id',
          options: _auth(token),
        );
        final env = _envelope(res);
        return env.when(
          ok: (data) => Ok(NodeContent.fromJson(data)),
          err: (code, message) => Err(code, message),
        );
      });

  @override
  Future<Result<SubmitResult>> submit(String token, SubmitRequest req) =>
      _guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/submit',
          data: req.toJson(),
          options: _auth(token),
        );
        final env = _envelope(res);
        return env.when(
          ok: (data) => Ok(SubmitResult.fromJson(data)),
          err: (code, message) => Err(code, message),
        );
      });

  Options _auth(String token) =>
      Options(headers: {'authorization': 'Bearer $token'});

  /// Desempaqueta la envoltura del contrato a un [Result] de su `data`.
  Result<Map<String, dynamic>> _envelope(Response<Map<String, dynamic>> res) {
    final body = res.data ?? const {};
    if (body['error'] is Map) {
      final error = (body['error'] as Map).cast<String, dynamic>();
      return Err(
        error['code'] as String? ?? ApiErrorCode.badRequest,
        error['message'] as String? ?? '',
      );
    }
    if (body['data'] is Map) {
      return Ok((body['data'] as Map).cast<String, dynamic>());
    }
    return const Err(ApiErrorCode.badRequest, 'Respuesta inesperada.');
  }

  /// Convierte fallos de transporte en un [Err] de red (dato, no excepción).
  Future<Result<T>> _guard<T>(Future<Result<T>> Function() run) async {
    try {
      return await run();
    } on DioException {
      return const Err(kNetworkErrorCode, 'sin señal');
    } catch (_) {
      return const Err(kNetworkErrorCode, 'sin señal');
    }
  }
}

/// Construye el Dio configurado para hablar con el backend.
Dio buildDio() => Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        contentType: 'application/json',
        // Leemos los envelopes de error nosotros mismos.
        validateStatus: (_) => true,
      ),
    );
