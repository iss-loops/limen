# 🜂 LIMEN

> *"El umbral no es la puerta. Es darte cuenta de que hay una puerta."*

App móvil **Flutter** de criptopuzzles progresivos con capa ARG y resolución colaborativa.
**Gratuita. Sin anuncios. Sin compras.** Proyecto personal / portafolio.

Este documento es la **guía de trabajo para Claude Code**. Léelo completo antes de escribir una sola línea. Se construye **bloque por bloque**; no avances al siguiente bloque hasta cerrar el entregable del actual.

> **Nota de identidad:** el producto se llama **LIMEN**. El paquete Flutter del repo ya existe como `iss` (ver `pubspec.yaml`). No hace falta `flutter create`: se trabaja sobre este repo. Renombrar el paquete es una decisión abierta de bajo valor (ver §13); por defecto se mantiene `iss` como nombre interno y *LIMEN* como nombre de producto.

---

## 0. Cómo trabajar en este repo (reglas para el agente)

Estas reglas son obligatorias y tienen prioridad sobre cualquier inercia de "hacerlo rápido".

1. **Un bloque a la vez.** El roadmap (§11) está dividido en bloques. Cada bloque cierra con un entregable verificable y su *Definition of Done*. No empieces el siguiente sin que el actual funcione y esté probado.
2. **Pregunta antes de asumir.** Si una decisión de diseño o arquitectura no está resuelta aquí (ver §13, decisiones abiertas), **detente y pregunta**. No inventes alcance.
3. **TDD donde haya lógica.** El dominio (motor de puzzles, validación, desbloqueo, grafo) se escribe con tests primero. La UI puede ir después, pero la lógica de negocio nace probada. El backend también: cada endpoint con su test (Pest/PHPUnit).
4. **Sin comentarios de relleno.** El código se explica solo con nombres claros. Comenta únicamente lo no obvio (un porqué, no un qué).
5. **Inmutabilidad y tipos sellados.** Nada de modelos mutables ni `copyWith` a mano. Nada de `if/else` gigantes para discriminar tipos: usa uniones selladas y *pattern matching*.
6. **No repetir paradigmas viejos.** Prohibido `setState` esparcido para estado de negocio, `Provider` clásico, o lógica en los widgets. Ver §6.
7. **Server-side authority es ley.** Ninguna solución, ningún nodo futuro y ninguna pista vive en el cliente hasta que el servidor la autoriza. Ver §4 y §8. Si dudas si algo va en cliente o servidor, **va en el servidor**.
8. **Contenido como dato, desde el principio.** Ningún nodo se hardcodea en Dart más allá del primer espasmo de prueba (Bloque 0). Los nodos viven como datos (seed/fixtures → BD) con un esquema versionado. Ver §4.
9. **Accesibilidad e i18n no son del final.** Respeta `reduce motion`, contraste mínimo y `Semantics` desde que existe el widget. Todo copy pasa por la capa de i18n desde el Bloque 1. Ver §9.
10. **Commits pequeños y descriptivos**, uno por unidad lógica de trabajo. Lint y análisis estático en verde antes de cada commit.

---

## 1. Qué es LIMEN

No es "una app de acertijos". Es una **madriguera de conejo de bolsillo** que no le dice al usuario que es un juego: le entrega un primer enigma disfrazado de pantalla de bienvenida y desde ahí desciende por capas de criptografía, esteganografía y narrativa que cruzan al mundo físico, mientras una comunidad invisible resuelve a su lado.

El producto vende la sensación de haber sido **elegido** y la dignidad de sentirse inteligente. Todo el código existe para proteger y amplificar ese instante de *aha*.

### Definición de éxito
> Un usuario nuevo abre la app sin instrucciones, descubre por su cuenta que el primer puzzle existe, lo resuelve, y siente urgencia por abrir el segundo.

Esta definición es **medible** (ver §10): el embudo onboarding → primer descubrimiento → primera flag → apertura del segundo nodo es la métrica norte.

### Reglas de oro del producto
1. La primera prueba real es **darse cuenta de que hay un puzzle**.
2. Toda respuesta es **binaria y verificable** (un número, una flag, una contraseña, coordenadas). Nada interpretativo.
3. El misterio del autor **nunca se resuelve**.
4. **Cero tutoriales, cero condescendencia.** El reconocimiento es el acceso al siguiente nivel.

---

## 2. Narrativa (contexto para tono y copy)

