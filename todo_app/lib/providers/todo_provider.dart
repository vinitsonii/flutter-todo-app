import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'filter_provider.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// Raw stream of all todos for current user
final todosStreamProvider = StreamProvider<List<TodoModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getTodos(user.uid);
});

// Filtered todos based on selected filters
final filteredTodosProvider = Provider<AsyncValue<List<TodoModel>>>((ref) {
  final todosAsync = ref.watch(todosStreamProvider);
  final filter = ref.watch(filterProvider);

  return todosAsync.whenData((todos) {
    var filtered = todos;

    // Category filter
    if (filter.category != null) {
      filtered = filtered
          .where((t) => t.category == filter.category)
          .toList();
    }

    // Priority filter
    if (filter.priority != null) {
      filtered = filtered
          .where((t) => t.priority == filter.priority)
          .toList();
    }

    // Status filter
    if (filter.status != null) {
      filtered = filtered
          .where((t) => t.status == filter.status)
          .toList();
    }

    // Search filter
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              t.description.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  });
});

// Stats provider
final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todos = ref.watch(todosStreamProvider).valueOrNull ?? [];
  return {
    'total': todos.length,
    'done': todos.where((t) => t.status == TodoStatus.done).length,
    'inProgress': todos.where((t) => t.status == TodoStatus.inProgress).length,
    'todo': todos.where((t) => t.status == TodoStatus.todo).length,
    'overdue': todos.where((t) => t.isOverdue).length,
  };
});
