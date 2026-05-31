/// Nodo de entrada del Arco 0 (la bienvenida que ES el primer puzzle).
///
/// Estructura del grafo, no secreto: el cliente puede saber cuál es la puerta.
/// Las soluciones y el contenido de los nodos siguen siendo server-side.
const String kEntryNodeId = 'node0';

/// Número de nodos del Arco 0 (para el indicador de progreso). Estructural,
/// no secreto: solo dice cuántas puertas hay, no qué hay tras ellas.
const int kArcLength = 3;

/// IDs de los nodos del Arco 0, en orden (para el mapa del arco). Estructura
/// del grafo, no contenido: el cliente sabe cuántas puertas hay y su orden,
/// nunca qué hay tras ellas ni las soluciones.
const List<String> kArcNodeIds = ['node0', 'node1', 'node2'];
