import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/session_storage.dart';
import 'features/session/alias_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lee el alias antes del primer frame para que el guard del router decida
  // sin parpadeo entre /login y el arco.
  final alias = await SessionStorage().readAlias();
  runApp(
    ProviderScope(
      overrides: [aliasBootstrapProvider.overrideWithValue(alias)],
      child: const LimenApp(),
    ),
  );
}
