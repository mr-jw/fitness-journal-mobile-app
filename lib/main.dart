import 'package:fitness_tracker/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker/pages/activities_page.dart';
import 'package:fitness_tracker/api/text_editor_controller.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static const String title = 'FYP: Fitness Application v0.2';
  static const primaryColor = Color(0x0090ee90);

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
    GlobalVar.descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          title: MyApp.title,
          home: const ActivityPage(),
        );
      });
}