Existe una entidad sin rostro —un colectivo, una IA, una conciencia distribuida— que observa **quién está listo para cruzar el umbral**. No recluta por currículum, sino por capacidad de ver lo que otros pasan por alto. LIMEN es su mensajero.

- **Voz del sistema:** segunda persona, presente, parca. Nunca explica de más.
- **Ambigüedad deliberada del autor:** ¿juego? ¿experimento? ¿alguien real observa? Nunca se confirma.

### Arcos (estructura de contenido)
- **Arco 0 — "La Señal"**: enseña el lenguaje del juego. Esteganografía simple, César, un QR. Termina con: *has sido visto*.
- **Arco I — "El Descenso"**: Vigenère, metadatos, OSINT ligero. Primer salto físico opcional.
- **Arco II — "Las Voces"**: espectrogramas de audio, PGP, coordenadas, primer puzzle colaborativo obligatorio.
- **Arco III — "El Umbral"**: cripto moderna ligera, metapuzzle que une arcos previos. Final abierto.
- **Capa irresoluta**: siempre queda un nodo sin solución pública. Es el imán de leyenda; nunca se valida públicamente.

---

## 3. Sistema estético (design tokens)

Oscuridad casi total. Monoespaciado como protagonista. Glitch como puntuación, no como fondo. Un solo acento por pantalla.

### Paleta

| Token | Hex | Uso | Contraste sobre `bg.void` |
|---|---|---|---|
| `bg.void` | `#0A0A0C` | Fondo base | — |
| `bg.panel` | `#121317` | Superficies elevadas | — |
| `ink.primary` | `#E6E6E6` | Texto principal | ~14:1 ✅ |
| `ink.dim` | `#9A9AA2` | Texto secundario, pistas tenues | ~7:1 ✅ (subido desde `#6B6B72`, que daba ~3.5:1 y **fallaba** WCAG AA) |
| `accent.signal` | `#3DF5A8` | Verde fósforo: éxito, terminal, flag correcta | ✅ |
| `accent.alert` | `#FF6B6B` | Error, fallo (subido de `#FF4D4D` para AA) | ✅ |
| `accent.glyph` | `#9B82FF` | Violeta: narrativa/ARG, lo "no humano" (subido de `#7A5CFF`) | ✅ |

Regla: verde para terminal/solución, violeta para momentos narrativos, rojo solo cuando algo se rompe.
**Requisito:** todo texto cumple WCAG AA (≥4.5:1 cuerpo, ≥3:1 texto grande). El color de marca cede ante la legibilidad, no al revés.

### Tipografía
- **Mono primaria** (cuerpo, entradas, voz del sistema): JetBrains Mono o IBM Plex Mono. *(elección a confirmar — §13)*
- **Serif ritual** (solo fragmentos narrativos de la entidad): EB Garamond o similar.
- Máximo dos familias. Fuentes empaquetadas como assets (no `google_fonts` en runtime, para funcionar offline).

### Movimiento y sonido
- **Decode reveal** (firma del producto): el texto aparece como descifrándose — caracteres aleatorios que se asientan en el correcto. Es **un solo widget reutilizable**, configurable (duración, alfabeto, velocidad).
  - **Presupuesto de rendimiento:** 60 fps en gama media; para textos largos, anima por *ventana* (no todos los caracteres a la vez).
  - **`reduce motion`:** si el sistema lo pide, el efecto se degrada a un fade simple. Obligatorio.
- **Cursor de bloque** parpadeante.
- Transiciones por desvanecido lento, ceremoniales. Nunca slides alegres.
- Sonido: clicks mecánicos al teclear; drone grave que sube de tono cerca de una solución (señal sutil); acorde de revelación en cada flag correcta. Todo sonido respeta el silenciador del sistema y un toggle propio.

### Referentes estéticos (underground)

La identidad vive en la tensión entre dos polos. Ninguna pantalla es solo uno: el **default** es The xx; lo **glyph** (narrativa/ARG) abre hacia Tame Impala.

**The xx — el vacío íntimo (modo por defecto, ~80% de la app)**
Define la mayoría de las pantallas: terminal, entrada, voz del sistema.
- **Vacío como lujo.** Negativo agresivo: una sola idea por pantalla, rodeada de oscuridad. Si dudas, quita.
- **Monocromo + una marca.** Casi todo en `ink.primary`/`ink.dim` sobre `bg.void`; el acento (`accent.signal`) aparece una vez, como la "X": un solo gesto cargado, nunca decoración repartida.
- **Intimidad, no espectáculo.** Tipografía mono a cuerpo cómodo, mucho interlineado, ritmo lento. El usuario susurra con la máquina, no le gritan.
- **Silencio sonoro.** Mayoría del tiempo, casi nada: respiración de fondo, un click. El silencio hace que el acorde de revelación pese.

