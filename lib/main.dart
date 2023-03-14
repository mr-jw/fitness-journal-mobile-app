import 'package:flutter/material.dart';
import 'package:fitness_tracker/pages/activities_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'FYP: Fitness Application v0.2';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: ActivityPage(),
      );
}
