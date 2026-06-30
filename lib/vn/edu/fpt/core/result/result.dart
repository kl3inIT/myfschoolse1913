sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;
}

class AppFailure {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;
}
