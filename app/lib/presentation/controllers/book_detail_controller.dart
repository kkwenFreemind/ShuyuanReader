import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';
import '../../data/services/download_service.dart';
import '../../domain/repositories/book_repository.dart';
import '../../data/models/download_status.dart';

/// 書籍詳情頁控制器
/// 
/// 負責管理書籍詳情頁的業務邏輯，包括：
/// - 書籍狀態管理（下載狀態、進度等）
/// - 下載操作（開始、暫停、取消）
/// - 刪除已下載的書籍
/// - 打開閱讀器
/// 
/// 使用 GetX 進行狀態管理和依賴注入
class BookDetailController extends GetxController {
  // ==================== 依賴注入 ====================
  
  /// 下載服務
  /// 負責實際的文件下載、取消和刪除操作
  final DownloadService _downloadService;
  
  /// 書籍倉庫
  /// 負責書籍數據的持久化和更新
  final BookRepository _bookRepository;
  
  /// 構造函數
  /// 
  /// 通過依賴注入接收服務實例
  /// 
  /// 參數:
  /// - [_downloadService]: 下載服務實例
  /// - [_bookRepository]: 書籍倉庫實例
  BookDetailController(
    this._downloadService,
    this._bookRepository,
  );
  
  // ==================== 響應式狀態 ====================
  
  /// 當前書籍
  /// 
  /// 響應式對象，當書籍狀態改變時自動更新 UI
  /// 初始值從 Get.arguments 獲取（路由傳參）
  late Rx<Book> book;
  
  // ==================== 生命週期方法 ====================
  
  @override
  void onInit() {
    super.onInit();
    
    // 從路由參數中獲取書籍對象
    // Get.arguments 應該是從書籍列表頁傳遞過來的 Book 對象
    book = Rx<Book>(Get.arguments as Book);
  }
  
  // ==================== 公共方法 ====================
  
