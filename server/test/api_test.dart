import 'dart:convert';

import 'package:limen_server/limen_server.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  late Handler api;

  setUp(() {
    api = buildApi(AppState());
  });

  Future<Map<String, dynamic>> jsonOf(Response res) async =>
      jsonDecode(await res.readAsString()) as Map<String, dynamic>;

  Request post(String path, {String? token, Object? body}) => Request(
        'POST',
        Uri.parse('http://localhost$path'),
        headers: {
          if (token != null) 'authorization': 'Bearer $token',
          if (body != null) 'content-type': 'application/json',
        },
        body: body == null ? null : jsonEncode(body),
      );

  Request get(String path, {String? token}) => Request(
        'GET',
        Uri.parse('http://localhost$path'),
        headers: {if (token != null) 'authorization': 'Bearer $token'},
      );

  Future<String> newSession() async {
    final res = await api(post('/api/v1/session'));
    return (await jsonOf(res))['data']['token'] as String;
  }

  test('GET /healthz responde 200 (health check de deploy)', () async {
    final res = await api(get('/healthz'));
    expect(res.statusCode, 200);
    expect((await jsonOf(res))['data']['status'], 'ok');
  });

  test('POST /session devuelve un token', () async {
    final res = await api(post('/api/v1/session'));
    expect(res.statusCode, 200);
    final body = await jsonOf(res);
    expect(body['data']['token'], isA<String>());
    expect(body['meta']['v'], 1);
  });

  test('GET /node sin sesión → 401', () async {
    final res = await api(get('/api/v1/node/node0'));
    expect(res.statusCode, 401);
    expect((await jsonOf(res))['error']['code'], 'UNAUTHORIZED');
  });

  test('GET /node/node0 con sesión → contenido sin solución', () async {
    final token = await newSession();
    final res = await api(get('/api/v1/node/node0', token: token));
    expect(res.statusCode, 200);
    final data = (await jsonOf(res))['data'] as Map<String, dynamic>;
    expect(data['id'], 'node0');
    expect(jsonEncode(data).toLowerCase(), isNot(contains('visto')));
    expect(jsonEncode(data), isNot(contains('expected')));
  });

  test('GET /node/node1 bloqueado antes de resolver node0 → 403', () async {
    final token = await newSession();
    final res = await api(get('/api/v1/node/node1', token: token));
    expect(res.statusCode, 403);
    expect((await jsonOf(res))['error']['code'], 'NODE_LOCKED');
  });

  test('GET /node inexistente → 404', () async {
    final token = await newSession();
    final res = await api(get('/api/v1/node/nope', token: token));
    expect(res.statusCode, 404);
    expect((await jsonOf(res))['error']['code'], 'NOT_FOUND');
  });

  test('POST /submit correcto → correct, desbloqueo y narrativa', () async {
    final token = await newSession();
    final res = await api(post('/api/v1/submit',
        token: token, body: {'nodeId': 'node0', 'answer': '  VISTO '}));
    expect(res.statusCode, 200);
    final data = (await jsonOf(res))['data'] as Map<String, dynamic>;
    expect(data['correct'], isTrue);
    expect(data['nextNodeId'], 'node1');
    expect(data['narrative'], isNotNull);
  });

  test('POST /submit incorrecto → correct=false, sin desbloqueo', () async {
    final token = await newSession();
    final res = await api(post('/api/v1/submit',
        token: token, body: {'nodeId': 'node0', 'answer': 'nada'}));
    final data = (await jsonOf(res))['data'] as Map<String, dynamic>;
    expect(data['correct'], isFalse);
    expect(data['nextNodeId'], isNull);
    expect(data['narrative'], isNull);
  });

  test('resolver node0 desbloquea node1', () async {
    final token = await newSession();
    await api(post('/api/v1/submit',
        token: token, body: {'nodeId': 'node0', 'answer': 'visto'}));
    final res = await api(get('/api/v1/node/node1', token: token));
    expect(res.statusCode, 200);
    expect(((await jsonOf(res))['data'])['id'], 'node1');
  });

  test('no se puede resolver un nodo bloqueado', () async {
    final token = await newSession();
    final res = await api(post('/api/v1/submit',
        token: token, body: {'nodeId': 'node1', 'answer': 'umbral'}));
    expect(res.statusCode, 403);
  });

  test('cadena completa node0 → node1 → node2 con cierre', () async {
    final token = await newSession();

    await api(post('/api/v1/submit',
        token: token, body: {'nodeId': 'node0', 'answer': 'visto'}));
    await api(post('/api/v1/submit',
        token: token, body: {'nodeId': 'node1', 'answer': 'umbral'}));
    final res = await api(post('/api/v1/submit',
        token: token, body: {'nodeId': 'node2', 'answer': 'LIMEN{te_veo}'}));

    final data = (await jsonOf(res))['data'] as Map<String, dynamic>;
    expect(data['correct'], isTrue);
    expect(data['nextNodeId'], isNull);
    expect(data['narrative'], 'has sido visto.');
  });
}
