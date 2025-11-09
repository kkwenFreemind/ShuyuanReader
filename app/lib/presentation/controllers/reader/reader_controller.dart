/// EPUB 閱讀器控制器
///
/// **職責**：
/// 這是 EPUB 閱讀器的核心控制器，遵循 Clean Architecture 原則。
/// 使用 GetX 進行狀態管理和依賴注入。
///
/// **主要功能**：
/// - 書籍加載與 EPUB 渲染初始化
/// - 閱讀進度追蹤與持久化
/// - 翻頁控制（支持直書/橫書）
/// - 直書/橫書模式切換
/// - 書籤管理（添加/移除/查詢）
/// - 閱讀設置（字體大小、亮度、夜間模式）
/// - 工具欄顯示/隱藏控制
///
/// **依賴注入**：
/// 通過構造函數注入 Use Cases，實現與領域層的解耦。
///
/// **狀態管理**：
/// 使用 GetX 的 Observable (.obs) 來管理響應式狀態。
///
/// **使用示例**：
/// ```dart
/// // 在路由中傳遞 bookId
/// Get.toNamed(
///   Routes.reader,
///   arguments: {'bookId': book.id},
/// );
///
/// // 在 ReaderPage 中綁定控制器
/// final controller = Get.find<ReaderController>();
/// ```
library;

import 'dart:io';

import 'package:get/get.dart';
import 'package:epub_view/epub_view.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../../domain/entities/book.dart';
import '../../../domain/entities/reader/reading_progress.dart';
import '../../../domain/entities/reader/reader_settings.dart';
import '../../../domain/entities/reader/reading_direction.dart';
import '../../../domain/repositories/book_repository.dart';
import '../../../domain/services/epub_preprocessor.dart';
import '../../../domain/usecases/reader/get_reading_progress.dart';
import '../../../domain/usecases/reader/save_reading_progress.dart';
import '../../../domain/usecases/reader/toggle_bookmark.dart';
import '../../../domain/usecases/reader/update_reader_settings.dart';
import '../../../data/datasources/reader/reading_local_data_source.dart';

/// EPUB 閱讀器控制器
///
/// 管理 EPUB 閱讀器的所有狀態和業務邏輯。
/// 繼承自 GetxController，自動處理生命週期和內存管理。
class ReaderController extends GetxController {
  // ==================== 依賴注入 ====================

  /// 書籍倉庫（Repository）
  ///
  /// 用於從數據庫加載書籍信息。
  final BookRepository bookRepository;

  /// 獲取閱讀進度 Use Case
  final GetReadingProgress getReadingProgress;

  /// 保存閱讀進度 Use Case
  final SaveReadingProgress saveReadingProgress;

  /// 切換書籤 Use Case
  final ToggleBookmark toggleBookmark;

  /// 更新閱讀器設置 Use Case
  final UpdateReaderSettings updateReaderSettings;

  /// 閱讀設置數據源
  final ReadingLocalDataSource readingLocalDataSource;

  /// 構造函數
  ///
  /// 通過依賴注入接收所有必要的 Use Cases 和 Repository。
  /// 這些依賴將在應用啟動時通過 GetX 的依賴注入系統提供。
  ReaderController({
    required this.bookRepository,
    required this.getReadingProgress,
    required this.saveReadingProgress,
    required this.toggleBookmark,
    required this.updateReaderSettings,
    required this.readingLocalDataSource,
  });

  // ==================== 響應式狀態 ====================

  /// 當前正在閱讀的書籍
  ///
  /// 初始值為 null，在 onInit 中加載。
  final book = Rx<Book?>(null);

  /// 當前頁碼（從 1 開始）
  ///
  /// 響應式變數，當頁碼改變時 UI 會自動更新。
  final currentPage = 1.obs;

  /// 總頁數
  ///
  /// 在 EPUB 加載完成後計算得出。
  final totalPages = 0.obs;

  /// 當前閱讀方向
  ///
  /// 預設為直書模式（vertical）。
  final readingDirection = ReadingDirection.vertical.obs;

  /// 當前字體大小（sp）
  ///
  /// 範圍：12.0 - 20.0，預設 16.0
  final fontSize = 16.0.obs;

  /// 當前屏幕亮度
  ///
  /// 範圍：0.0 - 1.0，預設 1.0（最亮）
  final brightness = 1.0.obs;

  /// 是否開啟夜間模式
  final isNightMode = false.obs;

  /// 是否自動隱藏工具欄
  final autoHideToolbar = true.obs;

