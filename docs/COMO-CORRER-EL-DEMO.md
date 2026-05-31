# Cómo correr el demo de LIMEN

Monorepo Dart (path deps, no workspace — Dart 3.5.4):

```
iss/
├── lib/                    # App Flutter (paquete `iss`)
├── packages/limen_domain/  # Dominio compartido (Dart puro, sin Flutter)
└── server/                 # Backend shelf (autoridad de validación)
```

## 1. Backend (terminal A)

```bash
cd server
dart pub get
dart run bin/server.dart        # escucha en http://localhost:8080
# Puerto configurable:  PORT=9000 dart run bin/server.dart
```

## 2. App (terminal B)

```bash
flutter pub get
flutter run -d chrome           # o -d windows / -d macos
# Si el server no está en localhost:8080:
flutter run -d chrome --dart-define=LIMEN_API=http://localhost:9000/api/v1
```

> En emulador Android usa `--dart-define=LIMEN_API=http://10.0.2.2:8080/api/v1`.

## 3. El recorrido (Arco 0, rebanada vertical)

1. **Nodo 0 — Onboarding "no-instrucción":** la bienvenida *es* el puzzle.
   Las iniciales de las cinco líneas deletrean la respuesta → `visto`.
2. **Nodo 1 — César (×3):** `xpeudo` → `umbral`.
3. **Nodo 2 — Base64 anidado:** decodifica dos veces → `LIMEN{te_veo}`.
4. **Cierre:** *has sido visto.*

## Pruebas

```bash
(cd packages/limen_domain && dart test)   # 35 tests de dominio (TDD)
(cd server && dart test)                  # 10 tests de endpoint
flutter test                              # widget tests (decode reveal, loop)
```

## Verificación de calidad

```bash
(cd packages/limen_domain && dart analyze)
(cd server && dart analyze)
flutter analyze
```
