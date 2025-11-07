import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// 下載服務
/// 
/// 負責處理書籍的下載、取消和刪除操作
/// 使用 Dio 進行網絡請求，支持下載進度回調
class DownloadService {
  /// Dio 實例，用於執行網絡請求
  final Dio _dio;
  
  /// 取消令牌映射表
  /// key: bookId, value: CancelToken
  /// 用於管理和取消正在進行的下載
  final Map<String, CancelToken> _cancelTokens = {};

  /// 構造函數
  /// 
  /// 通過依賴注入方式接收 Dio 實例
  /// 便於測試和靈活配置
  DownloadService(this._dio);

  /// 下載書籍
  /// 
  /// 從指定 URL 下載書籍文件到本地存儲
  /// 
  /// 參數:
  /// - [bookId]: 書籍唯一標識符
  /// - [url]: 書籍下載地址
  /// - [onProgress]: 下載進度回調函數，參數為進度值 (0.0 - 1.0)
  /// 
  /// 返回:
  /// - 下載完成後的本地文件路徑
  /// 
  /// 異常:
  /// - [DownloadCancelledException]: 下載被用戶取消
  /// - [DownloadFailedException]: 下載過程中發生錯誤
  Future<String> downloadBook({
    required String bookId,
    required String url,
    required Function(double progress) onProgress,
  }) async {
    try {
      // 步驟 1: 獲取應用文檔目錄
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${appDir.path}/books');
      
      // 步驟 2: 確保 books 子目錄存在
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      // 步驟 3: 生成本地文件路徑
      final fileName = '$bookId.epub';
      final savePath = '${booksDir.path}/$fileName';

      // 步驟 4: 創建取消令牌並保存到映射表
      final cancelToken = CancelToken();
      _cancelTokens[bookId] = cancelToken;

      // 步驟 5: 使用 Dio 開始下載
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          // 只有當 total 有效時才計算進度
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // 步驟 6: 下載完成，移除取消令牌
      _cancelTokens.remove(bookId);

      return savePath;
    } on DioException catch (e) {
      // 清理取消令牌
      _cancelTokens.remove(bookId);
      
      // 根據錯誤類型拋出相應的異常
      if (e.type == DioExceptionType.cancel) {
        throw DownloadCancelledException('下載已取消');
      } else {
        throw DownloadFailedException('下載失敗: ${e.message}');
      }
    } catch (e) {
      // 處理其他異常（如文件系統錯誤）
      _cancelTokens.remove(bookId);
      throw DownloadFailedException('下載失敗: $e');
    }
  }

  /// 取消下載
  /// 
  /// 取消指定書籍的下載任務
  /// 如果該書籍沒有正在進行的下載任務，則此操作無效
  /// 
  /// 參數:
  /// - [bookId]: 要取消下載的書籍 ID
  void cancelDownload(String bookId) {
    final cancelToken = _cancelTokens[bookId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('用戶取消下載');
      _cancelTokens.remove(bookId);
    }
  }

  /// 刪除本地書籍文件
  /// 
  /// 從設備存儲中刪除已下載的書籍文件
  /// 如果文件不存在，則操作無效
  /// 
  /// 參數:
  /// - [localPath]: 要刪除的文件的完整路徑
  /// 
  /// 異常:
  /// - [DeletionFailedException]: 刪除過程中發生錯誤
  Future<void> deleteBook(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw DeletionFailedException('刪除失敗: $e');
    }
  }
}

/// 下載被取消異常
/// 
/// 當用戶主動取消下載操作時拋出
class DownloadCancelledException implements Exception {
  final String message;
  
  DownloadCancelledException(this.message);
  
  @override
  String toString() => 'DownloadCancelledException: $message';
}

/// 下載失敗異常
/// 
/// 當下載過程中發生錯誤時拋出
/// 包括網絡錯誤、文件系統錯誤等
class DownloadFailedException implements Exception {
  final String message;
  
  DownloadFailedException(this.message);
  
  @override
  String toString() => 'DownloadFailedException: $message';
}

/// 刪除失敗異常
/// 
/// 當刪除本地文件失敗時拋出
class DeletionFailedException implements Exception {
  final String message;
  
  DeletionFailedException(this.message);
  
  @override
  String toString() => 'DeletionFailedException: $message';
}
