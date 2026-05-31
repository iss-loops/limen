import 'dart:math';

import 'package:flutter/material.dart';

/// Firma visual de LIMEN: el texto aparece como descifrándose — caracteres
/// aleatorios que se asientan en el correcto, de izquierda a derecha.
///
/// - **Reduce motion:** degrada a un fade simple (obligatorio, §9).
/// - **Rendimiento:** solo revuelve una *ventana* cerca del frente de revelado,
///   no todos los caracteres a la vez (presupuesto 60 fps, §3).
/// - **Accesibilidad:** expone el texto final a lectores de pantalla, nunca el
///   ruido intermedio.
class DecodeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// 0 = The xx (rápido, seco). 1 = Tame Impala (lento, con estela).
  final double intensity;

  final String semanticsLabel;

  const DecodeText(
    this.text, {
    super.key,
    this.style,
    this.intensity = 0,
    this.semanticsLabel = '',
  });

  @override
  State<DecodeText> createState() => _DecodeTextState();
}

class _DecodeTextState extends State<DecodeText>
    with SingleTickerProviderStateMixin {
  static const _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#%&@/\\<>{}=+*';
  static const _windowSize = 10;

  late final AnimationController _controller;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    // Más intensidad (glyph) ⇒ se asienta más lento, con rastro.
    final base = 28 * widget.text.length;
    final ms = (base * (1 + widget.intensity)).clamp(450, 4000).toInt();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();
  }

  @override
  void didUpdateWidget(DecodeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _scrambleChar() => _alphabet[_rng.nextInt(_alphabet.length)];

  String _frameText(double progress) {
    final chars = widget.text.runes.toList();
    final revealed = (progress * chars.length).floor();
    final buffer = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      final original = String.fromCharCode(chars[i]);
      if (i < revealed || original.trim().isEmpty) {
        buffer.write(original);
      } else if (i < revealed + _windowSize) {
        buffer.write(_scrambleChar());
      } else {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.semanticsLabel.isEmpty ? widget.text : widget.semanticsLabel;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Widget visual;
    if (reduceMotion) {
      visual = _FadeIn(
        duration: const Duration(milliseconds: 400),
        child: Text(widget.text, style: widget.style),
      );
    } else {
      visual = AnimatedBuilder(
        animation: _controller,
        builder: (context, _) =>
            Text(_frameText(_controller.value), style: widget.style),
      );
    }

    return Semantics(
      label: label,
      child: ExcludeSemantics(child: visual),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _FadeIn({required this.child, required this.duration});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: _opacity,
        duration: widget.duration,
        child: widget.child,
      );
}
