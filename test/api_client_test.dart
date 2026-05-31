// Verifica que LimenApiClient mapea el contrato (§7) a Result tipado y
// deserializa los DTOs, usando un adapter Dio en memoria (sin red).
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iss/core/network/api_client.dart';
import 'package:limen_domain/limen_domain.dart';

class _CannedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? __) async {
    Map<String, dynamic> ok(Object data) => {
          'data': data,
          'meta': {'v': 1}
        };

    String requestBody = '';
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      requestBody = utf8.decode(chunks.expand((c) => c).toList());
    }

    final (status, body) = switch (options.path) {
      '/session' => (200, ok({'token': 'tok-123'})),
      '/node/node0' => (
          200,
          ok({
            'id': 'node0',
            'arco': 0,
            'schemaVersion': 1,
            'presentation': {'kind': 'text', 'body': 'mira', 'glyph': false, 'intensity': 0},
            'entry': {'kind': 'text', 'placeholder': null},
          })
        ),
      '/node/locked' => (
          403,
          {
            'error': {'code': ApiErrorCode.nodeLocked, 'message': 'no aún'}
          }
        ),
      '/node/boom' => throw Exception('transport down'),
      '/submit' => () {
          final answer = (jsonDecode(requestBody)
              as Map<String, dynamic>)['answer'] as String;
          final correct = normalizeAnswer(answer) == 'visto';
          return (
            200,
            ok({
              'correct': correct,
              'nextNodeId': correct ? 'node1' : null,
              'narrative': correct ? 'lo viste.' : null,
            })
          );
        }(),
      _ => (404, {'error': {'code': 'NOT_FOUND', 'message': ''}}),
    };

    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late LimenApiClient api;

  setUp(() {
    final dio = Dio(BaseOptions(validateStatus: (_) => true))
      ..httpClientAdapter = _CannedAdapter();
    api = LimenApiClient(dio);
  });

  test('createSession devuelve el token', () async {
    expect(await api.createSession(), const Ok('tok-123'));
  });

  test('getNode deserializa el NodeContent', () async {
    final res = await api.getNode('t', 'node0');
    final node = (res as Ok<NodeContent>).value;
    expect(node.id, 'node0');
    expect(node.presentation, isA<TextPresentation>());
  });

  test('un nodo bloqueado se mapea a Err con su código', () async {
    final res = await api.getNode('t', 'locked');
    expect((res as Err<NodeContent>).code, ApiErrorCode.nodeLocked);
  });

  test('submit correcto → SubmitResult con desbloqueo', () async {
    final res =
        await api.submit('t', const SubmitRequest(nodeId: 'node0', answer: ' VISTO '));
    final r = (res as Ok<SubmitResult>).value;
    expect(r.correct, isTrue);
    expect(r.nextNodeId, 'node1');
  });

  test('submit incorrecto → correct=false (dato, no excepción)', () async {
    final res =
        await api.submit('t', const SubmitRequest(nodeId: 'node0', answer: 'x'));
    expect((res as Ok<SubmitResult>).value.correct, isFalse);
  });

  test('fallo de transporte → Err de red', () async {
    final res = await api.getNode('t', 'boom');
    expect((res as Err<NodeContent>).code, kNetworkErrorCode);
  });
}
