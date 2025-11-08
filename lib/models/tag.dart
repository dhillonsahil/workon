import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String name;
  final String color; // e.g., "indigo", "green"

  Tag({this.id, required this.name, this.color = "indigo"});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color};
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      color: map['color'] ?? "indigo",
    );
  }

  Color get colorValue {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.amber;
      default:
        return Colors.indigo;
    }
  }
}
