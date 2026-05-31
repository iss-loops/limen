/// Resultado de una operación que puede fallar de forma esperada.
///
/// Un fallo (p. ej. "respuesta incorrecta") es un dato, no una excepción.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(String code, String message) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final code, :final message) => err(code, message),
      };
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Err<T> extends Result<T> {
  final String code;
  final String message;
  const Err(this.code, this.message);

  @override
  bool operator ==(Object other) =>
      other is Err<T> && other.code == code && other.message == message;

  @override
  int get hashCode => Object.hash(code, message);
}