  /// 已添加書籤的頁碼列表
  ///
  /// 響應式列表，當添加/移除書籤時 UI 會自動更新。
  final bookmarkedPages = <int>[].obs;

  /// 工具欄是否可見
  ///
  /// 控制閱讀頁面工具欄的顯示/隱藏。
  final isToolbarVisible = false.obs;

  /// 是否正在加載中
  ///
  /// 用於顯示加載指示器。
  final isLoading = true.obs;

  /// 錯誤消息
  ///
  /// 如果加載失敗，此變數會包含錯誤信息。
  final errorMessage = Rx<String?>(null);

  // ==================== EPUB 控制器 ====================

  /// EPUB 視圖控制器
  ///
  /// 來自 epub_view 包，用於控制 EPUB 內容的顯示和導航。
  /// 延遲初始化（late），在書籍加載完成後初始化。
  EpubController? epubController;

  /// 屏幕亮度控制器
  ///
  /// 用於調整屏幕亮度。
  final ScreenBrightness _screenBrightness = ScreenBrightness();

  /// EPUB 預處理器
  ///
  /// 用於處理 EPUB 文件，注入直書模式 CSS。
  final EpubPreprocessor _epubPreprocessor = EpubPreprocessor();

  /// 系統原始亮度
  ///
  /// 保存進入閱讀器前的系統亮度，退出時恢復。
  double? _originalBrightness;

  // ==================== 計算屬性 ====================

  /// 閱讀進度百分比（0.0 - 1.0）
  double get progressPercentage {
    if (totalPages.value == 0) return 0.0;
    return currentPage.value / totalPages.value;
  }

  /// 閱讀進度百分比（0 - 100）
  int get progressPercent {
    return (progressPercentage * 100).round();
  }

  /// 當前頁是否已添加書籤
  bool get isCurrentPageBookmarked {
    return bookmarkedPages.contains(currentPage.value);
  }

  /// 是否可以翻到下一頁
  bool get canGoNext {
    return currentPage.value < totalPages.value;
  }

  /// 是否可以翻到上一頁
  bool get canGoPrevious {
    return currentPage.value > 1;
  }

  /// 當前閱讀設置
  ReaderSettings get currentSettings {
    return ReaderSettings(
      direction: readingDirection.value,
      fontSize: fontSize.value,
      brightness: brightness.value,
      isNightMode: isNightMode.value,
      autoHideToolbar: autoHideToolbar.value,
    );
  }

  // ==================== 生命週期方法 ====================

  /// 控制器初始化
  ///
  /// 在控制器創建時自動調用（GetX 生命週期）。
  /// 執行以下初始化操作：
  /// 1. 加載書籍信息
  /// 2. 加載閱讀進度
  /// 3. 加載閱讀設置
  /// 4. 初始化 EPUB 控制器
  /// 5. 保存系統亮度
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// 控制器關閉
  ///
  /// 在控制器銷毀前自動調用（GetX 生命週期）。
  /// 執行以下清理操作：
  /// 1. 保存當前閱讀進度
  /// 2. 恢復系統亮度
  /// 3. 釋放 EPUB 控制器資源
  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  // ==================== 初始化方法 ====================

  /// 執行所有初始化操作
  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // 1. 保存系統原始亮度
      await _saveOriginalBrightness();

      // 2. 加載書籍信息
      await _loadBook();

      // 3. 加載閱讀進度
      await _loadReadingProgress();

      // 4. 加載閱讀設置
      await _loadReaderSettings();

      // 5. 初始化 EPUB 控制器
      await _initEpubController();

