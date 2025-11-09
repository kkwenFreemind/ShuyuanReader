import 'package:flutter/services.dart';

/// EPUB 閱讀器 Platform Channel
/// 
/// 提供 Flutter 和 Android Readium 之間的通訊接口
/// 這是 Task 4.1.4 的實現
/// 
/// @since 2025-11-09
class EpubReaderChannel {
  /// Platform Channel 名稱
  static const MethodChannel _channel =
      MethodChannel('com.shuyuan.reader/epub');

  /// 打開書籍
  /// 
  /// [filePath] EPUB 文件路徑
  /// [isVertical] 是否為直書模式（true = 直書 RTL，false = 橫書 LTR）
  /// 
  /// Throws [PlatformException] 如果打開失敗
  static Future<void> openBook(String filePath, bool isVertical) async {
    try {
      await _channel.invokeMethod('openBook', {
        'filePath': filePath,
        'isVertical': isVertical,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to open book: ${e.message}');
    }
  }

  /// 關閉當前書籍
  static Future<void> closeBook() async {
    try {
      await _channel.invokeMethod('closeBook');
    } on PlatformException catch (e) {
      throw Exception('Failed to close book: ${e.message}');
    }
  }

  /// 下一頁
  static Future<void> nextPage() async {
    try {
      await _channel.invokeMethod('nextPage');
    } on PlatformException catch (e) {
      throw Exception('Failed to go to next page: ${e.message}');
    }
  }

  /// 上一頁
  static Future<void> previousPage() async {
    try {
      await _channel.invokeMethod('previousPage');
    } on PlatformException catch (e) {
      throw Exception('Failed to go to previous page: ${e.message}');
    }
  }

  /// 獲取當前位置
  /// 
  /// 返回包含以下字段的 Map：
  /// - href: 當前章節路徑
  /// - progression: 章節內進度 (0.0-1.0)
  /// - totalProgression: 整本書進度 (0.0-1.0)
  /// - position: 當前頁碼
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      final result = await _channel.invokeMethod('getCurrentLocation');
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      throw Exception('Failed to get current location: ${e.message}');
    }
  }

  /// 設置字體大小
  /// 
  /// [size] 字體大小倍數 (1.0 = 默認，0.5 = 50%，2.0 = 200%)
  static Future<void> setFontSize(double size) async {
    try {
      await _channel.invokeMethod('setFontSize', {'size': size});
    } on PlatformException catch (e) {
      throw Exception('Failed to set font size: ${e.message}');
    }
  }

  /// 設置閱讀方向
  /// 
  /// [direction] 閱讀方向
  /// - "rtl": 直書（右到左）
  /// - "ltr": 橫書（左到右）
  static Future<void> setReadingDirection(String direction) async {
    try {
      await _channel.invokeMethod('setReadingDirection', {
        'direction': direction,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to set reading direction: ${e.message}');
    }
  }

  /// 切換書籤
  /// 
  /// 返回包含以下字段的 Map：
  /// - isBookmarked: 是否已添加書籤
  /// - locator: 書籤位置信息（如果已添加）
  static Future<Map<String, dynamic>> toggleBookmark() async {
    try {
      final result = await _channel.invokeMethod('toggleBookmark');
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      throw Exception('Failed to toggle bookmark: ${e.message}');
    }
  }

  /// 設置行高
  /// 
  /// [lineHeight] 行高倍數 (1.0 = 默認，1.5 = 1.5倍行距)
  static Future<void> setLineHeight(double lineHeight) async {
    try {
      await _channel.invokeMethod('setLineHeight', {'lineHeight': lineHeight});
    } on PlatformException catch (e) {
      throw Exception('Failed to set line height: ${e.message}');
    }
  }

  /// 設置主題
  /// 
  /// [theme] 主題名稱
  /// - "light": 淺色主題
  /// - "dark": 深色主題
  /// - "sepia": 護眼主題
  static Future<void> setTheme(String theme) async {
    try {
      await _channel.invokeMethod('setTheme', {'theme': theme});
    } on PlatformException catch (e) {
      throw Exception('Failed to set theme: ${e.message}');
    }
  }

  /// 跳轉到指定位置
  /// 
  /// [locator] 位置信息 Map
  static Future<void> goToLocation(Map<String, dynamic> locator) async {
    try {
      await _channel.invokeMethod('goToLocation', {'locator': locator});
    } on PlatformException catch (e) {
      throw Exception('Failed to go to location: ${e.message}');
    }
  }

  /// 搜索文字
  /// 
  /// [query] 搜索關鍵字
  /// 返回匹配位置的列表
  static Future<List<Map<String, dynamic>>> searchText(String query) async {
    try {
      final result = await _channel.invokeMethod('searchText', {'query': query});
      return (result as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to search text: ${e.message}');
    }
  }
}
