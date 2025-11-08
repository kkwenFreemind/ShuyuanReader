/// EPUB 閱讀器視圖組件
///
/// **職責**：
/// 這是一個封裝了 epub_view 包的自定義 Widget，提供了 EPUB 內容的渲染和交互功能。
/// 主要負責處理 EPUB 文件的顯示、手勢操作和加載狀態。
///
/// **主要功能**：
/// - EPUB 內容渲染
/// - 手勢翻頁支持（點擊、滑動）
/// - 閱讀方向適配（直書/橫書）
/// - 加載動畫顯示
/// - 章節分隔符自定義
///
/// **手勢說明**：
///
/// **直書模式（vertical）**：
/// - 從右向左滑動（primaryVelocity < 0）= 下一頁
/// - 從左向右滑動（primaryVelocity > 0）= 上一頁
/// - 點擊螢幕中央 = 切換工具欄
///
/// **橫書模式（horizontal）**：
/// - 從左向右滑動（primaryVelocity > 0）= 下一頁
/// - 從右向左滑動（primaryVelocity < 0）= 上一頁
/// - 點擊螢幕中央 = 切換工具欄
///
/// **使用示例**：
/// ```dart
/// EpubViewerWidget(
///   controller: epubController,
///   direction: ReadingDirection.vertical,
///   onPageTap: () => print('Page tapped'),
///   onNextPage: () => print('Next page'),
///   onPreviousPage: () => print('Previous page'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

import '../../../domain/entities/reader/reading_direction.dart';

/// EPUB 閱讀器視圖 Widget
///
/// 封裝 epub_view 包的 EpubView，提供統一的手勢操作和樣式。
class EpubViewerWidget extends StatelessWidget {
  /// EPUB 控制器
  ///
  /// 用於控制 EPUB 文件的加載和頁面導航。
  final EpubController? controller;

  /// 閱讀方向
  ///
  /// 決定手勢翻頁的方向邏輯：
  /// - vertical（直書）：從右向左滑動 = 下一頁
  /// - horizontal（橫書）：從左向右滑動 = 下一頁
  final ReadingDirection direction;

  /// 頁面點擊回調
  ///
  /// 通常用於切換工具欄的顯示/隱藏。
  final VoidCallback onPageTap;

  /// 翻到下一頁回調
  ///
  /// 當用戶滑動手勢觸發翻頁時調用。
  final VoidCallback onNextPage;

  /// 翻到上一頁回調
  ///
  /// 當用戶滑動手勢觸發翻頁時調用。
  final VoidCallback onPreviousPage;

  /// 背景顏色
  ///
  /// 預設為白色，可根據夜間模式調整。
  final Color? backgroundColor;

  /// 文字顏色
  ///
  /// 預設為黑色，可根據夜間模式調整。
  final Color? textColor;

  /// 構造函數
  const EpubViewerWidget({
    super.key,
    required this.controller,
    required this.direction,
    required this.onPageTap,
    required this.onNextPage,
    required this.onPreviousPage,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // 如果控制器為空，顯示提示信息
    if (controller == null) {
      return Container(
        color: backgroundColor ?? Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'EPUB 控制器未初始化',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      // 點擊螢幕中央：切換工具欄
      onTap: onPageTap,

      // 水平滑動手勢：翻頁
      onHorizontalDragEnd: (details) {
        _handleSwipeGesture(details);
      },

      // EPUB 內容視圖
      child: Container(
        color: backgroundColor ?? Colors.white,
        child: EpubView(
          controller: controller!,

          // 自定義構建器
          builders: EpubViewBuilders<DefaultBuilderOptions>(
            // 章節分隔符
            chapterDividerBuilder: (_) => Container(
              height: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(vertical: 16),
            ),

            // 加載動畫
            loaderBuilder: (_) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '正在加載 EPUB 內容...',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // 選項構建器（可選）
            options: const DefaultBuilderOptions(),
          ),

          // EPUB 載入錯誤處理
          onExternalLinkPressed: (href) {
            // 處理外部鏈接（暫不處理）
            debugPrint('External link pressed: $href');
          },
        ),
      ),
    );
  }

  /// 處理滑動手勢
  ///
  /// 根據閱讀方向和滑動速度決定翻頁方向。
  ///
  /// **直書模式（vertical）**：
  /// - primaryVelocity < 0（從右向左滑）→ 下一頁
  /// - primaryVelocity > 0（從左向右滑）→ 上一頁
  ///
  /// **橫書模式（horizontal）**：
  /// - primaryVelocity > 0（從左向右滑）→ 下一頁
  /// - primaryVelocity < 0（從右向左滑）→ 上一頁
  void _handleSwipeGesture(DragEndDetails details) {
    final velocity = details.primaryVelocity;

    // 速度太小，不觸發翻頁
    if (velocity == null || velocity.abs() < 500) {
      return;
    }

    if (direction == ReadingDirection.vertical) {
      // 直書模式：從右向左滑動 = 下一頁
      if (velocity < 0) {
        onNextPage();
      } else {
        onPreviousPage();
      }
    } else {
      // 橫書模式：從左向右滑動 = 下一頁
      if (velocity > 0) {
        onNextPage();
      } else {
        onPreviousPage();
      }
    }
  }
}

