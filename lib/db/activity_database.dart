import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fitness_tracker/model/activity.dart';

class ActivityDatabase {
  static final ActivityDatabase instance = ActivityDatabase._init();

  static Database? _database;

  ActivityDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('activities.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'DOUBLE NOT NULL';

    db.execute('''
CREATE TABLE $tableActivities (
  ${ActivityFields.id} $idType,
  ${ActivityFields.title} $textType,
  ${ActivityFields.description} $textType,
  ${ActivityFields.date} $textType,
  ${ActivityFields.audio} $textType,
  ${ActivityFields.mood} $doubleType
)
''');
  }

  Future<Activity> create(Activity activity) async {
    final db = await instance.database;

    final id = await db.insert(tableActivities, activity.toJSON());
    return activity.copy(id: id);
  }

  Future<Activity> readActivity(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableActivities,
      columns: ActivityFields.values,
      where: '${ActivityFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Activity.fromJSON(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Activity>> readAllActivities() async {
    final db = await instance.database;

    final result = await db.query(tableActivities);

    return result.map((json) => Activity.fromJSON(json)).toList();
  }

  Future<int> update(Activity activity) async {
    final db = await instance.database;

    return db.update(
      tableActivities,
      activity.toJSON(),
      where: '${ActivityFields.id} = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableActivities,
      where: '${ActivityFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
