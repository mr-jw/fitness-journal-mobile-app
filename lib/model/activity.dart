const String tableActivities = 'activities';

class ActivityFields {
  static final List<String> values = [
    // add all fields
    id, title, description, createdDate, audioPath,
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String description = 'description';
  static const String createdDate = 'date';
  static const String audioPath = 'audioPath';
}

class Activity {
  final int? id;
  final String title;
  final String description;
  final DateTime createdDate;
  final String audioPath;

  const Activity({
    this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    required this.audioPath,
  });

  Activity copy({
    int? id,
    String? title,
    String? description,
    DateTime? createdDate,
    String? audioPath,
  }) =>
      Activity(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdDate: createdDate ?? this.createdDate,
        audioPath: audioPath ?? this.audioPath,
      );

  static Activity fromJSON(Map<String, Object?> json) => Activity(
        id: json[ActivityFields.id] as int?,
        title: json[ActivityFields.title] as String,
        description: json[ActivityFields.description] as String,
        createdDate: DateTime.parse(json[ActivityFields.createdDate] as String),
        audioPath: json[ActivityFields.audioPath] as String,
      );

  Map<String, Object?> toJSON() => {
        ActivityFields.id: id,
        ActivityFields.title: title,
        ActivityFields.description: description,
        ActivityFields.createdDate: createdDate.toIso8601String(),
        ActivityFields.audioPath: audioPath,
      };
}
