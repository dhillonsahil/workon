import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/work_title.dart';
import '../providers/title_provider.dart';

class TitlesTagsScreen extends StatefulWidget {
  const TitlesTagsScreen({super.key});

  @override
  State<TitlesTagsScreen> createState() => _TitlesTagsScreenState();
}

class _TitlesTagsScreenState extends State<TitlesTagsScreen> {
  final _titleCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final titles = context.watch<TitleProvider>().titles;
    final tags = context.watch<TitleProvider>().tags;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Titles & Tags"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Titles"),
              Tab(text: "Tags"),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildTitlesTab(titles), _buildTagsTab(tags)],
        ),
      ),
    );
  }

  Widget _buildTitlesTab(List<WorkTitle> titles) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: "New Title",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTitle,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: titles.isEmpty
              ? const Center(child: Text("No titles yet"))
              : ListView.builder(
                  itemCount: titles.length,
                  itemBuilder: (ctx, i) {
                    final title = titles[i];
                    return ListTile(
                      title: Text(title.name),
                      subtitle: title.tag != null
                          ? Text("#${title.tag}")
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTitle(title),
                      ),
                      onTap: () => _editTitle(title),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTagsTab(Set<String> tags) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagCtrl,
                  decoration: const InputDecoration(
                    labelText: "New Tag",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addTag, child: const Icon(Icons.add)),
            ],
          ),
        ),
        Expanded(
          child: tags.isEmpty
              ? const Center(child: Text("No tags yet"))
              : ListView.builder(
                  itemCount: tags.length,
                  itemBuilder: (ctx, i) {
                    final tag = tags.elementAt(i);
                    return ListTile(
                      title: Text("#$tag"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTag(tag),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _addTitle() {
    final name = _titleCtrl.text.trim();
    if (name.isEmpty) return;
    context.read<TitleProvider>().addTitle(WorkTitle(name: name));
    _titleCtrl.clear();
  }

  void _editTitle(WorkTitle title) {
    final nameCtrl = TextEditingController(text: title.name);
    final tagCtrl = TextEditingController(text: title.tag ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Title"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: tagCtrl,
              decoration: const InputDecoration(labelText: "Tag"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              if (newName.isEmpty) return;
              context.read<TitleProvider>().updateTitle(
                title.copyWith(
                  name: newName,
                  tag: tagCtrl.text.trim().isEmpty ? null : tagCtrl.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteTitle(WorkTitle title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Title?"),
        content: Text("Remove \"${title.name}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<TitleProvider>().deleteTitle(title);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty) return;
    context.read<TitleProvider>().addTag(tag);
    _tagCtrl.clear();
  }

  void _deleteTag(String tag) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Tag?"),
        content: Text("Remove \"#$tag\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<TitleProvider>().removeTag(tag);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
