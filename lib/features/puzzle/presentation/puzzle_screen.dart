import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:limen_domain/limen_domain.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/widgets/arc_progress.dart';
import '../../../core/widgets/block_cursor.dart';
import '../../../core/widgets/decode_text.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../session/session_controller.dart';
import '../application/node_provider.dart';
import '../application/progress_controller.dart';
import '../application/submit_controller.dart';

/// Pantalla terminal de un nodo. Sirve tanto al onboarding "no-instrucción"
/// ([bare] = sin cromo) como al resto del arco.
class PuzzleScreen extends ConsumerStatefulWidget {
  final String nodeId;
  final bool bare;

  const PuzzleScreen({super.key, required this.nodeId, this.bare = false});

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  final _answer = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _answer.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _answer.text;
    if (text.trim().isEmpty) return;
    ref.read(submitProvider(widget.nodeId).notifier).submit(text);
  }

  void _keystroke() => ref.read(soundControllerProvider).keystroke();

  @override
  Widget build(BuildContext context) {
    // Acorde de revelación (sonido básico) al acertar.
    ref.listen<SubmissionState>(submitProvider(widget.nodeId), (prev, next) {
      if (next is SubmissionDone && next.result.correct) {
        ref.read(soundControllerProvider).reveal();
        HapticFeedback.mediumImpact();
      }
    });

    final nodeAsync = ref.watch(nodeProvider(widget.nodeId));
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: PhotoBackdrop(
        asset: _backgroundFor(widget.nodeId),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: nodeAsync.when(
                      loading: () => _SystemLine(l10n.loading),
                      error: (err, _) {
                        final locked = err is NodeException &&
                            err.code == ApiErrorCode.nodeLocked;
                        return _ErrorState(
                          message: locked ? l10n.nodeLocked : l10n.networkDown,
                          onRetry: locked
                              ? null
                              : () {
                                  ref.invalidate(sessionProvider);
                                  ref.invalidate(nodeProvider(widget.nodeId));
                                },
                        );
                      },
                      data: (node) => _content(node, l10n),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 4,
              right: 4,
              child: SafeArea(child: _MuteButton()),
            ),
          ],
        ),
      ),
    );
  }

  /// Un fondo fotográfico por nodo (variedad tipo "álbum").
  String _backgroundFor(String nodeId) => switch (nodeId) {
        'node0' => Backgrounds.glints,
        'node1' => Backgrounds.waves,
        'node2' => Backgrounds.spheres,
        _ => Backgrounds.waves,
      };

  Widget _content(NodeContent node, AppL10n l10n) {
    final submission = ref.watch(submitProvider(widget.nodeId));
    if (submission is SubmissionDone && submission.result.correct) {
      return _Revealed(result: submission.result);
    }
    return _PuzzleView(
      node: node,
      submission: submission,
      controller: _answer,
      focus: _focus,
      bare: widget.bare,
      onSubmit: _submit,
      onKeystroke: _keystroke,
    );
  }
}

/// El puzzle en sí: el prompt (decode reveal) + la entrada + feedback.
class _PuzzleView extends StatelessWidget {
  final NodeContent node;
  final SubmissionState submission;
  final TextEditingController controller;
  final FocusNode focus;
  final bool bare;
  final VoidCallback onSubmit;
  final VoidCallback onKeystroke;

