import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/job.dart';
import '../../models/day_record.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'puantaj.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jobs (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        name      TEXT    NOT NULL,
        startDate TEXT    NOT NULL,
        isActive  INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT    NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE day_records (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        jobId    INTEGER NOT NULL,
        date     TEXT    NOT NULL,
        isWorked INTEGER NOT NULL DEFAULT 0,
        note     TEXT,
        UNIQUE(jobId, date),
        FOREIGN KEY (jobId) REFERENCES jobs(id)
      )
    ''');
  }

  // ──────────────────────────────────────────
  // Job CRUD
  // ──────────────────────────────────────────

  static Future<int> insertJob(Job job) async {
    final db = await database;
    final map = job.toMap()..remove('id');
    return db.insert('jobs', map);
  }

  static Future<List<Job>> getJobs() async {
    final db = await database;
    final rows = await db.query('jobs', orderBy: 'id DESC');
    return rows.map(Job.fromMap).toList();
  }

  static Future<void> updateJob(Job job) async {
    final db = await database;
    await db.update(
      'jobs',
      job.toMap(),
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  static Future<void> deleteJob(int id) async {
    final db = await database;
    await db.delete('day_records', where: 'jobId = ?', whereArgs: [id]);
    await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns the number of days worked for a job.
  static Future<int> getWorkedCount(int jobId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM day_records WHERE jobId=? AND isWorked=1',
      [jobId],
    );
    return (result.first['cnt'] as int?) ?? 0;
  }

  // ──────────────────────────────────────────
  // DayRecord CRUD
  // ──────────────────────────────────────────

  static Future<void> upsertRecord(DayRecord record) async {
    final db = await database;
    if (record.id != null) {
      // Update existing row by primary key
      await db.update(
        'day_records',
        {'isWorked': record.isWorked ? 1 : 0, 'note': record.note},
        where: 'id = ?',
        whereArgs: [record.id],
      );
    } else {
      // Insert, replace if (jobId, date) already exists
      await db.insert(
        'day_records',
        {
          'jobId': record.jobId,
          'date': record.date,
          'isWorked': record.isWorked ? 1 : 0,
          'note': record.note,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<DayRecord>> getRecordsForJob(int jobId) async {
    final db = await database;
    final rows = await db.query(
      'day_records',
      where: 'jobId = ?',
      whereArgs: [jobId],
      orderBy: 'date ASC',
    );
    return rows.map(DayRecord.fromMap).toList();
  }

  static Future<DayRecord?> getRecord(int jobId, String date) async {
    final db = await database;
    final rows = await db.query(
      'day_records',
      where: 'jobId = ? AND date = ?',
      whereArgs: [jobId, date],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DayRecord.fromMap(rows.first);
  }
}
