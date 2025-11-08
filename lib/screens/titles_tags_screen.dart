import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/work_title.dart';
import '../providers/title_provider.dart';

class TitlesTagsScreen extends StatefulWidget {
  const TitlesTagsScreen({super.key});

  @override
  State<TitlesTagsScreen> createState() => _TitlesTagsScreenState();
}

class _TitlesTagsScreenState extends State<TitlesTagsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = context.watch<TitleProvider>().titles;
    final tags = context.watch<TitleProvider>().tags;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Titles & Tags"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Titles"),
            Tab(text: "Tags"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTitlesTab(titles, tags), _buildTagsTab(tags)],
      ),
    );
  }

  // ==================== TITLES TAB ====================
  Widget _buildTitlesTab(List<WorkTitle> titles, Set<String> tags) {
    String? selectedTag;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ADD TITLE
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: "New Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setStateDropdown) {
                      return DropdownButtonFormField<String>(
                        value: selectedTag,
                        decoration: const InputDecoration(
                          labelText: "Tag",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          ...tags.map(
                            (t) =>
                                DropdownMenuItem(value: t, child: Text("#$t")),
                          ),
                          const DropdownMenuItem(
                            value: "_add_new",
                            child: Text("Add New Tag"),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == "_add_new") {
                            final newTag = await _showAddTagDialog();
                            if (newTag != null) {
                              setStateDropdown(() => selectedTag = newTag);
                            }
                          } else {
                            setStateDropdown(() => selectedTag = value);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final name = _titleCtrl.text.trim();
                      if (name.isEmpty) return;
                      context.read<TitleProvider>().addTitle(
                        WorkTitle(
                          name: name,
                          tag: selectedTag == "_add_new" ? null : selectedTag,
                        ),
                      );
                      _titleCtrl.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Title"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // TITLES LIST
          Expanded(
            child: titles.isEmpty
                ? const Center(child: Text("No titles yet"))
                : ListView.builder(
                    itemCount: titles.length,
                    itemBuilder: (ctx, i) {
                      final title = titles[i];
                      return Card(
                        child: ListTile(
                          title: Text(
                            title.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: title.tag != null
                              ? Text("#${title.tag}")
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // EDIT BUTTON
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: "Edit Title",
                                onPressed: () => _editTitle(title, tags),
                              ),
                              // DELETE BUTTON
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: "Delete Title",
                                onPressed: () => _deleteTitle(title),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== TAGS TAB ====================
  Widget _buildTagsTab(Set<String> tags) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ADD TAG
          Card(
            child: Padding(
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
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final tag = _tagCtrl.text.trim();
                      if (tag.isNotEmpty && !tags.contains(tag)) {
                        context.read<TitleProvider>().addTag(tag);
                        _tagCtrl.clear();
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // TAGS LIST
          Expanded(
            child: tags.isEmpty
                ? const Center(child: Text("No tags yet"))
                : ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (ctx, i) {
                      final tag = tags.elementAt(i);
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.tag, color: Colors.indigo),
                          title: Text("#$tag"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // EDIT TAG
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: "Edit Tag",
                                onPressed: () => _editTag(tag),
                              ),
                              // DELETE TAG
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: "Delete Tag",
                                onPressed: () => _deleteTag(tag),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==================== EDIT TITLE ====================
  void _editTitle(WorkTitle title, Set<String> tags) {
    final nameCtrl = TextEditingController(text: title.name);
    String? selectedTag = title.tag;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Title"),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setStateDialog) {
                    // ENSURE selectedTag exists in current tags
                    final validTag = tags.contains(selectedTag)
                        ? selectedTag
                        : null;

                    return DropdownButtonFormField<String>(
                      value: validTag,
                      decoration: const InputDecoration(
                        labelText: "Tag",
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        ...tags.map(
                          (t) => DropdownMenuItem(value: t, child: Text("#$t")),
                        ),
                        const DropdownMenuItem(
                          value: "_add_new",
                          child: Text("Add New Tag"),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == "_add_new") {
                          final newTag = await _showAddTagDialog();
                          if (newTag != null) {
                            setStateDialog(() => selectedTag = newTag);
                          }
                        } else {
                          setStateDialog(() => selectedTag = value);
                        }
                      },
                    );
                  },
                ),
              ],
            );
          },
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
                  tag: selectedTag == "_add_new" ? null : selectedTag,
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

  // ==================== EDIT TAG ====================
  void _editTag(String oldTag) {
    final ctrl = TextEditingController(text: oldTag);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Tag"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: "New Tag Name",
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
              final newTag = ctrl.text.trim();
              if (newTag.isNotEmpty && newTag != oldTag) {
                context.read<TitleProvider>().updateTag(oldTag, newTag);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // ==================== DELETE TITLE ====================
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

  // ==================== DELETE TAG ====================
  void _deleteTag(String tag) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Tag?"),
        content: Text("Remove \"#$tag\" from all entries and titles?"),
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

  // ==================== ADD TAG DIALOG ====================
  Future<String?> _showAddTagDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Tag"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: "e.g. Study",
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
              final tag = ctrl.text.trim();
              if (tag.isNotEmpty &&
                  !context.read<TitleProvider>().tags.contains(tag)) {
                context.read<TitleProvider>().addTag(tag);
                Navigator.pop(ctx, tag);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
