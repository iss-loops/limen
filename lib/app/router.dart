import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/puzzle/application/progress_controller.dart';
import '../features/puzzle/domain/arc.dart';
import '../features/puzzle/presentation/puzzle_screen.dart';

/// Router declarativo con guard de desbloqueo: no se puede navegar a un nodo
/// que el progreso (cliente) no tiene desbloqueado. El servidor reconfirma.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const PuzzleScreen(nodeId: kEntryNodeId, bare: true),
      ),
      GoRoute(
        path: '/node/:id',
        builder: (context, state) =>
            PuzzleScreen(nodeId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      if (!state.uri.path.startsWith('/node/')) return null;
      final id = state.pathParameters['id'];
      if (id == kEntryNodeId) return '/';
      if (id != null && !ref.read(progressProvider).isUnlocked(id)) return '/';
      return null;
    },
  );
});
