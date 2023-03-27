import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String graphName = "Activity Creation Rate (current week)";

  List<DateTime> weekDates = [];
  late List<Activity> _activities = [];
  late List<double> _graphOneData = [];
  late List<double> _graphTwoData = [];

  @override
  void initState() {
    super.initState();

    DateTime weekStart = beginningOfWeek(today);

    // populate weekDates with days for this week.
    for (int j = 0; j < 7; j++) {
      weekDates.add(
          DateTime.utc(weekStart.year, weekStart.month, weekStart.day + j));
    }

    _graphOneData = [];

    _getActivities();
  }

  DateTime beginningOfWeek(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));

  void _getActivities() async {
    setState(() => _isLoading = true);

    // get all activities from this week.
    _activities = await ActivityDatabase.instance.readActivitiesFromThisWeek();

    _graphOneData = _tallyActivitiesForWeek();

    _graphTwoData = _calculateAverageMoodForWeek();

    setState(() => _isLoading = false);
  }

  List<double> _tallyActivitiesForWeek() {
    List<double> result = [];
    double tally = 0;

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

  List<double> _calculateAverageMoodForWeek() {
    List<double> result = [];
    double total = 0;
    int counter = 0;

    for (int i = 0; i < weekDates.length; i++) {
      total = 0;
      counter = 0;
      for (int j = 0; j < _activities.length; j++) {
        if (isSameDay(weekDates[i], _activities[j].date)) {
          counter++;
          total += _activities[j].mood;
        }
      }

      if ((total == 0) || (counter == 0)) {
        result.add(0.0);
      } else {
        result.add(total / counter);
      }
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          children: [
            activityRate(),
            const SizedBox(height: 20),
            moodAverages(),
          ],
        ),
      ),
    );
  }

  Container activityRate() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          const Text(
            "Created Activities (current week)",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade300,
                radius: 10,
              ),
              const Text("\t\t\tNo. created activities"),
            ],
          ),
          const SizedBox(height: 25),
          LineChartWidget(_getGraphPoints(_graphOneData), 6),
          const SizedBox(height: 10),
          activityTable(),
        ],
      ),
    );
  }

  Container moodAverages() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          const Text(
            "Your Average Mood (current week)",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade300,
                radius: 10,
              ),
              const Text("\t\t\tAverage mood for day"),
            ],
          ),
          const SizedBox(height: 25),
          LineChartWidget(_getGraphPoints(_graphTwoData), 8),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Padding activityTable() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Table(
        border: TableBorder.all(color: Colors.black),
        children: [
          TableRow(
            children: [
              const Text(
                'Total activities',
                textAlign: TextAlign.center,
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${_graphOneData.length}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          TableRow(
            children: [
              const Text(
                'Dates of Week',
                textAlign: TextAlign.center,
              ),
              Text(
                '${DateFormat.MMMd().format(beginningOfWeek(today)).toString()} - ${DateFormat.MMMd().format(beginningOfWeek(today).add(const Duration(days: 7))).toString()}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
