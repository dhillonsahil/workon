// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workon/providers/entry_provider.dart';
import 'package:workon/providers/title_provider.dart';
import 'package:workon/providers/stats_provider.dart';
import 'package:workon/providers/todo_provider.dart';
import 'package:workon/providers/theme_provider.dart';
import 'package:workon/screens/home_screen.dart';
import 'package:workon/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WorkonApp());
}

class WorkonApp extends StatelessWidget {
  const WorkonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EntryProvider()..loadEntries()),
        ChangeNotifierProvider(create: (_) => TitleProvider()..loadTitles()),
        ChangeNotifierProvider(create: (_) => StatsProvider()..loadStats()),
        ChangeNotifierProvider(create: (_) => TodoProvider()..loadTodos()),
      ],
      builder: (context, child) {
        final themeProvider = context.watch<ThemeProvider>();
        return MaterialApp(
          title: 'WorkOn',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            fontFamily: 'Poppins',
          ),
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          routes: {
            '/settings': (_) => const SettingsScreen(),
            // '/titles' route removed — we access it from DailyProgressTab directly
          },
        );
      },
    );
  }
}
