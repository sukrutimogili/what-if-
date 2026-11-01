import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show sqfliteFfiInit, databaseFactoryFfi;

import '../models/journey_entry.dart';

/// SQLite storage for the user's responses ("My Journey").
///
/// Android and iOS use the regular sqflite plugin. Linux, Windows and macOS
/// use sqflite_common_ffi, which needs the system SQLite library
/// (on Ubuntu: `sudo apt install libsqlite3-dev`).
class JournalDb {
  Database? _db;

  /// Call once at start-up, before opening the database.
  static void initPlatform() {
    if (kIsWeb) return;
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<void> open() async {
    await _db?.close();
    _db = null;

    final dir = await getApplicationSupportDirectory();
    await Directory(dir.path).create(recursive: true);
    final path = p.join(dir.path, 'what_if_journal.db');

    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE entries (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              prompt_id TEXT NOT NULL,
              prompt_text TEXT NOT NULL,
              category_id TEXT NOT NULL,
              response TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
  }

  Database get _database {
    final db = _db;
    if (db == null) {
      throw StateError('The journal database has not been opened.');
    }
    return db;
  }

  Future<List<JourneyEntry>> all() async {
    final rows = await _database.query('entries', orderBy: 'updated_at DESC');
    return rows.map(JourneyEntry.fromMap).toList();
  }

  Future<JourneyEntry> save(JourneyEntry entry) async {
    final db = _database;
    if (entry.id == null) {
      final id = await db.insert('entries', entry.toMap());
      return entry.withId(id);
    }
    await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    return entry;
  }

  Future<void> delete(int id) async {
    await _database.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}
