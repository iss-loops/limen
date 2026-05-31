import 'package:flutter/material.dart';

/// Design tokens de LIMEN (§3 del README) expuestos como [ThemeExtension].
///
/// Contrastes corregidos a WCAG AA: el color de marca cede ante la legibilidad.
@immutable
class LimenColors extends ThemeExtension<LimenColors> {
  /// Fondo base.
  final Color bgVoid;

  /// Superficies elevadas.
  final Color bgPanel;

  /// Texto principal (~14:1 sobre void).
  final Color inkPrimary;

  /// Texto secundario / pistas tenues (~7:1, subido para no fallar AA).
  final Color inkDim;

  /// Verde fósforo: terminal, éxito, flag correcta.
  final Color accentSignal;

  /// Rojo: error, fallo.
  final Color accentAlert;

  /// Violeta: narrativa/ARG, lo "no humano".
  final Color accentGlyph;

  const LimenColors({
    required this.bgVoid,
    required this.bgPanel,
    required this.inkPrimary,
    required this.inkDim,
    required this.accentSignal,
    required this.accentAlert,
    required this.accentGlyph,
  });

  static const dark = LimenColors(
    bgVoid: Color(0xFF0A0A0C),
    bgPanel: Color(0xFF121317),
    inkPrimary: Color(0xFFE6E6E6),
    inkDim: Color(0xFF9A9AA2),
    accentSignal: Color(0xFF3DF5A8),
    accentAlert: Color(0xFFFF6B6B),
    accentGlyph: Color(0xFF9B82FF),
  );

  @override
  LimenColors copyWith({
    Color? bgVoid,
    Color? bgPanel,
    Color? inkPrimary,
    Color? inkDim,
    Color? accentSignal,
    Color? accentAlert,
    Color? accentGlyph,
  }) =>
      LimenColors(
        bgVoid: bgVoid ?? this.bgVoid,
        bgPanel: bgPanel ?? this.bgPanel,
        inkPrimary: inkPrimary ?? this.inkPrimary,
        inkDim: inkDim ?? this.inkDim,
        accentSignal: accentSignal ?? this.accentSignal,
        accentAlert: accentAlert ?? this.accentAlert,
        accentGlyph: accentGlyph ?? this.accentGlyph,
      );

  @override
  LimenColors lerp(ThemeExtension<LimenColors>? other, double t) {
    if (other is! LimenColors) return this;
    return LimenColors(
      bgVoid: Color.lerp(bgVoid, other.bgVoid, t)!,
      bgPanel: Color.lerp(bgPanel, other.bgPanel, t)!,
      inkPrimary: Color.lerp(inkPrimary, other.inkPrimary, t)!,
      inkDim: Color.lerp(inkDim, other.inkDim, t)!,
      accentSignal: Color.lerp(accentSignal, other.accentSignal, t)!,
      accentAlert: Color.lerp(accentAlert, other.accentAlert, t)!,
      accentGlyph: Color.lerp(accentGlyph, other.accentGlyph, t)!,
    );
  }
}

/// Acceso ergonómico a los tokens desde el contexto.
extension LimenThemeX on BuildContext {
  LimenColors get c => Theme.of(this).extension<LimenColors>()!;
}

/// Familia mono empaquetada (offline; sin google_fonts en runtime).
const String kMonoFamily = 'JetBrainsMono';

/// Halo fósforo sutil para el acento de terminal — efecto clave del design
/// system ("minimal glow, text-shadow 0 0 10px"). Estático: válido también con
/// reduce motion (color/profundidad sin movimiento).
List<Shadow> phosphorGlow(Color color, {double blur = 10}) =>
    [Shadow(color: color.withOpacity(0.55), blurRadius: blur)];
