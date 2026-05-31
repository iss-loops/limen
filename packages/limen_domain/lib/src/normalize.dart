/// Normalización canónica de respuestas.
///
/// Compone los acentos latinos (forma NFC) + recorta + colapsa espacios
/// internos + pasa a minúsculas. El cliente la usa solo para UX; la autoridad
/// de validación es siempre el servidor.
String normalizeAnswer(String raw) {
  final composed = _composeLatinDiacritics(raw);
  return composed.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}

// Combina <letra base> + <marca diacrítica combinante> en su forma
// precompuesta. Cubre los acentos del español (es-ES), suficiente y
// determinista para el alcance del demo. Una librería NFC completa
// (p. ej. `unorm_dart`) sustituiría esto en producción.
const _acute = '́'; // ́  combining acute accent
const _tilde = '̃'; // ̃  combining tilde
const _diaeresis = '̈'; // ̈  combining diaeresis

const _compositions = <String, String>{
  'a$_acute': 'á', 'e$_acute': 'é', 'i$_acute': 'í',
  'o$_acute': 'ó', 'u$_acute': 'ú',
  'A$_acute': 'Á', 'E$_acute': 'É', 'I$_acute': 'Í',
  'O$_acute': 'Ó', 'U$_acute': 'Ú',
  'n$_tilde': 'ñ', 'N$_tilde': 'Ñ',
  'u$_diaeresis': 'ü', 'U$_diaeresis': 'Ü',
};

String _composeLatinDiacritics(String s) {
  if (!s.contains(_acute) && !s.contains(_tilde) && !s.contains(_diaeresis)) {
    return s;
  }
  var out = s;
  _compositions.forEach((from, to) => out = out.replaceAll(from, to));
  return out;
}
