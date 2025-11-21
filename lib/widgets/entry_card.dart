// lib/widgets/entry_card.dart
import 'package:flutter/material.dart';
import 'package:workon/models/entry.dart';

class EntryCard extends StatelessWidget {
  final WorkEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const EntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Tag
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (entry.tag != null && entry.tag!.isNotEmpty)
                    Chip(
                      label: Text(
                        "#${entry.tag}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.indigo.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Description — FIXED: Now null-safe
              if (entry.description?.isNotEmpty == true) ...[
                Text(
                  entry.description!, // Safe because we checked isNotEmpty
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
              ],

              // Time + Hours
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${entry.hours}h ${entry.minutes}m",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
