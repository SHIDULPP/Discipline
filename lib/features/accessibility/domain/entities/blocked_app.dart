import 'package:equatable/equatable.dart';

class BlockedApp extends Equatable {
  const BlockedApp({
    required this.packageName,
    required this.label,
    required this.isBlocked,
    required this.isInstalled,
  });

  final String packageName;
  final String label;
  final bool isBlocked;
  final bool isInstalled;

  @override
  List<Object?> get props => [packageName, label, isBlocked, isInstalled];
}
