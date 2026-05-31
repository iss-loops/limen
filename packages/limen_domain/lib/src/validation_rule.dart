/// Regla con la que el servidor decide si una respuesta es válida.
///
/// El dominio contiene la *lógica*; el valor esperado lo aporta el servidor.
sealed class ValidationRule {
  const ValidationRule();

  Map<String, dynamic> toJson();

  static ValidationRule fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'exact' => const ExactRule(),
        'normalized' => const NormalizedRule(),
        'regex' => RegexRule(json['pattern'] as String),
        'numericTolerance' =>
          NumericToleranceRule((json['tolerance'] as num)),
        final other =>
          throw ArgumentError('ValidationRule desconocida: $other'),
      };
}

/// Igualdad exacta byte a byte (sensible a mayúsculas y espacios).
final class ExactRule extends ValidationRule {
  const ExactRule();
  @override
  Map<String, dynamic> toJson() => {'type': 'exact'};
}

/// Igualdad tras normalización canónica.
final class NormalizedRule extends ValidationRule {
  const NormalizedRule();
  @override
  Map<String, dynamic> toJson() => {'type': 'normalized'};
}

/// La respuesta debe satisfacer el patrón.
final class RegexRule extends ValidationRule {
  final String pattern;
  const RegexRule(this.pattern);
  @override
  Map<String, dynamic> toJson() => {'type': 'regex', 'pattern': pattern};
}

/// La respuesta numérica debe caer dentro de la tolerancia del valor esperado.
final class NumericToleranceRule extends ValidationRule {
  final num tolerance;
  const NumericToleranceRule(this.tolerance);
  @override
  Map<String, dynamic> toJson() =>
      {'type': 'numericTolerance', 'tolerance': tolerance};
}
