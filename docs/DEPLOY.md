# Deploy del backend de LIMEN

El server es un binario Dart AOT en un contenedor (`Dockerfile`, contexto = raíz
del repo). Lee `PORT` del entorno y escucha en `0.0.0.0`. Verificado localmente.

## 🟢 Desplegado (Render, free)

- **URL:** https://limen-bt36.onrender.com
- Repo: github.com/iss-loops/limen (blueprint `render.yaml`, autodeploy en push a `main`).
- El plan free duerme tras ~15 min inactivo (~50s en despertar la 1ª petición).

## Opción A — Railway (CLI ya instalada)

```bash
railway login                 # interactivo (navegador) — hazlo tú
railway init                  # crea proyecto nuevo (o: railway link a uno existente)
railway up                    # build del Dockerfile + deploy
railway domain                # genera la URL pública  → https://<algo>.up.railway.app
```

## Opción B — Fly.io

```bash
# instala flyctl: https://fly.io/docs/flyctl/install/
fly auth login
fly launch --copy-config --no-deploy   # usa fly.toml (ya incluido)
fly deploy                              # → https://limen-demo.fly.dev
```

## Probar el server desplegado

```bash
curl -X POST https://TU-URL/api/v1/session
# → {"data":{"token":"..."},"meta":{"v":1}}
```

## Apuntar la app al server desplegado (modo online)

```bash
flutter run -d <device> \
  --dart-define=LIMEN_OFFLINE=false \
  --dart-define=LIMEN_API=https://TU-URL/api/v1

# o un APK release que apunta a la nube:
flutter build apk --release \
  --dart-define=LIMEN_OFFLINE=false \
  --dart-define=LIMEN_API=https://TU-URL/api/v1
```

Con esto el teléfono ya no necesita tu PC ni `adb reverse`: habla directo con la
nube, en cualquier red. La validación vuelve a ser 100% server-side (sin
soluciones en el cliente).