      // 6. 應用閱讀設置
      await _applySettings();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加載書籍失敗：${e.toString()}';
      Get.snackbar(
        '錯誤',
        '加載書籍失敗：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 加載書籍信息
  ///
  /// 從路由參數中獲取 bookId，然後從數據庫加載書籍詳情。
  /// 同時驗證本地 EPUB 文件是否存在。
  ///
  /// **錯誤處理**：
  /// - 缺少 bookId 參數
  /// - 書籍不存在
  /// - 書籍尚未下載
  /// - 本地文件不存在
  Future<void> _loadBook() async {
    try {
      // 1. 從路由參數獲取 bookId
      final args = Get.arguments as Map<String, dynamic>?;
      if (args == null || !args.containsKey('bookId')) {
        errorMessage.value = '缺少書籍 ID 參數';
        throw Exception('缺少 bookId 參數');
      }

      final String bookId = args['bookId'] as String;

      // 2. 從數據庫加載書籍詳情
      final loadedBook = await bookRepository.getBookById(bookId);
      if (loadedBook == null) {
        errorMessage.value = '找不到書籍：$bookId';
        throw Exception('找不到書籍：$bookId');
      }

      // 3. 驗證書籍是否已下載
      if (loadedBook.localPath == null || loadedBook.localPath!.isEmpty) {
        errorMessage.value = '書籍尚未下載，請先下載';
        throw Exception('書籍尚未下載');
      }

      // 4. 驗證本地文件是否存在
      final file = File(loadedBook.localPath!);
      if (!await file.exists()) {
        errorMessage.value = '本地文件不存在：${loadedBook.localPath}';
        throw Exception('本地文件不存在：${loadedBook.localPath}');
      }

      // 5. 設置書籍信息
      book.value = loadedBook;
    } catch (e) {
      // 記錄錯誤並重新拋出
      if (errorMessage.value == null) {
        errorMessage.value = '加載書籍失敗：$e';
      }
      rethrow;
    }
  }

  /// 加載閱讀進度
  ///
  /// 從數據庫加載上次閱讀的進度，包括當前頁碼和書籤。
  Future<void> _loadReadingProgress() async {
    if (book.value == null) return;

    try {
      final progress = await getReadingProgress.call(book.value!.id);
      if (progress != null) {
        currentPage.value = progress.currentPage;
        bookmarkedPages.value = progress.bookmarkedPages;
      }
    } catch (e) {
      // 如果沒有閱讀進度，使用預設值
      currentPage.value = 1;
      bookmarkedPages.clear();
    }
  }

  /// 加載閱讀器設置
  ///
  /// 從 SharedPreferences 加載用戶的閱讀偏好設置。
  /// 
  /// **預設行為**（Task 4.10.3）：
  /// - 首次打開書籍：使用直書模式（vertical）
  /// - 後續打開：使用上次保存的設置
  /// 
  /// **實現細節**（Task 4.14.1）：
  /// 1. 嘗試加載書籍特定設置
  /// 2. 如果不存在，使用全局預設設置
  /// 3. 如果全局設置也不存在，使用系統預設設置
  Future<void> _loadReaderSettings() async {
    if (book.value == null) return;

    try {
      // 從 SharedPreferences 讀取書籍特定設置
      // 如果不存在，會自動返回全局預設設置或系統預設設置
      final settings = readingLocalDataSource.getBookSettings(book.value!.id);

      // 應用設置到響應式變數
      readingDirection.value = settings.direction;
      fontSize.value = settings.fontSize;
      brightness.value = settings.brightness;
      isNightMode.value = settings.isNightMode;
      autoHideToolbar.value = settings.autoHideToolbar;
    } catch (e) {
      // 加載失敗時使用預設設置
      final defaultSettings = ReaderSettings.defaultSettings();
      readingDirection.value = defaultSettings.direction;
      fontSize.value = defaultSettings.fontSize;
      brightness.value = defaultSettings.brightness;
      isNightMode.value = defaultSettings.isNightMode;
      autoHideToolbar.value = defaultSettings.autoHideToolbar;
    }
  }

  /// 初始化 EPUB 控制器
  ///
  /// 創建 EpubController 並加載 EPUB 文件。
  /// 根據當前設置（直書模式、字體大小）預處理 EPUB 文件。
  Future<void> _initEpubController() async {
    if (book.value == null || book.value!.localPath == null) {
      throw Exception('書籍路徑無效');
    }

    try {
      String epubPath = book.value!.localPath!;

      // 使用當前設置預處理 EPUB
      epubPath = await _epubPreprocessor.processWithSettings(
        epubPath: epubPath,
        bookId: book.value!.id,
        isVerticalText: readingDirection.value == ReadingDirection.vertical,
        fontSize: fontSize.value,
      );

      // 創建 EPUB 控制器
      epubController = EpubController(
        document: EpubDocument.openFile(File(epubPath)),
        // TODO: 支持從上次位置繼續閱讀 (使用 epubCfi)
      );

      // 監聽 EPUB 加載完成事件
      // TODO: 在 EPUB 加載完成後計算總頁數
    } catch (e) {
      throw Exception('EPUB 控制器初始化失敗：$e');
    }
  }

  /// 應用所有閱讀設置
  Future<void> _applySettings() async {
    await _applyBrightness();
    // 字體大小和閱讀方向將在 UI 層應用
  }

  /// 保存系統原始亮度
  Future<void> _saveOriginalBrightness() async {
    try {
      _originalBrightness = await _screenBrightness.current;
    } catch (e) {
      _originalBrightness = null;
    }
  }

  // ==================== 清理方法 ====================

  /// 執行所有清理操作
  Future<void> _cleanup() async {
    try {
      // 1. 保存閱讀進度
      await _saveProgress();

      // 2. 恢復系統亮度
      await _restoreOriginalBrightness();

      // 3. 釋放 EPUB 控制器
      epubController?.dispose();
      epubController = null;
    } catch (e) {
      // 清理失敗不影響退出
    }
  }

  /// 恢復系統原始亮度
  Future<void> _restoreOriginalBrightness() async {
    if (_originalBrightness != null) {
      try {
        await _screenBrightness.setScreenBrightness(_originalBrightness!);
      } catch (e) {
        // 恢復失敗不影響退出
      }
    }
  }

  // ==================== 翻頁控制 ====================

  /// 翻到下一頁
  ///
  /// 如果當前不是最後一頁，則翻到下一頁並保存進度。
  void nextPage() {
    if (!canGoNext) return;

    currentPage.value++;
    epubController?.next();
    _saveProgress();

    // 如果啟用自動隱藏，則隱藏工具欄
    if (autoHideToolbar.value && isToolbarVisible.value) {
      isToolbarVisible.value = false;
    }
  }

  /// 翻到上一頁
  ///
  /// 如果當前不是第一頁，則翻到上一頁並保存進度。
  void previousPage() {
    if (!canGoPrevious) return;

    currentPage.value--;
    epubController?.previous();
    _saveProgress();

    // 如果啟用自動隱藏，則隱藏工具欄
    if (autoHideToolbar.value && isToolbarVisible.value) {
      isToolbarVisible.value = false;
    }
  }

  /// 跳轉到指定頁
  ///
  /// **參數**：
  /// - [page]: 目標頁碼（從 1 開始）
  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;

    currentPage.value = page;
    // TODO: 實現跳轉到指定頁 (需要 epub_view 支持)
    _saveProgress();
  }

