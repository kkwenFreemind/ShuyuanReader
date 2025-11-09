/// 切換書籤用例
///
/// 添加或移除指定頁面的書籤
library;

import '../../entities/reader/reading_progress.dart';
import '../../repositories/reading_repository.dart';

/// 切換書籤用例
///
/// **職責**：
/// - 切換指定頁面的書籤狀態
/// - 如果該頁已有書籤則移除，否則添加
/// - 保存更新後的閱讀進度
///
/// **使用場景**：
/// - 用戶點擊書籤按鈕
/// - 快速標記重要頁面
class ToggleBookmark {
  /// 閱讀數據倉儲
  final ReadingRepository repository;

  /// 構造函數
  ///
  /// 通過依賴注入接收 Repository 實例
  ToggleBookmark(this.repository);

  /// 執行切換書籤操作
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  /// - [page]: 要切換書籤的頁碼
  ///
  /// **流程**：
  /// 1. 獲取當前閱讀進度
  /// 2. 如果不存在，創建新的閱讀進度
  /// 3. 切換指定頁的書籤狀態
  /// 4. 保存更新後的閱讀進度
  ///
  /// **拋出異常**：
  /// - 數據庫訪問失敗
  Future<void> call({
    required String bookId,
    required int page,
  }) async {
    // 1. 獲取當前閱讀進度
    ReadingProgress? progress = await repository.getReadingProgress(bookId);

    // 2. 如果不存在，創建新的閱讀進度
    if (progress == null) {
      progress = ReadingProgress(
        bookId: bookId,
        currentPage: page,
        bookmarkedPages: const [],
        lastReadTime: DateTime.now(),
      );
    }

    // 3. 切換書籤狀態
    final updatedProgress = progress.toggleBookmark(page);

    // 4. 保存更新後的閱讀進度
    await repository.saveReadingProgress(updatedProgress);
  }
}

