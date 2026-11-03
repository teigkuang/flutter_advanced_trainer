import 'package:flutter_test/flutter_test.dart';
import 'package:advance_trainer/engine/models.dart';
import 'package:advance_trainer/engine/progress_engine.dart';

/// 测试向量对照算法仓 advanced-trainer（Java）已验算的结果。
TrainingItem _defaultItem() => TrainingItem(
      name: '胸肌卧推',
      beginNum: 1, // A=1
      plusVar: 1, // P=1
      dGrade: 8, // 阶数 3 → dGrade=8
      beginGrade: 1, // 起始阶数 0 → beginGrade=1
      failRule: 'STAY',
      createdAt: '2026-11-01',
    );

void main() {
  group('序列生成 buildSeq', () {
    test('奇数阶双峰：grade=5 → (1)(2)(3)(3)(2)(1)', () {
      final s = ProgressEngine.buildSeq(1, 1, 5, 0);
      expect(s, [1, 2, 3, 3, 2, 1]);
      expect(s.length, 5 + 1); // 长度恒为 grade+1
    });

    test('偶数阶单峰：grade=4 → (1)(2)(3)(2)(1)', () {
      final s = ProgressEngine.buildSeq(1, 1, 4, 0);
      expect(s, [1, 2, 3, 2, 1]);
      expect(s.length, 4 + 1);
    });

    test('grade 0 只有一项', () {
      expect(ProgressEngine.buildSeq(1, 1, 0, 0), [1]);
    });
  });

  group('标题 gradeTitle', () {
    test('奇数=正第c阶', () => expect(ProgressEngine.gradeTitle(5), '正第2阶'));
    test('偶数=准第c阶', () => expect(ProgressEngine.gradeTitle(4), '准第2阶'));
  });

  group('初始进度 initialState', () {
    test('默认项起点阶首级首次', () {
      final st = ProgressEngine.initialState(_defaultItem());
      expect(st.grade, 0);
      expect(st.level, 0);
      expect(st.rep, 0);
    });
  });

  group('推算当前这一次 currentRepData（对照第 36 次）', () {
    test('(5,0,3) → 正第2阶·第1级·第4次，6 项序列', () {
      final item = _defaultItem();
      final d = ProgressEngine.currentRepData(item, const ProgressState(5, 0, 3));
      expect(d.title, '正第2阶 · 第1级 · 第4次');
      expect(d.sequence, [1, 2, 3, 3, 2, 1]);
      expect(d.levelNeed, 6); // repCount(5)
      expect(d.levelDone, 3);
      expect(d.levelLeft, 3);
    });
  });

  group('已取得的成绩 totalCompleted（对照算法仓验算）', () {
    final item = _defaultItem();

    test('初始态 (0,0,0) → 0（待开始）', () {
      expect(ProgressEngine.totalCompleted(item, const ProgressState(0, 0, 0)), 0);
    });

    test('第 36 次状态 (5,0,3) → 已完成 35 次', () {
      expect(ProgressEngine.totalCompleted(item, const ProgressState(5, 0, 3)), 35);
    });

    test('(2,1,0) → 已完成 6 次（0、1 阶全满 + 2 阶第1级 0 次）', () {
      expect(ProgressEngine.totalCompleted(item, const ProgressState(2, 1, 0)), 6);
    });

    test('第 2 次 (0,0,1) → 已完成 1 次', () {
      expect(ProgressEngine.totalCompleted(item, const ProgressState(0, 0, 1)), 1);
    });
  });

  group('推进 advance', () {
    final item = _defaultItem();

    test('次未满 → rep+1', () {
      expect(ProgressEngine.advance(item, const ProgressState(5, 0, 3)),
          const ProgressState(5, 0, 4));
    });

    test('次满 → 升一级', () {
      expect(ProgressEngine.advance(item, const ProgressState(5, 0, 5)),
          const ProgressState(5, 1, 0));
    });

    test('级满 → 升一阶', () {
      expect(ProgressEngine.advance(item, const ProgressState(5, 2, 5)),
          const ProgressState(6, 0, 0));
    });

    test('阶满 → 完成返回 null（末阶 grade7 末级 level3 末次 rep7）', () {
      expect(ProgressEngine.advance(item, const ProgressState(7, 3, 7)), isNull);
    });
  });

  group('回退 recede', () {
    test('STAY 停留原地', () {
      final stay = _defaultItem();
      expect(ProgressEngine.recede(stay, const ProgressState(5, 0, 3)),
          const ProgressState(5, 0, 3));
    });

    test('RECEDE 级内回退一次', () {
      final item = _defaultItem()..failRule = 'RECEDE';
      expect(ProgressEngine.recede(item, const ProgressState(5, 0, 3)),
          const ProgressState(5, 0, 2));
    });

    test('RECEDE 级首回上一级末次', () {
      final item = _defaultItem()..failRule = 'RECEDE';
      expect(ProgressEngine.recede(item, const ProgressState(5, 1, 0)),
          const ProgressState(5, 0, 5));
    });

    test('RECEDE 阶首回上一阶末级末次', () {
      final item = _defaultItem()..failRule = 'RECEDE';
      expect(ProgressEngine.recede(item, const ProgressState(5, 0, 0)),
          const ProgressState(4, 2, 4));
    });

    test('RECEDE 已在起点不可回退', () {
      final item = _defaultItem()..failRule = 'RECEDE';
      expect(ProgressEngine.recede(item, const ProgressState(0, 0, 0)),
          const ProgressState(0, 0, 0));
    });
  });
}
