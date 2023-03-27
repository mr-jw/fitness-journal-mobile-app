import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../db/activity_database.dart';
import '../model/activity.dart';
import '../widgets/line_chart_widget.dart';
import 'package:collection/collection.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isLoading = false;
  DateTime today = DateTime.now();

  late List<Activity> _activities = [];
  late List<double> _graphData = [];
  @override
  void initState() {
    super.initState();

    _graphData = [];

    _getActivities();
  }

  DateTime beginningOfWeek(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));

  void _getActivities() async {
    setState(() => _isLoading = true);

    // get all activities from this week.
    _activities = await ActivityDatabase.instance.readActivitiesFromThisWeek();

    _graphData = _tallyActivitiesForWeek();

    setState(() => _isLoading = false);
  }

  List<double> _tallyActivitiesForWeek() {
    List<double> result = [];
    List<DateTime> weekDates = [];
    DateTime weekStart = beginningOfWeek(today);
    double tally = 0;
    // populate weekDates with days for this week.
    for (int j = 0; j < 7; j++) {
      weekDates.add(
          DateTime.utc(weekStart.year, weekStart.month, weekStart.day + j));
    }

    for (int i = 0; i < weekDates.length; i++) {
      tally = 0;

      for (int j = 0; j < _activities.length; j++) {
        if (isSameDay(weekDates[i], _activities[j].date)) {
          tally += 1;
        }
      }

      result.add(tally);
    }

    return result;
  }

  List<MoodPoint> _getGraphPoints(List<double> data) {
    return data
        .mapIndexed(
            (index, element) => MoodPoint(x: index.toDouble(), y: element))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade300,
                  radius: 10,
                ),
                Text("\t\t\tNo. Activities Carried Out"),
              ],
            ),
            SizedBox(height: 25),
            LineChartWidget(_getGraphPoints(_graphData)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: RawMaterialButton(
                    onPressed: () {},
                    elevation: 0.0,
                    fillColor: Colors.green.shade300,
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      size: 20.0,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: RawMaterialButton(
                    onPressed: () {},
                    elevation: 0.0,
                    fillColor: Colors.green.shade300,
                    child: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20.0,
                    ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
