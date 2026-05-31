import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Hash de respuestas para reglas de igualdad almacenadas server-side.
///
/// Demo: SHA-256 con sal por-nodo. En producción → argon2/bcrypt (README §8).
String hashAnswer(String normalizedAnswer, String salt) {
  final bytes = utf8.encode('$salt:$normalizedAnswer');
  return sha256.convert(bytes).toString();
}

/// Comparación en tiempo constante de dos hashes hex.
///
/// No corta al primer byte distinto: recorre toda la longitud para no
/// filtrar información por temporización.
bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
