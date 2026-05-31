import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistencia del token de sesión anónima. Nada sensible (soluciones,
/// nodos futuros) se guarda aquí: solo el token de dispositivo.
class SessionStorage {
  static const _tokenKey = 'limen_session_token';
  final FlutterSecureStorage _storage;

  SessionStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
