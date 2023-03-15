import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:fitness_tracker/api/sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ActivityFormWidget extends StatefulWidget {
  final Function(String) fullAudioFilePathCallBack;
  final String? title;
  final String? description;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedDescription;

  const ActivityFormWidget({
    Key? key,
    this.title = '',
    this.description = '',
    required this.onChangedTitle,
    required this.onChangedDescription,
    required this.fullAudioFilePathCallBack,
  }) : super(key: key);

  @override
  State<ActivityFormWidget> createState() => _ActivityFormWidgetState();
}

class _ActivityFormWidgetState extends State<ActivityFormWidget> {
  final soundRecorder = SoundRecorder();

  @override
  void initState() {
    super.initState();

    // set the file name to a temporary name, initialise the sound recorder.
    soundRecorder.setFileName("tmpActivityRecording");
    soundRecorder.init();
  }

  @override
  void dispose() {
    super.dispose();
    soundRecorder.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Record your Log",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 35),
              buildTitle(),
              const SizedBox(height: 35),
              audioRecorderWidget(),
              const SizedBox(height: 35),
              buildDescription(),
            ],
          ),
        ),
      );

  Widget audioRecorderWidget() {
    var isRecording = soundRecorder.isRecording;
    var icon = isRecording ? Icons.stop : Icons.mic;

    return Column(
      children: <Widget>[
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Record your thoughts...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 35),
        RawMaterialButton(
          onPressed: () async {
            await soundRecorder.toggleRecording();
            isRecording = soundRecorder.isRecording;
            setState(() {});
            // pass the recording file path back to edit activity page.
            widget.fullAudioFilePathCallBack(soundRecorder.getCompletePath());
          },
          elevation: 2,
          fillColor: Colors.white,
          padding: const EdgeInsets.all(15.0),
          shape: const CircleBorder(),
          child: Icon(
            icon,
            size: 40.0,
          ),
        ),
      ],
    );
  }

  Widget buildTitle() {
    return TextFormField(
      maxLines: 1,
      initialValue: widget.title,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        hintText: 'Enter activity name...',
      ),
      validator: (title) =>
          title != null && title.isEmpty ? 'The title cannot be empty' : null,
      onChanged: widget.onChangedTitle,
    );
  }

  Widget buildDescription() => TextFormField(
        maxLines: 25,
        initialValue: widget.description,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter a description, or speak to generate one...',
        ),
        validator: (title) => title != null && title.isEmpty
            ? 'The description cannot be empty'
            : null,
        onChanged: widget.onChangedDescription,
      );
}
