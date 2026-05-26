import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/todo_model.dart';
import '../../../providers/filter_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All
          _FilterChip(
            label: 'All',
            isSelected: filter.category == null &&
                filter.priority == null &&
                filter.status == null,
            onTap: () => ref.read(filterProvider.notifier).clearAll(),
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),

          // Status filters
          _FilterChip(
            label: 'To Do',
            isSelected: filter.status == TodoStatus.todo,
            onTap: () => ref.read(filterProvider.notifier).setStatus(
                  filter.status == TodoStatus.todo ? null : TodoStatus.todo,
                ),
            color: AppColors.info,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'In Progress',
            isSelected: filter.status == TodoStatus.inProgress,
            onTap: () => ref.read(filterProvider.notifier).setStatus(
                  filter.status == TodoStatus.inProgress
                      ? null
                      : TodoStatus.inProgress,
                ),
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Done',
            isSelected: filter.status == TodoStatus.done,
            onTap: () => ref.read(filterProvider.notifier).setStatus(
                  filter.status == TodoStatus.done ? null : TodoStatus.done,
                ),
            color: AppColors.success,
          ),
          const SizedBox(width: 8),

          // Priority filters
          _FilterChip(
            label: '🔴 High',
            isSelected: filter.priority == Priority.high,
            onTap: () => ref.read(filterProvider.notifier).setPriority(
                  filter.priority == Priority.high ? null : Priority.high,
                ),
            color: AppColors.priorityHigh,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '🟡 Medium',
            isSelected: filter.priority == Priority.medium,
            onTap: () => ref.read(filterProvider.notifier).setPriority(
                  filter.priority == Priority.medium ? null : Priority.medium,
                ),
            color: AppColors.priorityMedium,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '🟢 Low',
            isSelected: filter.priority == Priority.low,
            onTap: () => ref.read(filterProvider.notifier).setPriority(
                  filter.priority == Priority.low ? null : Priority.low,
                ),
            color: AppColors.priorityLow,
          ),
          const SizedBox(width: 8),

          // Category filters
          ...Category.values.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: cat.label,
                  isSelected: filter.category == cat,
                  onTap: () => ref.read(filterProvider.notifier).setCategory(
                        filter.category == cat ? null : cat,
                      ),
                  color: _categoryColor(cat),
                ),
              )),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn();
  }

  Color _categoryColor(Category cat) {
    switch (cat) {
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
