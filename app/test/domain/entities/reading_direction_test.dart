/// ReadingDirection 枚舉單元測試
///
/// 測試 ReadingDirection 枚舉的所有功能，包括：
/// - 枚舉值定義
/// - 顯示名稱
/// - 判斷方法
/// - 切換方法
/// - CSS 屬性
/// - UI 相關屬性

import 'package:flutter_test/flutter_test.dart';
import 'package:shuyuan_reader/domain/entities/reader/reading_direction.dart';

void main() {
  group('枚舉值測試', () {
    test('應該定義兩個閱讀方向', () {
      expect(ReadingDirection.values.length, 2);
      expect(ReadingDirection.values, contains(ReadingDirection.vertical));
      expect(ReadingDirection.values, contains(ReadingDirection.horizontal));
    });

    test('vertical 應該有正確的顯示名稱', () {
      expect(ReadingDirection.vertical.displayName, '直書');
    });

    test('horizontal 應該有正確的顯示名稱', () {
      expect(ReadingDirection.horizontal.displayName, '橫書');
    });
  });

  group('判斷方法測試', () {
    test('isVertical 應該正確判斷直書模式', () {
      expect(ReadingDirection.vertical.isVertical, true);
      expect(ReadingDirection.horizontal.isVertical, false);
    });

    test('isHorizontal 應該正確判斷橫書模式', () {
      expect(ReadingDirection.vertical.isHorizontal, false);
      expect(ReadingDirection.horizontal.isHorizontal, true);
    });
  });

  group('切換方法測試', () {
    test('toggle 應該從直書切換到橫書', () {
      final result = ReadingDirection.vertical.toggle();
      expect(result, ReadingDirection.horizontal);
    });

    test('toggle 應該從橫書切換到直書', () {
      final result = ReadingDirection.horizontal.toggle();
      expect(result, ReadingDirection.vertical);
    });

    test('toggle 應該能夠反覆切換', () {
      final direction = ReadingDirection.vertical;
      final toggled1 = direction.toggle();
      final toggled2 = toggled1.toggle();

      expect(toggled1, ReadingDirection.horizontal);
      expect(toggled2, ReadingDirection.vertical);
    });
  });

  group('CSS 屬性測試', () {
    test('vertical 應該返回正確的 CSS writing-mode', () {
      expect(
        ReadingDirection.vertical.cssWritingMode,
        'vertical-rl',
      );
    });

    test('horizontal 應該返回正確的 CSS writing-mode', () {
      expect(
        ReadingDirection.horizontal.cssWritingMode,
        'horizontal-tb',
      );
    });
  });

  group('UI 相關屬性測試', () {
    test('vertical 應該有直書圖標', () {
      expect(ReadingDirection.vertical.icon, '⚔️');
    });

    test('horizontal 應該有橫書圖標', () {
      expect(ReadingDirection.horizontal.icon, '📖');
    });

    test('vertical 應該有正確的翻頁提示', () {
      expect(
        ReadingDirection.vertical.swipeHint,
        '⬅️ 向左滑 = 下一頁',
      );
    });

    test('horizontal 應該有正確的翻頁提示', () {
      expect(
        ReadingDirection.horizontal.swipeHint,
        '➡️ 向右滑 = 下一頁',
      );
    });
  });

  group('toString 測試', () {
    test('vertical 的 toString 應該包含名稱和顯示名稱', () {
      final str = ReadingDirection.vertical.toString();
      expect(str, contains('ReadingDirection'));
      expect(str, contains('vertical'));
      expect(str, contains('直書'));
    });

    test('horizontal 的 toString 應該包含名稱和顯示名稱', () {
      final str = ReadingDirection.horizontal.toString();
      expect(str, contains('ReadingDirection'));
      expect(str, contains('horizontal'));
      expect(str, contains('橫書'));
    });
  });

  group('枚舉名稱測試', () {
    test('vertical 的 name 屬性應該是 "vertical"', () {
      expect(ReadingDirection.vertical.name, 'vertical');
    });

    test('horizontal 的 name 屬性應該是 "horizontal"', () {
      expect(ReadingDirection.horizontal.name, 'horizontal');
    });

    test('應該能夠通過名稱查找枚舉值', () {
      final vertical = ReadingDirection.values.byName('vertical');
      final horizontal = ReadingDirection.values.byName('horizontal');

      expect(vertical, ReadingDirection.vertical);
      expect(horizontal, ReadingDirection.horizontal);
    });
  });

  group('完整使用場景測試', () {
    test('應該能夠根據用戶偏好選擇閱讀方向', () {
      // 模擬用戶選擇直書
      var currentDirection = ReadingDirection.vertical;
      expect(currentDirection.displayName, '直書');
      expect(currentDirection.cssWritingMode, 'vertical-rl');

      // 用戶切換到橫書
      currentDirection = currentDirection.toggle();
      expect(currentDirection.displayName, '橫書');
      expect(currentDirection.cssWritingMode, 'horizontal-tb');
    });

    test('應該能夠為不同閱讀方向顯示正確的 UI 提示', () {
      final directions = ReadingDirection.values;

      for (final direction in directions) {
        // 確保每個方向都有必要的 UI 屬性
        expect(direction.displayName.isNotEmpty, true);
        expect(direction.icon.isNotEmpty, true);
        expect(direction.swipeHint.isNotEmpty, true);
        expect(direction.cssWritingMode.isNotEmpty, true);
      }
    });

    test('應該能夠保存和恢復閱讀方向', () {
      // 保存（通過 name）
      final saved = ReadingDirection.vertical;
      final savedName = saved.name;

      // 恢復
      final restored = ReadingDirection.values.byName(savedName);

      expect(restored, saved);
      expect(restored.displayName, saved.displayName);
    });
  });
}
