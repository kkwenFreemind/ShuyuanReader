/// 閱讀數據倉儲實現
///
/// 使用 Hive 實現閱讀進度和書籤的持久化存儲
/// 連接領域層和數據層
library;

import 'package:hive/hive.dart';
import '../../../domain/entities/reader/reading_progress.dart';
import '../../../domain/repositories/reading_repository.dart';
import '../../models/reader/reading_progress_model.dart';

/// 閱讀數據倉儲實現
///
/// **職責**：
/// - 實現 ReadingRepository 接口
/// - 使用 Hive 進行數據持久化
/// - 處理 Entity 與 Model 之間的轉換
///
/// **Box 管理**：
/// - Box 名稱：'reading_progress'
/// - 數據類型：ReadingProgressModel
/// - Key：bookId (String)
class ReadingRepositoryImpl implements ReadingRepository {
  /// Hive Box 名稱
  static const String boxName = 'reading_progress';

  /// 獲取 Hive Box
  ///
  /// **說明**：
  /// - Box 應該在應用初始化時打開（AppInitializer）
  /// - 如果 Box 未打開，會拋出異常
  Box<ReadingProgressModel> get _box {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Reading progress box is not open. '
          'Make sure to open it in AppInitializer.');
    }
    return Hive.box<ReadingProgressModel>(boxName);
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    try {
      final model = _box.get(bookId);
      if (model == null) {
        return null;
      }
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get reading progress for book $bookId: $e');
    }
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    try {
      final model = ReadingProgressModel.fromEntity(progress);
      await _box.put(progress.bookId, model);
    } catch (e) {
      throw Exception(
          'Failed to save reading progress for book ${progress.bookId}: $e');
    }
  }

  @override
  Future<void> deleteReadingProgress(String bookId) async {
    try {
      await _box.delete(bookId);
    } catch (e) {
      throw Exception('Failed to delete reading progress for book $bookId: $e');
    }
  }

  @override
  Future<List<ReadingProgress>> getAllReadingProgress() async {
    try {
      final models = _box.values.toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all reading progress: $e');
    }
  }
}

