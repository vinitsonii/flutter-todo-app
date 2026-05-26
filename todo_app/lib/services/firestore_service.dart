import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference to user's todos collection
  CollectionReference<Map<String, dynamic>> _todosRef(String userId) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.todosCollection);
  }

  // Real-time stream of todos
  Stream<List<TodoModel>> getTodos(String userId) {
    return _todosRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoModel.fromFirestore(doc))
            .toList());
  }

  // Add a new todo
  Future<void> addTodo(TodoModel todo) async {
    await _todosRef(todo.userId).doc(todo.id).set(todo.toFirestore());
  }

  // Update an existing todo
  Future<void> updateTodo(TodoModel todo) async {
    await _todosRef(todo.userId).doc(todo.id).update({
      ...todo.toFirestore(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Delete a todo
  Future<void> deleteTodo(String userId, String todoId) async {
    await _todosRef(userId).doc(todoId).delete();
  }

  // Toggle todo status (cycle: todo → inProgress → done → todo)
  Future<void> toggleStatus(TodoModel todo) async {
    final nextStatus = switch (todo.status) {
      TodoStatus.todo => TodoStatus.inProgress,
      TodoStatus.inProgress => TodoStatus.done,
      TodoStatus.done => TodoStatus.todo,
    };
    await _todosRef(todo.userId).doc(todo.id).update({
      'status': nextStatus.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
