import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../features/puzzle/application/progress_controller.dart';
import '../../features/puzzle/domain/arc.dart';

/// Indicador de progreso del arco: puntos que se "encienden" (con halo) al
/// resolver cada nodo. Orientación discreta sin romper la estética.
class ArcProgress extends ConsumerWidget {
  const ArcProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solved = ref.watch(progressProvider).solved.length;
    final c = context.c;

    return Semantics(
      label: AppL10n.of(context).arcProgress(solved, kArcLength),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(kArcLength, (i) {
          final done = i < solved;
          return Padding(
            padding: const EdgeInsets.only(left: 7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? c.accentSignal : c.inkDim.withOpacity(0.3),
                boxShadow: done
                    ? [BoxShadow(color: c.accentSignal.withOpacity(0.6), blurRadius: 6)]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
