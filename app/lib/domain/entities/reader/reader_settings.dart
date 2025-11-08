/// 閱讀器設置實體
///
/// 純領域層實體，用於管理閱讀器的各項設置。
/// 此類不依賴任何框架，遵循 Clean Architecture 原則。
///
/// **主要功能**：
/// - 管理閱讀方向（直書/橫書）
/// - 管理字體大小設置
/// - 管理屏幕亮度設置
/// - 管理夜間模式開關
/// - 管理工具欄自動隱藏設置
///
/// **設計模式**：
/// - Immutable Object（不可變對象）
/// - Value Object（值對象，通過 Equatable）
/// - Copy-on-Write（通過 copyWith 方法）
///
/// **使用示例**：
/// ```dart
/// // 創建預設設置
/// final settings = ReaderSettings.defaultSettings();
///
/// // 修改字體大小
/// final newSettings = settings.updateFontSize(18.0);
///
/// // 切換閱讀方向
/// final verticalSettings = settings.updateDirection(ReadingDirection.vertical);
///
/// // 調整亮度
/// final brighterSettings = settings.updateBrightness(0.8);
/// ```
library;

import 'package:equatable/equatable.dart';
import 'reading_direction.dart';

/// 閱讀器設置實體類
///
/// 管理閱讀器的所有可配置設置項。
/// 此類是不可變的，所有修改操作都返回新實例。
class ReaderSettings extends Equatable {
  /// 閱讀方向（直書/橫書）
  ///
  /// 預設為直書模式（vertical），適合傳統中文閱讀。
  final ReadingDirection direction;

  /// 字體大小（sp）
  ///
  /// 取值範圍：12.0 - 20.0
  /// 預設值：16.0
  /// 推薦檔位：12, 14, 16, 18, 20
  final double fontSize;

  /// 屏幕亮度
  ///
  /// 取值範圍：0.0 - 1.0
  /// 預設值：1.0（跟隨系統）
  /// - 0.0：最暗
  /// - 0.5：中等亮度
  /// - 1.0：最亮
  final double brightness;

  /// 是否開啟夜間模式
  ///
  /// 預設值：false
  /// 夜間模式會調整顏色方案，降低眼睛疲勞。
  final bool isNightMode;

  /// 是否自動隱藏工具欄
  ///
  /// 預設值：true
  /// 啟用後，工具欄會在閱讀時自動隱藏，提供更沉浸的閱讀體驗。
  final bool autoHideToolbar;

  /// 構造函數
  ///
  /// 創建一個閱讀器設置實例。
  /// 所有參數都有預設值，可以直接調用 `ReaderSettings()` 創建預設設置。
  const ReaderSettings({
    this.direction = ReadingDirection.vertical,
    this.fontSize = 16.0,
    this.brightness = 1.0,
    this.isNightMode = false,
    this.autoHideToolbar = true,
  });

  /// 創建預設設置
  ///
  /// 返回一個包含所有預設值的設置實例：
  /// - 直書模式
  /// - 字體大小 16sp
  /// - 亮度 100%
  /// - 非夜間模式
  /// - 自動隱藏工具欄
  factory ReaderSettings.defaultSettings() {
    return const ReaderSettings();
  }

  // ==================== 設置更新方法 ====================

  /// 更新閱讀方向
  ///
  /// 返回一個新的設置實例，其中閱讀方向已更新。
  ///
  /// **參數**：
  /// - [newDirection]: 新的閱讀方向
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ReaderSettings updateDirection(ReadingDirection newDirection) {
    return copyWith(direction: newDirection);
  }

  /// 更新字體大小
  ///
  /// 返回一個新的設置實例，其中字體大小已更新。
  /// 字體大小會被限制在 [minFontSize] 和 [maxFontSize] 之間。
  ///
  /// **參數**：
  /// - [newSize]: 新的字體大小（sp）
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ///
  /// **示例**：
  /// ```dart
  /// final larger = settings.updateFontSize(18.0);
  /// ```
  ReaderSettings updateFontSize(double newSize) {
    final clampedSize = newSize.clamp(minFontSize, maxFontSize);
    return copyWith(fontSize: clampedSize);
  }

  /// 更新屏幕亮度
  ///
  /// 返回一個新的設置實例，其中亮度已更新。
  /// 亮度值會被限制在 0.0 和 1.0 之間。
  ///
  /// **參數**：
  /// - [newBrightness]: 新的亮度值（0.0 - 1.0）
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ReaderSettings updateBrightness(double newBrightness) {
    final clampedBrightness = newBrightness.clamp(0.0, 1.0);
    return copyWith(brightness: clampedBrightness);
  }

  /// 切換夜間模式
  ///
  /// 返回一個新的設置實例，夜間模式狀態已切換。
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ReaderSettings toggleNightMode() {
    return copyWith(isNightMode: !isNightMode);
  }

