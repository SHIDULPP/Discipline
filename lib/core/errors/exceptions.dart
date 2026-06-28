class CacheException implements Exception {
  const CacheException(this.message);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class PlatformException implements Exception {
  const PlatformException(this.message);

  final String message;

  @override
  String toString() => 'PlatformException: $message';
}

class NotFoundException implements Exception {
  const NotFoundException(this.message);

  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
