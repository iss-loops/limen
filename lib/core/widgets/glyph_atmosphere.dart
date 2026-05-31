import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Atmósfera "Tame Impala" para los momentos glyph: glow violeta, viñeta,
/// scanlines y grano analógico, modulados por [intensity] (0 = The xx, sin
/// efecto; 1 = profundidad psicodélica plena).
///
/// `reduce motion` (§9): el polo glyph se expresa solo con color/profundidad
/// (glow + viñeta + grano estático), sin el shimmer animado.
class GlyphAtmosphere extends StatefulWidget {
  final double intensity;
  final Widget child;

  const GlyphAtmosphere({
    super.key,
    required this.intensity,
    required this.child,
  });

  @override
  State<GlyphAtmosphere> createState() => _GlyphAtmosphereState();
}

class _GlyphAtmosphereState extends State<GlyphAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intensity = widget.intensity.clamp(0.0, 1.0);
    if (intensity <= 0) return widget.child;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final glyph = context.c.accentGlyph;

    final overlay = reduceMotion
        ? CustomPaint(
            painter: _GlyphPainter(intensity: intensity, frame: 0, glyph: glyph),
          )
        : AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _GlyphPainter(
                intensity: intensity,
                frame: _controller.value,
                glyph: glyph,
              ),
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: glyph.withOpacity(0.05 * intensity)),
        widget.child,
        Positioned.fill(child: IgnorePointer(child: overlay)),
      ],
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final double intensity;
  final double frame;
  final Color glyph;

  _GlyphPainter({
    required this.intensity,
    required this.frame,
    required this.glyph,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Glow violeta que respira desde el centro.
    final glow = Paint()
      ..shader = RadialGradient(
        radius: 0.9,
        colors: [glyph.withOpacity(0.16 * intensity), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, glow);

    // Viñeta: bordes que se hunden en la oscuridad.
    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 1.05,
        stops: const [0.55, 1.0],
        colors: [Colors.transparent, Colors.black.withOpacity(0.5 * intensity)],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);

    // Scanlines tenues (máquina vieja que sueña).
    final line = Paint()..color = Colors.black.withOpacity(0.16 * intensity);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }

    // Grano: shimmer si anima; estático (semilla fija) en reduce motion.
    final rng = Random((frame * 100000).floor() + 7);
    final count = ((size.width * size.height) / 2600).clamp(0, 360).toInt();
    final dot = Paint();
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final base = rng.nextBool() ? glyph : Colors.white;
      dot.color = base.withOpacity(0.06 * intensity * rng.nextDouble());
      canvas.drawRect(Rect.fromLTWH(dx, dy, 1.2, 1.2), dot);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.frame != frame || old.intensity != intensity;
}
