import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/liquid_glass.dart';
import '../puzzle/application/progress_controller.dart';
import '../puzzle/domain/arc.dart';

/// Estado de un nodo en el mapa, derivado del progreso (cliente).
enum _NodeState { solved, available, sealed }

/// Mapa del Arco 0 (estética Liquid Glass): la cadena de nodos con su estado
/// sobre un fondo fotográfico. Nunca revela contenido ni soluciones.
class ArcMapScreen extends ConsumerWidget {
  const ArcMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final progress = ref.watch(progressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: PhotoBackdrop(
        asset: Backgrounds.coldplay,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                            color: Colors.white,
                            constraints: const BoxConstraints(
                                minWidth: 48, minHeight: 48),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(l10n.mapTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              shadows: const [
                                Shadow(color: Color(0xAA000000), blurRadius: 12)
                              ],
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: kArcNodeIds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final id = kArcNodeIds[i];
                          final state = progress.solved.contains(id)
                              ? _NodeState.solved
                              : progress.isUnlocked(id)
                                  ? _NodeState.available
                                  : _NodeState.sealed;
                          return _NodeCard(
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
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final int index;
  final _NodeState state;
  final VoidCallback? onTap;

  const _NodeCard({required this.index, required this.state, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    final (icon, tint, stateLabel) = switch (state) {
      _NodeState.solved => (Icons.check_circle_outline, c.accentSignal, l10n.stateSolved),
      _NodeState.available => (Icons.adjust, c.accentSignal, l10n.stateAvailable),
      _NodeState.sealed => (Icons.lock_outline, Colors.white60, l10n.stateSealed),
    };
    final label = '0${index + 1}';

    return Semantics(
      button: onTap != null,
      label: '${l10n.nodeLabel(label)}, $stateLabel',
      child: Opacity(
        opacity: state == _NodeState.sealed ? 0.7 : 1,
        child: LiquidGlass(
          onTap: onTap,
          dark: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tint.withOpacity(0.6)),
                  boxShadow: state != _NodeState.sealed
                      ? [BoxShadow(color: tint.withOpacity(0.4), blurRadius: 10)]
                      : null,
                ),
                child: Icon(icon, color: tint, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.nodeLabel(label),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: Colors.white)),
                    Text(stateLabel,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(color: tint)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
