import 'package:flutter/material.dart';
import 'package:fitness_tracker/model/activity.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListTile(
              leading: const Icon(
                Icons.fitness_center,
                size: 40,
              ),
              title: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
              subtitle: RatingBarIndicator(
                rating: activity.mood,
                itemBuilder: (context, index) => themeProvider.isDarkTheme
                    ? Image.asset('assets/images/indicator-dark.png')
                    : Image.asset('assets/images/indicator-light.png'),
                itemCount: 5,
                itemSize: 20.0,
                itemPadding:
                    const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                direction: Axis.horizontal,
              ),
              trailing: Text(
                DateFormat.jm().format(activity.date),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
