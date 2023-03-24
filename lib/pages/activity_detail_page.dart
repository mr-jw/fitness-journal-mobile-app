import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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

  // variables for audio player.
  final audioPlayer = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    refreshActivity();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future refreshActivity() async {
    setState(() => isLoading = true);

    activity = await ActivityDatabase.instance.readActivity(widget.activityId);

    setAudio();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  title(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  displayTimeOfCreation(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  displayDescription(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  audioPlaybackWidget(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  viewMoodWidget(),
                ],
              ),
      );

  ListTile title() {
    return ListTile(
      title: Text(
        "${activity.title}",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  ListTile displayTimeOfCreation() {
    return ListTile(
      leading: const Icon(
        Icons.alarm,
        color: Colors.black,
        size: 35,
      ),
      title: const Text(
        "Created on",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        "${DateFormat.MMMMEEEEd().format(activity.date)} \n${DateFormat.jm().format(activity.date)}",
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  ListTile displayDescription() {
    return ListTile(
      leading: const Icon(
        Icons.text_snippet_outlined,
        color: Colors.black,
        size: 35,
      ),
      title: const Text(
        "Description",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        activity.description,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  ListTile audioPlaybackWidget() {
    return ListTile(
      leading: const Icon(
        Icons.audiotrack_outlined,
        color: Colors.black,
        size: 35,
      ),
      title: const Text(
        "Recording",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle: Column(
        children: [
          Slider(
            activeColor: Colors.green.shade300,
            inactiveColor: Colors.green.shade100,
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await audioPlayer.seek(position);

              await audioPlayer.resume();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration - position)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.green.shade300,
              foregroundColor: Colors.white,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    await audioPlayer.resume();
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  ListTile viewMoodWidget() {
    return ListTile(
      minLeadingWidth: 30,
      leading: const Icon(
        Icons.text_snippet_outlined,
        color: Colors.black,
        size: 35,
      ),
      title: Transform.translate(
        offset: const Offset(0, -18),
        child: const Text(
          "Mood Level",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      subtitle: Transform.translate(
        offset: const Offset(0, -10),
        child: Column(
          children: [
            RatingBarIndicator(
              rating: activity.mood,
              itemBuilder: (context, index) =>
                  Image.asset('assets/images/indicator.png'),
              itemCount: 5,
              itemSize: 45.0,
              itemPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 2.0),
              direction: Axis.horizontal,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Sad",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Happy",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    String audioPath = activity.audio;
    final file = File(audioPath);
    audioPlayer.setSourceUrl(file.path);
  }

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
          deleteRecording();
          Navigator.of(context).pop();
        },
      );

  Future deleteRecording() {
    File recording = File(activity.audio);
    return deleteFile(recording);
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }
}
