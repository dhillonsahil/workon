import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSettingsTap;
  final VoidCallback onTitlesTap;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onSettingsTap,
    required this.onTitlesTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.list_alt),
          tooltip: "Work Titles",
          onPressed: onTitlesTap,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: "Settings",
          onPressed: onSettingsTap,
        ),
      ],
    );
  }
}
