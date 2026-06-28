import 'package:discipline/features/accessibility/domain/entities/accessibility_status.dart';
import 'package:discipline/features/accessibility/domain/repositories/accessibility_repository.dart';

class GetAccessibilityStatus {
  const GetAccessibilityStatus(this._repository);

  final AccessibilityRepository _repository;

  Future<AccessibilityStatus> call() => _repository.getStatus();
}
