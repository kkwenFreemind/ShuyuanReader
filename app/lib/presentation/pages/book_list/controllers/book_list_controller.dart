import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shuyuan_reader/core/enums/loading_state.dart';
import 'package:shuyuan_reader/core/errors/exceptions.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';
import 'package:shuyuan_reader/domain/usecases/get_books_usecase.dart';
import 'package:shuyuan_reader/domain/usecases/refresh_books_usecase.dart';
import 'package:shuyuan_reader/domain/usecases/get_book_by_id_usecase.dart';

/// 書籍列表頁面控制器
/// 
/// 負責管理書籍列表頁面的所有業務邏輯，包括：
/// - 加載書籍列表
/// - 刷新書籍列表
/// - 處理錯誤狀態
/// - 支持離線模式
/// - 處理書籍點擊事件
class BookListController extends GetxController {
  // ==================== 依賴注入 ====================
  
  final GetBooksUseCase _getBooksUseCase;
  final RefreshBooksUseCase _refreshBooksUseCase;
  // Note: GetBookByIdUseCase will be used in future features (e.g., search, detail page)

  // ==================== 響應式變量 ====================
  
  /// 書籍列表
  /// 存儲當前顯示的所有書籍
  final RxList<Book> books = <Book>[].obs;
  
  /// 加載狀態
  /// 控制 UI 顯示（loading、success、error、empty）
  final Rx<LoadingState> loadingState = LoadingState.loading.obs;
  
  /// 錯誤消息
  /// 當加載失敗時存儲錯誤信息
  final RxString errorMessage = ''.obs;
  
  /// 離線模式標記
  /// true: 當前使用緩存數據（無網絡連接）
  /// false: 使用在線數據
  final RxBool isOffline = false.obs;

  // ==================== 構造函數 ====================
  
  BookListController({
    required GetBooksUseCase getBooksUseCase,
    required RefreshBooksUseCase refreshBooksUseCase,
    GetBookByIdUseCase? getBookByIdUseCase, // Optional for now
  })  : _getBooksUseCase = getBooksUseCase,
        _refreshBooksUseCase = refreshBooksUseCase;