**Tame Impala — la profundidad psicodélica (modo glyph, momentos narrativos)**
Reservado para cuando habla la entidad, transiciones de arco y la capa irresoluta. Es el premio, no el fondo.
- **Profundidad y glow.** `accent.glyph` (violeta) con halo/bloom suave, gradientes lentos que respiran; sensación de mirar *dentro* de algo, no a una superficie plana.
- **Retro-futuro analógico.** Grano sutil, leve aberración cromática, scanlines tenues: textura "de máquina vieja que sueña", no glitch agresivo.
- **Reverberación temporal.** El movimiento se siente con *delay* y eco: el decode reveal en modo glyph se asienta más lento, con rastro; las transiciones dejan estela.
- **Drone envolvente.** El drone grave se vuelve cavernoso y reverberante cerca de la solución o cuando la entidad observa.

**Cómo conviven (regla operativa):** el peso visual y sonoro es The xx; Tame Impala es un *crescendo* puntual. Cuanto más cerca del *aha* o de lo "no humano", más se inclina la pantalla hacia el polo psicodélico — y vuelve al vacío después. Esta inclinación es un parámetro continuo, no dos temas separados: un único `intensity` (0 = xx, 1 = impala) que modula glow, grano, velocidad de decode y reverb del drone. Todo respeta `reduce motion` (§9): en ese modo el polo Tame Impala se expresa solo con color/profundidad, sin movimiento.

---

## 4. El motor de puzzles (el corazón)

Diseñado para que **agregar un puzzle nuevo no requiera tocar código de la app** — solo datos en el backend. Esto es lo que evita una pantalla nueva por cada acertijo.

### Modelo de dominio
Un puzzle es un **nodo** (vértice de un grafo dirigido). Cada nodo declara:

- `id`, `arco`, `schemaVersion`.
- `presentación`: cómo se muestra (texto, imagen, audio/espectrograma, mapa, web externa, mixto).
- `payload`: contenido visible (la imagen con esteganografía, el cifrado, el audio) — entregado vía URL firmada cuando es un asset pesado (§7).
- `entrada`: cómo responde el usuario (texto libre, coordenadas, escaneo QR, selección).
- `condición de desbloqueo`: qué nodos previos hay que resolver para verlo.
- `pistas` escalonadas, con costo.
- **NUNCA la solución.** Vive solo en el servidor.

El nodo se modela como **unión sellada** (`freezed`): cada tipo de presentación/entrada es una variante. El render y la validación seleccionan por *pattern matching*, no por cadenas de `if`.

### Contenido como dato (pipeline desde el día 1)
Los nodos no se hardcodean. Existen como **seeds** versionados (un archivo por nodo, YAML/JSON con esquema validado) que se cargan a la BD. El panel de autoría web (Bloque 5) es solo una UI sobre este mismo esquema; el formato existe mucho antes que el panel. Editar un nodo ya resuelto **no rompe el progreso**: las soluciones son inmutables por `schemaVersion`; un cambio incompatible crea una versión nueva.

### Catálogo de tipos de reto (extensible)
1. Cifrados clásicos (César, Vigenère, sustitución).
2. Cifrados modernos ligeros (Base64/32 anidado, XOR, RSA didáctico con números pequeños).
3. Esteganografía en imagen (LSB, canal alfa, EXIF).
4. Esteganografía en audio (mensaje en espectrograma → visor de espectro).
5. OSINT (la pista lleva a una fuente pública **sembrada por ti**, nunca a datos de terceros reales).
6. Geolocalización / ARG físico (coordenadas, QR real).
7. Forense de archivo (archivo descargable con datos ocultos en su estructura).
8. Metapuzzle (combina respuestas de varios nodos resueltos).

### Formato de flag
- Formato canónico: `LIMEN{...}` para retos que entregan flag explícita.
- Otros tipos tienen forma propia declarada por el nodo: número entero, coordenadas `lat,lng`, contraseña.
- El nodo declara su **regla de validación** (ver abajo): match exacto, normalizado, con tolerancia numérica, o regex.
- **Entropía mínima:** ninguna respuesta válida con menos de ~28 bits de espacio efectivo (no se valida "5"). El seed se rechaza en validación si la respuesta es trivialmente adivinable.

