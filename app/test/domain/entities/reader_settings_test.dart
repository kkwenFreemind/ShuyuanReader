/// ReaderSettings 實體單元測試
///
/// 測試 ReaderSettings 類的所有功能，包括：
/// - 構造函數和預設值
/// - 設置更新方法
/// - 字體大小調整
/// - 亮度調整
/// - 模式切換
/// - 驗證方法
/// - JSON 序列化
/// - Equatable 行為

import 'package:flutter_test/flutter_test.dart';
import 'package:shuyuan_reader/domain/entities/reader/reader_settings.dart';
import 'package:shuyuan_reader/domain/entities/reader/reading_direction.dart';

void main() {
  group('構造函數測試', () {
    test('預設構造函數應該使用預設值', () {
      const settings = ReaderSettings();

      expect(settings.direction, ReadingDirection.vertical);
      expect(settings.fontSize, 16.0);
      expect(settings.brightness, 1.0);
      expect(settings.isNightMode, false);
      expect(settings.autoHideToolbar, true);
    });

    test('defaultSettings 工廠方法應該返回預設設置', () {
      final settings = ReaderSettings.defaultSettings();

      expect(settings.direction, ReadingDirection.vertical);
      expect(settings.fontSize, 16.0);
      expect(settings.brightness, 1.0);
      expect(settings.isNightMode, false);
      expect(settings.autoHideToolbar, true);
    });

    test('應該能夠使用自定義值創建設置', () {
      const settings = ReaderSettings(
        direction: ReadingDirection.horizontal,
        fontSize: 18.0,
        brightness: 0.7,
        isNightMode: true,
        autoHideToolbar: false,
      );

      expect(settings.direction, ReadingDirection.horizontal);
      expect(settings.fontSize, 18.0);
      expect(settings.brightness, 0.7);
      expect(settings.isNightMode, true);
      expect(settings.autoHideToolbar, false);
    });
  });

  group('閱讀方向更新測試', () {
    test('updateDirection 應該更新閱讀方向', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateDirection(ReadingDirection.horizontal);

      expect(newSettings.direction, ReadingDirection.horizontal);
      expect(newSettings.fontSize, settings.fontSize);
      expect(newSettings.brightness, settings.brightness);
    });

    test('updateDirection 應該返回新實例', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateDirection(ReadingDirection.horizontal);

      expect(identical(settings, newSettings), false);
    });
  });

  group('字體大小調整測試', () {
    test('updateFontSize 應該更新字體大小', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateFontSize(18.0);

      expect(newSettings.fontSize, 18.0);
      expect(newSettings.direction, settings.direction);
    });

    test('updateFontSize 應該限制最小值為 12.0', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateFontSize(8.0);

      expect(newSettings.fontSize, 12.0);
    });

    test('updateFontSize 應該限制最大值為 20.0', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateFontSize(25.0);

      expect(newSettings.fontSize, 20.0);
    });

    test('increaseFontSize 應該增加 2sp', () {
      const settings = ReaderSettings(fontSize: 14.0);
      final newSettings = settings.increaseFontSize();

      expect(newSettings.fontSize, 16.0);
    });

    test('increaseFontSize 不應該超過最大值', () {
      const settings = ReaderSettings(fontSize: 20.0);
      final newSettings = settings.increaseFontSize();

      expect(newSettings.fontSize, 20.0);
    });

    test('decreaseFontSize 應該減少 2sp', () {
      const settings = ReaderSettings(fontSize: 16.0);
      final newSettings = settings.decreaseFontSize();

      expect(newSettings.fontSize, 14.0);
    });

    test('decreaseFontSize 不應該低於最小值', () {
      const settings = ReaderSettings(fontSize: 12.0);
      final newSettings = settings.decreaseFontSize();

      expect(newSettings.fontSize, 12.0);
    });

    test('fontSizePresetIndex 應該返回正確的檔位索引', () {
      expect(const ReaderSettings(fontSize: 12.0).fontSizePresetIndex, 0);
      expect(const ReaderSettings(fontSize: 14.0).fontSizePresetIndex, 1);
      expect(const ReaderSettings(fontSize: 16.0).fontSizePresetIndex, 2);
      expect(const ReaderSettings(fontSize: 18.0).fontSizePresetIndex, 3);
      expect(const ReaderSettings(fontSize: 20.0).fontSizePresetIndex, 4);
    });

    test('fontSizePresetIndex 應該返回最接近的檔位索引', () {
      // 13.5 更接近 14.0 (距離 0.5 vs 距離 1.5)
      expect(const ReaderSettings(fontSize: 13.5).fontSizePresetIndex, 1);
      // 15.0 與 14.0 和 16.0 等距 (都是 1.0)，返回第一個匹配 (index 1)
      expect(const ReaderSettings(fontSize: 15.0).fontSizePresetIndex, 1);
      // 17.5 更接近 18.0 (距離 0.5 vs 距離 1.5)
      expect(const ReaderSettings(fontSize: 17.5).fontSizePresetIndex, 3);
    });
  });

  group('亮度調整測試', () {
    test('updateBrightness 應該更新亮度', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateBrightness(0.5);

      expect(newSettings.brightness, 0.5);
    });

    test('updateBrightness 應該限制最小值為 0.0', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateBrightness(-0.5);

      expect(newSettings.brightness, 0.0);
    });

    test('updateBrightness 應該限制最大值為 1.0', () {
      const settings = ReaderSettings();
      final newSettings = settings.updateBrightness(1.5);

      expect(newSettings.brightness, 1.0);
    });
  });

  group('模式切換測試', () {
    test('toggleNightMode 應該切換夜間模式', () {
      const settings = ReaderSettings(isNightMode: false);
      final newSettings = settings.toggleNightMode();

      expect(newSettings.isNightMode, true);
    });

    test('toggleNightMode 應該能夠反覆切換', () {
      const settings = ReaderSettings(isNightMode: false);
      final toggled1 = settings.toggleNightMode();
      final toggled2 = toggled1.toggleNightMode();

      expect(toggled1.isNightMode, true);
      expect(toggled2.isNightMode, false);
    });

    test('toggleAutoHideToolbar 應該切換工具欄自動隱藏', () {
      const settings = ReaderSettings(autoHideToolbar: true);
      final newSettings = settings.toggleAutoHideToolbar();

      expect(newSettings.autoHideToolbar, false);
    });

    test('toggleAutoHideToolbar 應該能夠反覆切換', () {
      const settings = ReaderSettings(autoHideToolbar: true);
      final toggled1 = settings.toggleAutoHideToolbar();
      final toggled2 = toggled1.toggleAutoHideToolbar();

      expect(toggled1.autoHideToolbar, false);
      expect(toggled2.autoHideToolbar, true);
    });
  });

  group('驗證方法測試', () {
    test('isValid 應該對有效設置返回 true', () {
      const settings = ReaderSettings(
        fontSize: 16.0,
        brightness: 0.8,
      );

      expect(settings.isValid(), true);
    });

    test('isValid 應該對字體過小返回 false', () {
      const settings = ReaderSettings(fontSize: 10.0);

      expect(settings.isValid(), false);
    });

    test('isValid 應該對字體過大返回 false', () {
      const settings = ReaderSettings(fontSize: 25.0);

      expect(settings.isValid(), false);
    });

    test('isValid 應該對亮度為負數返回 false', () {
      const settings = ReaderSettings(brightness: -0.1);

      expect(settings.isValid(), false);
    });

    test('isValid 應該對亮度超過 1.0 返回 false', () {
      const settings = ReaderSettings(brightness: 1.5);

      expect(settings.isValid(), false);
    });

    test('isValid 應該對邊界值返回 true', () {
      const minSettings = ReaderSettings(fontSize: 12.0, brightness: 0.0);
      const maxSettings = ReaderSettings(fontSize: 20.0, brightness: 1.0);

      expect(minSettings.isValid(), true);
      expect(maxSettings.isValid(), true);
    });
  });

  group('copyWith 測試', () {
    test('copyWith 應該創建新實例並修改指定字段', () {
      const settings = ReaderSettings();
      final newSettings = settings.copyWith(
        fontSize: 18.0,
        isNightMode: true,
      );

      expect(newSettings.fontSize, 18.0);
      expect(newSettings.isNightMode, true);
      expect(newSettings.direction, settings.direction);
      expect(newSettings.brightness, settings.brightness);
      expect(newSettings.autoHideToolbar, settings.autoHideToolbar);
    });

    test('copyWith 不傳參數應該返回相同值的新實例', () {
      const settings = ReaderSettings(
        direction: ReadingDirection.horizontal,
        fontSize: 18.0,
      );
      final newSettings = settings.copyWith();

      expect(identical(settings, newSettings), false);
      expect(newSettings.direction, settings.direction);
      expect(newSettings.fontSize, settings.fontSize);
      expect(newSettings.brightness, settings.brightness);
      expect(newSettings.isNightMode, settings.isNightMode);
      expect(newSettings.autoHideToolbar, settings.autoHideToolbar);
    });

    test('copyWith 應該能夠修改所有字段', () {
      const settings = ReaderSettings();
      final newSettings = settings.copyWith(
        direction: ReadingDirection.horizontal,
        fontSize: 14.0,
        brightness: 0.6,
        isNightMode: true,
        autoHideToolbar: false,
      );

      expect(newSettings.direction, ReadingDirection.horizontal);
      expect(newSettings.fontSize, 14.0);
      expect(newSettings.brightness, 0.6);
      expect(newSettings.isNightMode, true);
      expect(newSettings.autoHideToolbar, false);
    });
  });

  group('JSON 序列化測試', () {
    test('toJson 應該正確序列化為 JSON', () {
      const settings = ReaderSettings(
        direction: ReadingDirection.horizontal,
        fontSize: 18.0,
        brightness: 0.8,
        isNightMode: true,
        autoHideToolbar: false,
      );

      final json = settings.toJson();

      expect(json['direction'], 'horizontal');
      expect(json['fontSize'], 18.0);
      expect(json['brightness'], 0.8);
      expect(json['isNightMode'], true);
      expect(json['autoHideToolbar'], false);
    });

    test('fromJson 應該正確從 JSON 反序列化', () {
      final json = {
        'direction': 'vertical',
        'fontSize': 16.0,
        'brightness': 0.9,
        'isNightMode': false,
        'autoHideToolbar': true,
      };

      final settings = ReaderSettings.fromJson(json);

      expect(settings.direction, ReadingDirection.vertical);
      expect(settings.fontSize, 16.0);
      expect(settings.brightness, 0.9);
      expect(settings.isNightMode, false);
      expect(settings.autoHideToolbar, true);
    });

    test('JSON 序列化和反序列化應該保持數據一致', () {
      const original = ReaderSettings(
        direction: ReadingDirection.horizontal,
        fontSize: 14.0,
        brightness: 0.7,
        isNightMode: true,
        autoHideToolbar: false,
      );

      final json = original.toJson();
      final restored = ReaderSettings.fromJson(json);

      expect(restored, original);
    });
  });

  group('Equatable 測試', () {
    test('相同值的兩個實例應該相等', () {
      const settings1 = ReaderSettings(
        direction: ReadingDirection.vertical,
        fontSize: 16.0,
      );
      const settings2 = ReaderSettings(
        direction: ReadingDirection.vertical,
        fontSize: 16.0,
      );

      expect(settings1, settings2);
      expect(settings1.hashCode, settings2.hashCode);
    });

    test('不同值的兩個實例應該不相等', () {
      const settings1 = ReaderSettings(fontSize: 16.0);
      const settings2 = ReaderSettings(fontSize: 18.0);

      expect(settings1, isNot(settings2));
    });

    test('任一字段不同都應該導致不相等', () {
      const base = ReaderSettings();

      expect(base.copyWith(direction: ReadingDirection.horizontal), isNot(base));
      expect(base.copyWith(fontSize: 18.0), isNot(base));
      expect(base.copyWith(brightness: 0.5), isNot(base));
      expect(base.copyWith(isNightMode: true), isNot(base));
      expect(base.copyWith(autoHideToolbar: false), isNot(base));
    });
  });

  group('toString 測試', () {
    test('toString 應該包含所有字段信息', () {
      const settings = ReaderSettings(
        direction: ReadingDirection.horizontal,
        fontSize: 18.0,
        brightness: 0.8,
        isNightMode: true,
        autoHideToolbar: false,
      );

      final str = settings.toString();

      expect(str, contains('ReaderSettings'));
      expect(str, contains('horizontal'));
      expect(str, contains('18.0sp'));
      expect(str, contains('80%'));
      expect(str, contains('isNightMode: true'));
      expect(str, contains('autoHideToolbar: false'));
    });

    test('toString 應該正確顯示亮度百分比', () {
      const settings1 = ReaderSettings(brightness: 0.5);
      const settings2 = ReaderSettings(brightness: 1.0);
      const settings3 = ReaderSettings(brightness: 0.0);

      expect(settings1.toString(), contains('50%'));
      expect(settings2.toString(), contains('100%'));
      expect(settings3.toString(), contains('0%'));
    });
  });

  group('常量測試', () {
    test('字體大小常量應該定義正確', () {
      expect(ReaderSettings.minFontSize, 12.0);
      expect(ReaderSettings.maxFontSize, 20.0);
    });

    test('字體大小預設檔位應該包含 5 個值', () {
      expect(ReaderSettings.fontSizePresets.length, 5);
      expect(ReaderSettings.fontSizePresets, [12.0, 14.0, 16.0, 18.0, 20.0]);
    });

    test('字體大小預設檔位應該在有效範圍內', () {
      for (final size in ReaderSettings.fontSizePresets) {
        expect(size, greaterThanOrEqualTo(ReaderSettings.minFontSize));
        expect(size, lessThanOrEqualTo(ReaderSettings.maxFontSize));
      }
    });
  });
}
