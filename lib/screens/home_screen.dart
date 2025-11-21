// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:workon/screens/daily_progress_tab.dart';
import 'package:workon/screens/todos_overview_screen.dart';
import 'package:workon/screens/stats_screen.dart';
import 'package:workon/screens/settings_screen.dart';
import 'package:workon/widgets/curved_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // This key lets us call showAddOptions() from the FAB
  final GlobalKey<DailyProgressTabState> _dailyProgressKey =
      GlobalKey<DailyProgressTabState>();

  // All screens in IndexedStack for instant switching
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DailyProgressTab(key: _dailyProgressKey), // Key attached here
      const TodosOverviewScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  // Called by the center FAB
  void _onFabPressed() {
    // Only show add options when on Daily Progress tab
    if (_currentIndex == 0) {
      _dailyProgressKey.currentState?.showAddOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CurvedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        onFabPressed: _onFabPressed,
      ),
    );
  }
}
