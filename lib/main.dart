import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/entry_provider.dart';
import 'providers/title_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WorkOnApp());
}

class WorkOnApp extends StatelessWidget {
  const WorkOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EntryProvider()),
        ChangeNotifierProvider(create: (_) => TitleProvider()),
      ],
      child: MaterialApp(
        title: 'WorkOn',
        theme: ThemeData(
          fontFamily: 'Inter',
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
