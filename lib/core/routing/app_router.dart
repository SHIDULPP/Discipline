import 'package:discipline/core/constants/route_paths.dart';
import 'package:discipline/features/accessibility/presentation/screens/accessibility_screen.dart';
import 'package:discipline/features/home/presentation/screens/home_screen.dart';
import 'package:discipline/features/settings/presentation/screens/settings_screen.dart';
import 'package:discipline/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:discipline/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.taskCreate,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: RoutePaths.taskEdit,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskFormScreen(taskId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.statistics,
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.accessibility,
        builder: (context, state) => const AccessibilityScreen(),
      ),
    ],
  );
}