### Flujo de validación (crítico — server-side real)

> ⚠️ **Cambio respecto a borradores previos:** *no* se hashea en el cliente. Hashear en el cliente y comparar hash-contra-hash convierte al hash en el secreto (equivale a mandar texto plano) y, con respuestas de baja entropía, es fuerza-bruteable offline. Además impide validación difusa (tolerancia/regex). **El servidor es la única autoridad.**

```
Usuario ingresa respuesta
  → cliente normaliza SOLO para UX (trim, mostrar formato), NO para seguridad
  → cliente envía la respuesta normalizada al servidor sobre TLS (HTTPS obligatorio + cert pinning)
  → servidor:
       · normaliza canónicamente (case, espacios, unicode NFC, formato flag)
       · aplica la regla del nodo:
           - exacto / normalizado     → comparación en tiempo constante
           - tolerancia numérica/geo  → distancia ≤ umbral
           - regex                    → match server-side
       · para reglas de igualdad almacena hash lento con sal por-nodo (argon2/bcrypt),
         no texto plano ni SHA simple
       · registra el intento (anti-fuerza bruta, §8)
  → servidor responde { correcto, siguiente_nodo?, mensaje_narrativo?, estado? }
       · estado = "pendiente" para validaciones asíncronas (PGP, fuente externa) vía n8n
  → cliente reproduce decode reveal + acorde + desbloqueo (o estado de espera narrativo)
```

### Pistas
- Escalonadas: de empujón temático a casi-solución.
- **Se ganan, no se compran** (proyecto gratis): fichas obtenidas al resolver nodos, o desbloqueo por tiempo de espera.
- La entrega de pistas también es **server-side** (el cliente nunca tiene la pista N+1 antes de ganarla).

### Comportamiento offline
- Los payloads ya entregados se **cachean** (lectura del nodo actual funciona sin red).
- El **submit siempre requiere red** (autoridad en servidor). Sin conexión: cola local de un intento + mensaje en voz del sistema ("la señal no llega"), reintento al recuperar red.
- Nada sensible (soluciones, nodos futuros) se persiste en el cliente.

---

## 5. Arquitectura Flutter

**Feature-first + Clean.** Cada feature es un módulo autocontenido. Regla de dependencias: `presentation → domain ← data`. El dominio no conoce Flutter ni Dio.

```
lib/
├── main.dart
├── app/                      arranque, theme, router, DI raíz
│   ├── app.dart
│   ├── router.dart           go_router, rutas declarativas + guards de desbloqueo
│   ├── l10n/                 localizaciones (ARB) — i18n desde Bloque 1
│   └── theme/                tokens de §3 como ThemeExtension
├── core/                     transversal, sin dependencia de features
│   ├── network/              cliente Dio, interceptores, cert pinning, errores
│   ├── crypto/               normalización canónica de respuestas (UX), no validación
│   ├── storage/              secure storage para sesión/token + caché de nodos
│   ├── result/               tipo Result<T> (éxito/fallo)
│   ├── telemetry/            eventos de embudo (§10)
│   └── widgets/              DecodeText, BlockCursor, GlyphPanel (reutilizables)
├── features/
│   ├── onboarding/           el primer puzzle disfrazado de bienvenida
│   ├── puzzle/               el motor: render de nodo + entrada + validación
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── arc_map/              grafo de progreso del arco
│   ├── community/            salas por nodo, muro de primeros
│   ├── hints/                pistas y fichas
│   └── profile/              alias, progreso, sesión
└── shared/                   modelos compartidos entre features
```

---

## 6. Decisiones de paradigma (qué usar y qué evitar)

| Tema | Usar | Evitar |
|---|---|---|
| Estado | Riverpod 2.x con **riverpod_generator** (`@riverpod`), `AsyncNotifier` tipado | `setState` para negocio, `Provider` clásico |
| Modelos | `freezed` + `json_serializable`, inmutables, uniones selladas | clases mutables, `copyWith` a mano |
| Errores | tipo `Result<T>` (fallo = dato esperado) | excepciones para flujo normal (ej. "respuesta incorrecta") |
| Routing | `go_router` declarativo con guards | navegación imperativa dispersa |
| DI | Riverpod como contenedor | `get_it` paralelo salvo necesidad real |
| Efectos visuales | `CustomPainter` + shaders en `core/widgets` | duplicar el efecto glitch en cada pantalla |
| Lógica | en `domain`, testeada | lógica dentro de widgets |
| Copy | claves i18n (ARB) | strings hardcodeados en widgets |

