import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../db/activity_database.dart';
import '../model/activity.dart';
import '../themes/theme_provider.dart';
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
  late DateTime weekStart;
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

      // check for division by 0.
      if ((total == 0) || (counter == 0)) {
        result.add(0.0);
      } else {
        result.add(total / counter);
      }
    }
    return result;
  }

  // convert gathered data to Graph (x/y) mood points.
  List<Point> _getGraphPoints(List<double> data) {
    return data
        .mapIndexed((index, element) => Point(x: index.toDouble(), y: element))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'This Week (${DateFormat.MMMd().format(beginningOfWeek(today)).toString()} - ${DateFormat.MMMd().format(beginningOfWeek(today).add(const Duration(days: 7))).toString()})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  activityRateGraphWidget(),
                  const SizedBox(height: 20),
                  moodAveragesGraphWidget(),
                ],
              ),
      ),
    );
  }

  Container activityRateGraphWidget() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Your Activities",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: themeProvider.isDarkTheme
                    ? Colors.amber.shade300
                    : Colors.green.shade300,
                radius: 8,
              ),
              const Text("\t\t\tNumber of Activities"),
            ],
          ),
          const SizedBox(height: 20),
          LineChartWidget(_getGraphPoints(_graphOneData)),
        ],
      ),
    );
  }

  Container moodAveragesGraphWidget() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Your Mood",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: themeProvider.isDarkTheme
                    ? Colors.amber.shade300
                    : Colors.green.shade300,
                radius: 8,
              ),
              const Text("\t\t\t(Mean) Mood Average"),
            ],
          ),
          const SizedBox(height: 20),
          LineChartWidget(_getGraphPoints(_graphTwoData)),
        ],
      ),
    );
  }

  Padding activityTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                '${_activities.length}',
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
