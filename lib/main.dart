import 'package:flutter/material.dart';
import 'package:fitness_tracker/pages/activities_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'FYP: Fitness Application v0.2';
  static const primaryColor = Color(0x0090ee90);

  const MyApp({super.key});

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
        title: title,
        home: const ActivityPage(),
      );
}
