/// 保存閱讀進度用例
///
/// 將當前閱讀進度保存到本地數據庫
library;

import '../../entities/reader/reading_progress.dart';
import '../../repositories/reading_repository.dart';

/// 保存閱讀進度用例
///
/// **職責**：
/// - 保存閱讀進度到 Repository
/// - 封裝保存邏輯
/// - 作為 Controller 與 Repository 的中間層
///
/// **使用場景**：
/// - 翻頁時自動保存進度
/// - 退出閱讀器時保存最後位置
/// - 切換書籤狀態時保存
class SaveReadingProgress {
  /// 閱讀數據倉儲
  final ReadingRepository repository;

  /// 構造函數
  ///
  /// 通過依賴注入接收 Repository 實例
  SaveReadingProgress(this.repository);

  /// 執行保存閱讀進度操作
  ///
  /// **參數**：
  /// - [progress]: 要保存的閱讀進度對象
  ///
  /// **說明**：
  /// - 如果該書籍已有進度記錄，則更新
  /// - 如果沒有，則創建新記錄
  ///
  /// **拋出異常**：
  /// - 數據庫寫入失敗
  Future<void> call(ReadingProgress progress) async {
    await repository.saveReadingProgress(progress);
  }
}

