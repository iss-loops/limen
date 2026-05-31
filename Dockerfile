# Build: compila el backend Dart a un binario nativo (AOT).
# Contexto de build = raíz del repo (necesita packages/ + server/).
FROM dart:stable AS build

WORKDIR /app
# Dependencia compartida (path dep del server: ../packages/limen_domain).
COPY packages/ packages/
COPY server/ server/

WORKDIR /app/server
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

# Runtime mínimo: solo el binario + las libs del runtime de Dart.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /app/bin/server

# Railway/Fly inyectan PORT; el server lo lee (default 8080) y escucha en 0.0.0.0.
ENV PORT=8080
EXPOSE 8080
CMD ["/app/bin/server"]