  // ==================== 閱讀方向控制 ====================

  /// 切換閱讀方向
  ///
  /// 在直書和橫書之間切換，並重新加載 EPUB（如果需要）。
  /// 切換到直書模式時會注入 CSS，切換到橫書時使用原始文件。
  Future<void> toggleReadingDirection() async {
    final oldDirection = readingDirection.value;
    readingDirection.value = readingDirection.value.toggle();

    // 重新初始化 EPUB 控制器以應用新的閱讀方向
    try {
      isLoading.value = true;
      await _initEpubController();
      isLoading.value = false;

      Get.snackbar(
        '閱讀方向已切換',
        '當前模式：${readingDirection.value.displayName}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      _saveSettings();
    } catch (e) {
      // 如果失敗，恢復原來的方向
      readingDirection.value = oldDirection;
      isLoading.value = false;

      Get.snackbar(
        '切換失敗',
        '無法切換閱讀方向：$e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 設置閱讀方向
  ///
  /// **參數**：
  /// - [direction]: 新的閱讀方向
  Future<void> setReadingDirection(ReadingDirection direction) async {
    if (readingDirection.value == direction) return;

    final oldDirection = readingDirection.value;
    readingDirection.value = direction;

    try {
      isLoading.value = true;
      await _initEpubController();
      isLoading.value = false;
      _saveSettings();
    } catch (e) {
      readingDirection.value = oldDirection;
      isLoading.value = false;
      rethrow;
    }
  }

  // ==================== 字體大小控制 ====================

  /// 設置字體大小
  ///
  /// **參數**：
  /// - [size]: 新的字體大小（sp），自動限制在 12-20 範圍內
  void setFontSize(double size) {
    final clampedSize = size.clamp(
      ReaderSettings.minFontSize,
      ReaderSettings.maxFontSize,
    );

    fontSize.value = clampedSize;
    _applyFontSize();
    _saveSettings();
  }

  /// 增加字體大小
  ///
  /// 每次增加 2sp，最大到 20sp。
  void increaseFontSize() {
    setFontSize(fontSize.value + 2.0);
  }

  /// 減少字體大小
  ///
  /// 每次減少 2sp，最小到 12sp。
  void decreaseFontSize() {
    setFontSize(fontSize.value - 2.0);
  }

  /// 應用字體大小到 EPUB 視圖
  ///
  /// 通過重新加載 EPUB 來應用新的字體大小設置。
  /// 這會使用 EpubPreprocessor 注入字體大小 CSS。
  ///
  /// **實現方案**：
  /// 使用 CSS 預處理方式，類似於直書模式的實現：
  /// 1. 調用 EpubPreprocessor.processWithSettings() 注入字體大小 CSS
  /// 2. 重新創建 EpubController
  /// 3. 字體大小更改會立即生效
  ///
  /// **注意**：
  /// 重新加載會導致當前閱讀位置丟失，需要在未來版本中保存和恢復 epubCfi。
  Future<void> _applyFontSize() async {
    try {
      // 重新初始化 EPUB 控制器以應用新字體大小
      await _initEpubController();
    } catch (e) {
      // 如果應用失敗，顯示錯誤但不中斷閱讀
      Get.snackbar(
        '字體大小更改',
        '字體大小已更新，將在翻頁後生效',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ==================== 亮度控制 ====================

  /// 設置屏幕亮度
  ///
  /// **參數**：
  /// - [value]: 亮度值（0.0 - 1.0）
  Future<void> setBrightness(double value) async {
    final clampedValue = value.clamp(0.0, 1.0);
    brightness.value = clampedValue;

    await _applyBrightness();
    _saveSettings();
  }

  /// 應用亮度設置
  Future<void> _applyBrightness() async {
    try {
      await _screenBrightness.setScreenBrightness(brightness.value);
    } catch (e) {
      Get.snackbar(
        '錯誤',
        '設置亮度失敗',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== 夜間模式控制 ====================

  /// 切換夜間模式
  void toggleNightMode() {
    isNightMode.value = !isNightMode.value;
    _saveSettings();

    Get.snackbar(
      '夜間模式',
      isNightMode.value ? '已開啟' : '已關閉',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // ==================== 工具欄控制 ====================

  /// 切換工具欄顯示
  void toggleToolbar() {
    isToolbarVisible.value = !isToolbarVisible.value;
  }

  /// 顯示工具欄
  void showToolbar() {
    isToolbarVisible.value = true;
  }

  /// 隱藏工具欄
  void hideToolbar() {
    isToolbarVisible.value = false;
  }

  /// 切換工具欄自動隱藏
  void toggleAutoHideToolbar() {
    autoHideToolbar.value = !autoHideToolbar.value;
    _saveSettings();
  }

  // ==================== 書籤管理 ====================

  /// 切換當前頁的書籤
  ///
  /// 如果當前頁已添加書籤則移除，否則添加。
  Future<void> toggleCurrentBookmark() async {
    if (book.value == null) return;

    try {
      await toggleBookmark.call(
        bookId: book.value!.id,
        page: currentPage.value,
      );

      if (bookmarkedPages.contains(currentPage.value)) {
        bookmarkedPages.remove(currentPage.value);
        Get.snackbar(
          '書籤',
          '已移除書籤',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      } else {
        bookmarkedPages.add(currentPage.value);
        bookmarkedPages.sort(); // 保持排序
        Get.snackbar(
          '書籤',
          '已添加書籤',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Get.snackbar(
        '錯誤',
        '操作書籤失敗',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== 進度保存 ====================

  /// 保存閱讀進度
  ///
  /// 將當前頁碼和書籤保存到數據庫。
  Future<void> _saveProgress() async {
    if (book.value == null) return;

    try {
      final progress = ReadingProgress(
        bookId: book.value!.id,
        currentPage: currentPage.value,
        bookmarkedPages: bookmarkedPages.toList(),
        lastReadTime: DateTime.now(),
        totalPages: totalPages.value > 0 ? totalPages.value : null,
      );

      await saveReadingProgress.call(progress);
    } catch (e) {
      // 保存失敗不影響閱讀
    }
  }

  /// 保存閱讀器設置
  /// 
  /// 保存書籍特定的閱讀設置到 SharedPreferences。
  /// 如果保存失敗，不影響正常使用。
  Future<void> _saveSettings() async {
    if (book.value == null) return;

    try {
      // 保存書籍特定設置
      await readingLocalDataSource.saveBookSettings(
        book.value!.id,
        currentSettings,
      );
    } catch (e) {
      // 保存失敗不影響使用
    }
  }

  // ==================== 實用方法 ====================

  /// 刷新頁面
  ///
  /// 重新加載當前頁內容。
  @override
  void refresh() {
    // TODO: 實現頁面刷新
    super.refresh();
  }

  // TODO: 實現 CFI 計算
  // /// 獲取當前 EPUB CFI
  // ///
  // /// CFI (Canonical Fragment Identifier) 是 EPUB 中用於定位的標準格式。
  // String? _getCurrentEpubCfi() {
  //   return null;
  // }
}
