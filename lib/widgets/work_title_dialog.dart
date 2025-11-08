import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/work_title.dart';
import '../providers/title_provider.dart';

void showWorkTitleDialog(BuildContext context) {
  final nameController = TextEditingController();
  final tagController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Add Work Title"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Title *",
                hintText: "e.g. English, Gym, Coding",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: "Tag (optional)",
                hintText: "e.g. Study, Exercise",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text("Title is required")),
              );
              return;
            }
            final title = WorkTitle(
              name: name,
              tag: tagController.text.trim().isEmpty
                  ? null
                  : tagController.text.trim(),
            );
            context.read<TitleProvider>().addTitle(title);
            Navigator.pop(ctx);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
