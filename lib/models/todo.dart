// lib/models/todo.dart
class Todo {
  final int? id;
  final String title;
  final String description;
  final String? tag;
  final String priority; // 'high', 'medium', 'low'
  final DateTime dueDate;
  final bool isCompleted;
  final int? timeTakenMinutes; // Only set when completed
  final DateTime createdAt;

  Todo({
    this.id,
    required this.title,
    this.description = '',
    this.tag,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    this.timeTakenMinutes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tag': tag,
      'priority': priority,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'isCompleted': isCompleted ? 1 : 0,
      'timeTakenMinutes': timeTakenMinutes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      tag: map['tag'],
      priority: map['priority'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      timeTakenMinutes: map['timeTakenMinutes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Todo copyWith({
    int? id,
    String? title,
    String? description,
    String? tag,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    int? timeTakenMinutes,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tag: tag ?? this.tag,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      timeTakenMinutes: timeTakenMinutes ?? this.timeTakenMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
