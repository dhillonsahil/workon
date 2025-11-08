import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart'; // ADD THIS
import '../db/database_helper.dart';
import '../providers/entry_provider.dart';
import '../providers/title_provider.dart';

class ExportImport {
  static Future<void> exportData(BuildContext context) async {
    if (!await _requestStoragePermission()) {
      _showSnackBar(context, "Storage permission is required to export data.");
      return;
    }

    try {
      final db = await DatabaseHelper.instance.database;
      final entries = await db.query('entries');
      final titles = await db.query('work_titles');
      final tags = await db.query('tags');

      final data = {
        'entries': entries,
        'work_titles': titles,
        'tags': tags,
        'exported_at': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(data);
      final directory = await getExternalStorageDirectory();
      final fileName = 'workon_export_${_timestamp()}.json';
      final file = File('${directory!.path}/$fileName');
      await file.writeAsString(jsonString);

      _showSnackBar(
        context,
        "Exported successfully!\nSaved to: $fileName",
        isSuccess: true,
      );
    } catch (e) {
      _showSnackBar(context, "Export failed: ${e.toString()}");
    }
  }

  static Future<void> importData(BuildContext context) async {
    if (!await _requestStoragePermission()) {
      _showSnackBar(context, "Storage permission is required to import data.");
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();

      batch.delete('entries');
      batch.delete('work_titles');
      batch.delete('tags');

      for (final e in data['entries'] ?? []) batch.insert('entries', e);
      for (final t in data['work_titles'] ?? []) batch.insert('work_titles', t);
      for (final g in data['tags'] ?? []) batch.insert('tags', g);

      await batch.commit(noResult: true);

      // RELOAD PROVIDERS SAFELY
      Future.microtask(() {
        final entryProvider = Provider.of<EntryProvider>(
          context,
          listen: false,
        );
        final titleProvider = Provider.of<TitleProvider>(
          context,
          listen: false,
        );

        entryProvider.loadEntries();
        titleProvider.loadTitles();
      });

      _showSnackBar(context, "Data imported successfully!", isSuccess: true);
    } catch (e) {
      _showSnackBar(context, "Import failed: ${e.toString()}");
    }
  }

  static Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green[700] : Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _timestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}';
  }
}
