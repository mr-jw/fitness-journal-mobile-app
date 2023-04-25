import 'package:fitness_tracker/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker/widgets/activity_card_widget.dart';
import 'package:fitness_tracker/model/activity.dart';
import 'package:fitness_tracker/db/activity_database.dart';
import 'package:fitness_tracker/pages/edit_activity_page.dart';
import 'package:fitness_tracker/pages/activity_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../themes/theme_provider.dart';
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

  // list of page naivgation widgets.
  static const List<Widget> _pages = <Widget>[
    AnalyticsPage(),
    ActivityPage(),
    SettingsPage(),
  ];

  // current index.
  int _selectedIndex = 1;

  // method to change current page index.
  void onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        _appBarTitle = "Analytics";
      } else if (index == 1) {
        _appBarTitle = "Activities";
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
  late DateTime _selectedDay = DateTime.now();

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
    // April
    addActivity("Sprint", 27, 03, 4);
    addActivity("Squats", 29, 03, 2);
    addActivity("Press-ups", 29, 03, 3.5);
    addActivity("Sprint", 30, 03, 4);
    addActivity("Squats", 31, 03, 2);
    addActivity("Press-ups", 28, 03, 3.5);
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
    final themeProvider = Provider.of<ThemeProvider>(context);
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
          color: themeProvider.isDarkTheme
              ? Colors.amber.shade200
              : Colors.green.shade200,
          shape: BoxShape.circle,
        ),
        // Use `CalendarStyle` to customize the UI
        selectedDecoration: BoxDecoration(
          color: themeProvider.isDarkTheme
              ? Colors.amber.shade400
              : Colors.green.shade400,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.black,
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
                        style: TextStyle(fontSize: 24),
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image(
            image: themeProvider.isDarkTheme
                ? const AssetImage('assets/images/myfit-logo-dark.png')
                : const AssetImage('assets/images/myfit-logo.png'),
          ),
        ),
        centerTitle: true,
        title: Text(
          _appBarTitle,
        ),
      ),
      body: _selectedIndex != 1
          ? _pages.elementAt(_selectedIndex)
          : activitiesPageContent(),
      floatingActionButton:
          (_selectedIndex != 1) || (_selectedDay.day != DateTime.now().day)
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Activities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
