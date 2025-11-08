// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../db/database_helper.dart';
// import 'package:provider/provider.dart';
// import '../providers/entry_provider.dart';
// import '../providers/title_provider.dart';

// class ExportImport {
//   // EXPORT
//   static Future<void> exportData(BuildContext context) async {
//     try {
//       // Try SAF first (no permission needed)
//       final directoryPath = await FilePicker.platform.getDirectoryPath(
//         dialogTitle: 'Choose export folder',
//       );

//       final db = await DatabaseHelper.instance.database;
//       final entries = await db.query('entries');
//       final titles = await db.query('work_titles');
//       final tags = await db.query('tags');

//       final data = {
//         'entries': entries,
//         'work_titles': titles,
//         'tags': tags,
//         'exported_at': DateTime.now().toIso8601String(),
//       };

//       final jsonString = jsonEncode(data);
//       final fileName =
//           await _promptFileName(context) ??
//           'workon_export_${_timestamp()}.json';

//       String filePath;

//       if (directoryPath != null) {
//         filePath = '$directoryPath/$fileName';
//       } else {
//         // Fallback: request permission + use external storage
//         if (!await _requestPermission(context)) {
//           _showSnackBar(context, "Permission denied.");
//           return;
//         }
//         final dir = await getExternalStorageDirectory();
//         if (dir == null) {
//           _showSnackBar(context, "Could not access storage.");
//           return;
//         }
//         filePath = '${dir.path}/$fileName';
//       }

//       final file = File(filePath);
//       await file.writeAsString(jsonString);

//       _showSnackBar(context, "Exported to:\n$filePath", isSuccess: true);
//     } catch (e) {
//       _showSnackBar(context, "Export failed: $e");
//     }
//   }

//   // IMPORT
//   static Future<void> importData(BuildContext context) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//         dialogTitle: 'Select WorkOn Export File',
//       );

//       if (result == null || result.files.isEmpty) {
//         _showSnackBar(context, "Import cancelled");
//         return;
//       }

//       final file = File(result.files.single.path!);
//       final jsonString = await file.readAsString();
//       final data = jsonDecode(jsonString) as Map<String, dynamic>;

//       final db = await DatabaseHelper.instance.database;
//       final batch = db.batch();
//       batch.delete('entries');
//       batch.delete('work_titles');
//       batch.delete('tags');
//       for (final e in data['entries'] ?? []) batch.insert('entries', e);
//       for (final t in data['work_titles'] ?? []) batch.insert('work_titles', t);
//       for (final g in data['tags'] ?? []) batch.insert('tags', g);
//       await batch.commit(noResult: true);

//       Future.microtask(() {
//         Provider.of<EntryProvider>(context, listen: false).loadEntries();
//         Provider.of<TitleProvider>(context, listen: false).loadTitles();
//       });

//       _showSnackBar(context, "Imported successfully!", isSuccess: true);
//     } catch (e) {
//       _showSnackBar(context, "Import failed: $e");
//     }
//   }

//   // PERMISSION
//   static Future<bool> _requestPermission(BuildContext context) async {
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       status = await Permission.storage.request();
//     }
//     return status.isGranted;
//   }

//   // PROMPT FILE NAME
//   static Future<String?> _promptFileName(BuildContext context) async {
//     final controller = TextEditingController(
//       text: 'workon_export_${_timestamp()}.json',
//     );
//     return showDialog<String>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Export File Name"),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             hintText: "e.g. my_data.json",
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               var name = controller.text.trim();
//               if (name.isEmpty) return;
//               if (!name.endsWith('.json')) name = '$name.json';
//               Navigator.pop(ctx, name);
//             },
//             child: const Text("Export"),
//           ),
//         ],
//       ),
//     );
//   }

//   // SNACKBAR
//   static void _showSnackBar(
//     BuildContext context,
//     String message, {
//     bool isSuccess = false,
//   }) {
//     if (!context.mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isSuccess ? Colors.green[700] : Colors.red[700],
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }

//   // TIMESTAMP
//   static String _timestamp() {
//     final now = DateTime.now();
//     return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}';
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../providers/title_provider.dart';

class ExportImport {
  // EXPORT
  static Future<void> exportData(BuildContext context) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Fetch all data with proper tables
      final entries = await db.query('entries');
      final workTitles = await db.query('work_titles');
      final tags = await db.query('tags');

      final exportData = {
        'entries': entries,
        'work_titles': workTitles,
        'tags': tags,
        'exported_at': DateTime.now().toIso8601String(),
        'version': 2, // For future compatibility
      };

      final jsonString = jsonEncode(exportData);

      // Prompt filename
      final fileName =
          await _promptFileName(context) ??
          'workon_export_${_timestamp()}.json';

      // Let user pick folder (SAF - no permission needed)
      final directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose Export Folder',
      );

      String filePath;

      if (directoryPath != null) {
        filePath = '$directoryPath/$fileName';
      } else {
        // Fallback: use app-specific external storage
        if (!await _requestPermission(context)) {
          _showSnackBar(context, "Permission denied. Using app folder.");
          final dir = await getApplicationDocumentsDirectory();
          filePath = '${dir.path}/$fileName';
        } else {
          final dir = await getExternalStorageDirectory();
          if (dir == null) {
            _showSnackBar(context, "Storage unavailable. Using app folder.");
            final appDir = await getApplicationDocumentsDirectory();
            filePath = '${appDir.path}/$fileName';
          } else {
            filePath = '${dir.path}/$fileName';
          }
        }
      }

      final file = File(filePath);
      await file.writeAsString(jsonString);

      _showSnackBar(
        context,
        "Exported successfully!\n$filePath",
        isSuccess: true,
      );
    } catch (e) {
      _showSnackBar(context, "Export failed: $e");
    }
  }

  // IMPORT
  static Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select WorkOn Backup File',
      );

      if (result == null || result.files.isEmpty) {
        _showSnackBar(context, "Import cancelled");
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final db = await DatabaseHelper.instance.database;
      final batch = db.batch();

      // Clear existing data
      await db.delete('entries');
      await db.delete('work_titles');
      await db.delete('tags');

      // Insert new data
      for (final e in data['entries'] ?? []) {
        await db.insert(
          'entries',
          e,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final t in data['work_titles'] ?? []) {
        await db.insert(
          'work_titles',
          t,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final g in data['tags'] ?? []) {
        await db.insert(
          'tags',
          g,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Reload providers
      Future.microtask(() {
        Provider.of<EntryProvider>(context, listen: false).loadEntries();
        Provider.of<TitleProvider>(context, listen: false).loadTitles();
      });

      _showSnackBar(context, "Imported successfully!", isSuccess: true);
    } catch (e) {
      _showSnackBar(context, "Import failed: $e");
    }
  }

  // PERMISSION (only for fallback)
  static Future<bool> _requestPermission(BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // PROMPT FILE NAME
  static Future<String?> _promptFileName(BuildContext context) async {
    final controller = TextEditingController(
      text: 'workon_export_${_timestamp()}.json',
    );

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Export File Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "e.g. my_backup.json",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              var name = controller.text.trim();
              if (name.isEmpty) return;
              if (!name.endsWith('.json')) name = '$name.json';
              Navigator.pop(ctx, name);
            },
            child: const Text("Export"),
          ),
        ],
      ),
    );
  }

  // SNACKBAR
  static void _showSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green[700] : Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  // TIMESTAMP
  static String _timestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }
}
