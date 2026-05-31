// E2E real: el servidor shelf levantado sobre un socket real (puerto efímero)
// y recorrido por HTTP de verdad con dart:io HttpClient. Sin mocks.
import 'dart:convert';
import 'dart:io';

import 'package:limen_server/limen_server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late String base;
  final client = HttpClient();

  setUpAll(() async {
    server = await shelf_io.serve(
        buildApi(AppState()), InternetAddress.loopbackIPv4, 0);
    base = 'http://127.0.0.1:${server.port}/api/v1';
  });

  tearDownAll(() async {
    client.close(force: true);
    await server.close(force: true);
  });

  Future<(int, Map<String, dynamic>)> req(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final r = await client.openUrl(method, Uri.parse('$base$path'));
    if (token != null) r.headers.set('authorization', 'Bearer $token');
    if (body != null) {
      r.headers.contentType = ContentType.json;
      r.write(jsonEncode(body));
    }
    final res = await r.close();
    final text = await res.transform(utf8.decoder).join();
    return (res.statusCode, jsonDecode(text) as Map<String, dynamic>);
  }

  test('recorrido completo del Arco 0 sobre HTTP real', () async {
    final (sc, sBody) = await req('POST', '/session');
    expect(sc, 200);
    final token = sBody['data']['token'] as String;

    // node0 abierto, sin filtrar solución; node1 bloqueado.
    final (n0c, n0) = await req('GET', '/node/node0', token: token);
    expect(n0c, 200);
    expect(jsonEncode(n0['data']).toLowerCase(), isNot(contains('visto')));
    final (n1c, _) = await req('GET', '/node/node1', token: token);
    expect(n1c, 403);

    // node0 -> node1 -> node2 -> cierre
    final (_, s0) = await req('POST', '/submit',
        token: token, body: {'nodeId': 'node0', 'answer': '  VISTO '});
    expect(s0['data']['nextNodeId'], 'node1');

    final (n1okc, _) = await req('GET', '/node/node1', token: token);
    expect(n1okc, 200);

    final (_, s1) = await req('POST', '/submit',
        token: token, body: {'nodeId': 'node1', 'answer': 'umbral'});
    expect(s1['data']['nextNodeId'], 'node2');

    final (_, s2) = await req('POST', '/submit',
        token: token, body: {'nodeId': 'node2', 'answer': 'LIMEN{te_veo}'});
    expect(s2['data']['correct'], isTrue);
    expect(s2['data']['nextNodeId'], isNull);
    expect(s2['data']['narrative'], 'has sido visto.');
  });
}
