import 'package:discipline/features/tasks/domain/validators/task_validator.dart';

abstract final class TaskInputValidator {
  static void validateCreateOrUpdate({
    required String heading,
    required String subHeading,
    required Duration completionDuration,
  }) {
    TaskValidator.validateCreateOrUpdate(
      heading: heading,
      subHeading: subHeading,
      completionDuration: completionDuration,
    );
  }
}
