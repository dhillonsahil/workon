import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workon/db/database_helper.dart';
import 'package:workon/models/entry.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final today = DateTime.now();
      final daysSince2020 = today.difference(DateTime(2020)).inDays;
      final controller = PrimaryScrollController.of(context);
      controller.jumpTo(daysSince2020 * 56.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),
          ),
          Consumer<EntryProvider>(
            builder: (context, provider, _) {
              final entries = provider.getEntriesForDate(_selectedDate);
              if (entries.isEmpty) {
                return const SliverToBoxAdapter(child: _EmptyState());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final entry = entries[i];
                    return Dismissible(
                      key: ValueKey(entry.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _showDeleteDialog(context, entry),
                      onDismissed: (_) {
                        provider.addEntry(
                          entry.copyWith(id: null),
                        ); // temp re-add for undo
                        provider.loadEntries(); // refresh
                      },
                      child: InkWell(
                        onTap: () => _showEditDialog(context, entry),
                        child: EntryCard(entry: entry),
                      ),
                    );
                  }, childCount: entries.length),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddEntryDialog(date: _selectedDate),
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, WorkEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Entry?"),
        content: Text(
          "Remove \"${entry.title}\" from ${_formatDate(entry.date)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteEntry(entry.id!);
      context.read<EntryProvider>().loadEntries();
    }
    return false;
  }

  void _showEditDialog(BuildContext context, WorkEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AddEntryDialog(date: entry.date, entryToEdit: entry),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.note_add, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No entries yet",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text("Tap + to add your first log"),
        ],
      ),
    );
  }
}
