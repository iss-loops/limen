/// Arista dirigida del grafo de nodos: [from] debe resolverse para abrir [to].
class NodeEdge {
  final String from;
  final String to;
  const NodeEdge(this.from, this.to);
}

/// ¿El nodo [nodeId] está desbloqueado dado el conjunto de nodos resueltos?
///
/// Un nodo sin prerrequisitos siempre está desbloqueado; uno con varios
/// requiere que TODOS estén resueltos.
bool isUnlocked(String nodeId, Set<String> solvedIds, List<NodeEdge> edges) =>
    edges
        .where((e) => e.to == nodeId)
        .map((e) => e.from)
        .every(solvedIds.contains);
