// lib/utils/export_import.dart
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workon/db/database_helper.dart';
import 'package:workon/providers/entry_provider.dart';
import 'package:workon/providers/todo_provider.dart';

class ExportImport {
  // EXPORT — uses current entries & todos from providers (must be called inside widget tree)
  static Future<void> exportData(BuildContext context) async {
    try {
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);

      final entries = entryProvider.entries;
      final todos = todoProvider.todos;

      final data = [
        [
          'Type',
          'Title',
          'Description',
          'Tag',
          'Date',
          'Hours',
          'Minutes',
          'Priority',
          'Completed',
          'Time Taken',
        ],
        ...entries.map(
          (e) => [
            'Work',
            e.title,
            e.description ?? '',
            e.tag ?? '',
            '${e.date.day}/${e.date.month}/${e.date.year}',
            e.hours,
            e.minutes,
            '',
            '',
            '',
          ],
        ),
        ...todos.map(
          (t) => [
            'Todo',
            t.title,
            t.description ?? '',
            t.tag ?? '',
            '${t.dueDate.day}/${t.dueDate.month}/${t.dueDate.year}',
            '',
            '',
            t.priority,
            t.isCompleted ? 'Yes' : 'No',
            t.timeTakenMinutes?.toString() ?? '',
          ],
        ),
      ];

      final csv = const ListToCsvConverter().convert(data);
      final fileName =
          'workon_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final xfile = XFile.fromData(
        utf8.encode(csv),
        mimeType: 'text/csv',
        name: fileName,
      );

      await Share.shareXFiles([xfile], text: 'My WorkOn Data Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // IMPORT — Full CSV import with reload
  static Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'Select WorkOn CSV Export',
      );

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        _showError(context, "Could not read file");
        return;
      }

      final csvString = utf8.decode(bytes);
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows[0][0] != 'Type') {
        _showError(context, "Invalid CSV format");
        return;
      }

      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();

      // Clear existing data
      await db.delete('entries');
      await db.delete('todos');

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final type = row[0].toString();

        if (type == 'Work') {
          final dateParts = row[4].toString().split('/');
          batch.insert('entries', {
            'title': row[1],
            'description': row[2].toString().isNotEmpty ? row[2] : null,
            'tag': row[3].toString().isNotEmpty ? row[3] : null,
            'date': DateTime(
              int.parse(dateParts[2]),
              int.parse(dateParts[1]),
              int.parse(dateParts[0]),
            ).millisecondsSinceEpoch,
            'hours': int.tryParse(row[5].toString()) ?? 0,
            'minutes': int.tryParse(row[6].toString()) ?? 0,
          });
        } else if (type == 'Todo') {
          final dateParts = row[4].toString().split('/');
          batch.insert('todos', {
            'title': row[1],
            'description': row[2].toString().isNotEmpty ? row[2] : null,
            'tag': row[3].toString().isNotEmpty ? row[3] : null,
            'priority': row[7],
            'dueDate': DateTime(
              int.parse(dateParts[2]),
              int.parse(dateParts[1]),
              int.parse(dateParts[0]),
            ).millisecondsSinceEpoch,
            'isCompleted': row[8] == 'Yes' ? 1 : 0,
            'timeTakenMinutes': row[9].toString().isNotEmpty
                ? int.tryParse(row[9].toString())
                : null,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }

      await batch.commit(noResult: true);

      // Reload data
      if (context.mounted) {
        Provider.of<EntryProvider>(context, listen: false).loadEntries();
        Provider.of<TodoProvider>(context, listen: false).loadTodos();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Import successful!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, "Import failed: $e");
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
