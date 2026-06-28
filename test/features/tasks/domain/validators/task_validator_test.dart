import 'package:discipline/core/errors/exceptions.dart';
import 'package:discipline/features/tasks/domain/validators/task_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskValidator', () {
    test('rejects empty heading', () {
      expect(
        () => TaskValidator.validateHeading('   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('accepts valid create payload', () {
      expect(
        () => TaskValidator.validateCreateOrUpdate(
          heading: 'Focus session',
          subHeading: 'Deep work',
          completionDuration: const Duration(minutes: 25),
        ),
        returnsNormally,
      );
    });

    test('rejects duration below minimum', () {
      expect(
        () => TaskValidator.validateDuration(const Duration(seconds: 30)),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
