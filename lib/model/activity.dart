import 'package:intl/intl.dart';

const String tableActivities = 'activities';

class ActivityFields {
  static final List<String> values = [
    // add all fields
    id, title, description, date, audio, mood
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String description = 'description';
  static const String date = 'date';
  static const String audio = 'audio';
  static const String mood = 'mood';
}

class Activity {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final String audio;
  final double mood;

  const Activity({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.audio,
    required this.mood,
  });

  Activity copy({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? audio,
    double? mood,
  }) =>
      Activity(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        audio: audio ?? this.audio,
        mood: mood ?? this.mood,
      );

  static Activity fromJSON(Map<String, Object?> json) => Activity(
        id: json[ActivityFields.id] as int?,
        title: json[ActivityFields.title] as String,
        description: json[ActivityFields.description] as String,
        date: DateTime.parse(json[ActivityFields.date] as String),
        audio: json[ActivityFields.audio] as String,
        mood: json[ActivityFields.mood] as double,
      );

  Map<String, Object?> toJSON() => {
        ActivityFields.id: id,
        ActivityFields.title: title,
        ActivityFields.description: description,
        ActivityFields.date: date.toIso8601String(),
        ActivityFields.audio: audio,
        ActivityFields.mood: mood,
      };
}
