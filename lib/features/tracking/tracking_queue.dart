import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Antrian lokal untuk titik GPS yang gagal terkirim (misalnya saat
/// kehilangan sinyal di gunung). Titik akan dikirim ulang saat online.
class TrackingQueue {
  Database? _db;
  bool _memoryOnly = false;
  final List<Map<String, dynamic>> _memoryRows = [];
  int _memoryId = 0;

  Future<void> _ensureDb() async {
    if (_db != null || _memoryOnly) return;

    try {
      final dir = await getDatabasesPath();
      _db = await openDatabase(
        p.join(dir, 'summitgo_tracking.db'),
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE pending_points (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              session_id INTEGER NOT NULL,
              client_uuid TEXT NOT NULL UNIQUE,
              payload TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (_) {
      // sqflite tidak tersedia (mis. desktop/web). Pakai memori sebagai
      // fallback agar aplikasi tidak crash.
      _memoryOnly = true;
    }
  }

  Future<void> enqueue(int sessionId, List<Map<String, dynamic>> points) async {
    if (points.isEmpty) return;
    await _ensureDb();

    if (_memoryOnly) {
      for (final point in points) {
        final uuid = point['client_uuid']?.toString() ?? '';
        final exists = _memoryRows.any((row) => row['client_uuid'] == uuid);
        if (exists) continue;
        _memoryRows.add({
          'id': ++_memoryId,
          'session_id': sessionId,
          'client_uuid': uuid,
          'payload': point,
        });
      }
      return;
    }

    final batch = _db!.batch();
    for (final point in points) {
      batch.insert(
        'pending_points',
        {
          'session_id': sessionId,
          'client_uuid': point['client_uuid']?.toString() ?? '',
          'payload': jsonEncode(point),
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> pending(
    int sessionId, {
    int limit = 100,
  }) async {
    await _ensureDb();

    if (_memoryOnly) {
      return _memoryRows
          .where((row) => row['session_id'] == sessionId)
          .take(limit)
          .map((row) => {
                'row_id': row['id'],
                'payload': row['payload'] as Map<String, dynamic>,
              })
          .toList();
    }

    final rows = await _db!.query(
      'pending_points',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'id ASC',
      limit: limit,
    );

    return rows
        .map((row) => {
              'row_id': row['id'],
              'payload': jsonDecode(row['payload'] as String)
                  as Map<String, dynamic>,
            })
        .toList();
  }

  Future<int> count([int? sessionId]) async {
    await _ensureDb();

    if (_memoryOnly) {
      if (sessionId == null) return _memoryRows.length;
      return _memoryRows
          .where((row) => row['session_id'] == sessionId)
          .length;
    }

    final result = await _db!.rawQuery(
      sessionId == null
          ? 'SELECT COUNT(*) AS total FROM pending_points'
          : 'SELECT COUNT(*) AS total FROM pending_points WHERE session_id = ?',
      sessionId == null ? [] : [sessionId],
    );

    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  Future<void> remove(List<int> rowIds) async {
    if (rowIds.isEmpty) return;
    await _ensureDb();

    if (_memoryOnly) {
      _memoryRows.removeWhere((row) => rowIds.contains(row['id']));
      return;
    }

    final placeholders = List.filled(rowIds.length, '?').join(',');
    await _db!.delete(
      'pending_points',
      where: 'id IN ($placeholders)',
      whereArgs: rowIds,
    );
  }

  Future<void> clear([int? sessionId]) async {
    await _ensureDb();

    if (_memoryOnly) {
      if (sessionId == null) {
        _memoryRows.clear();
      } else {
        _memoryRows.removeWhere((row) => row['session_id'] == sessionId);
      }
      return;
    }

    if (sessionId == null) {
      await _db!.delete('pending_points');
    } else {
      await _db!.delete(
        'pending_points',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
    }
  }
}
