import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/book_detail_controller.dart';
import '../../data/models/download_status.dart';

/// 書籍詳情頁面
/// 
/// 顯示書籍的詳細信息，包括：
/// - 封面圖片（帶 Hero 動畫）
/// - 書籍基本信息（書名、作者、語言、文件大小）
/// - 下載狀態和操作按鈕
/// 
/// 使用 GetView 自動注入 BookDetailController
class BookDetailPage extends GetView<BookDetailController> {
  const BookDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('書籍詳情'),
        centerTitle: true,
      ),
      body: Obx(() => _buildBody()),
    );
  }

  /// 構建頁面主體內容
  /// 
  /// 使用 SingleChildScrollView 支持滾動
  /// 內容包括封面、書籍信息和操作按鈕
  /// 添加 SafeArea 確保內容不被系統 UI 遮擋
  Widget _buildBody() {
    return SafeArea(
      bottom: false, // 按鈕區域會單獨處理底部安全區域
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImage(),
            _buildBookInfo(),
            _buildActionButtons(),
            // 添加底部安全區域間距
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// 構建封面圖片組件
  /// 
  /// 使用 Hero 動畫實現從列表頁到詳情頁的平滑過渡
  /// 使用 CachedNetworkImage 加載網絡圖片並提供緩存
  /// 響應式高度：根據屏幕大小調整封面高度
  Widget _buildCoverImage() {
    final book = controller.book.value;
    final context = Get.context!;
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 響應式高度計算：
    // - 小屏幕（< 600）：屏幕高度的 40%
    // - 中等屏幕（600-900）：屏幕高度的 45%
    // - 大屏幕（> 900）：固定 500，但不超過屏幕高度的 50%
    final coverHeight = screenWidth < 600
        ? screenHeight * 0.4
        : screenWidth < 900
            ? screenHeight * 0.45
            : (screenHeight * 0.5).clamp(400.0, 500.0);
    
    return Hero(
      tag: 'book-cover-${book.id}',
      transitionOnUserGestures: true,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return DefaultTextStyle(
          style: DefaultTextStyle.of(toHeroContext).style,
          child: toHeroContext.widget,
        );
      },
      child: Container(
        width: double.infinity,
        height: coverHeight,
        color: theme.colorScheme.surfaceContainerHighest,
        child: CachedNetworkImage(
          imageUrl: book.coverUrl,
          fit: BoxFit.contain, // 完整顯示圖片，不裁切
          placeholder: (context, url) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: theme.colorScheme.surfaceContainerHigh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  size: 80,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '封面加載失敗',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 構建書籍信息區域
  /// 
  /// 顯示書名、作者、語言、文件大小和描述信息
  /// 優化間距和視覺層次
  Widget _buildBookInfo() {
    final book = controller.book.value;
    final context = Get.context!;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 響應式水平 padding
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 書名 - 使用 headlineSmall 樣式
          Text(
            book.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
              letterSpacing: 0.5,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // 作者 - 使用 bodyLarge 樣式
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  book.author,
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 語言和文件大小 - 使用 bodyMedium 樣式
          Row(
            children: [
              Icon(
                Icons.language,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                book.language,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 24),
              
              // 文件大小
              Icon(
                Icons.insert_drive_file_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                book.fileSizeFormatted,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          
          // 描述（如果有）
          if (book.description.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(
              thickness: 1,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '簡介',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              book.description,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.6,
                letterSpacing: 0.2,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 構建操作按鈕區域
  /// 
  /// 根據書籍的下載狀態顯示不同的操作按鈕
  /// 添加響應式間距和安全區域處理
  Widget _buildActionButtons() {
    final book = controller.book.value;
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    
    // 響應式水平 padding
    final horizontalPadding = screenWidth < 600 ? 16.0 : 24.0;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16.0,
        horizontalPadding,
        24.0, // 增加底部間距
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<DownloadStatus>(book.downloadStatus),
          child: () {
            switch (book.downloadStatus) {
              case DownloadStatus.notDownloaded:
                return _buildDownloadButton();
              case DownloadStatus.downloading:
                return _buildDownloadingWidget();
              case DownloadStatus.paused:
                return _buildPausedWidget();
              case DownloadStatus.downloaded:
                return _buildDownloadedButtons();
              case DownloadStatus.failed:
                return _buildDownloadButton();
            }
          }(),
        ),
      ),
    );
  }

  /// 構建下載按鈕（未下載狀態）
  /// 
  /// 顯示主要的下載按鈕，點擊後開始下載書籍
  Widget _buildDownloadButton() {
    final context = Get.context!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: controller.startDownload,
        icon: const Icon(Icons.download, size: 24),
        label: Text(
          '下載書籍',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  /// 構建下載中組件
  /// 
  /// 顯示下載進度條、百分比和暫停/取消按鈕
  Widget _buildDownloadingWidget() {
    final book = controller.book.value;
    final progress = book.downloadProgress;
    final percentage = (progress * 100).toStringAsFixed(0);
    final context = Get.context!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 進度信息行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '下載中',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '$percentage%',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 進度條
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          tween: Tween<double>(
            begin: 0,
            end: progress,
          ),
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        
        // 操作按鈕行
        Row(
          children: [
            // 暫停按鈕
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.pauseDownload,
                icon: const Icon(Icons.pause, size: 20),
                label: Text(
                  '暫停',
                  style: textTheme.labelLarge,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.tertiary,
                  side: BorderSide(color: colorScheme.tertiary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 取消按鈕
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.cancelDownload,
                icon: const Icon(Icons.close, size: 20),
                label: Text(
                  '取消',
                  style: textTheme.labelLarge,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 構建暫停狀態組件
  /// 
  /// 顯示暫停狀態的進度條和操作按鈕（繼續、取消）
  Widget _buildPausedWidget() {
    final book = controller.book.value;
    final context = Get.context!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 暫停狀態標題和進度
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '已暫停',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.tertiary,
              ),
            ),
            Text(
              '${(book.downloadProgress * 100).toStringAsFixed(0)}%',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 進度條（橙色）
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          tween: Tween<double>(
            begin: 0,
            end: book.downloadProgress,
          ),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
              borderRadius: BorderRadius.circular(4),
            );
          },
        ),
        const SizedBox(height: 16),
        
        // 操作按鈕行
        Row(
          children: [
            // 繼續按鈕
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.startDownload,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(
                  '繼續',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSecondary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 取消按鈕
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.cancelDownload,
                icon: const Icon(Icons.close, size: 20),
                label: Text(
                  '取消',
                  style: textTheme.labelLarge,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 構建已下載組件
  /// 
  /// 顯示打開閱讀和刪除書籍按鈕
  Widget _buildDownloadedButtons() {
    final context = Get.context!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Column(
      children: [
        // 打開閱讀按鈕
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: controller.openReader,
            icon: const Icon(Icons.menu_book, size: 24),
            label: Text(
              '打開閱讀',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: colorScheme.onSecondary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 刪除書籍按鈕
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: controller.deleteBook,
            icon: const Icon(Icons.delete_outline, size: 24),
            label: Text(
              '刪除書籍',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
