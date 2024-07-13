import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;
  static final int _version = 1;
  static final String _tableName = 'tasks';
  final databaseName = "todolist.db";
  String taskTable =
      "CREATE TABLE task (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT NOT NULL, dateTime TEXT NOT NULL)";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(taskTable);
    });
  }

  static Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        dateTime TEXT
      )
    ''');
  }

  /*Future<Database?> initDB() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, title TEXT, description TEXT, FOREIGN KEY(userId) REFERENCES users(id))",
        );
      },
      version: 1,
    );
  }*/
  static Future<void> addTask(Map<String, dynamic> task) async {
    final db = await DBHelper.database;
    await db.insert(
      _tableName,
      task,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTask(id, title, description, dateTime) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update task set title = ?, description = ?, dateTime = ? where id = ?',
        [title, description, dateTime, id]);
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: _createDb,
      version: _version,
    );
    return _database!;
  }

  static Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getTasks(task) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> tasks = await db.query(_tableName);
    return tasks;
  }
}
