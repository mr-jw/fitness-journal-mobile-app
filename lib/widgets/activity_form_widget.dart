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
  String? description;
  final ValueChanged<String> onChangedTitle;

  ActivityFormWidget({
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
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              const Text(
                "Record your Log",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              buildTitle(),
              const SizedBox(height: 25),
              buildAudioRecording(),
              const SizedBox(height: 25),
              buildDescription(),
              const SizedBox(height: 25),
              buildMood(),
            ],
          ),
        ),
      );

  Widget buildAudioRecording() {
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
        const SizedBox(height: 25),
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
            size: 30.0,
          ),
        ),
      ],
    );
  }

  Future buildAudioTranscription() async {
    // pass the recording file path to the audio transcriber.
    // transcribe message.
    await audioTranscriber.transcribe(soundRecorder.getCompletePath());

    // some sort of check to see if the audio transcriber has stopped.

    widget.description = GlobalVar.descriptionController.text =
        audioTranscriber.getTranscribedMessage();
  }

  Widget buildMood() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "On a scale of 1-5, how did you feel?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 20),
        RatingBar(
          initialRating: 3,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 50.0,
          ratingWidget: RatingWidget(
            full: Image.asset('assets/images/indicator.png'),
            half: Image.asset('assets/images/indicator-half.png'),
            empty: Image.asset('assets/images/indicator-empty.png'),
          ),
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          onRatingUpdate: (mood) {
            print(mood);
            widget.moodletWidgetCallBack(mood);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Not great"),
              Text("Excellent"),
            ],
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

  Widget buildDescription() {
    // this is working to update the description form
    // but the value needs to be passed back as onChangeDescription.
    buildAudioTranscription();

    return Column(
      children: [
        TextFormField(
          controller: GlobalVar.descriptionController,
          maxLines: 15,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter a description, or speak to generate one...',
          ),
          validator: (description) => description != null && description.isEmpty
              ? 'The description cannot be empty'
              : null,
        ),
      ],
    );
  }
}
