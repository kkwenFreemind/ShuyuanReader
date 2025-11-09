/// 更新閱讀器設置用例
/// 
/// 保存用戶的閱讀偏好設置到本地存儲
library;

import '../../entities/reader/reader_settings.dart';
import '../../../data/datasources/reader/reading_local_data_source.dart';

/// 更新閱讀器設置用例
///
/// **職責**：
/// - 保存全局預設設置
/// - 保存書籍特定設置
/// - 提供統一的設置保存接口
///
/// **使用場景**：
/// - 用戶調整字體大小
/// - 用戶切換閱讀方向
/// - 用戶調整亮度
/// - 用戶切換夜間模式
/// - 用戶切換工具欄自動隱藏
///
/// **使用示例**：
/// ```dart
/// final useCase = UpdateReaderSettings(dataSource);
///
/// // 保存全局預設設置
/// await useCase.saveDefault(settings);
///
/// // 保存書籍特定設置
/// await useCase.saveForBook(bookId, settings);
/// ```
class UpdateReaderSettings {
  final ReadingLocalDataSource _dataSource;

  /// 構造函數
  ///
  /// **參數**：
  /// - [_dataSource]: 本地數據源
  UpdateReaderSettings(this._dataSource);

  /// 保存全局預設設置
  ///
  /// 這些設置將應用於所有沒有特定設置的書籍。
  ///
  /// **參數**：
  /// - [settings]: 閱讀器設置
  ///
  /// **異常**：
  /// - 如果保存失敗，可能拋出異常
  Future<void> saveDefault(ReaderSettings settings) async {
    await _dataSource.saveDefaultSettings(settings);
  }

  /// 保存書籍特定設置
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  /// - [settings]: 閱讀器設置
  ///
  /// **異常**：
  /// - 如果保存失敗，可能拋出異常
  Future<void> saveForBook(String bookId, ReaderSettings settings) async {
    await _dataSource.saveBookSettings(bookId, settings);
  }

  /// 簡化調用接口
  ///
  /// 保存全局預設設置的便捷方法。
  /// 這是 ReaderController 中主要使用的接口。
  ///
  /// **參數**：
  /// - [settings]: 閱讀器設置
  Future<void> call(ReaderSettings settings) async {
    await saveDefault(settings);
  }
}
