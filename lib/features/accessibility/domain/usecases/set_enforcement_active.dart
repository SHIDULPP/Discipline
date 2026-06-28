import 'package:discipline/features/accessibility/domain/repositories/accessibility_repository.dart';

class SetEnforcementActive {
  const SetEnforcementActive(this._repository);

  final AccessibilityRepository _repository;

  Future<void> call({required bool active, String? taskId}) {
    return _repository.setEnforcementActive(active: active, taskId: taskId);
  }
}
