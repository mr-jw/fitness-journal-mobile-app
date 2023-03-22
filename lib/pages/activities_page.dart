import 'package:fitness_tracker/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker/widgets/activity_card_widget.dart';
import 'package:fitness_tracker/model/activity.dart';
import 'package:fitness_tracker/db/activity_database.dart';
import 'package:fitness_tracker/pages/edit_activity_page.dart';
import 'package:fitness_tracker/pages/activity_detail_page.dart';
import 'package:table_calendar/table_calendar.dart';

import 'analytics_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String _appBarTitle = "Activities";
  // database communication variables.
  late List<Activity> _activities;
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

  @override
  void initState() {
    super.initState();

    refreshActivities();
  }

  @override
  void dispose() {
    super.dispose();
    ActivityDatabase.instance.close();
  }

  Future refreshActivities() async {
    setState(() => _isLoading = true);

    _activities = await ActivityDatabase.instance.readAllActivities();

    setState(() => _isLoading = false);
  }

  Widget activitiesPageContent() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _activities.isEmpty
                  ? const Center(
                      child: Text(
                        'No Activities.',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    )
                  : buildActivities(),
        ),
      ],
    );
  }

  ListView buildActivities() => ListView.separated(
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

              refreshActivities();
            },
            child: ActivityCardWidget(activity: activity, index: index),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(
          height: 1,
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
        ),
        body: _selectedIndex != 0
            ? _pages.elementAt(_selectedIndex)
            : activitiesPageContent(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const AddEditActivityPage()),
            );

            refreshActivities();
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
