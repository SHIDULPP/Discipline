import 'package:discipline/core/errors/exceptions.dart';
import 'package:hive/hive.dart';

abstract final class HiveErrorMapper {
  static Never rethrowAsCacheException(Object error, [String? context]) {
    if (error is CacheException ||
        error is NotFoundException ||
        error is ValidationException) {
      throw error;
    }

    final prefix = context != null ? '$context: ' : '';
    if (error is HiveError) {
      throw CacheException('$prefix${error.message}');
    }
    throw CacheException('$prefix$error');
  }
}
