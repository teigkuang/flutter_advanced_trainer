/// 本地数据库（SQLite）· 三表结构
///
/// 结构对齐算法仓 `advanced-trainer` 的数据模型：
///   training_item / progress / completion_log
/// progress 只存"当前位置"，本次序列等由算法现算（不落快照列）。
/// 注：产品需求已去掉"段和"展示，本地表亦不建 segment_sum 列。
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    // 桌面端用 FFI 工厂；移动端走原生 sqflite。
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    Directory dir;
    try {
      dir = await getApplicationDocumentsDirectory();
    } catch (_) {
      dir = Directory.current;
    }
    final path = p.join(dir.path, 'advance_trainer.db');
    _db = await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2：训练方式 + 具体实施目标（替代原"单位"展示）
      for (final col in ['training_method', 'goal_text']) {
        final exists = await _columnExists(db, 'training_item', col);
        if (!exists) {
          await db.execute('ALTER TABLE training_item ADD COLUMN $col TEXT');
        }
      }
    }
    if (oldVersion < 3) {
      // v3：任务类型（运动/事务/学习/记录）+ 清单文件（事务/学习）
      for (final col in ['task_type', 'list_file_path', 'list_file_name']) {
        final exists = await _columnExists(db, 'training_item', col);
        if (!exists) {
          await db.execute('ALTER TABLE training_item ADD COLUMN $col TEXT');
        }
      }
    }
    if (oldVersion < 4) {
      // v4：运动任务节拍器 BPM
      final exists = await _columnExists(db, 'training_item', 'bpm');
      if (!exists) {
        await db.execute('ALTER TABLE training_item ADD COLUMN bpm INTEGER');
      }
    }
    if (oldVersion < 5) {
      // v5：事务/学习 全局清单游标（持久化，下次执行从上次位置继续）
      final exists = await _columnExists(db, 'training_item', 'list_cursor');
      if (!exists) {
        await db.execute('ALTER TABLE training_item ADD COLUMN list_cursor INTEGER');
      }
    }
  }

  static Future<bool> _columnExists(Database db, String table, String column) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((r) => r['name'] == column);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE training_item(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        training_method TEXT,
        task_type TEXT,
        goal_text TEXT,
        metric_unit TEXT,
        list_file_path TEXT,
        list_file_name TEXT,
        begin_num INTEGER NOT NULL,
        plus_var INTEGER NOT NULL,
        d_grade INTEGER NOT NULL,
        begin_grade INTEGER NOT NULL,
        bpm INTEGER,
        list_cursor INTEGER,
        fail_rule TEXT,
        status TEXT,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE progress(
        item_id INTEGER PRIMARY KEY,
        grade INTEGER NOT NULL,
        level INTEGER NOT NULL,
        rep INTEGER NOT NULL,
        updated_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE completion_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        log_date TEXT,
        grade INTEGER,
        level INTEGER,
        rep INTEGER,
        target TEXT,
        result TEXT,
        note TEXT,
        created_at TEXT
      )
    ''');
  }
}
