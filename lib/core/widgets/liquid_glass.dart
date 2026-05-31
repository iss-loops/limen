import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Kit "Liquid Glass" (glassmorphism) — traducción a Flutter de la guía
/// LIQUID_GLASS_GUIDE.md: fondos fotográficos con overlay + paneles/botones de
/// cristal (transparencia + borde brillante + esquinas 16dp + blur).

/// Fondo fotográfico a pantalla completa con overlay legible (guía §4):
/// foto a cover + capa negra 10% + degradado vertical (20% arriba →
/// transparente → 50% abajo) que enmarca el contenido sin opacar la foto.
class PhotoBackdrop extends StatelessWidget {
  final String asset;
  final Widget child;

  const PhotoBackdrop({super.key, required this.asset, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        const ColoredBox(color: Color(0x1A000000)), // negro 10%
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x33000000), Color(0x00000000), Color(0x80000000)],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Panel de cristal: blur del fondo + relleno translúcido + borde brillante +
/// esquinas 16dp. [dark] usa la variante Dark Glass de la guía.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool dark;
  final VoidCallback? onTap;

  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.dark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fill = dark ? const Color(0x80000000) : const Color(0x59FFFFFF);
    final border = dark ? const Color(0x33FFFFFF) : const Color(0x80FFFFFF);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: border, width: 1.5),
    );

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: ShapeDecoration(color: fill, shape: shape),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

/// Botón de cristal (mono, centrado), un solo CTA. [accent] tiñe el texto.
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  const GlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: LiquidGlass(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            height: 24,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Título-firma cursivo (estética Liquid Glass, guía §2A).
class Wordmark extends StatelessWidget {
  final double size;
  const Wordmark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Text(
      'LIMEN',
      style: TextStyle(
        fontFamily: kCursiveFamily,
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 1,
        shadows: const [Shadow(color: Color(0xAA000000), blurRadius: 18)],
      ),
    );
  }
}