"Respuesta incorrecta" es un **dato esperado**, no una excepción. Modélalo en el `Result`.
**Versiones:** fijar versiones exactas en `pubspec.yaml` y documentar la mayor de freezed/riverpod usada (la generación de código difiere entre majors).

---

## 7. Backend y servicios

Aprovecha la infraestructura existente: **Laravel** + droplet con **n8n** (DigitalOcean).

### Laravel — fuente de verdad
- API REST/JSON **versionada** bajo `/api/v1`, auth con **Sanctum** (tokens).
- Tablas: `users`, `arcs`, `puzzle_nodes`, `node_edges` (grafo), `solutions` (hashes/reglas + sal por-nodo), `user_progress`, `hints`, `hint_unlocks`, `submissions` (intentos, anti-fuerza bruta).
- Endpoints:
  - `POST /api/v1/submit` — recibe intento, valida, devuelve desbloqueo + narrativa (o estado pendiente).
  - `GET /api/v1/node/{id}` — entrega el nodo **solo si** el progreso del usuario lo autoriza.
  - `POST /api/v1/hint` — entrega pista N si las reglas lo permiten.
  - `GET /api/v1/arc/{id}/map` — grafo de progreso del usuario.
- Assets pesados (imágenes stego, audio) vía **URL firmada con expiración** (no rutas públicas adivinables).
- **Rate limiting agresivo** en `/submit` (§8).

### Contrato de API (forma estable)
Toda respuesta comparte sobre:
```json
// éxito
{ "data": { ... }, "meta": { "v": 1 } }
// error (formato único)
{ "error": { "code": "RATE_LIMITED", "message": "...", "retryAfter": 30 } }
```
`POST /submit` request: `{ "nodeId": "...", "answer": "<texto normalizado cliente-UX>" }`
`POST /submit` response: `{ "data": { "correct": true, "nextNodeId": "...|null", "narrative": "...|null", "status": "ok|pending" } }`
El cliente mapea cada `error.code` a un `Result` fallido tipado; los códigos son un enum compartido (documentado), no strings ad hoc.

### n8n — orquestación y ARG (límite con Laravel)
Laravel valida lo síncrono y determinista. n8n maneja lo **asíncrono o externo**:
- Eventos en vivo (primero en resolver → push + muro).
- Puente físico: webhook que recibe un escaneo de QR real y desbloquea un nodo (firma el webhook).
- Liberación temporizada de arcos.
- Validaciones asíncronas complejas (firma PGP, fuente externa) → marcan el `submission` como resuelto/rechazado y disparan push.
- Detección de patrones de submission anómalos.
Cuando un submit cae en n8n, Laravel responde `status: "pending"` y el cliente muestra estado de espera narrativo.

### Tiempo real y push
- Comunidad: WebSockets (Laravel Reverb).
- Push: Firebase Messaging (FCM + APNs). Requiere certificados APNs y proyecto Firebase — provisionar en Bloque 3 (no al final).

---

## 8. Seguridad, anti-spoiler y legal

**Principio rector:** *si está en el cliente, está comprometido.* Asume que cualquiera decompila el APK.

- Validación y autorización **100% server-side**; nada de hash-en-cliente (§4).
- TLS obligatorio + **certificate pinning** en Dio.
- **Rate limiting por capas** en `/submit`: por cuenta y por IP, con *backoff* exponencial por nodo y bloqueo temporal tras N fallos; escalado a reto adicional si se detecta patrón de fuerza bruta.
- Respuestas con entropía suficiente (validada en el seed).
- Comparaciones de igualdad en **tiempo constante**; hash lento con sal por-nodo.
- Spoilers en comunidad ocultos por defecto (tap para revelar) + moderación.
- La capa irresoluta nunca se valida públicamente (ni siquiera existe su `solution` en BD si no hace falta).

