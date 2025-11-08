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
      // AppBar：工具欄
      appBar: _buildAppBar(controller),

      // Body：主要內容區域
      body: _buildBody(controller),

      // 使用 SafeArea 避免被系統 UI 遮擋
      // bottomNavigationBar: _buildBottomBar(controller),
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
  PreferredSizeWidget? _buildAppBar(ReaderController controller) {
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
        Obx(() {
          final direction = controller.readingDirection.value;
          return IconButton(
            // 使用 Text widget 顯示 emoji 圖標
            icon: Text(
              direction.icon,
              style: const TextStyle(fontSize: 24),
            ),
            onPressed: controller.toggleReadingDirection,
            tooltip: direction.displayName,
          );
        }),

        // 書籤按鈕
        Obx(() {
          final isBookmarked = controller.isCurrentPageBookmarked;
          return IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : null,
            ),
            onPressed: controller.toggleCurrentBookmark,
            tooltip: isBookmarked ? '移除書籤' : '添加書籤',
          );
        }),

        // 設置按鈕（未來實現）
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // TODO: 打開設置面板 (Task 4.8.1)
            Get.snackbar(
              '功能開發中',
              '設置面板將在後續版本實現',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          },
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
      return Stack(
        children: [
          // EPUB 內容顯示區域
          Obx(() {
            return EpubViewerWidget(
              controller: controller.epubController,
              direction: controller.readingDirection.value,
              onPageTap: controller.toggleToolbar,
              onNextPage: controller.nextPage,
              onPreviousPage: controller.previousPage,
              backgroundColor: controller.isNightMode.value
                  ? Colors.black
                  : Colors.white,
              textColor: controller.isNightMode.value
                  ? Colors.white
                  : Colors.black,
            );
          }),

          // 底部進度條（可選顯示）
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isNightMode.value
            ? Colors.grey[900]?.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 進度條
          Obx(() {
            return LinearProgressIndicator(
              value: controller.progressPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.isNightMode.value
                    ? Colors.amber[700]!
                    : Colors.blue,
              ),
              minHeight: 4,
            );
          }),

          const SizedBox(height: 8),

          // 頁碼和百分比
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 當前頁 / 總頁數
                Text(
                  '第 ${controller.currentPage.value} 頁 / 共 ${controller.totalPages.value} 頁',
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.isNightMode.value
                        ? Colors.grey[400]
                        : Colors.grey[700],
                  ),
                ),

                // 閱讀百分比
                Text(
                  '${controller.progressPercent}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: controller.isNightMode.value
                        ? Colors.amber[700]
                        : Colors.blue,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

