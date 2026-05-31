import 'dart:convert';

import 'package:limen_domain/limen_domain.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'seeds.dart';
import 'session_store.dart';

/// Estado del servidor: seeds + sesiones. Inyectable para tests.
class AppState {
  final Map<String, NodeSeed> seeds;
  final List<NodeEdge> edges;
  final SessionStore sessions;

  AppState({
    Map<String, NodeSeed>? seeds,
    List<NodeEdge>? edges,
    SessionStore? sessions,
  })  : seeds = seeds ?? nodeSeeds,
        edges = edges ?? nodeEdges,
        sessions = sessions ?? SessionStore();
}

/// Construye el handler de la API v1, con CORS para correr en Flutter web.
Handler buildApi(AppState state) {
  final router = Router()
    ..get('/healthz', (Request req) => _ok({'status': 'ok'}))
    ..post('/api/v1/session', (Request req) => _session(state))
    ..get('/api/v1/node/<id>', (Request req, String id) => _node(state, req, id))
    ..post('/api/v1/submit', (Request req) => _submit(state, req));

  return const Pipeline()
      .addMiddleware(_cors())
      .addHandler(router.call);
}

// --- Handlers --------------------------------------------------------------

Response _session(AppState state) {
  final token = state.sessions.createSession();
  return _ok(SessionResponse(token).toJson());
}

Future<Response> _node(AppState state, Request req, String id) async {
  final token = _bearer(req);
  if (token == null || !state.sessions.exists(token)) {
    return _err(ApiErrorCode.unauthorized, 'Sesión no válida.', 401);
  }
  final seed = state.seeds[id];
  if (seed == null) {
    return _err(ApiErrorCode.notFound, 'Ese nodo no existe.', 404);
  }
  if (!isUnlocked(id, state.sessions.solved(token), state.edges)) {
    return _err(ApiErrorCode.nodeLocked, 'Aún no es tu turno.', 403);
  }
  return _ok(seed.content.toJson());
}

Future<Response> _submit(AppState state, Request req) async {
  final token = _bearer(req);
  if (token == null || !state.sessions.exists(token)) {
    return _err(ApiErrorCode.unauthorized, 'Sesión no válida.', 401);
  }

  final SubmitRequest submit;
  try {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    submit = SubmitRequest.fromJson(body);
  } catch (_) {
    return _err(ApiErrorCode.badRequest, 'Petición mal formada.', 400);
  }

  final seed = state.seeds[submit.nodeId];
  if (seed == null) {
    return _err(ApiErrorCode.notFound, 'Ese nodo no existe.', 404);
  }
  if (!isUnlocked(submit.nodeId, state.sessions.solved(token), state.edges)) {
    return _err(ApiErrorCode.nodeLocked, 'Aún no es tu turno.', 403);
  }

  final correct = _check(seed, submit.answer);
  if (correct) {
    state.sessions.markSolved(token, submit.nodeId);
  }

  final result = SubmitResult(
    correct: correct,
    nextNodeId: correct ? seed.nextNodeId : null,
    narrative: correct ? seed.narrative : null,
  );
  return _ok(result.toJson());
}

/// Aplica la regla del nodo. Igualdad → hash con sal en tiempo constante;
/// regex/numérico → `validate` del dominio. La autoridad vive aquí.
bool _check(NodeSeed seed, String rawAnswer) {
  return switch (seed.rule) {
    ExactRule() => constantTimeEquals(
        hashAnswer(rawAnswer, seed.salt), seed.expectedHash),
    NormalizedRule() => constantTimeEquals(
        hashAnswer(normalizeAnswer(rawAnswer), seed.salt), seed.expectedHash),
    RegexRule() ||
    NumericToleranceRule() =>
      validate(seed.rule, normalizeAnswer(rawAnswer), seed.expectedPlain),
  };
}

// --- Envoltura del contrato ------------------------------------------------

Response _ok(Object data) => Response.ok(
      jsonEncode({
        'data': data,
        'meta': {'v': 1},
      }),
      headers: _jsonHeaders,
    );

Response _err(String code, String message, int status) => Response(
      status,
      body: jsonEncode({
        'error': {'code': code, 'message': message},
      }),
      headers: _jsonHeaders,
    );

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

String? _bearer(Request req) {
  final auth = req.headers['authorization'];
  if (auth == null || !auth.startsWith('Bearer ')) return null;
  return auth.substring('Bearer '.length).trim();
}

Middleware _cors() => (Handler inner) => (Request req) async {
      if (req.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final res = await inner(req);
      return res.change(headers: {...res.headers, ..._corsHeaders});
    };

const _corsHeaders = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, POST, OPTIONS',
  'access-control-allow-headers': 'origin, content-type, authorization',
};
