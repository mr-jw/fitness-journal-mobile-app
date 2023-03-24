import 'package:fitness_tracker/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker/widgets/activity_card_widget.dart';
import 'package:fitness_tracker/model/activity.dart';
import 'package:fitness_tracker/db/activity_database.dart';
import 'package:fitness_tracker/pages/edit_activity_page.dart';
import 'package:fitness_tracker/pages/activity_detail_page.dart';
import 'package:table_calendar/table_calendar.dart';

import 'analytics_page.dart';

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _appBarTitle = "Activities";

  // database communication variables.
  late List<Activity> _activities;
  int i = 0;

  bool _isLoading = false;

  // page naivgation variables.
  static const List<Widget> _pages = <Widget>[
    ActivityPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  int _selectedIndex = 0;
  void onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        _appBarTitle = "Activities";
      } else if (index == 1) {
        _appBarTitle = "Analytics";
      } else {
        _appBarTitle = "Settings";
      }

      _selectedIndex = index;
    });
  }

  // table calendar variables/attributes.
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.disabled;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = _focusedDay;

// debug code.
  Future addActivity(String title, int day, int month, double mood) async {
    final activity = Activity(
      title: title,
      description: "Test Description.",
      date: DateTime.utc(2023, month, day),
      audio: "...",
      mood: mood,
    );

    await ActivityDatabase.instance.create(activity);
  }

  void loadTestData() {
    // March
    addActivity("Sprint", 13, 03, 2);
    addActivity("Dumbell-press", 13, 03, 3.5);
    addActivity("Press-ups", 16, 03, 1.5);
    addActivity("Deadlifts", 22, 03, 2);
    addActivity("Squats", 22, 03, 2);
    addActivity("Press-ups", 23, 03, 3.5);
    addActivity("Sprint", 25, 03, 4);
    addActivity("Deadlifts", 28, 03, 2);
    addActivity("Bench-press", 31, 03, 1.5);

    // April
    addActivity("Sprint", 02, 04, 4);
    addActivity("Squats", 04, 04, 2);
    addActivity("Press-ups", 04, 04, 3.5);
    addActivity("Sprint", 10, 04, 4);
    addActivity("Squats", 16, 04, 2);
    addActivity("Press-ups", 17, 04, 3.5);
  }

  @override
  void initState() {
    super.initState();

    _activities = [];

    //loadTestData();

    _getEventsForDay();
  }

  @override
  void dispose() {
    super.dispose();
    ActivityDatabase.instance.close();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _getEventsForDay();
    }
  }

  void _getEventsForDay() async {
    setState(() => _isLoading = true);

    _activities = await ActivityDatabase.instance.readAllActivities();

    setState(() => _isLoading = false);

    removeInvalidActivities();
  }

  void removeInvalidActivities() {
    i = 0;
    while (i < _activities.length) {
      if (isSameDay(_activities[i].date, _selectedDay)) {
        i++;
      } else {
        // date doesn't match, remove it.
        _activities.remove(_activities[i]);

        if (i == _activities.length) {
          break;
        } else {
          i = 0;
          continue;
        }
      }
    }
  }

  Widget buildCalendar() {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2023),
      lastDay: DateTime.utc(2025),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      rangeSelectionMode: _rangeSelectionMode,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayTextStyle: const TextStyle(
          color: Colors.black,
        ),
        // Use `CalendarStyle` to customize the UI
        todayDecoration: BoxDecoration(
          color: Colors.green.shade200,
          shape: BoxShape.circle,
        ),
        // Use `CalendarStyle` to customize the UI
        selectedDecoration: BoxDecoration(
          color: Colors.green.shade400,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
      onDaySelected: _onDaySelected,
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget activitiesPageContent() {
    return Column(
      children: [
        buildCalendar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _activities.isEmpty
                  ? const Center(
                      child: Text(
                        'No Activities.',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    )
                  : buildActivities(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildActivities() {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];

        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  ActivityDetailPage(activityId: activity.id!),
            ));

            _getEventsForDay();
          },
          child: ActivityCardWidget(activity: activity, index: index),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
        ),
        body: _selectedIndex != 0
            ? _pages.elementAt(_selectedIndex)
            : activitiesPageContent(),
        floatingActionButton: _selectedIndex != 0
            ? null
            : FloatingActionButton(
                child: const Icon(
                  Icons.add,
                  size: 25,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const AddEditActivityPage()),
                  );

                  _getEventsForDay();
                },
              ),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 25,
          backgroundColor: Colors.green.shade300,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Activities',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: onItemTapped,
        ),
      );
}
