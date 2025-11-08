class WorkTitle {
  final int? id;
  final String name;
  final String? tag;

  WorkTitle({this.id, required this.name, this.tag});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'tag': tag};
  }

  factory WorkTitle.fromMap(Map<String, dynamic> map) {
    return WorkTitle(id: map['id'], name: map['name'], tag: map['tag']);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkTitle && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  // ADD THIS METHOD
  WorkTitle copyWith({int? id, String? name, String? tag}) {
    return WorkTitle(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
    );
  }
}
