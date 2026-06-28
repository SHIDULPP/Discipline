import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/features/tasks/domain/validators/task_validator.dart';

abstract final class TaskFormValidators {
  static String? heading(String? value) =>
      _mapException(() => TaskValidator.validateHeading(value ?? ''));

  static String? subHeading(String? value) =>
      _mapException(() => TaskValidator.validateSubHeading(value ?? ''));

  static String? duration({required int hours, required int minutes}) =>
      _mapException(
        () => TaskValidator.validateDurationParts(hours: hours, minutes: minutes),
      );

  static String? _mapException(void Function() validate) {
    try {
      validate();
      return null;
    } on ValidationException catch (error) {
      return error.message;
    }
  }
}
