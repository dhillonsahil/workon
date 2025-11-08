import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../widgets/entry_card.dart';
import '../widgets/add_entry_dialog.dart';

class DailyProgressTab extends StatefulWidget {
  const DailyProgressTab({super.key});

  @override
  State<DailyProgressTab> createState() => _DailyProgressTabState();
}

class _DailyProgressTabState extends State<DailyProgressTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Auto-scroll to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now();
      final daysSince2020 = today.difference(DateTime(2020)).inDays;
      final scrollController = PrimaryScrollController.of(context);
      scrollController.jumpTo(daysSince2020 * 56.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (date) => setState(() => _selectedDate = date),
          ),
          Expanded(
            child: Consumer<EntryProvider>(
              builder: (context, provider, _) {
                final entries = provider.getEntriesForDate(_selectedDate);
                if (entries.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (ctx, i) => EntryCard(entry: entries[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddEntryDialog(date: _selectedDate),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No entries for ${_formatDate(_selectedDate)}",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap + to add your first log",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
