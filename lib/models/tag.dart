class WorkEntry {
  final int? id;
  final String title;
  final String description;
  final int hours;
  final int minutes;
  final DateTime date;
  final String? tag; // ADD THIS

  WorkEntry({
    this.id,
    required this.title,
    this.description = '',
    required this.hours,
    required this.minutes,
    required this.date,
    this.tag, // ADD THIS
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hours': hours,
      'minutes': minutes,
      'date': date.millisecondsSinceEpoch,
      'tag': tag, // ADD THIS
    };
  }

  static WorkEntry fromMap(Map<String, dynamic> map) {
    return WorkEntry(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      hours: map['hours'],
      minutes: map['minutes'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      tag: map['tag'], // ADD THIS
    );
  }

  // ADD copyWith
  WorkEntry copyWith({
    int? id,
    String? title,
    String? description,
    int? hours,
    int? minutes,
    DateTime? date,
    String? tag,
  }) {
    return WorkEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      date: date ?? this.date,
      tag: tag ?? this.tag,
    );
  }
}
