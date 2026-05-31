import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tema oscuro de LIMEN: monoespaciado protagonista, un acento por pantalla.
ThemeData buildLimenTheme() {
  const colors = LimenColors.dark;

  final textTheme = const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, height: 1.6, letterSpacing: 0.2),
    bodyMedium: TextStyle(fontSize: 14, height: 1.6, letterSpacing: 0.2),
    titleMedium: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w500),
    labelLarge: TextStyle(fontSize: 14, letterSpacing: 1.5),
  ).apply(
    fontFamily: kMonoFamily,
    bodyColor: colors.inkPrimary,
    displayColor: colors.inkPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.bgVoid,
    fontFamily: kMonoFamily,
    colorScheme: ColorScheme.dark(
      surface: colors.bgVoid,
      primary: colors.accentSignal,
      secondary: colors.accentGlyph,
      error: colors.accentAlert,
      onSurface: colors.inkPrimary,
    ),
    textTheme: textTheme,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.accentSignal,
      selectionColor: const Color(0x333DF5A8),
      selectionHandleColor: colors.accentSignal,
    ),
    // Anillo de foco visible solo con teclado (a11y focus-states); no afecta el
    // look táctil.
    focusColor: colors.accentSignal.withOpacity(0.18),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? BorderSide(color: colors.accentSignal, width: 2)
              : null,
        ),
      ),
    ),
    extensions: const [colors],
  );
}
