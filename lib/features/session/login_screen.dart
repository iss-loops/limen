import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/widgets/block_cursor.dart';
import '../../core/widgets/decode_text.dart';
import '../../core/widgets/pressable_scale.dart';
import 'alias_controller.dart';

/// Gate de alias: la persona se nombra antes de cruzar. Identidad temática,
/// no autenticación (el modelo de sesión sigue siendo anónimo).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _alias = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _alias.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _enter() async {
    final text = _alias.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    await ref.read(aliasProvider.notifier).setAlias(text);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecodeText(
                      l10n.loginPrompt,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: c.inkPrimary),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        Text('> ',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: c.accentSignal,
                              shadows: phosphorGlow(c.accentSignal),
                            )),
                        Expanded(
                          child: Semantics(
                            label: l10n.aliasFieldLabel,
                            textField: true,
                            child: TextField(
                              controller: _alias,
                              focusNode: _focus,
                              autofocus: true,
                              textInputAction: TextInputAction.go,
                              textCapitalization: TextCapitalization.none,
                              onChanged: (_) =>
                                  ref.read(soundControllerProvider).keystroke(),
                              onSubmitted: (_) => _enter(),
                              cursorColor: c.accentSignal,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(color: c.inkPrimary),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: l10n.aliasHint,
                                hintStyle: theme.textTheme.bodyLarge
                                    ?.copyWith(color: c.inkDim),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        BlockCursor(color: c.accentSignal),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PressableScale(
                        child: TextButton(
                          onPressed: _enter,
                          style: TextButton.styleFrom(
                            foregroundColor: c.accentSignal,
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: Text(
                            l10n.enterAction,
                            style:
                                TextStyle(shadows: phosphorGlow(c.accentSignal)),
                          ),
                        ),
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
