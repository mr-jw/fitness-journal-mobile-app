import 'package:flutter/material.dart';
import 'package:fitness_tracker/model/activity.dart';

/*
final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100
];
*/

class ActivityCardWidget extends StatelessWidget {
  const ActivityCardWidget({
    Key? key,
    required this.activity,
    required this.index,
  }) : super(key: key);

  final Activity activity;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colour = Colors.amber.shade300;

    /// Pick colors from the accent colors based on index
    //final color = _lightColors[index % _lightColors.length];

    return Card(
      color: colour,
      child: Container(
        constraints: const BoxConstraints(minHeight: 75),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Activity ${index + 1}: ${activity.title}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
