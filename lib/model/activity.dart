const String tableActivities = 'activities';

class ActivityFields {
  static final List<String> values = [
    // add all fields
    id, title, createdDate,
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String createdDate = 'date';
}

class Activity {
  final int? id;
  final String title;
  final DateTime createdDate;

  const Activity({
    this.id,
    required this.title,
    required this.createdDate,
  });

  Activity copy({
    int? id,
    String? title,
    DateTime? createdDate,
  }) =>
      Activity(
        id: id ?? this.id,
        title: title ?? this.title,
        createdDate: createdDate ?? this.createdDate,
      );

  static Activity fromJSON(Map<String, Object?> json) => Activity(
        id: json[ActivityFields.id] as int?,
        title: json[ActivityFields.title] as String,
        createdDate: DateTime.parse(json[ActivityFields.createdDate] as String),
      );

  Map<String, Object?> toJSON() => {
        ActivityFields.id: id,
        ActivityFields.title: title,
        ActivityFields.createdDate: createdDate.toIso8601String(),
      };
}