  // ==================== 生命週期方法 ====================
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('📚 [BookListController] 初始化控制器');
    loadBooks();
  }

  // ==================== 公開方法 ====================
  
  /// 加載書籍列表
  /// 
  /// 優先使用緩存數據，如果緩存過期或不存在則從遠程加載。
  /// 支持強制刷新模式。
  /// 
  /// [forceRefresh] 是否強制從遠程刷新（忽略緩存）
  Future<void> loadBooks({bool forceRefresh = false}) async {
    try {
      debugPrint('📚 [BookListController] 開始加載書籍 (forceRefresh: $forceRefresh)');
      
      // 只在非刷新時顯示 loading 狀態
      if (!forceRefresh) {
        loadingState.value = LoadingState.loading;
      }

      // 調用 UseCase 獲取書籍列表
      final result = await _getBooksUseCase.call(forceRefresh: forceRefresh);
      
      debugPrint('✅ [BookListController] 成功加載 ${result.length} 本書籍');
      
      // 更新狀態
      books.value = result;
      loadingState.value = result.isEmpty ? LoadingState.empty : LoadingState.success;
      isOffline.value = false;
      errorMessage.value = '';
      
    } on NetworkException catch (e) {
      debugPrint('⚠️ [BookListController] 網絡錯誤: ${e.message}');
      
      // 嘗試使用緩存數據（離線模式）
      await _handleOfflineMode(e);
      
    } on ServerException catch (e) {
      debugPrint('❌ [BookListController] 服務器錯誤: ${e.message}');
      
      // 嘗試使用緩存數據
      await _handleOfflineMode(e);
      
    } on CacheException catch (e) {
      debugPrint('❌ [BookListController] 緩存錯誤: ${e.message}');
      
      // 緩存錯誤時無法回退，直接顯示錯誤
      loadingState.value = LoadingState.error;
      errorMessage.value = '數據加載失敗：${e.message}';
      isOffline.value = false;
      
    } catch (e) {
      debugPrint('❌ [BookListController] 未知錯誤: $e');
      
      // 未知錯誤，嘗試回退到緩存
      await _handleOfflineMode(CacheException(e.toString()));
    }
  }

  /// 刷新書籍列表
  /// 
  /// 強制從遠程服務器重新獲取最新數據，忽略緩存。
  /// 用於下拉刷新場景。
  Future<void> refreshBooks() async {
    try {
      debugPrint('🔄 [BookListController] 開始刷新書籍列表');
      
      // 調用刷新 UseCase（強制從遠程獲取）
      final result = await _refreshBooksUseCase.call();
      
      debugPrint('✅ [BookListController] 成功刷新 ${result.length} 本書籍');
      
      // 更新狀態
      books.value = result;
      loadingState.value = result.isEmpty ? LoadingState.empty : LoadingState.success;
      isOffline.value = false;
      errorMessage.value = '';
      
      // Show success toast (only if not in test mode)
      if (!Get.testMode) {
        Get.snackbar(
          '刷新成功',
          '已加載最新書籍列表',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      
    } on NetworkException catch (e) {
      debugPrint('⚠️ [BookListController] 刷新失敗（網絡錯誤）: ${e.message}');
      
      // Show error toast (only if not in test mode)
      if (!Get.testMode) {
        Get.snackbar(
          '刷新失敗',
          '網絡連接異常，請檢查網絡設置',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
      
    } on ServerException catch (e) {
      debugPrint('❌ [BookListController] 刷新失敗（服務器錯誤）: ${e.message}');
      
      if (!Get.testMode) {
        Get.snackbar(
          '刷新失敗',
          '服務器暫時無法訪問，請稍後再試',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
      
    } catch (e) {
      debugPrint('❌ [BookListController] 刷新失敗（未知錯誤）: $e');
      
      if (!Get.testMode) {
        Get.snackbar(
          '刷新失敗',
          '發生未知錯誤，請稍後再試',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 處理書籍點擊事件
  /// 
  /// 跳轉到書籍詳情頁面
  /// 
  /// [book] 被點擊的書籍
  void onBookTap(Book book) {
    debugPrint('👆 [BookListController] 用戶點擊書籍: ${book.title}');
    
    // TODO: 在 Spec 03 實現書籍詳情頁面後啟用路由跳轉
    // Get.toNamed(Routes.BOOK_DETAIL, arguments: book);
    
    // Show temporary toast (only if not in test mode)
    if (!Get.testMode) {
      Get.snackbar(
        '書籍詳情',
        '《${book.title}》\n作者：${book.author}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// 重試加載
  /// 
  /// 當加載失敗時，用戶點擊重試按鈕調用此方法。
  /// 強制從遠程重新加載數據。
  void retry() {
    debugPrint('🔄 [BookListController] 用戶點擊重試');
    loadBooks(forceRefresh: true);
  }

  // ==================== 私有方法 ====================
  
  /// 處理離線模式
  /// 
  /// 當網絡或服務器錯誤時，嘗試使用緩存數據繼續顯示內容
  /// 
  /// [exception] 原始異常
  Future<void> _handleOfflineMode(Object exception) async {
    try {
      debugPrint('🔄 [BookListController] 嘗試加載緩存數據（離線模式）');
      
      // 嘗試獲取緩存數據
      final cachedBooks = await _getBooksUseCase.call(forceRefresh: false);
      
      if (cachedBooks.isNotEmpty) {
        // 緩存數據可用，進入離線模式
        debugPrint('✅ [BookListController] 離線模式：使用緩存數據 (${cachedBooks.length} 本書籍)');
        
        books.value = cachedBooks;
        loadingState.value = LoadingState.success;
        isOffline.value = true;
        errorMessage.value = '';
        
        // Show offline mode toast (only if not in test mode)
        if (!Get.testMode) {
          Get.snackbar(
            '離線模式',
            '網絡不可用，正在使用緩存數據',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        // 緩存為空，無法使用離線模式
        debugPrint('❌ [BookListController] 緩存為空，無法進入離線模式');
        
        loadingState.value = LoadingState.error;
        errorMessage.value = _getErrorMessage(exception);
        isOffline.value = false;
      }
    } catch (e) {
      // 獲取緩存數據也失敗
      debugPrint('❌ [BookListController] 無法加載緩存數據: $e');
      
      loadingState.value = LoadingState.error;
      errorMessage.value = _getErrorMessage(exception);
      isOffline.value = false;
    }
  }

  /// 獲取友好的錯誤消息
  /// 
  /// [exception] 異常對象
  /// 返回用戶可讀的錯誤消息
  String _getErrorMessage(Object exception) {
    if (exception is NetworkException) {
      return '網絡連接失敗，請檢查網絡設置';
    } else if (exception is ServerException) {
      return '服務器暫時無法訪問，請稍後再試';
    } else if (exception is CacheException) {
      return '本地數據讀取失敗';
    } else {
      return '發生未知錯誤，請稍後再試';
    }
  }
}
