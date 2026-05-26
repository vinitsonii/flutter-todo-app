import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/todo_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/todo_provider.dart';

class TaskCard extends ConsumerWidget {
  final TodoModel todo;
  final int index;

  const TaskCard({super.key, required this.todo, required this.index});

  Color get _priorityColor {
    switch (todo.priority) {
      case Priority.low:
        return AppColors.priorityLow;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.high:
        return AppColors.priorityHigh;
    }
  }

  Color get _categoryColor {
    switch (todo.category) {
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

  Color get _statusColor {
    switch (todo.status) {
      case TodoStatus.todo:
        return AppColors.info;
      case TodoStatus.inProgress:
        return AppColors.warning;
      case TodoStatus.done:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = todo.status == TodoStatus.done;
    final user = ref.watch(currentUserProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Slidable(
      key: ValueKey(todo.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => context.push('/home/edit', extra: todo),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
            borderRadius: BorderRadius.circular(16),
          ),
          SlidableAction(
            onPressed: (_) async {
              if (user != null) {
                await firestoreService.deleteTodo(user.uid, todo.id);
              }
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => context.push('/home/edit', extra: todo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.card.withValues(alpha: 0.5)
                : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: todo.isOverdue
                  ? AppColors.error.withValues(alpha: 0.4)
                  : _priorityColor.withValues(alpha: 0.2),
              width: 0.5,
            ),
            boxShadow: isDone
                ? []
                : [
                    BoxShadow(
                      color: AppColors.background.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status toggle button
                GestureDetector(
                  onTap: () => firestoreService.toggleStatus(todo),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _statusColor,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),

                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              todo.title,
                              style: TextStyle(
                                color: isDone
                                    ? AppColors.textHint
                                    : AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.textHint,
                              ),
                            ),
                          ),
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _categoryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              todo.category.label,
                              style: TextStyle(
                                color: _categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          todo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDone
                                ? AppColors.textHint
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Bottom row: Priority + Due date + Status
                      Row(
                        children: [
                          // Priority indicator
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: _priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            todo.priority.label,
                            style: TextStyle(
                              color: _priorityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          // Due date
                          if (todo.dueDate != null) ...[
                            Icon(
                              todo.isOverdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.calendar_today_outlined,
                              size: 12,
                              color: todo.isOverdue
                                  ? AppColors.error
                                  : AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d').format(todo.dueDate!),
                              style: TextStyle(
                                color: todo.isOverdue
                                    ? AppColors.error
                                    : AppColors.textHint,
                                fontSize: 11,
                                fontWeight: todo.isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],

                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              todo.status.label,
                              style: TextStyle(
                                color: _statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
