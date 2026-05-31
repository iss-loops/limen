import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/arc_map/arc_map_screen.dart';
import '../features/puzzle/application/progress_controller.dart';
import '../features/puzzle/domain/arc.dart';
import '../features/puzzle/presentation/puzzle_screen.dart';
import '../features/session/alias_controller.dart';
import '../features/session/login_screen.dart';

/// Router declarativo con guards: gate de alias + desbloqueo de nodos. El
/// servidor reconfirma la autorización de cada nodo.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _ceremonialFade(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _ceremonialFade(
          state,
          const PuzzleScreen(nodeId: kEntryNodeId, bare: true),
        ),
      ),
      GoRoute(
        path: '/node/:id',
        pageBuilder: (context, state) => _ceremonialFade(
          state,
          PuzzleScreen(nodeId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/map',
        pageBuilder: (context, state) =>
            _ceremonialFade(state, const ArcMapScreen()),
      ),
    ],
    redirect: (context, state) {
      final alias = ref.read(aliasProvider);
      final hasAlias = alias != null && alias.isNotEmpty;
      final loc = state.uri.path;

      // Gate de alias: sin alias, todo lleva a /login.
      if (!hasAlias) return loc == '/login' ? null : '/login';
      if (loc == '/login') return '/';

      // Guard de desbloqueo de nodos.
      if (loc.startsWith('/node/')) {
        final id = state.pathParameters['id'];
        if (id == kEntryNodeId) return '/';
        if (id != null && !ref.read(progressProvider).isUnlocked(id)) {
          return '/';
        }
      }
      return null;
    },
  );
});

/// Transición ceremonial: desvanecido lento, nunca un slide alegre (README §3).
/// Respeta reduce-motion (corte directo).
CustomTransitionPage<void> _ceremonialFade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 420),
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) return child;
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return FadeTransition(opacity: curved, child: child);
    },
  );
}
