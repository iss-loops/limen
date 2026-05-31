import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/pressable_scale.dart';
import '../puzzle/application/progress_controller.dart';
import '../puzzle/domain/arc.dart';

/// Estado de un nodo en el mapa, derivado del progreso (cliente).
enum _NodeState { solved, available, sealed }

/// Mapa del Arco 0: la cadena de nodos con su estado. Permite volver a un nodo
/// resuelto o saltar al disponible. Nunca revela contenido ni soluciones.
class ArcMapScreen extends ConsumerWidget {
  const ArcMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final progress = ref.watch(progressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Semantics(
                        button: true,
                        label: l10n.backAction,
                        child: IconButton(
                          onPressed: () => context.canPop()
                              ? context.pop()
                              : context.go('/'),
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 20,
                          color: c.inkDim,
                          constraints:
                              const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(l10n.mapTitle,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: c.inkPrimary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: kArcNodeIds.length,
                      separatorBuilder: (_, __) => _Connector(color: c.inkDim),
                      itemBuilder: (context, i) {
                        final id = kArcNodeIds[i];
                        final state = progress.solved.contains(id)
                            ? _NodeState.solved
                            : progress.isUnlocked(id)
                                ? _NodeState.available
                                : _NodeState.sealed;
                        return _NodeRow(
                          index: i,
                          state: state,
                          onTap: state == _NodeState.sealed
                              ? null
                              : () => context.go(i == 0 ? '/' : '/node/$id'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  final Color color;
  const _Connector({required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 23),
        child: Container(
          width: 1,
          height: 24,
          color: color.withOpacity(0.3),
        ),
      );
}

class _NodeRow extends StatelessWidget {
  final int index;
  final _NodeState state;
  final VoidCallback? onTap;

  const _NodeRow({required this.index, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    final (icon, tint, stateLabel) = switch (state) {
      _NodeState.solved => (Icons.check_circle_outline, c.accentSignal, l10n.stateSolved),
      _NodeState.available => (Icons.adjust, c.accentSignal, l10n.stateAvailable),
      _NodeState.sealed => (Icons.lock_outline, c.inkDim, l10n.stateSealed),
    };
    final label = '0${index + 1}';

    final row = Semantics(
      button: onTap != null,
      label: '${l10n.nodeLabel(label)}, $stateLabel',
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: tint.withOpacity(0.5)),
                boxShadow: state != _NodeState.sealed
                    ? [BoxShadow(color: tint.withOpacity(0.4), blurRadius: 10)]
                    : null,
              ),
              child: Icon(icon, color: tint, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.nodeLabel(label),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: state == _NodeState.sealed
                            ? c.inkDim
                            : c.inkPrimary,
                      )),
                  Text(stateLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(color: tint)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: c.inkDim, size: 20),
          ],
        ),
      ),
    );

    if (onTap == null) return Opacity(opacity: 0.7, child: row);
    return PressableScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: row,
      ),
    );
  }
}
