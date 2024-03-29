import 'package:flutter/material.dart';
import 'package:fitness_tracker/model/activity.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

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
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListTile(
              leading: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.black,
                size: 40,
              ),
              title: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: RatingBarIndicator(
                rating: activity.mood,
                itemBuilder: (context, index) =>
                    Image.asset('assets/images/indicator.png'),
                itemCount: 5,
                itemSize: 20.0,
                itemPadding:
                    const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                direction: Axis.horizontal,
              ),
              trailing: Text(
                DateFormat.jm().format(activity.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