  /// 切換工具欄自動隱藏
  ///
  /// 返回一個新的設置實例，工具欄自動隱藏狀態已切換。
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ReaderSettings toggleAutoHideToolbar() {
    return copyWith(autoHideToolbar: !autoHideToolbar);
  }

  // ==================== 字體大小相關 ====================

  /// 最小字體大小（sp）
  static const double minFontSize = 12.0;

  /// 最大字體大小（sp）
  static const double maxFontSize = 20.0;

  /// 推薦的字體大小檔位
  static const List<double> fontSizePresets = [12.0, 14.0, 16.0, 18.0, 20.0];

  /// 增加字體大小
  ///
  /// 字體大小增加 2sp，如果已達到最大值則不變。
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ReaderSettings increaseFontSize() {
    return updateFontSize(fontSize + 2.0);
  }

  /// 減少字體大小
  ///
  /// 字體大小減少 2sp，如果已達到最小值則不變。
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ReaderSettings decreaseFontSize() {
    return updateFontSize(fontSize - 2.0);
  }

  /// 獲取當前字體大小檔位索引
  ///
  /// 返回當前字體大小在 [fontSizePresets] 中的索引。
  /// 如果不在預設檔位中，返回最接近的檔位索引。
  ///
  /// **返回**：
  /// 檔位索引（0-4）
  int get fontSizePresetIndex {
    double minDiff = double.infinity;
    int closestIndex = 2; // 預設為中間檔位

    for (int i = 0; i < fontSizePresets.length; i++) {
      final diff = (fontSize - fontSizePresets[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  // ==================== 驗證方法 ====================

  /// 驗證設置是否有效
  ///
  /// 檢查所有設置值是否在有效範圍內。
  ///
  /// **返回**：
  /// true 如果所有設置都有效，否則 false
  bool isValid() {
    return fontSize >= minFontSize &&
        fontSize <= maxFontSize &&
        brightness >= 0.0 &&
        brightness <= 1.0;
  }

  // ==================== 實用方法 ====================

  /// 創建當前設置的副本，並可選擇性地修改某些字段
  ///
  /// 這是實現不可變性的核心方法。
  ///
  /// **參數**：
  /// - [direction]: 可選，新的閱讀方向
  /// - [fontSize]: 可選，新的字體大小
  /// - [brightness]: 可選，新的亮度值
  /// - [isNightMode]: 可選，新的夜間模式狀態
  /// - [autoHideToolbar]: 可選，新的工具欄自動隱藏狀態
  ///
  /// **返回**：
  /// 新的 ReaderSettings 實例
  ReaderSettings copyWith({
    ReadingDirection? direction,
    double? fontSize,
    double? brightness,
    bool? isNightMode,
    bool? autoHideToolbar,
  }) {
    return ReaderSettings(
      direction: direction ?? this.direction,
      fontSize: fontSize ?? this.fontSize,
      brightness: brightness ?? this.brightness,
      isNightMode: isNightMode ?? this.isNightMode,
      autoHideToolbar: autoHideToolbar ?? this.autoHideToolbar,
    );
  }

  /// 將設置轉換為 JSON Map
  ///
  /// 用於持久化存儲或數據傳輸。
  ///
  /// **返回**：
  /// JSON Map
  Map<String, dynamic> toJson() {
    return {
      'direction': direction.name,
      'fontSize': fontSize,
      'brightness': brightness,
      'isNightMode': isNightMode,
      'autoHideToolbar': autoHideToolbar,
    };
  }

  /// 從 JSON Map 創建設置實例
  ///
  /// 用於從持久化存儲或網絡數據恢復設置。
  ///
  /// **參數**：
  /// - [json]: JSON Map
  ///
  /// **返回**：
  /// ReaderSettings 實例
  ///
  /// **異常**：
  /// - 如果 JSON 格式不正確，可能拋出異常
  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      direction: ReadingDirection.values.byName(json['direction'] as String),
      fontSize: (json['fontSize'] as num).toDouble(),
      brightness: (json['brightness'] as num).toDouble(),
      isNightMode: json['isNightMode'] as bool,
      autoHideToolbar: json['autoHideToolbar'] as bool,
    );
  }

  /// 轉換為字符串表示（用於調試）
  ///
  /// **返回**：
  /// 格式化的字符串
  @override
  String toString() {
    return 'ReaderSettings('
        'direction: $direction, '
        'fontSize: ${fontSize}sp, '
        'brightness: ${(brightness * 100).toInt()}%, '
        'isNightMode: $isNightMode, '
        'autoHideToolbar: $autoHideToolbar'
        ')';
  }

  /// Equatable props
  ///
  /// 用於值比較，兩個 ReaderSettings 實例如果所有字段相等，則認為相等。
  @override
  List<Object?> get props => [
        direction,
        fontSize,
        brightness,
        isNightMode,
        autoHideToolbar,
      ];
}
