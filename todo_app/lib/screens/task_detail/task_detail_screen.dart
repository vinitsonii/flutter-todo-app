import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/todo_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final TodoModel? todo;

  const TaskDetailScreen({super.key, this.todo});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _priority = Priority.medium;
  Category _category = Category.personal;
  TodoStatus _status = TodoStatus.todo;
  DateTime? _dueDate;
  bool _isLoading = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _priority = widget.todo!.priority;
      _category = widget.todo!.category;
      _status = widget.todo!.status;
      _dueDate = widget.todo!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save tasks.')),
        );
      }
      return;
    }

    final firestoreService = ref.read(firestoreServiceProvider);
    final now = DateTime.now();

    try {
      if (_isEditing) {
        final updated = widget.todo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          priority: _priority,
          status: _status,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          updatedAt: now,
        );
        await firestoreService.updateTodo(updated);
      } else {
        final newTodo = TodoModel(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          userId: user.uid,
          category: _category,
          priority: _priority,
          status: _status,
          dueDate: _dueDate,
          createdAt: now,
          updatedAt: now,
        );
        await firestoreService.addTodo(newTodo);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextField(
                    controller: _titleController,
                    label: 'Task Title',
                    hint: 'What needs to be done?',
                    prefixIcon: Icons.title_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Title is required';
                      return null;
                    },
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 16),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description (optional)',
                    hint: 'Add details...',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 3,
                  ).animate(delay: 50.ms).fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Priority
                  const _SectionLabel(label: 'Priority').animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 10),
                  _PrioritySelector(
                    selected: _priority,
                    onChanged: (p) => setState(() => _priority = p),
                  ).animate(delay: 120.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Category
                  const _SectionLabel(label: 'Category').animate(delay: 150.ms).fadeIn(),
                  const SizedBox(height: 10),
                  _CategorySelector(
                    selected: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ).animate(delay: 170.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Status (only shown when editing)
                  if (_isEditing) ...[
                    const _SectionLabel(label: 'Status').animate(delay: 200.ms).fadeIn(),
                    const SizedBox(height: 10),
                    _StatusSelector(
                      selected: _status,
                      onChanged: (s) => setState(() => _status = s),
                    ).animate(delay: 220.ms).fadeIn(),
                    const SizedBox(height: 24),
                  ],

                  // Due Date
                  const _SectionLabel(label: 'Due Date').animate(delay: 250.ms).fadeIn(),
                  const SizedBox(height: 10),
                  _DueDatePicker(
                    dueDate: _dueDate,
                    onChanged: (d) => setState(() => _dueDate = d),
                  ).animate(delay: 270.ms).fadeIn(),

                  const SizedBox(height: 36),

                  // Save button
                  GradientButton(
                    label: _isEditing ? 'Update Task' : 'Create Task',
                    isLoading: _isLoading,
                    onPressed: _save,
                    icon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = ref.read(currentUserProvider);
              if (user != null) {
                await ref
                    .read(firestoreServiceProvider)
                    .deleteTodo(user.uid, widget.todo!.id);
                if (mounted) context.go('/home');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((p) {
        final color = p == Priority.low
            ? AppColors.priorityLow
            : p == Priority.medium
                ? AppColors.priorityMedium
                : AppColors.priorityHigh;
        final isSelected = selected == p;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.label,
                      style: TextStyle(
                        color: isSelected ? color : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final Category selected;
  final ValueChanged<Category> onChanged;

  const _CategorySelector({required this.selected, required this.onChanged});

  Color _color(Category c) {
    switch (c) {
      case Category.work:
        return AppColors.categoryWork;
      case Category.personal:
        return AppColors.categoryPersonal;
      case Category.shopping:
        return AppColors.categoryShopping;
      case Category.health:
        return AppColors.categoryHealth;
      case Category.other:
        return AppColors.categoryOther;
    }
  }

  IconData _icon(Category c) {
    switch (c) {
      case Category.work:
        return Icons.work_outline_rounded;
      case Category.personal:
        return Icons.person_outline_rounded;
      case Category.shopping:
        return Icons.shopping_cart_outlined;
      case Category.health:
        return Icons.favorite_outline_rounded;
      case Category.other:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Category.values.map((c) {
        final color = _color(c);
        final isSelected = selected == c;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon(c), size: 16, color: isSelected ? color : AppColors.textHint),
                const SizedBox(width: 6),
                Text(
                  c.label,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final TodoStatus selected;
  final ValueChanged<TodoStatus> onChanged;

  const _StatusSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TodoStatus.values.map((s) {
        final color = s == TodoStatus.todo
            ? AppColors.info
            : s == TodoStatus.inProgress
                ? AppColors.warning
                : AppColors.success;
        final isSelected = selected == s;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  s.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DueDatePicker extends StatelessWidget {
  final DateTime? dueDate;
  final ValueChanged<DateTime?> onChanged;

  const _DueDatePicker({required this.dueDate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dueDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                      surface: AppColors.surface,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.textHint, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    dueDate != null
                        ? DateFormat('EEEE, MMM d, yyyy').format(dueDate!)
                        : 'Select due date',
                    style: TextStyle(
                      color: dueDate != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (dueDate != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(null),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
            ),
          ),
        ],
      ],
    );
  }
}