**Legal y cumplimiento de tiendas:**
- QR físicos solo en espacios legales y con permiso; nada que parezca vandalismo o alarme a terceros.
- OSINT solo sobre fuentes que **tú** controlas; nunca datos personales reales.
- Privacidad: alias, mínimo de datos personales; cumplir la ley aplicable (política de privacidad publicada antes del lanzamiento).
- Moderación en salas (el anonimato atrae abuso): reporte, mute, registro.
- **Riesgo de review de tiendas:** apps que llevan al usuario fuera de la app o con "funcionalidad mínima" pueden ser rechazadas. Asegurar que la app tiene valor autónomo y que los saltos externos son opcionales/contextualizados. Clasificación por edad acorde al contenido.

---

## 9. Accesibilidad e internacionalización

- **Contraste:** todo texto cumple WCAG AA (§3). El `ink.dim` se subió para no fallar.
- **Reduce motion:** decode reveal y transiciones se degradan a fade si el sistema lo pide.
- **Lectores de pantalla:** cada widget significativo con `Semantics`; el decode reveal expone el texto final, no el ruido intermedio.
- **Tamaño de toque** mínimo 44–48 dp; soporte de `textScaleFactor` sin romper layout.
- **i18n desde Bloque 1:** todo copy en archivos ARB. La voz del sistema en español es la base; el idioma de lanzamiento (solo ES, o ES+EN) es decisión abierta (§13), pero la *infraestructura* i18n existe desde el principio para no reescribir después.

---

## 10. Telemetría (medir el "éxito")

Para validar la definición de éxito (§1) sin telemetría invasiva:
- Eventos de **embudo** anónimos: `app_open`, `puzzle_discovered`, `first_attempt`, `first_solve`, `second_node_open`, más tiempo entre etapas.
- Sin PII; respeta opt-out; alias en vez de identidad.
- Herramienta: solución self-hosted respetuosa con privacidad (p. ej. en el mismo droplet) — decisión abierta (§13).
- Estos eventos guían el ajuste del onboarding (la hipótesis más arriesgada del producto).

---

## 11. Roadmap por bloques (paso a paso)

Cada bloque cierra con un entregable verificable y una *Definition of Done* (DoD). **No avances sin cerrarlo.**

> **DoD transversal a todos los bloques:** análisis estático en verde · tests del dominio y endpoints nuevos pasando · sin copy hardcodeado · a11y básica (contraste + reduce motion) respetada.

### Bloque 0 — Fundaciones
- Estructura feature-first completa (sobre el repo `iss` existente), CI básico (lint + test en cada push).
- Theme con tokens de §3 como `ThemeExtension` (con contrastes corregidos).
- Cliente Dio + cert pinning + `Result<T>` + manejo de errores con formato único (§7).
- Laravel: auth Sanctum + esquema de BD núcleo + `/api/v1/submit` con un nodo de prueba **validado server-side** (sin hash en cliente).
- **Entregable:** la app levanta, autentica, envía una respuesta y el servidor responde correcto/incorrecto con el contrato de §7.

### Bloque 1 — Motor de un solo puzzle + prueba de la hipótesis central
- Widgets `DecodeText` (con reduce-motion y presupuesto de fps) y `BlockCursor`.
- Pantalla "Terminal de nodo": renderiza un nodo de texto y valida contra el servidor.
- **Prototipo del onboarding "no-instrucción"** y su medición (la hipótesis más arriesgada se prueba YA, no en Bloque 2): ¿el usuario descubre solo que hay un puzzle?
- i18n (ARB) y eventos de embudo (§10) operativos.
- Decode reveal + acorde de éxito.
- **Entregable:** se resuelve un César de punta a punta con la estética definida, y se mide si testers descubren el puzzle sin ayuda.

### Bloque 2 — Grafo y Arco 0
- Modelo de grafo + desbloqueo encadenado (tests primero).
- **Pipeline de contenido como dato:** esquema de seed (YAML/JSON) + carga a BD (precede al panel del Bloque 5).
- Mapa del arco.
- Tipos: César, Base64 anidado, esteganografía LSB simple.
- Onboarding pulido con base en la medición del Bloque 1.
- **Entregable:** el Arco 0 completo (3–5 capas) jugable de inicio a fin, alimentado por seeds. **Ya es un demo presentable.**

### Bloque 3 — Comunidad y pistas
- Salas por nodo (WebSockets / Reverb).
- Pistas + fichas ganadas (entrega server-side).
- Muro de primeros.
- Provisión de push (Firebase + APNs).
- **Entregable:** el usuario puede atorarse, pedir pista, discutir y ver el ranking.

