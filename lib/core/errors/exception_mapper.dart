import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/core/errors/failures.dart';

/// Maps data-layer exceptions to domain failures for presentation.
abstract final class ExceptionMapper {
  static Failure toFailure(Object error) {
    return switch (error) {
      ValidationException(:final message) => ValidationFailure(message),
      CacheException(:final message) => CacheFailure(message),
      NotFoundException(:final message) => NotFoundFailure(message),
      PlatformException(:final message) => PlatformFailure(message),
      _ => PlatformFailure(error.toString()),
    };
  }

  static String messageFor(Object error) {
    if (error is Failure) return error.message;
    return toFailure(error).message;
  }
}
