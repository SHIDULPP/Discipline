import 'package:discipline/core/constants/app_constants.dart';
import 'package:discipline/core/errors/exceptions.dart';

/// Single source of truth for task field validation rules.
abstract final class TaskValidator {
  static void validateCreateOrUpdate({
    required String heading,
    required String subHeading,
    required Duration completionDuration,
  }) {
    validateHeading(heading);
    validateSubHeading(subHeading);
    validateDuration(completionDuration);
  }

  static void validateHeading(String heading) {
    final trimmed = heading.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Heading cannot be empty');
    }
    if (trimmed.length > AppConstants.maxHeadingLength) {
      throw ValidationException(
        'Heading cannot exceed ${AppConstants.maxHeadingLength} characters',
      );
    }
  }

  static void validateSubHeading(String subHeading) {
    final trimmed = subHeading.trim();
    if (trimmed.length > AppConstants.maxSubHeadingLength) {
      throw ValidationException(
        'Sub heading cannot exceed ${AppConstants.maxSubHeadingLength} characters',
      );
    }
  }

  static void validateDuration(Duration completionDuration) {
    final durationMinutes = completionDuration.inMinutes;
    if (durationMinutes < AppConstants.minCompletionDurationMinutes) {
      throw ValidationException(
        'Completion duration must be at least '
        '${AppConstants.minCompletionDurationMinutes} minute',
      );
    }
    if (durationMinutes > AppConstants.maxCompletionDurationMinutes) {
      throw const ValidationException(
        'Completion duration cannot exceed 24 hours',
      );
    }
  }

  static void validateDurationParts({required int hours, required int minutes}) {
    validateDuration(Duration(hours: hours, minutes: minutes));
  }
}