### Bloque 4 — ARG y tipos avanzados
- Visor de espectrograma (audio).
- Escáner QR + integración n8n para desbloqueo físico (webhook firmado).
- Geolocalización (con tolerancia server-side).
- Manejo de estado `pending` para validaciones asíncronas.
- **Entregable:** un nodo que exige salir de la app y volver.

### Bloque 5 — Panel de autoría interno
- Herramienta web (Laravel) sobre el **mismo esquema de seed** del Bloque 2, para crear nodos sin recompilar la app.
- **Entregable:** se puede dar de alta un nodo nuevo desde la web y aparece en la app.

### Bloque 6 — Pulido y lanzamiento
- Diseño sonoro completo, accesibilidad completa (auditoría a11y), performance.
- Beta cerrada con comunidad de CTF/ARG.
- Política de privacidad publicada; revisión de cumplimiento de tiendas.
- Lanzamiento del Arco 0 público + capa irresoluta sembrada.
- **Entregable:** en tiendas, con un misterio abierto.

---

## 12. Stack

| Capa | Tecnología |
|---|---|
| App | Flutter (estable, Dart 3) |
| Estado | Riverpod 2.x + riverpod_generator + freezed |
| Routing | go_router |
| Red | Dio (+ cert pinning) |
| Almacenamiento seguro | flutter_secure_storage |
| i18n | flutter_localizations + ARB |
| Audio | just_audio + visor FFT propio |
| QR | mobile_scanner |
| Push | firebase_messaging |
| Backend | Laravel + Sanctum |
| Tiempo real | Laravel Reverb |
| Orquestación | n8n (droplet) |
| BD | PostgreSQL o MySQL |
| Hosting | DigitalOcean |

---

## 13. Decisiones abiertas y riesgos

Resolver con Isi **antes** del bloque indicado. No inventar la respuesta.

| # | Decisión / riesgo | Impacto | Cuándo |
|---|---|---|---|
| D1 | Monorepo (app + Laravel) vs repos separados | Estructura, CI | Antes de Bloque 0 |
| D2 | Tipografía mono (JetBrains vs IBM Plex) | Estética, assets | Antes de Bloque 1 |
| D3 | Renombrar paquete `iss` → `limen` o mantener | Bajo; toca android/ios | Antes de Bloque 0 |
| D4 | Idioma de lanzamiento: solo ES vs ES+EN | i18n, alcance comunidad | Antes de Bloque 1 |
| D5 | Herramienta de telemetría self-hosted | Privacidad, infra | Antes de Bloque 1 |
| D6 | BD: PostgreSQL vs MySQL | Backend | Antes de Bloque 0 |
| R1 | La hipótesis "el usuario descubre solo el puzzle" puede fallar | Producto entero | Se mide en Bloque 1 |
| R2 | Rechazo de tiendas por funcionalidad mínima / saltos externos | Lanzamiento | Vigilar desde Bloque 4 |
| R3 | Abuso/moderación en salas anónimas | Comunidad, legal | Bloque 3 |

---

## 14. Setup inicial (Bloque 0)

```
# El repo ya existe (paquete Flutter `iss`). NO ejecutar flutter create.
cd iss
flutter pub get
# añadir dependencias: flutter_riverpod, riverpod_annotation, riverpod_generator,
#   freezed, json_serializable, go_router, dio, flutter_secure_storage,
#   flutter_localizations, build_runner (dev)
# mantener analysis_options.yaml en modo estricto
# crear la estructura de carpetas de §5
dart run build_runner build --delete-conflicting-outputs
```

Backend Laravel en repo separado o monorepo (**D1**, confirmar con Isi antes de Bloque 0).

---

## 15. Glosario

- **Nodo**: unidad atómica de puzzle; vértice del grafo.
- **Arco**: conjunto narrativo de nodos encadenados.
- **Flag**: respuesta verificable de un nodo (canónico: `LIMEN{...}`).
- **Decode reveal**: efecto visual firma (texto que se "descifra" al aparecer).
- **Capa irresoluta**: nodo sin solución pública; imán de leyenda.
- **Server-side authority**: toda validación/autorización vive en el servidor.
- **Seed**: definición de un nodo como dato versionado, fuente del contenido.
- **DoD (Definition of Done)**: criterios de cierre de un bloque más allá del entregable.

---

*Primer bloque a ejecutar: **Bloque 0 — Fundaciones**. Antes de empezar, resolver las decisiones abiertas marcadas "antes de Bloque 0" en §13 (D1, D3, D6).*
