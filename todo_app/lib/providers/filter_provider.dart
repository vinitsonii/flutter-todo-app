import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';

class TodoFilter {
  final Category? category;
  final Priority? priority;
  final TodoStatus? status;
  final String searchQuery;

  const TodoFilter({
    this.category,
    this.priority,
    this.status,
    this.searchQuery = '',
  });

  TodoFilter copyWith({
    Category? category,
    bool clearCategory = false,
    Priority? priority,
    bool clearPriority = false,
    TodoStatus? status,
    bool clearStatus = false,
    String? searchQuery,
  }) {
    return TodoFilter(
      category: clearCategory ? null : (category ?? this.category),
      priority: clearPriority ? null : (priority ?? this.priority),
      status: clearStatus ? null : (status ?? this.status),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FilterNotifier extends StateNotifier<TodoFilter> {
  FilterNotifier() : super(const TodoFilter());

  void setCategory(Category? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
    );
  }

  void setPriority(Priority? priority) {
    state = state.copyWith(
      priority: priority,
      clearPriority: priority == null,
    );
  }

  void setStatus(TodoStatus? status) {
    state = state.copyWith(
      status: status,
      clearStatus: status == null,
    );
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearAll() {
    state = const TodoFilter();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, TodoFilter>(
  (ref) => FilterNotifier(),
);
