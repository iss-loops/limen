import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;

import 'package:limen_server/limen_server.dart';

Future<void> main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final state = AppState();
  final server = await io.serve(buildApi(state), InternetAddress.anyIPv4, port);
  stdout.writeln('LIMEN server escuchando en http://${server.address.host}:${server.port}');
}
