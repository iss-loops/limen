import 'normalize.dart';
import 'validation_rule.dart';

/// Decide si [answer] satisface [rule] contra [expected]. Función pura.
///
/// El servidor pasa la respuesta del usuario y el valor esperado del seed.
/// El dominio nunca almacena [expected].
bool validate(ValidationRule rule, String answer, String expected) =>
    switch (rule) {
      ExactRule() => answer == expected,
      NormalizedRule() => normalizeAnswer(answer) == normalizeAnswer(expected),
      RegexRule(:final pattern) => RegExp(pattern).hasMatch(answer),
      NumericToleranceRule(:final tolerance) =>
        _withinTolerance(answer, expected, tolerance),
    };

bool _withinTolerance(String answer, String expected, num tolerance) {
  final a = num.tryParse(answer.trim());
  final e = num.tryParse(expected.trim());
  if (a == null || e == null) return false;
  return (a - e).abs() <= tolerance;
}
