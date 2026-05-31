/// Cómo se presenta un nodo. Unión sellada: el render hace pattern matching.
sealed class NodePresentation {
  const NodePresentation();
  Map<String, dynamic> toJson();

  static NodePresentation fromJson(Map<String, dynamic> json) =>
      switch (json['kind']) {
        'text' => TextPresentation(
            body: json['body'] as String,
            glyph: json['glyph'] as bool? ?? false,
            intensity: (json['intensity'] as num? ?? 0).toDouble(),
          ),
        final other =>
          throw ArgumentError('NodePresentation desconocida: $other'),
      };
}

/// Presentación de texto (terminal). [glyph] activa el polo Tame Impala;
/// [intensity] (0 = The xx, 1 = Tame Impala) modula glow/grano/velocidad.
final class TextPresentation extends NodePresentation {
  final String body;
  final bool glyph;
  final double intensity;
  const TextPresentation({
    required this.body,
    this.glyph = false,
    this.intensity = 0,
  });
  @override
  Map<String, dynamic> toJson() => {
        'kind': 'text',
        'body': body,
        'glyph': glyph,
        'intensity': intensity,
      };
}

/// Cómo responde el usuario. Unión sellada.
sealed class NodeEntry {
  const NodeEntry();
  Map<String, dynamic> toJson();

  static NodeEntry fromJson(Map<String, dynamic> json) =>
      switch (json['kind']) {
        'text' => TextEntry(placeholder: json['placeholder'] as String?),
        'numeric' => NumericEntry(placeholder: json['placeholder'] as String?),
        final other => throw ArgumentError('NodeEntry desconocida: $other'),
      };
}

/// Entrada de texto libre.
final class TextEntry extends NodeEntry {
  final String? placeholder;
  const TextEntry({this.placeholder});
  @override
  Map<String, dynamic> toJson() => {'kind': 'text', 'placeholder': placeholder};
}

/// Entrada numérica.
final class NumericEntry extends NodeEntry {
  final String? placeholder;
  const NumericEntry({this.placeholder});
  @override
  Map<String, dynamic> toJson() =>
      {'kind': 'numeric', 'placeholder': placeholder};
}

/// Contenido de un nodo tal como lo ve el cliente. **Nunca** la solución.
class NodeContent {
  final String id;
  final int arco;
  final int schemaVersion;
  final NodePresentation presentation;
  final NodeEntry entry;

  const NodeContent({
    required this.id,
    required this.arco,
    required this.schemaVersion,
    required this.presentation,
    required this.entry,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'arco': arco,
        'schemaVersion': schemaVersion,
        'presentation': presentation.toJson(),
        'entry': entry.toJson(),
      };

  static NodeContent fromJson(Map<String, dynamic> json) => NodeContent(
        id: json['id'] as String,
        arco: json['arco'] as int,
        schemaVersion: json['schemaVersion'] as int,
        presentation: NodePresentation.fromJson(
            (json['presentation'] as Map).cast<String, dynamic>()),
        entry: NodeEntry.fromJson((json['entry'] as Map).cast<String, dynamic>()),
      );
}
