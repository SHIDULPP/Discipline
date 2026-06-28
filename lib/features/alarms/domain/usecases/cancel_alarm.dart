import 'package:discipline/features/alarms/domain/repositories/alarm_repository.dart';

class CancelAlarm {
  const CancelAlarm(this._repository);

  final AlarmRepository _repository;

  Future<void> call(String taskId) => _repository.cancelAlarm(taskId);
}
