import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:limen_domain/limen_domain.dart';

import '../../core/providers.dart';

/// Falla al abrir/recuperar la sesión anónima.
class SessionException implements Exception {
  final String message;
  const SessionException(this.message);
  @override
  String toString() => message;
}

/// Token de sesión anónima: lo recupera de secure storage o abre uno nuevo
/// contra el servidor. Sin login real.
class SessionController extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final storage = ref.read(sessionStorageProvider);
    final existing = await storage.readToken();
    if (existing != null) return existing;

    final api = ref.read(gatewayProvider);
    final res = await api.createSession();
    switch (res) {
      case Ok(:final value):
        await storage.writeToken(value);
        return value;
      case Err(:final message):
        throw SessionException(message);
    }
  }
}

final sessionProvider =
    AsyncNotifierProvider<SessionController, String>(SessionController.new);