  const _PuzzleView({
    required this.node,
    required this.submission,
    required this.controller,
    required this.focus,
    required this.bare,
    required this.onSubmit,
    required this.onKeystroke,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final presentation = node.presentation;
    final entry = node.entry;

    final accent = switch (presentation) {
      TextPresentation(:final glyph) => glyph ? c.accentGlyph : c.inkPrimary,
    };
    final intensity = switch (presentation) {
      TextPresentation(:final intensity) => intensity,
    };
    final body = switch (presentation) {
      TextPresentation(:final body) => body,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!bare) ...[
            Row(
              children: [
                Semantics(
                  button: true,
                  label: l10n.mapOpen,
                  child: IconButton(
                    onPressed: () => context.push('/map'),
                    icon: const Icon(Icons.hub_outlined),
                    iconSize: 20,
                    color: Colors.white,
                    visualDensity: VisualDensity.compact,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
                const SizedBox(width: 4),
                const Wordmark(size: 34),
                const Spacer(),
                const ArcProgress(),
              ],
            ),
            const SizedBox(height: 16),
          ] else
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Wordmark(size: 54),
            ),
          LiquidGlass(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DecodeText(
                  body,
                  intensity: intensity,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: accent),
                ),
                const SizedBox(height: 28),
                _InputRow(
                  controller: controller,
                  focus: focus,
                  entry: entry,
                  enabled: submission is! SubmissionSending,
                  onSubmit: onSubmit,
                  onKeystroke: onKeystroke,
                ),
                const SizedBox(height: 12),
                _Feedback(submission: submission),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: l10n.submitAction,
            color: c.accentSignal,
            onTap: submission is SubmissionSending ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final NodeEntry entry;
  final bool enabled;
  final VoidCallback onSubmit;
  final VoidCallback onKeystroke;

  const _InputRow({
    required this.controller,
    required this.focus,
    required this.entry,
    required this.enabled,
    required this.onSubmit,
    required this.onKeystroke,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final placeholder = switch (entry) {
      TextEntry(:final placeholder) => placeholder,
      NumericEntry(:final placeholder) => placeholder,
    };
    final numeric = entry is NumericEntry;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('> ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: c.accentSignal,
                  shadows: phosphorGlow(c.accentSignal),
                )),
        Expanded(
          child: Semantics(
            label: l10n.answerFieldLabel,
            textField: true,
            child: TextField(
              controller: controller,
              focusNode: focus,
              autofocus: true,
              enabled: enabled,
              keyboardType:
                  numeric ? TextInputType.number : TextInputType.text,
              textInputAction: TextInputAction.send,
              onChanged: (_) => onKeystroke(),
              onSubmitted: (_) => onSubmit(),
              cursorColor: c.accentSignal,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: c.inkPrimary),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: c.inkDim),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        BlockCursor(color: c.accentSignal),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  final SubmissionState submission;
  const _Feedback({required this.submission});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final (text, color) = switch (submission) {
      SubmissionSending() => (l10n.loading, c.inkDim),
      SubmissionDone(:final result) when !result.correct =>
        (l10n.wrongAnswer, c.accentAlert),
      SubmissionFailed(:final code) => (
          code == ApiErrorCode.nodeLocked ? l10n.nodeLocked : l10n.networkDown,
          c.accentAlert,
        ),
      _ => (null, c.inkDim),
    };
    if (text == null) return const SizedBox(height: 22);
    return SizedBox(
      height: 22,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}

/// Momento glyph: la narrativa revelada con glow violeta (Tame Impala).
/// Si hay siguiente nodo, ofrece avanzar; si no, es el cierre del arco.
class _Revealed extends ConsumerWidget {
  final SubmitResult result;
  const _Revealed({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final closing = result.nextNodeId == null;
    final narrative = result.narrative ?? '';

    // Scrollable + centrado: aguanta Dynamic Type grande sin desbordar.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: c.accentGlyph.withOpacity(0.45),
                      blurRadius: 48,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: LiquidGlass(
                  padding: const EdgeInsets.all(24),
                  child: DecodeText(
                    narrative,
                    intensity: closing ? 1.0 : 0.6,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: c.accentGlyph,
                          height: 1.5,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (closing)
                GlassButton(
                  label: l10n.restartAction,
                  onTap: () {
                    ref.read(progressProvider.notifier).reset();
                    context.go('/');
                  },
                )
              else
                GlassButton(
                  label: l10n.continueAction,
                  color: c.accentSignal,
                  onTap: () => context.go('/node/${result.nextNodeId}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle de silencio discreto (esquina superior). No revela el puzzle.
class _MuteButton extends ConsumerWidget {
  const _MuteButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(soundEnabledProvider);
    final l10n = AppL10n.of(context);
    return IconButton(
      onPressed: () => ref.read(soundEnabledProvider.notifier).toggle(),
      icon: Icon(on ? Icons.volume_up_outlined : Icons.volume_off_outlined),
      iconSize: 18,
      color: context.c.inkDim,
      tooltip: l10n.soundToggle,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}

/// Estado de error con ruta de recuperación (regla `error-recovery`): los
/// fallos de red ofrecen reintentar; los de progreso (nodo bloqueado) no.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    return Center(
      child: LiquidGlass(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: c.accentAlert),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              GlassButton(
                label: l10n.retryAction,
                color: c.accentSignal,
                onTap: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Línea de la voz del sistema (estado de carga).
class _SystemLine extends StatelessWidget {
  final String text;
  const _SystemLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LiquidGlass(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
