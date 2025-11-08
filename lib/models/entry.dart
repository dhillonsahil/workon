class WorkEntry {
  final int? id;
  final String title;
  final String description;
  final int hours;
  final int minutes;
  final DateTime date;

  WorkEntry({
    this.id,
    required this.title,
    required this.description,
    required this.hours,
    required this.minutes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hours': hours,
      'minutes': minutes,
      'date': date.toIso8601String().split('T')[0],
    };
  }

  factory WorkEntry.fromMap(Map<String, dynamic> map) {
    return WorkEntry(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      hours: map['hours'],
      minutes: map['minutes'],
      date: DateTime.parse(map['date']),
    );
  }

  int get totalMinutes => hours * 60 + minutes;

  String get formattedTime {
    final h = hours > 0 ? '${hours}h ' : '';
    final m = minutes > 0 ? '${minutes}m' : '';
    return (h + m).trim();
  }

  WorkEntry copyWith({
    int? id,
    String? title,
    String? description,
    int? hours,
    int? minutes,
    DateTime? date,
  }) {
    return WorkEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      date: date ?? this.date,
    );
  }
}
