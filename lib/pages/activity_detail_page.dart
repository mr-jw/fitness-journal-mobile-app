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
            : Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Activity carried out at ${DateFormat.jm().format(activity.date)}",
                    ),
                    const SizedBox(height: 35),
                    Text(
                      activity.description,
                    ),
                    /*
                    const SizedBox(height: 35),
                    Text(
                      "DEBUG - Audio filepath name: ${activity.audioPath}",
                      style: TextStyle(color: Colors.red),
                    ),
                    */
                    audioPlaybackWidget(),
                    const SizedBox(height: 50),
                    viewMoodWidget(),
                  ],
                ),
              ),
      );

  Widget audioPlaybackWidget() {
    return Column(
      children: [
        const SizedBox(height: 35),
        const SizedBox(height: 4),
        Text(
          '${activity.title} recording',
          style: const TextStyle(fontSize: 20),
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatTime(position)),
              Text(formatTime(duration - position)),
            ],
          ),
        ),
        CircleAvatar(
          radius: 30,
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
        )
      ],
    );
  }

  Widget viewMoodWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "How you felt after this activity...",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 25),
        RatingBarIndicator(
          rating: activity.mood,
          itemBuilder: (context, index) =>
              Image.asset('assets/images/indicator.png'),
          itemCount: 5,
          itemSize: 50.0,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          direction: Axis.horizontal,
        ),
      ],
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
