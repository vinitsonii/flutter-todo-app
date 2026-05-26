import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

enum TodoStatus { todo, inProgress, done }

enum Category { work, personal, shopping, health, other }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }
}

extension TodoStatusExtension on TodoStatus {
  String get label {
    switch (this) {
      case TodoStatus.todo:
        return 'To Do';
      case TodoStatus.inProgress:
        return 'In Progress';
      case TodoStatus.done:
        return 'Done';
    }
  }
}

extension CategoryExtension on Category {
  String get label {
    switch (this) {
      case Category.work:
        return 'Work';
      case Category.personal:
        return 'Personal';
      case Category.shopping:
        return 'Shopping';
      case Category.health:
        return 'Health';
      case Category.other:
        return 'Other';
    }
  }
}

class TodoModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final Category category;
  final Priority priority;
  final TodoStatus status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.category,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue {
    if (dueDate == null || status == TodoStatus.done) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    Category? category,
    Priority? priority,
    TodoStatus? status,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'userId': userId,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      category: Category.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => Category.other,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => Priority.medium,
      ),
      status: TodoStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TodoStatus.todo,
      ),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
