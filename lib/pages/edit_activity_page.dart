import 'package:flutter/material.dart';
import 'package:fitness_tracker/widgets/activity_form_widget.dart';
import 'package:fitness_tracker/db/activity_database.dart';
import 'package:fitness_tracker/model/activity.dart';

class AddEditActivityPage extends StatefulWidget {
  final Activity? activity;

  const AddEditActivityPage({
    Key? key,
    this.activity,
  }) : super(key: key);
  @override
  _AddEditActivityPageState createState() => _AddEditActivityPageState();
}

class _AddEditActivityPageState extends State<AddEditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;

  @override
  void initState() {
    super.initState();

    title = widget.activity?.title ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: ActivityFormWidget(
            /*
            isImportant: isImportant,
            number: number,
            */
            title: title,
            onChangedTitle: (title) => setState(() => this.title = title),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.black,
          primary: isFormValid ? Colors.yellow : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateActivity,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateActivity() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.activity != null;

      if (isUpdating) {
        await updateActivity();
      } else {
        await addActivity();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateActivity() async {
    final activity = widget.activity!.copy(
      title: title,
    );

    await ActivityDatabase.instance.update(activity);
  }

  Future addActivity() async {
    final activity = Activity(
      title: title,
      createdDate: DateTime.now(),
    );

    await ActivityDatabase.instance.create(activity);
  }
}
