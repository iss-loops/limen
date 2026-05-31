import 'dart:convert';

import 'package:limen_domain/limen_domain.dart';

/// ⚠️ MODO DEMO OFFLINE — INSEGURO POR DISEÑO.
///
/// Estos nodos incluyen su solución en el cliente para que la app abra sin
/// backend. Esto ROMPE el principio server-authority del README (§8): un APK
/// es descompilable, así que cualquiera podría extraer las respuestas.
/// Es un atajo de exhibición; el modo producción usa el servidor real, donde
/// las soluciones nunca salen del backend. Mismo contenido que `server/`.
class LocalSeed {
  final NodeContent content;
  final String solution;
  final String? nextNodeId;
  final String? narrative;
  const LocalSeed({
    required this.content,
    required this.solution,
    this.nextNodeId,
    this.narrative,
  });
}

String _doubleBase64(String plain) =>
    base64.encode(utf8.encode(base64.encode(utf8.encode(plain))));

final Map<String, LocalSeed> localNodeSeeds = {
  'node0': const LocalSeed(
    content: NodeContent(
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
    nextNodeId: 'node1',
    narrative: 'Lo viste. Casi nadie mira dos veces.',
  ),
  'node1': const LocalSeed(
    content: NodeContent(
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
    nextNodeId: 'node2',
    narrative: 'Cruzaste el umbral. Hay otra capa debajo.',
  ),
  'node2': LocalSeed(
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
    nextNodeId: null,
    narrative: 'has sido visto.',
  ),
};

const List<NodeEdge> localEdges = [
  NodeEdge('node0', 'node1'),
  NodeEdge('node1', 'node2'),
];
