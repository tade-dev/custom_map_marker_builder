class MarkerBuilderException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  MarkerBuilderException(this.message, [this.originalError, this.stackTrace]);

  @override
  String toString() {
    if (originalError != null) {
      return 'MarkerBuilderException: $message (Original: $originalError)';
    }
    return 'MarkerBuilderException: $message';
  }
}

class RenderException extends MarkerBuilderException {
  RenderException(super.message, [super.originalError, super.stackTrace]);
}

class TimeoutException extends MarkerBuilderException {
  TimeoutException(super.message, [super.originalError, super.stackTrace]);
}

class CacheException extends MarkerBuilderException {
  CacheException(super.message, [super.originalError, super.stackTrace]);
}
