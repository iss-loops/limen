import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:limen_domain/limen_domain.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/audio/sound_controller.dart';
import '../../../core/widgets/block_cursor.dart';
import '../../../core/widgets/decode_text.dart';
import '../../../core/widgets/glyph_atmosphere.dart';
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

    // La atmósfera glyph sube en el reveal y llega a su pico en el cierre.
    final submission = ref.watch(submitProvider(widget.nodeId));
    final ambient = (submission is SubmissionDone && submission.result.correct)
        ? (submission.result.nextNodeId == null ? 1.0 : 0.55)
        : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: GlyphAtmosphere(
          intensity: ambient,
          child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: nodeAsync.when(
                loading: () => _SystemLine(l10n.loading),
                error: (err, _) => _SystemLine(
                  err is NodeException && err.code == ApiErrorCode.nodeLocked
                      ? l10n.nodeLocked
                      : l10n.networkDown,
                  isError: true,
                ),
                data: (node) => _content(node, l10n),
              ),
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
    );
  }

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
            Text('LIMEN',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: c.inkDim)),
            const SizedBox(height: 32),
          ] else
            const SizedBox(height: 8),
          DecodeText(
            body,
            intensity: intensity,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: accent),
          ),
          const SizedBox(height: 36),
          _InputRow(
            controller: controller,
            focus: focus,
            entry: entry,
            enabled: submission is! SubmissionSending,
            onSubmit: onSubmit,
            onKeystroke: onKeystroke,
          ),
          const SizedBox(height: 16),
          _Feedback(submission: submission),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: submission is SubmissionSending ? null : onSubmit,
              style: TextButton.styleFrom(
                foregroundColor: c.accentSignal,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Text(l10n.submitAction),
            ),
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
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: c.accentSignal)),
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

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: c.accentGlyph.withOpacity(0.35),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: DecodeText(
              narrative,
              intensity: closing ? 1.0 : 0.6,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: c.accentGlyph,
                    height: 1.5,
                  ),
            ),
          ),
          const SizedBox(height: 40),
          if (closing)
            TextButton(
              onPressed: () {
                ref.read(progressProvider.notifier).reset();
                context.go('/');
              },
              style: TextButton.styleFrom(
                foregroundColor: c.inkDim,
                minimumSize: const Size(48, 48),
              ),
              child: Text(l10n.restartAction),
            )
          else
            TextButton(
              onPressed: () => context.go('/node/${result.nextNodeId}'),
              style: TextButton.styleFrom(
                foregroundColor: c.accentSignal,
                minimumSize: const Size(48, 48),
              ),
              child: Text(l10n.continueAction),
            ),
        ],
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

class _SystemLine extends StatelessWidget {
  final String text;
  final bool isError;
  const _SystemLine(this.text, {this.isError = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: isError ? c.accentAlert : c.inkDim),
      ),
    );
  }
}
