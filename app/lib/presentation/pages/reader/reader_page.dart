/// EPUB 閱讀器頁面
///
/// **職責**：
/// 這是 EPUB 閱讀器的主要 UI 頁面，負責整合所有閱讀相關功能。
/// 使用 GetX 進行狀態管理和依賴注入。
///
/// **主要功能**：
/// - EPUB 文件渲染與顯示
/// - 直書/橫書模式切換
/// - 閱讀進度顯示（頁碼、進度條）
/// - 書籤管理（添加/移除）
/// - 閱讀設置調整（字體、亮度、夜間模式）
/// - 工具欄顯示/隱藏
/// - 手勢操作支持（點擊、滑動）
///
/// **UI 佈局**：
/// ```
/// ┌──────────────────────────────────────┐
/// │  ← 書名    ⚔️ 📖   ⚙️  🔖           │ ← AppBar (可隱藏)
/// ├──────────────────────────────────────┤
/// │                                      │
/// │                                      │
/// │         EPUB 內容顯示區域             │
/// │                                      │
/// │                                      │
/// ├──────────────────────────────────────┤
/// │  ━━━━━━━━━━━━━━━━━━━━━━ 15%         │ ← 進度條 (可隱藏)
/// │      第 5 頁 / 共 30 頁              │
/// └──────────────────────────────────────┘
/// ```
///
/// **導航參數**：
/// - `bookId` (必需): 書籍 ID，用於加載書籍數據
///
/// **使用示例**：
/// ```dart
/// // 通過路由導航
/// Get.toNamed(
///   Routes.reader,
///   arguments: {'bookId': book.id},
/// );
///
/// // 或直接創建頁面
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => ReaderPage(),
///     settings: RouteSettings(
///       arguments: {'bookId': book.id},
///     ),
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/reader/reader_controller.dart';
import '../../widgets/reader/epub_viewer_widget.dart';
import '../../widgets/reader/reading_progress_bar.dart';
import '../../widgets/reader/reading_settings_panel.dart';
import '../../widgets/reader/animated_bookmark_button.dart';

