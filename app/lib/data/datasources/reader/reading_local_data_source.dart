/// 閱讀數據本地數據源
/// 
/// 負責：
/// - 從 Hive 讀取/保存閱讀進度
/// - 從 SharedPreferences 讀取/保存設置
library;

import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/reader/reader_settings.dart';
import '../../../domain/entities/reader/reading_direction.dart';

/// 閱讀設置本地數據源
///
/// 使用 SharedPreferences 存儲用戶的閱讀偏好設置。
/// 每個書籍可以有獨立的設置，也可以使用全局預設設置。
class ReadingLocalDataSource {
  final SharedPreferences _prefs;

  /// 構造函數
  ///
  /// 接收 SharedPreferences 實例（通過依賴注入）
  ReadingLocalDataSource(this._prefs);

  // ==================== 設置鍵常量 ====================

  /// 全局預設設置鍵前綴
  static const String _defaultPrefix = 'reader_default_';

  /// 書籍特定設置鍵前綴
  static const String _bookPrefix = 'reader_book_';

  /// 閱讀方向鍵後綴
  static const String _directionSuffix = 'direction';

  /// 字體大小鍵後綴
  static const String _fontSizeSuffix = 'font_size';

  /// 亮度鍵後綴
  static const String _brightnessSuffix = 'brightness';

  /// 夜間模式鍵後綴
  static const String _nightModeSuffix = 'night_mode';

  /// 自動隱藏工具欄鍵後綴
  static const String _autoHideToolbarSuffix = 'auto_hide_toolbar';

  // ==================== 保存設置 ====================

  /// 保存全局預設設置
  ///
  /// 這些設置將應用於所有沒有特定設置的書籍。
  Future<void> saveDefaultSettings(ReaderSettings settings) async {
    await _saveSettings(_defaultPrefix, settings);
  }

  /// 保存書籍特定設置
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  /// - [settings]: 閱讀器設置
  Future<void> saveBookSettings(String bookId, ReaderSettings settings) async {
    await _saveSettings('${_bookPrefix}$bookId\_', settings);
  }

  /// 內部方法：保存設置到 SharedPreferences
  Future<void> _saveSettings(String prefix, ReaderSettings settings) async {
    await Future.wait([
      _prefs.setString(
        '$prefix$_directionSuffix',
        settings.direction.name,
      ),
      _prefs.setDouble(
        '$prefix$_fontSizeSuffix',
        settings.fontSize,
      ),
      _prefs.setDouble(
        '$prefix$_brightnessSuffix',
        settings.brightness,
      ),
      _prefs.setBool(
        '$prefix$_nightModeSuffix',
        settings.isNightMode,
      ),
      _prefs.setBool(
        '$prefix$_autoHideToolbarSuffix',
        settings.autoHideToolbar,
      ),
    ]);
  }

  // ==================== 讀取設置 ====================

  /// 讀取全局預設設置
  ///
  /// 如果不存在，返回系統預設設置。
  ReaderSettings getDefaultSettings() {
    return _loadSettings(_defaultPrefix) ?? ReaderSettings.defaultSettings();
  }

  /// 讀取書籍特定設置
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  ///
  /// **返回**：
  /// - 如果存在書籍特定設置，返回該設置
  /// - 否則返回全局預設設置
  ReaderSettings getBookSettings(String bookId) {
    final bookSettings = _loadSettings('${_bookPrefix}$bookId\_');
    return bookSettings ?? getDefaultSettings();
  }

  /// 內部方法：從 SharedPreferences 讀取設置
  ReaderSettings? _loadSettings(String prefix) {
    // 檢查是否存在設置
    final directionStr = _prefs.getString('$prefix$_directionSuffix');
    if (directionStr == null) {
      return null; // 沒有保存的設置
    }

    // 讀取所有設置項
    final direction = ReadingDirection.values.firstWhere(
      (d) => d.name == directionStr,
      orElse: () => ReadingDirection.vertical,
    );

    final fontSize = _prefs.getDouble('$prefix$_fontSizeSuffix') ?? 16.0;
    
    final brightness = _prefs.getDouble('$prefix$_brightnessSuffix') ?? 1.0;
    
    final isNightMode = _prefs.getBool('$prefix$_nightModeSuffix') ?? false;
    
    final autoHideToolbar = _prefs.getBool('$prefix$_autoHideToolbarSuffix') ?? 
        true;

    return ReaderSettings(
      direction: direction,
      fontSize: fontSize,
      brightness: brightness,
      isNightMode: isNightMode,
      autoHideToolbar: autoHideToolbar,
    );
  }

  // ==================== 刪除設置 ====================

  /// 刪除書籍特定設置
  ///
  /// 刪除後將使用全局預設設置。
  Future<void> deleteBookSettings(String bookId) async {
    final prefix = '${_bookPrefix}$bookId\_';
    await Future.wait([
      _prefs.remove('$prefix$_directionSuffix'),
      _prefs.remove('$prefix$_fontSizeSuffix'),
      _prefs.remove('$prefix$_brightnessSuffix'),
      _prefs.remove('$prefix$_nightModeSuffix'),
      _prefs.remove('$prefix$_autoHideToolbarSuffix'),
    ]);
  }

  /// 重置全局預設設置
  ///
  /// 刪除所有全局設置，恢復系統預設值。
  Future<void> resetDefaultSettings() async {
    await Future.wait([
      _prefs.remove('$_defaultPrefix$_directionSuffix'),
      _prefs.remove('$_defaultPrefix$_fontSizeSuffix'),
      _prefs.remove('$_defaultPrefix$_brightnessSuffix'),
      _prefs.remove('$_defaultPrefix$_nightModeSuffix'),
      _prefs.remove('$_defaultPrefix$_autoHideToolbarSuffix'),
    ]);
  }

  // ==================== 檢查方法 ====================

  /// 檢查是否存在書籍特定設置
  bool hasBookSettings(String bookId) {
    return _prefs.containsKey('${_bookPrefix}$bookId\_$_directionSuffix');
  }

  /// 檢查是否存在全局預設設置
  bool hasDefaultSettings() {
    return _prefs.containsKey('$_defaultPrefix$_directionSuffix');
  }
}
