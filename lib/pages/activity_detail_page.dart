import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_tracker/pages/edit_activity_page.dart';
import 'package:fitness_tracker/db/activity_database.dart';
import 'package:fitness_tracker/model/activity.dart';

class ActivityDetailPage extends StatefulWidget {
  final int activityId;

  const ActivityDetailPage({
    Key? key,
    required this.activityId,
  }) : super(key: key);

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  late Activity activity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshActivity();
  }

  Future refreshActivity() async {
    setState(() => isLoading = true);

    activity = await ActivityDatabase.instance.readActivity(widget.activityId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Activity carried out at ${DateFormat.jm().format(activity.createdDate)}",
                    ),

                    /*
                    SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    )
                    */
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditActivityPage(activity: activity),
        ));

        refreshActivity();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await ActivityDatabase.instance.delete(widget.activityId);

          Navigator.of(context).pop();
        },
      );
}
