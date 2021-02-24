import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'models/history_model.dart';

final String tableName = 'History';

class HistoryHelper {

  HistoryHelper._();
  static final HistoryHelper _db = HistoryHelper._();
  factory HistoryHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'HistoryDB.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE IF NOT EXISTS $tableName(id INTEGER PRIMARY KEY, date TEXT, timeExceeded INTEGER, penalty INTEGER)');
        },
    );
  }

  //Create
  createHistory(History history) async {
    final db = await database;
    var res = await db.insert(tableName, history.toMap());
    return res;
  }

  // READ
  getHistory(int id) async {
    final db = await database;
    var res = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? History.fromMap(res.first) : Null;
  }

  // READ ALL DATA
  getAllHistory() async {
    final db = await database;
    var res = await db.query(tableName);
    List<History> list =
    res.isNotEmpty ? res.map((c) => History.fromMap(c)).toList() : [];
    return list;
  }

  // Update History
  updateHistory(History history) async {
    final db = await database;
    var res = await db.update(tableName, history.toMap(), where: 'id = ?', whereArgs: [history.id]);
    return res;
  }

  // Delete History
  deleteHistory(int id) async {
    final db = await database;
    db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Delete All History
  deleteAllHistory() async {
    final db = await database;
    db.rawDelete('Delete * from $tableName');
  }

}