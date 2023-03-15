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
    final colour = Colors.white60;

    /// Pick colors from the accent colors based on index
    //final color = _lightColors[index % _lightColors.length];

    return Card(
      color: Colors.white,
      shape: const StadiumBorder(
        side: BorderSide(
          color: Colors.black,
          width: 1.0,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 5.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: const Icon(
                Icons.fitness_center_sharp,
                color: Colors.black,
                size: 25,
              ),
              title: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
