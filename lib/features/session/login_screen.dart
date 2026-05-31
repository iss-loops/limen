import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/theme/tokens.dart';
import '../../core/audio/sound_controller.dart';
import '../../core/widgets/block_cursor.dart';
import '../../core/widgets/decode_text.dart';
import '../../core/widgets/liquid_glass.dart';
import 'alias_controller.dart';

/// Gate de alias con estética Liquid Glass (foto + cristal + título cursivo).
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
      body: PhotoBackdrop(
        asset: Backgrounds.spheres,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Wordmark(),
                      const SizedBox(height: 20),
                      LiquidGlass(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DecodeText(
                              l10n.loginPrompt,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 28),
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
                                      onChanged: (_) => ref
                                          .read(soundControllerProvider)
                                          .keystroke(),
                                      onSubmitted: (_) => _enter(),
                                      cursorColor: c.accentSignal,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(color: Colors.white),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        hintText: l10n.aliasHint,
                                        hintStyle: theme.textTheme.bodyLarge
                                            ?.copyWith(color: Colors.white60),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                BlockCursor(color: c.accentSignal),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassButton(label: l10n.enterAction, onTap: _enter),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

