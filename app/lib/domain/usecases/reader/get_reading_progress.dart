/// 獲取閱讀進度用例
///
/// 從本地數據庫讀取指定書籍的閱讀進度
library;

import '../../entities/reader/reading_progress.dart';
import '../../repositories/reading_repository.dart';

/// 獲取閱讀進度用例
///
/// **職責**：
/// - 從 Repository 獲取指定書籍的閱讀進度
/// - 封裝業務邏輯
/// - 作為 Controller 與 Repository 的中間層
///
/// **使用場景**：
/// - 打開書籍時加載上次閱讀位置
/// - 恢復書籤列表
/// - 顯示閱讀進度
class GetReadingProgress {
  /// 閱讀數據倉儲
  final ReadingRepository repository;

  /// 構造函數
  ///
  /// 通過依賴注入接收 Repository 實例
  GetReadingProgress(this.repository);

  /// 執行獲取閱讀進度操作
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  ///
  /// **返回**：
  /// - 如果存在閱讀進度，返回 ReadingProgress 對象
  /// - 如果不存在，返回 null（首次閱讀）
  ///
  /// **拋出異常**：
  /// - 數據庫訪問失敗
  Future<ReadingProgress?> call(String bookId) async {
    return await repository.getReadingProgress(bookId);
  }
}

