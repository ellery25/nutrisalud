/// Lightweight functional result type used by repositories so the
/// presentation layer never has to catch raw exceptions.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(String message) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final message) => err(message),
      };

  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}
