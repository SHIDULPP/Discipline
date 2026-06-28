abstract final class RoutePaths {
  static const String home = '/';
  static const String taskCreate = '/tasks/create';
  static const String taskEdit = '/tasks/:id/edit';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String accessibility = '/settings/accessibility';

  static String taskEditPath(String id) => '/tasks/$id/edit';
}
