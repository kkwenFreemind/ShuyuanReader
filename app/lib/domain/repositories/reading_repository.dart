/// 閱讀數據倉儲接口
///
/// 定義閱讀進度和書籤的數據操作接口
/// 遵循 Clean Architecture 的 Repository Pattern
library;

import '../entities/reader/reading_progress.dart';

/// 閱讀數據倉儲
///
/// **職責**：
/// - 定義閱讀進度的數據操作接口
/// - 作為領域層與數據層的橋梁
/// - 具體實現由數據層提供（使用 Hive）
///
/// **使用場景**：
/// - 保存/讀取閱讀進度
/// - 管理書籤數據
/// - 持久化閱讀設置
abstract class ReadingRepository {
  /// 獲取指定書籍的閱讀進度
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  ///
  /// **返回**：
  /// - 如果存在閱讀進度，返回 ReadingProgress 對象
  /// - 如果不存在，返回 null
  Future<ReadingProgress?> getReadingProgress(String bookId);

  /// 保存閱讀進度
  ///
  /// **參數**：
  /// - [progress]: 要保存的閱讀進度對象
  ///
  /// **說明**：
  /// - 如果該書籍已有進度記錄，則更新
  /// - 如果沒有，則創建新記錄
  Future<void> saveReadingProgress(ReadingProgress progress);

  /// 刪除指定書籍的閱讀進度
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  ///
  /// **使用場景**：
  /// - 用戶刪除書籍時清理數據
  /// - 重置閱讀進度
  Future<void> deleteReadingProgress(String bookId);

  /// 獲取所有閱讀進度記錄
  ///
  /// **返回**：
  /// - 所有書籍的閱讀進度列表
  ///
  /// **使用場景**：
  /// - 顯示最近閱讀列表
  /// - 統計閱讀數據
  Future<List<ReadingProgress>> getAllReadingProgress();
}
