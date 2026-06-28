import 'package:equatable/equatable.dart';

class AccessibilityStatus extends Equatable {
  const AccessibilityStatus({
    required this.isEnabled,
    required this.isServiceConnected,
  });

  final bool isEnabled;
  final bool isServiceConnected;

  @override
  List<Object?> get props => [isEnabled, isServiceConnected];
}
