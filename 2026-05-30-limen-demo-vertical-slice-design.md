# LIMEN — Vertical Slice del Arco 0 (demo full-stack en Dart)

**Fecha:** 2026-05-30
**Estado:** Diseño aprobado
**Tipo:** Demo de portafolio (no producto público)

---

## Contexto

LIMEN es una app móvil Flutter de criptopuzzles progresivos con capa ARG, descrita por completo en el `README.md` del repo. Ese plan apunta a un **producto público completo** (app + Laravel + n8n + comunidad en tiempo real + push + ARG físico + panel de autoría), lo que representa más de un año de trabajo en solitario.

Este spec acota un **primer entregable de demo de portafolio**: una rebanada vertical jugable y presentable del Arco 0, full-stack, construible en semanas. Recorta agresivamente todo lo que no sirve a "enseñar algo bonito y funcional", manteniendo la arquitectura limpia para que el resto del plan original pueda construirse encima después sin reescrituras.

### Decisiones que originaron este alcance
- **Meta:** demo de portafolio, no producto en tiendas.
- **Plataforma:** Flutter multiplataforma (móvil), full-stack (frontend + backend).
- **Backend:** ligero, en **Dart (Dart Frog)** — un solo lenguaje, código de dominio compartido entre app y servidor.
- **Estructura:** monorepo Dart con paquete de dominio compartido.

---

## Objetivo y definición de éxito

Un espectador (revisor de portafolio, tester) abre el demo sin instrucciones, **descubre por su cuenta que la pantalla de bienvenida es un puzzle**, lo resuelve, y avanza por una cadena corta de nodos hasta el cierre "has sido visto". La validación ocurre en el servidor; la estética (oscuridad mono + decode reveal + tensión The xx/Tame Impala) se siente pulida.

El demo es exitoso si transmite tres cosas: el *aha* del descubrimiento, la firma visual (decode reveal), y una arquitectura full-stack Dart limpia.

---

## Alcance

### Dentro
- **3 nodos encadenados del Arco 0** (la rebanada vertical):
  - **Nodo 0 — Onboarding "no-instrucción":** la pantalla de bienvenida que *es* el primer puzzle. Gancho e hipótesis más arriesgada; va primero.
  - **Nodo 1 — César** (terminal de texto): el loop central.
  - **Nodo 2 — Base64 anidado:** muestra el desbloqueo encadenado.
  - Cierre con el *beat* narrativo "has sido visto".
- Estética: design tokens (con contraste corregido a WCAG AA) + parámetro `intensity` (The xx ↔ Tame Impala) en los momentos glyph.
- Widgets reutilizables `DecodeText` y `BlockCursor`, con soporte de `reduce motion`.
- Sesión anónima (token de dispositivo, **sin login real**).
- Backend Dart Frog: `/session`, `/node/{id}` (autorizado por progreso), `/submit`.
- **Validación server-side real** usando el dominio compartido; las soluciones viven solo en los seeds del servidor.
- Decode reveal + acorde de éxito (sonido básico).
- Andamiaje de i18n (ES) desde el inicio.

### Fuera (recorte explícito del demo)
Comunidad / WebSockets, push (FCM/APNs), n8n, ARG físico (QR / geolocalización), panel de autoría, espectrograma de audio, PGP, forense de archivo, economía de fichas/pistas, rate-limiting agresivo, certificate pinning.

### Stretch (solo si sobra tiempo)
- **Nodo 3 — Esteganografía LSB** en imagen (suma pipeline de assets).

---

## Arquitectura

Monorepo Dart con **Dart pub workspace**:

```
limen/
├── pubspec.yaml          # workspace (resolution: workspace)
├── app/                  # Flutter — el código actual de `iss` se mueve aquí
├── server/               # Dart Frog
└── packages/
    └── limen_domain/     # compartido (sin Flutter, sin deps de servidor)
```

### `packages/limen_domain` (compartido)
- Modelos `freezed`: `PuzzleNode` como **unión sellada** por tipo de presentación/entrada.
- `Result<T>` (éxito/fallo; "respuesta incorrecta" es dato esperado, no excepción).
- `normalizeAnswer()` — normalización canónica (trim, case, unicode NFC, formato flag).
- `ValidationRule` — unión sellada: `exact`, `normalized`, `regex`, `numericTolerance`.
- `validate(rule, normalizedAnswer, expected)` — función pura. Recibe `expected` como parámetro; **el dominio no contiene ninguna solución**.

> **Límite de seguridad clave:** el dominio compartido contiene la *lógica* de validación, nunca los *valores* de solución. La app depende de `limen_domain` pero jamás recibe `expected`; solo el servidor lo provee desde sus seeds.

### `app/` (Flutter)
Feature-first + Clean (`presentation → domain ← data`):
- `app/` (theme con tokens como `ThemeExtension`, router go_router, l10n ARB).
- `core/` (Dio, secure storage, telemetría mínima, widgets `DecodeText`/`BlockCursor`).
- `features/onboarding`, `features/puzzle` (render de nodo + entrada + submit), `features/arc_map`.
- Estado con Riverpod 2.x + riverpod_generator; modelos `freezed`.

