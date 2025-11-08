import 'package:flutter/material.dart';
import '../utils/export_import.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Data Management"),
          _buildActionTile(
            context,
            icon: Icons.upload_file,
            title: "Export Data",
            subtitle: "Save all entries and titles to a JSON file",
            onTap: () => ExportImport.exportData(context),
          ),
          _buildActionTile(
            context,
            icon: Icons.download,
            title: "Import Data",
            subtitle: "Restore from a previously exported file",
            onTap: () => ExportImport.importData(context),
          ),
          const Divider(height: 32),
          _buildSectionTitle("About"),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text("Made with Flutter"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
