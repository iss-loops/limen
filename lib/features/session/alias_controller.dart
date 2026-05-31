import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Valor inicial del alias, leído de storage en `main()` antes de runApp y
/// sobreescrito en el ProviderScope. Permite que el guard del router lo lea de
/// forma síncrona (sin parpadeo).
final aliasBootstrapProvider = Provider<String?>((ref) => null);

/// Alias de la persona (identidad temática, no autenticación). Persistido en
/// secure storage; el modelo de sesión sigue siendo anónimo (token de device).
class AliasController extends Notifier<String?> {
  @override
  String? build() => ref.read(aliasBootstrapProvider);

  Future<void> setAlias(String alias) async {
    final trimmed = alias.trim();
    if (trimmed.isEmpty) return;
    await ref.read(sessionStorageProvider).writeAlias(trimmed);
    state = trimmed;
  }
}

final aliasProvider =
    NotifierProvider<AliasController, String?>(AliasController.new);
