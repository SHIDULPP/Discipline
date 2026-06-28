import 'package:discipline/features/accessibility/domain/repositories/accessibility_repository.dart';

class OpenAccessibilitySettings {
  const OpenAccessibilitySettings(this._repository);

  final AccessibilityRepository _repository;

  Future<void> call() => _repository.openAccessibilitySettings();
}