  /// 開始下載書籍
  /// 
  /// 執行以下操作：
  /// 1. 更新書籍狀態為 "下載中"
  /// 2. 調用 DownloadService 開始下載
  /// 3. 監聽下載進度並更新 UI
  /// 4. 下載完成後更新書籍狀態為 "已下載"
  /// 5. 保存更新後的書籍信息到數據庫
  /// 
  /// 錯誤處理：
  /// - 下載失敗時更新狀態為 "下載失敗"
  /// - 顯示錯誤提示給用戶
  Future<void> startDownload() async {
    try {
      // 步驟 1: 更新狀態為下載中
      book.value = book.value.copyWith(
        downloadStatus: DownloadStatus.downloading,
        downloadProgress: 0.0,
      );
      await _bookRepository.updateBook(book.value);

      // 步驟 2: 開始下載
      final localPath = await _downloadService.downloadBook(
        bookId: book.value.id,
        url: book.value.epubUrl,
        onProgress: (progress) {
          // 步驟 3: 實時更新下載進度
          book.value = book.value.copyWith(
            downloadProgress: progress,
          );
        },
      );

      // 步驟 4: 下載完成，更新狀態
      book.value = book.value.copyWith(
        downloadStatus: DownloadStatus.downloaded,
        downloadProgress: 1.0,
        localPath: localPath,
        downloadedAt: DateTime.now(),
      );
      await _bookRepository.updateBook(book.value);

      // 步驟 5: 顯示成功提示
      Get.snackbar(
        '✅ 下載完成',
        '《${book.value.title}》已成功下載，點擊「打開閱讀」即可開始閱讀',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } on DownloadCancelledException {
      // 用戶取消下載，重置狀態
      book.value = book.value.copyWith(
        downloadStatus: DownloadStatus.notDownloaded,
        downloadProgress: 0.0,
      );
      await _bookRepository.updateBook(book.value);
      
      // 顯示取消提示
      Get.snackbar(
        'ℹ️ 下載已取消',
        '《${book.value.title}》的下載已取消，您可以稍後再次下載',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } on DownloadFailedException catch (e) {
      // 下載失敗，更新狀態並顯示錯誤
      book.value = book.value.copyWith(
        downloadStatus: DownloadStatus.failed,
      );
      await _bookRepository.updateBook(book.value);

      Get.snackbar(
        '❌ 下載失敗',
        '無法下載《${book.value.title}》\n原因：${e.message}\n\n💡 建議：請檢查網絡連接後重試',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      // 處理其他未預期的錯誤
      book.value = book.value.copyWith(
        downloadStatus: DownloadStatus.failed,
      );
      await _bookRepository.updateBook(book.value);

      Get.snackbar(
        '❌ 下載異常',
        '下載《${book.value.title}》時發生異常\n\n💡 建議：\n• 請確保網絡連接正常\n• 檢查設備存儲空間是否充足\n• 稍後再試或聯繫技術支持',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
  
  /// 暫停下載
  /// 
  /// 執行以下操作：
  /// 1. 調用 DownloadService 取消當前下載
  /// 2. 更新書籍狀態為 "已暫停"
  /// 3. 保存當前下載進度到數據庫
  /// 
  /// 注意：
  /// - 暫停後可以通過 startDownload 繼續下載
  /// - 暫停狀態會保存下載進度
  void pauseDownload() {
    // 步驟 1: 取消當前下載
    _downloadService.cancelDownload(book.value.id);
    
    // 步驟 2: 更新狀態為暫停
    book.value = book.value.copyWith(
      downloadStatus: DownloadStatus.paused,
    );
    
    // 步驟 3: 保存到數據庫
    _bookRepository.updateBook(book.value);
  }
  
  /// 取消下載
  /// 
  /// 執行以下操作：
  /// 1. 調用 DownloadService 取消當前下載
  /// 2. 刪除部分下載的文件
  /// 3. 重置書籍狀態為 "未下載"
  /// 4. 重置下載進度為 0
  /// 5. 保存更新到數據庫
  /// 
  /// 注意：
  /// - 取消後需要重新開始下載
  /// - 已下載的部分會被刪除
  Future<void> cancelDownload() async {
    // 步驟 1: 取消當前下載
    _downloadService.cancelDownload(book.value.id);
    
    // 步驟 2: 刪除部分下載的文件（如果存在）
    if (book.value.localPath != null) {
      try {
        await _downloadService.deleteBook(book.value.localPath!);
      } catch (_) {
        // 忽略刪除錯誤，文件可能不存在
      }
    }
    
    // 步驟 3-4: 重置書籍狀態為未下載，清空進度和路徑
    book.value = book.value.copyWith(
      downloadStatus: DownloadStatus.notDownloaded,
      downloadProgress: 0.0,
      localPath: null,
    );
    
    // 步驟 5: 保存到數據庫
    await _bookRepository.updateBook(book.value);
  }
  
  /// 刪除已下載的書籍
  /// 
  /// 執行以下操作：
  /// 1. 顯示確認對話框
  /// 2. 用戶確認後調用 DownloadService 刪除文件
  /// 3. 更新書籍狀態為 "未下載"
  /// 4. 清空本地路徑和下載時間
  /// 5. 保存更新到數據庫
  /// 6. 顯示刪除成功提示
  /// 
  /// 錯誤處理：
  /// - 刪除失敗時顯示錯誤提示
  /// - 不更新書籍狀態
  Future<void> deleteBook() async {
    // 步驟 1: 顯示確認對話框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('確認刪除'),
          ],
        ),
        content: Text(
          '確定要刪除《${book.value.title}》嗎？\n\n刪除後需要重新下載才能閱讀。',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('確認刪除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 步驟 2: 刪除本地文件（如果存在）
      if (book.value.localPath != null) {
        await _downloadService.deleteBook(book.value.localPath!);
      }

      // 步驟 3-4: 重置狀態
      book.value = book.value.copyWith(
        downloadStatus: DownloadStatus.notDownloaded,
        downloadProgress: 0.0,
        localPath: null,
        downloadedAt: null,
      );
      // 步驟 5: 保存到數據庫
      await _bookRepository.updateBook(book.value);

      // 步驟 6: 顯示成功提示
      Get.snackbar(
        '✅ 刪除成功',
        '《${book.value.title}》已從本地刪除，需要時可以重新下載',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } on DeletionFailedException catch (e) {
      // 錯誤處理：刪除失敗
      Get.snackbar(
        '❌ 刪除失敗',
        '無法刪除《${book.value.title}》\n原因：${e.message}\n\n💡 建議：請檢查文件權限或稍後重試',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
  
  /// 打開閱讀器
  /// 
  /// 執行以下操作：
  /// 1. 檢查書籍是否已下載
  /// 2. 檢查本地文件是否存在
  /// 3. 跳轉到閱讀器頁面
  /// 4. 傳遞書籍對象作為參數
  /// 
  /// 注意：
  /// - 只有已下載的書籍才能打開
  /// - 文件不存在時顯示錯誤提示
  void openReader() {
    // 步驟 1-2: 檢查本地文件路徑是否存在
    if (book.value.localPath == null) {
      Get.snackbar(
        '⚠️ 無法打開',
        '《${book.value.title}》尚未下載\n\n💡 建議：請先下載書籍後再打開閱讀',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return;
    }

    // 步驟 3-4: 跳轉到閱讀器頁面（Spec 04）
    Get.toNamed('/reader', arguments: book.value);
  }
  
  // ==================== 私有輔助方法 ====================
  
  // 可以在後續任務中添加私有方法
  // 例如：_updateBookStatus, _showErrorDialog 等
}
