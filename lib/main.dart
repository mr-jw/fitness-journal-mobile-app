import 'package:flutter/material.dart';
import 'package:fitness_tracker/pages/activities_page.dart';
import 'package:fitness_tracker/api/text_editor_controller.dart';

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
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            elevation: 0.1,
            backgroundColor: Colors.green.shade300,
            centerTitle: true,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 0.1,
            backgroundColor: Colors.green.shade300,
          ),
        ),
        title: MyApp.title,
        home: const ActivityPage(),
      );
}
