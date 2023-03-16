import 'package:flutter/material.dart';
import 'package:fitness_tracker/widgets/activity_card_widget.dart';
import 'package:fitness_tracker/model/activity.dart';
import 'package:fitness_tracker/db/activity_database.dart';
import 'package:fitness_tracker/pages/edit_activity_page.dart';
import 'package:fitness_tracker/pages/activity_detail_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late List<Activity> activities;
  bool isLoading = false;
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
    setState(() => isLoading = true);

    activities = await ActivityDatabase.instance.readAllActivities();

    setState(() => isLoading = false);
  }

  Widget buildActivities() => ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

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
          ));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Activities"),
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : activities.isEmpty
                  ? const Text(
                      'No Activities.',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  : buildActivities(),
        ),
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
      );
}
