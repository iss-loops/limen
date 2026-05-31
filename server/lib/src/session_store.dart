import 'dart:convert';
import 'dart:math';

/// Progreso por sesión anónima, en memoria (demo). Sin login real.
class SessionStore {
  final Map<String, Set<String>> _solvedByToken = {};
  final Random _rng;

  SessionStore({Random? rng}) : _rng = rng ?? Random.secure();

  /// Crea una sesión anónima y devuelve su token de dispositivo.
  String createSession() {
    final bytes = List<int>.generate(24, (_) => _rng.nextInt(256));
    final token = base64Url.encode(bytes);
    _solvedByToken[token] = <String>{};
    return token;
  }

  bool exists(String token) => _solvedByToken.containsKey(token);

  Set<String> solved(String token) =>
      Set.unmodifiable(_solvedByToken[token] ?? const {});

  void markSolved(String token, String nodeId) {
    _solvedByToken[token]?.add(nodeId);
  }
}
