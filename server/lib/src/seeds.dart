import 'dart:convert';

import 'package:limen_domain/limen_domain.dart';

/// Definición server-side de un nodo: lo que ve el cliente + la solución.
///
/// La solución NUNCA sale de aquí: para reglas de igualdad se guarda como
/// hash con sal por-nodo; el cliente solo recibe [content].
class NodeSeed {
  final NodeContent content;
  final ValidationRule rule;

  /// Sal por-nodo (reglas de igualdad).
  final String salt;

  /// Hash de la solución normalizada (reglas de igualdad: exact/normalized).
  final String expectedHash;

  /// Patrón o valor en claro (reglas regex / tolerancia numérica).
  final String expectedPlain;

  final String? nextNodeId;
  final String? narrative;

  const NodeSeed({
    required this.content,
    required this.rule,
    this.salt = '',
    this.expectedHash = '',
    this.expectedPlain = '',
    this.nextNodeId,
    this.narrative,
  });
}

/// Construye un seed de regla de igualdad normalizada, hasheando la solución.
NodeSeed _normalizedNode({
  required NodeContent content,
  required String solution,
  required String salt,
  String? nextNodeId,
  String? narrative,
}) =>
    NodeSeed(
      content: content,
      rule: const NormalizedRule(),
      salt: salt,
      expectedHash: hashAnswer(normalizeAnswer(solution), salt),
      nextNodeId: nextNodeId,
      narrative: narrative,
    );

/// El doble-Base64 que se muestra en el nodo 2 se deriva del flag — así el
/// contenido es dato puro y la solución sigue siendo server-side.
String _doubleBase64(String plain) =>
    base64.encode(utf8.encode(base64.encode(utf8.encode(plain))));

/// Catálogo de nodos del Arco 0 (rebanada vertical del demo).
final Map<String, NodeSeed> nodeSeeds = {
  // Nodo 0 — Onboarding "no-instrucción": la bienvenida ES el puzzle.
  // Las iniciales de cada línea deletrean la respuesta: V-I-S-T-O.
  'node0': _normalizedNode(
    content: const NodeContent(
      id: 'node0',
      arco: 0,
      schemaVersion: 1,
      presentation: TextPresentation(
        body: 'Ves esto y crees que es el principio.\n'
            'Igual que los demás, esperas que algo te explique.\n'
            'Suele haber una flecha, un botón, una guía.\n'
            'Tú no la hallarás aquí.\n'
            'Observa otra vez lo que ya leíste.',
      ),
      entry: TextEntry(),
    ),
    solution: 'visto',
    salt: 's0_umbral_9f',
    nextNodeId: 'node1',
    narrative: 'Lo viste. Casi nadie mira dos veces.',
  ),

  // Nodo 1 — César (desplazamiento 3): "xpeudo" -> "umbral".
  'node1': _normalizedNode(
    content: const NodeContent(
      id: 'node1',
      arco: 0,
      schemaVersion: 1,
      presentation: TextPresentation(
        body: 'La señal llegó cifrada.\n\n'
            '    xpeudo\n\n'
            'cada letra avanzó tres pasos.',
      ),
      entry: TextEntry(placeholder: 'descífralo'),
    ),
    solution: 'umbral',
    salt: 's1_cesar_3a',
    nextNodeId: 'node2',
    narrative: 'Cruzaste el umbral. Hay otra capa debajo.',
  ),

  // Nodo 2 — Base64 anidado: decodificar dos veces -> LIMEN{te_veo}.
  'node2': _normalizedNode(
    content: NodeContent(
      id: 'node2',
      arco: 0,
      schemaVersion: 1,
      presentation: TextPresentation(
        body: 'Una capa nunca es una sola.\n\n'
            '    ${_doubleBase64('LIMEN{te_veo}')}\n\n'
            'pélala. Y otra vez.',
      ),
      entry: const TextEntry(placeholder: 'LIMEN{...}'),
    ),
    solution: 'LIMEN{te_veo}',
    salt: 's2_b64_7c',
    nextNodeId: null,
    narrative: 'has sido visto.',
  ),
};

/// Aristas del grafo: [from] resuelto desbloquea [to].
const List<NodeEdge> nodeEdges = [
  NodeEdge('node0', 'node1'),
  NodeEdge('node1', 'node2'),
];

/// Nodo de entrada del arco (sin prerrequisitos).
const String entryNodeId = 'node0';
