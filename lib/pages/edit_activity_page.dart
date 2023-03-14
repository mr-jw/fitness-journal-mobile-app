import 'dart:io';

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
  late String description;

  late String recordingFilePath;
  late String newRecordingName;

  @override
  void initState() {
    super.initState();

    title = widget.activity?.title ?? '';
    description = widget.activity?.description ?? '';
    recordingFilePath = widget.activity?.audioPath ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: ActivityFormWidget(
            // nice attempt, but something is not working correctly.
            // fileName isn't being given a value in SoundRecorder.
            // database is storing the file path correctly.
            fullAudioFilePathCallBack: (p0) {
              setState(() {
                // recordings/.wav + title.
                recordingFilePath = p0;
                newRecordingName = "$title-recording";
              });
            },
            title: title,
            description: description,
            onChangedTitle: (title) => setState(() {
              // when the title in form is changed or given a name,
              // update this activity title to the new value.
              this.title = title;

              newRecordingName = "$title-recording";
            }),
            onChangedDescription: (description) =>
                setState(() => this.description = description),
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

      processRecording();

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
        description: description,
        createdDate: DateTime.now(),
        audioPath: recordingFilePath);

    await ActivityDatabase.instance.create(activity);
  }

  Future processRecording() {
    File recording = File(recordingFilePath);
    return changeFileNameOnly(recording, newRecordingName);
  }

  // tmp function to test renaming.
  Future changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = "${path.substring(0, lastSeparator + 1)}$newFileName.wav";
    recordingFilePath = newPath;
    return file.rename(newPath);
  }
}
