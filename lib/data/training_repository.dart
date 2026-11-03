/// 数据访问层：仓储抽象 + SQLite 本地实现。
///
/// 抽象接口是为后续"后台服务 + 账号系统"预留的接缝：
/// 届时新增一个基于网络/账号的 `TrainingRepository` 实现替换即可，UI 不变。
library;

import 'package:sqflite/sqflite.dart';

import '../engine/models.dart';
import 'app_database.dart';

abstract class TrainingRepository {
  Future<List<TrainingItem>> listItems();
  Future<TrainingItem?> getItem(int id);
  Future<int> createItem(TrainingItem item);
  Future<ProgressState?> getProgress(int itemId);
  Future<void> saveProgress(int itemId, ProgressState st);
  Future<void> updateItemStatus(int id, String status);
  Future<void> addLog(LogEntry entry);
  Future<List<LogEntry>> listLogs(int itemId);
}

class SqliteTrainingRepository implements TrainingRepository {
  @override
  Future<List<TrainingItem>> listItems() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('training_item', orderBy: 'created_at');
    return rows.map(_itemFromRow).toList();
  }

  @override
  Future<TrainingItem?> getItem(int id) async {
    final db = await AppDatabase.instance;
    final rows = await db.query('training_item', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _itemFromRow(rows.first);
  }

  @override
  Future<int> createItem(TrainingItem item) async {
    final db = await AppDatabase.instance;
    final id = await db.insert('training_item', {
      'name': item.name,
      'training_method': item.trainingMethod,
      'goal_text': item.goalText,
      'metric_unit': item.metricUnit,
      'begin_num': item.beginNum,
      'plus_var': item.plusVar,
      'd_grade': item.dGrade,
      'begin_grade': item.beginGrade,
      'fail_rule': item.failRule,
      'status': item.status,
      'created_at': item.createdAt,
    });
    item.id = id;
    return id;
  }

  @override
  Future<ProgressState?> getProgress(int itemId) async {
    final db = await AppDatabase.instance;
    final rows =
        await db.query('progress', where: 'item_id = ?', whereArgs: [itemId]);
    if (rows.isEmpty) return null;
    return ProgressState(
      rows.first['grade'] as int,
      rows.first['level'] as int,
      rows.first['rep'] as int,
    );
  }

  @override
  Future<void> saveProgress(int itemId, ProgressState st) async {
    final db = await AppDatabase.instance;
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'progress',
      {
        'item_id': itemId,
        'grade': st.grade,
        'level': st.level,
        'rep': st.rep,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateItemStatus(int id, String status) async {
    final db = await AppDatabase.instance;
    await db.update('training_item', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> addLog(LogEntry entry) async {
    final db = await AppDatabase.instance;
    await db.insert('completion_log', {
      'item_id': entry.itemId,
      'log_date': entry.logDate,
      'grade': entry.grade,
      'level': entry.level,
      'rep': entry.rep,
      'target': entry.target,
      'result': entry.result,
      'note': entry.note,
      'created_at': entry.createdAt,
    });
  }

  @override
  Future<List<LogEntry>> listLogs(int itemId) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'completion_log',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'created_at DESC',
    );
    return rows.map(_logFromRow).toList();
  }

  TrainingItem _itemFromRow(Map<String, Object?> row) => TrainingItem(
        id: row['id'] as int?,
        name: row['name'] as String,
        trainingMethod: (row['training_method'] as String?) ?? '运动',
        goalText: (row['goal_text'] as String?) ?? '',
        metricUnit: (row['metric_unit'] as String?) ?? '',
        beginNum: row['begin_num'] as int,
        plusVar: row['plus_var'] as int,
        dGrade: row['d_grade'] as int,
        beginGrade: row['begin_grade'] as int,
        failRule: (row['fail_rule'] as String?) ?? 'STAY',
        status: (row['status'] as String?) ?? 'ACTIVE',
        createdAt: (row['created_at'] as String?) ?? '',
      );

  LogEntry _logFromRow(Map<String, Object?> row) => LogEntry(
        id: row['id'] as int?,
        itemId: row['item_id'] as int,
        logDate: (row['log_date'] as String?) ?? '',
        grade: row['grade'] as int,
        level: row['level'] as int,
        rep: row['rep'] as int,
        target: (row['target'] as String?) ?? '',
        result: (row['result'] as String?) ?? '',
        note: row['note'] as String?,
        createdAt: (row['created_at'] as String?) ?? '',
      );
}