/// EPUB 閱讀器頁面
///
/// 這是一個無狀態的 Widget，所有狀態都由 ReaderController 管理。
/// 使用 GetX 的響應式編程模式自動更新 UI。
class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 獲取 ReaderController 實例
    // 注意：Controller 應該在路由級別或應用級別已經被注入
    final controller = Get.find<ReaderController>();

    return Scaffold(
      // AppBar：工具欄（可隱藏）
      // 適用於兩種閱讀模式：
      // - 直書模式：AppBar 在頂部，不影響文字從右到左排列
      // - 橫書模式：AppBar 在頂部，標準佈局
      appBar: _buildAppBar(context, controller),

      // Body：主要內容區域
      // 使用 SafeArea 確保內容不被系統 UI（如劉海屏）遮擋
      body: SafeArea(
        // 在直書模式下，保留左右邊距以避免文字貼邊
        // 在橫書模式下，保留上下邊距
        child: _buildBody(controller),
      ),
    );
  }

  /// 構建 AppBar
  ///
  /// **功能**：
  /// - 返回按鈕（自動保存閱讀進度）
  /// - 書籍標題
  /// - 直書/橫書切換按鈕
  /// - 書籤按鈕
  /// - 設置按鈕
  ///
  /// **響應式**：
  /// - 工具欄可通過點擊螢幕中央顯示/隱藏
  /// - 書籤按鈕根據當前頁是否有書籤顯示不同圖標
  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ReaderController controller,
  ) {
    // 如果工具欄被隱藏，返回 null（無 AppBar）
    if (!controller.isToolbarVisible.value) {
      return null;
    }

    return AppBar(
      // 返回按鈕
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // 返回前自動保存閱讀進度（refresh 是 void 方法）
          controller.refresh();
          Get.back();
        },
        tooltip: '返回',
      ),

      // 書籍標題
      title: Obx(() {
        final book = controller.book.value;
        if (book == null) {
          return const Text('載入中...');
        }
        return Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }),

      // 工具欄按鈕
      actions: [
        // 直書/橫書切換按鈕
        // 點擊後會重新加載 EPUB（注入或移除 CSS）
        Obx(() {
          final direction = controller.readingDirection.value;
          return IconButton(
            // 使用 Text widget 顯示 emoji 圖標
            icon: Text(
              direction.icon,
              style: const TextStyle(fontSize: 24),
            ),
            onPressed: controller.toggleReadingDirection,
            tooltip: '${direction.displayName} - 點擊切換',
          );
        }),

        // 書籤按鈕
        Obx(() {
          final isBookmarked = controller.isCurrentPageBookmarked;
          return AnimatedBookmarkButton(
            isBookmarked: isBookmarked,
            onPressed: controller.toggleCurrentBookmark,
          );
        }),

        // 設置按鈕
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showSettingsPanel(context, controller),
          tooltip: '設置',
        ),
      ],

      // 背景色：根據夜間模式調整
      backgroundColor: controller.isNightMode.value
          ? Colors.grey[900]
          : null,
    );
  }

  /// 構建主要內容區域
  ///
  /// **結構**：
  /// - 加載狀態：顯示載入指示器
  /// - 錯誤狀態：顯示錯誤信息
  /// - 正常狀態：顯示 EPUB 內容
  ///
  /// **手勢支持**：
  /// - 點擊螢幕中央：切換工具欄顯示/隱藏
  Widget _buildBody(ReaderController controller) {
    return Obx(() {
      // 1. 加載狀態
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在加載書籍...'),
            ],
          ),
        );
      }

      // 2. 錯誤狀態
      if (controller.errorMessage.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
              ),
            ],
          ),
        );
      }

      // 3. 正常狀態：顯示 EPUB 內容
      // 性能優化：提取夜間模式顏色到外層 Obx，避免內層 EpubViewerWidget 不必要的重建
      final backgroundColor = controller.isNightMode.value
          ? Colors.black
          : Colors.white;
      final textColor = controller.isNightMode.value
          ? Colors.white
          : Colors.black;

      return Stack(
        children: [
          // EPUB 內容顯示區域
          // 直書模式：文字從右到左、從上到下排列（由 CSS 控制）
          // 橫書模式：文字從左到右、從上到下排列（預設）
          // 性能優化：使用單一 Obx 監聽 readingDirection，減少重複監聽
          Obx(() {
            return EpubViewerWidget(
              controller: controller.epubController,
              direction: controller.readingDirection.value,
              onPageTap: controller.toggleToolbar,
              onNextPage: controller.nextPage,
              onPreviousPage: controller.previousPage,
              backgroundColor: backgroundColor,
              textColor: textColor,
            );
          }),

          // 底部進度條（固定在底部，適用於兩種模式）
          // 直書模式：進度條仍在底部，不干擾文字閱讀
          // 橫書模式：進度條在底部，符合閱讀習慣
          if (controller.isToolbarVisible.value)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildProgressBar(controller),
            ),
        ],
      );
    });
  }

  /// 構建進度條
  ///
  /// **顯示內容**：
  /// - 進度條（視覺化）
  /// - 當前頁碼 / 總頁數
  /// - 閱讀百分比
  Widget _buildProgressBar(ReaderController controller) {
    return Obx(() {
      return ReadingProgressBar(
        currentPage: controller.currentPage.value,
        totalPages: controller.totalPages.value,
        progressPercentage: controller.progressPercentage,
        isNightMode: controller.isNightMode.value,
      );
    });
  }

  /// 顯示設置面板
  ///
  /// 從底部彈出設置面板，包含以下設置項：
  /// - 字體大小調整（5 檔：12/14/16/18/20sp）
  /// - 亮度調整（0-100%）
  /// - 夜間模式切換
  /// - 自動隱藏工具欄切換
  ///
  /// **使用 ModalBottomSheet**：
  /// - 圓角頂部設計
  /// - 拖動關閉支持
  /// - 半透明背景遮罩
  void _showSettingsPanel(BuildContext context, ReaderController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 透明背景讓圓角可見
      isScrollControlled: true, // 允許自定義高度
      builder: (context) => Obx(() {
        return ReadingSettingsPanel(
          // 當前設置值
          fontSize: controller.fontSize.value,
          brightness: controller.brightness.value,
          isNightMode: controller.isNightMode.value,
          autoHideToolbar: controller.autoHideToolbar.value,
          
          // 回調函數
          onFontSizeChanged: controller.setFontSize,
          onBrightnessChanged: controller.setBrightness,
          onNightModeChanged: (_) => controller.toggleNightMode(),
          onAutoHideToolbarChanged: (_) => controller.toggleAutoHideToolbar(),
        );
      }),
    );
  }
}

