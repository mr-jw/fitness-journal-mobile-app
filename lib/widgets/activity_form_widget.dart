import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fitness_tracker/api/sound_recorder.dart';
import 'package:fitness_tracker/api/audio_transcriber.dart';
import 'package:fitness_tracker/api/text_editor_controller.dart';

class ActivityFormWidget extends StatefulWidget {
  final Function(String) fullAudioFilePathCallBack;
  final Function(double) moodletWidgetCallBack;

  // attributes to be validated upon creation or change.
  final String? title;
  final String? description;
  final ValueChanged<String> onChangedTitle;

  const ActivityFormWidget({
    Key? key,
    this.title = '',
    this.description = '',
    required this.onChangedTitle,
    required this.fullAudioFilePathCallBack,
    required this.moodletWidgetCallBack,
  }) : super(key: key);

  @override
  State<ActivityFormWidget> createState() => _ActivityFormWidgetState();
}

class _ActivityFormWidgetState extends State<ActivityFormWidget> {
  final soundRecorder = SoundRecorder();
  final audioTranscriber = AudioTranscriber();

  @override
  void initState() {
    super.initState();

    GlobalVar.descriptionController.text = widget.description.toString();

    // set the file name to a temporary name, initialise the sound recorder.
    soundRecorder.setFileName("tmpActivityRecording");
    soundRecorder.init();
  }

  @override
  void dispose() {
    super.dispose();
    soundRecorder.dispose();
    GlobalVar.descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.symmetric(horizontal: 0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          ),
          const Text(
            "Create activity",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          buildTitle(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          buildAudioRecording(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          buildDescription(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 17),
          ),
          buildMood(),
        ],
      );

  ListTile buildTitle() {
    return ListTile(
      leading: const Icon(
        Icons.fitness_center,
        color: Colors.black,
        size: 35,
      ),
      title: TextFormField(
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
      ),
    );
  }

  ListTile buildAudioRecording() {
    var isRecording = soundRecorder.isRecording;
    var icon = isRecording ? Icons.stop : Icons.mic;

    return ListTile(
      leading: const Icon(
        Icons.audiotrack_outlined,
        color: Colors.black,
        size: 35,
      ),
      title: const Text(
        "Record your log",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Transform.translate(
        offset: const Offset(0, 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: RawMaterialButton(
            onPressed: () async {
              await soundRecorder.toggleRecording();
              isRecording = soundRecorder.isRecording;
              setState(() {});

              // pass the recording file path back to edit activity page.
              widget.fullAudioFilePathCallBack(soundRecorder.getCompletePath());
            },
            elevation: 2,
            fillColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
            shape: const CircleBorder(),
            child: Icon(
              icon,
              size: 30.0,
            ),
          ),
        ),
      ),
    );
  }

  Future buildAudioTranscription() async {
    // pass the recording file path to the audio transcriber.
    // transcribe message.

    if (soundRecorder.getCompletePath().isNotEmpty) {
      await audioTranscriber.transcribe(soundRecorder.getCompletePath());

      // some sort of check to see if the audio transcriber has stopped.

      GlobalVar.descriptionController.text =
          audioTranscriber.getTranscribedMessage();
    }
  }

  ListTile buildDescription() {
    // this is working to update the description form
    // but the value needs to be passed back as onChangeDescription.
    buildAudioTranscription();

    return ListTile(
      leading: const Icon(
        Icons.text_snippet_outlined,
        color: Colors.black,
        size: 35,
      ),
      title: TextFormField(
        controller: GlobalVar.descriptionController,
        maxLines: 10,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Speak to generate one...',
        ),
        validator: (description) => description != null && description.isEmpty
            ? 'The description cannot be empty'
            : null,
      ),
    );
  }

  ListTile buildMood() {
    return ListTile(
      leading: const Icon(
        Icons.text_snippet_outlined,
        color: Colors.black,
        size: 35,
      ),
      title: Transform.translate(
        offset: const Offset(0, -15),
        child: const Text(
          "How did you feel?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      subtitle: Transform.translate(
        offset: const Offset(0, -8),
        child: Column(
          children: [
            RatingBar(
              initialRating: 3,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 45.0,
              ratingWidget: RatingWidget(
                full: Image.asset('assets/images/indicator.png'),
                half: Image.asset('assets/images/indicator-half.png'),
                empty: Image.asset('assets/images/indicator-empty.png'),
              ),
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              onRatingUpdate: (mood) {
                widget.moodletWidgetCallBack(mood);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Sad"),
                  Text("Happy"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
