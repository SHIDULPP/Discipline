import 'package:discipline/core/theme/app_colors.dart';
import 'package:discipline/features/tasks/presentation/controllers/task_form_controller.dart';
import 'package:discipline/features/tasks/presentation/validators/task_form_validators.dart';
import 'package:discipline/features/tasks/presentation/widgets/duration_input_field.dart';
import 'package:discipline/features/tasks/presentation/widgets/form_entrance_animation.dart';
import 'package:discipline/features/tasks/presentation/widgets/start_time_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  bool get isEditing => taskId != null;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _headingController = TextEditingController();
  final _subHeadingController = TextEditingController();

  late DateTime _startTime;
  late int _durationHours;
  late int _durationMinutes;

  bool _isPopulated = false;
  String? _durationError;
  late final AnimationController _successController;
  late final Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _startTime = defaultTaskStartTime();
    _durationHours = 0;
    _durationMinutes = 30;

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _successScale = Tween<double>(begin: 1, end: 0.96).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeInOut),
    );

    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
    }
  }

  Future<void> _loadTask() async {
    final task = await ref
        .read(taskFormControllerProvider.notifier)
        .loadTask(widget.taskId!);

    if (!mounted || task == null) return;

    setState(() {
      _headingController.text = task.heading;
      _subHeadingController.text = task.subHeading;
      _startTime = task.startTime;
      _durationHours = task.completionDuration.inHours;
      _durationMinutes = task.completionDuration.inMinutes.remainder(60);
      _isPopulated = true;
    });
  }

  @override
  void dispose() {
    _headingController.dispose();
    _subHeadingController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Duration get _completionDuration =>
      Duration(hours: _durationHours, minutes: _durationMinutes);

  Future<void> _save() async {
    final durationError = TaskFormValidators.duration(
      hours: _durationHours,
      minutes: _durationMinutes,
    );
    setState(() => _durationError = durationError);

    if (!_formKey.currentState!.validate() || durationError != null) {
      _shakeForm();
      return;
    }

    final success = await ref.read(taskFormControllerProvider.notifier).save(
          taskId: widget.taskId,
          heading: _headingController.text,
          subHeading: _subHeadingController.text,
          startTime: _startTime,
          completionDuration: _completionDuration,
        );

    if (!mounted) return;

    if (success) {
      await _successController.forward();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Task updated' : 'Task created',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text(
          'This action cannot be undone. The task will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.overdue,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(taskFormControllerProvider.notifier)
        .delete(widget.taskId!);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    }
  }

  void _shakeForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please fix the errors before saving'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.overdue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(taskFormControllerProvider);
    final theme = Theme.of(context);
    final isLoading =
        widget.isEditing && !_isPopulated && formState.isLoading;
    final loadFailed =
        widget.isEditing && !_isPopulated && formState.errorMessage != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: formState.isBusy ? null : () => context.pop(),
        ),
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (widget.isEditing && !loadFailed)
            IconButton(
              tooltip: 'Delete task',
              onPressed: formState.isBusy ? null : _confirmDelete,
              icon: formState.isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isLoading
            ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
            : loadFailed
                ? _LoadError(
                    key: const ValueKey('error'),
                    message: formState.errorMessage!,
                    onBack: () => context.pop(),
                  )
                : KeyedSubtree(
                    key: const ValueKey('form'),
                    child: _buildForm(context, theme, formState),
                  ),
      ),
      bottomNavigationBar: isLoading || loadFailed
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ScaleTransition(
                  scale: _successScale,
                  child: FilledButton(
                    onPressed: formState.isBusy ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: formState.isSubmitting
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Text(
                              widget.isEditing ? 'Save Changes' : 'Create Task',
                              key: const ValueKey('label'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    ThemeData theme,
    TaskFormState formState,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final horizontalPadding = isWide ? 32.0 : 16.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 560 : double.infinity),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  24,
                ),
                children: [
                  if (formState.errorMessage != null)
                    FormEntranceAnimation(
                      index: 0,
                      child: _ErrorBanner(message: formState.errorMessage!),
                    ),
                  FormEntranceAnimation(
                    index: 1,
                    child: _FieldLabel(
                      label: 'Heading',
                      icon: Icons.title_rounded,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormEntranceAnimation(
                    index: 2,
                    child: TextFormField(
                      controller: _headingController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'What do you need to do?',
                      ),
                      validator: TaskFormValidators.heading,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FormEntranceAnimation(
                    index: 3,
                    child: _FieldLabel(
                      label: 'Sub Heading',
                      icon: Icons.notes_rounded,
                      optional: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormEntranceAnimation(
                    index: 4,
                    child: TextFormField(
                      controller: _subHeadingController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Add a short description',
                      ),
                      validator: TaskFormValidators.subHeading,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FormEntranceAnimation(
                    index: 5,
                    child: _FieldLabel(
                      label: 'Start Time',
                      icon: Icons.event_rounded,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormEntranceAnimation(
                    index: 6,
                    child: StartTimeInputField(
                      startTime: _startTime,
                      onChanged: (value) => setState(() => _startTime = value),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FormEntranceAnimation(
                    index: 7,
                    child: _FieldLabel(
                      label: 'Completion Duration',
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormEntranceAnimation(
                    index: 8,
                    child: DurationInputField(
                      hours: _durationHours,
                      minutes: _durationMinutes,
                      errorText: _durationError,
                      onChanged: (hours, minutes) {
                        setState(() {
                          _durationHours = hours;
                          _durationMinutes = minutes;
                          _durationError = TaskFormValidators.duration(
                            hours: hours,
                            minutes: minutes,
                          );
                        });
                      },
                    ),
                  ),
                  if (widget.isEditing) ...[
                    const SizedBox(height: 32),
                    FormEntranceAnimation(
                      index: 9,
                      child: OutlinedButton.icon(
                        onPressed: formState.isBusy ? null : _confirmDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete Task'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.overdue,
                          side: BorderSide(
                            color: AppColors.overdue.withValues(alpha: 0.5),
                          ),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.icon,
    this.optional = false,
  });

  final String label;
  final IconData icon;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            '(optional)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.upcoming,
                ),
          ),
        ],
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    super.key,
    required this.message,
    required this.onBack,
  });

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.overdue),
            const SizedBox(height: 16),
            Text(
              'Could not load task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.upcoming,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onBack, child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.overdue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.overdue.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.overdue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.overdue,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