### `server/` (Dart Frog)
- Endpoints `/session`, `/node/{id}`, `/submit`.
- **Seeds** de nodos (YAML/JSON) que incluyen las soluciones y su `ValidationRule`.
- Para reglas de igualdad: solución almacenada como hash con sal por-nodo. Para `regex`: patrón en el seed (no hasheable).
- Progreso por sesión anónima (en memoria o SQLite para el demo).
- Usa `limen_domain` para normalizar y validar.

---

## Flujo de datos

```
app inicia → POST /session → token anónimo (guardado en secure storage)
app → GET /node/0 → server verifica progreso → devuelve payload del nodo (SIN solución)
usuario responde → cliente normaliza solo para UX → POST /submit {nodeId, answer}
   → server: normaliza canónicamente + aplica ValidationRule del nodo
             + compara contra seed (hash+sal en igualdad; regex/ tolerancia según regla)
             + registra el intento
   → responde { correct, nextNodeId?, narrative? }
app → si correct: decode reveal + acorde + desbloquea siguiente nodo
      si no: feedback de fallo (dato esperado en Result)
```

Sin red, el submit se encola y muestra mensaje en voz del sistema; el payload del nodo actual se cachea para lectura offline.

---

## Contrato de API (forma estable)

```json
// éxito
{ "data": { ... }, "meta": { "v": 1 } }
// error
{ "error": { "code": "NODE_LOCKED", "message": "..." } }
```
- `POST /api/v1/session` → `{ "data": { "token": "..." } }`
- `GET  /api/v1/node/{id}` → `{ "data": { "id", "arco", "presentacion", "payload", "entrada" } }` (nunca la solución)
- `POST /api/v1/submit` req `{ "nodeId", "answer" }` → `{ "data": { "correct", "nextNodeId|null", "narrative|null" } }`

---

## Pruebas

- **TDD en `limen_domain`:** normalización, cada variante de `ValidationRule`, lógica de desbloqueo del grafo. La lógica de negocio nace probada.
- **Server:** tests de endpoint — `/submit` correcto e incorrecto, gating de `/node` por progreso, formato de error.
- **App:** widget test de `DecodeText` (incluida la rama `reduce motion`) + smoke del loop de resolución contra un server local/fake.

---

## Roadmap (hitos del demo)

DoD transversal: análisis estático en verde · tests de dominio y endpoints nuevos pasando · sin copy hardcodeado · a11y básica (contraste + reduce motion).

- **M0 — Fundaciones:** monorepo workspace; `limen_domain` con `Result` + normalización (TDD); tokens de tema (contraste corregido); cliente Dio; Dart Frog con `/submit` y un nodo validado server-side.
  - *Entregable:* la app levanta, abre sesión, envía una respuesta y el servidor responde correcto/incorrecto con el contrato definido.
- **M1 — Loop central:** `DecodeText`/`BlockCursor`; pantalla terminal de nodo; César de punta a punta con la estética; decode reveal + acorde.
  - *Entregable:* se resuelve un César completo con la estética definida.
- **M2 — Slice Arco 0:** desbloqueo del grafo (3 nodos); pipeline de seeds (YAML); onboarding "no-instrucción"; i18n (ES).
  - *Entregable:* el slice de 3 nodos jugable de inicio a fin, alimentado por seeds.
- **M3 — Pulido demo:** parámetro `intensity` (xx↔impala) en momentos glyph; reduce-motion; deploy del server (Railway/Fly.io); demo grabable.
  - *Entregable:* demo desplegado y presentable. *(Stretch: nodo LSB.)*

---

## Stack del demo

| Capa | Tecnología |
|---|---|
| App | Flutter (estable, Dart 3) |
| Estado | Riverpod 2.x + riverpod_generator + freezed |
| Routing | go_router |
| Red | Dio |
| Almacenamiento seguro | flutter_secure_storage |
| i18n | flutter_localizations + ARB |
| Dominio compartido | paquete Dart puro (`limen_domain`) |
| Backend | Dart Frog |
| Persistencia server | en memoria o SQLite (demo) |
| Deploy server | Docker → Railway o Fly.io |

---

## Camino al producto completo (post-demo)

La arquitectura permite crecer sin reescribir:
- `limen_domain` ya existe → el backend "real" (Laravel u otro) reimplementa los endpoints reutilizando el mismo contrato.
- La interfaz de validación es server-side desde el día 1 → no hay deuda de "hash en cliente".
- Seeds como dato → el panel de autoría (Bloque 5 del README) es UI sobre el mismo esquema.
- Features recortadas (comunidad, push, ARG físico) se añaden como módulos feature-first nuevos.

---

## Decisiones abiertas (resolver antes de M1)
- Tipografía mono: JetBrains Mono vs IBM Plex Mono.
- Persistencia del server para el demo: en memoria (más simple) vs SQLite (sobrevive reinicios).
- ¿Incluir el nodo LSB en el alcance base o dejarlo como stretch? (por defecto: stretch).
