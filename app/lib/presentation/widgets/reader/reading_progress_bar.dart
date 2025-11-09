/// 閱讀進度條組件
///
/// **職責**：
/// 這是一個顯示閱讀進度的專用 Widget，負責展示當前閱讀位置和進度百分比。
/// 是一個可重用的組件，可在不同場景下使用。
///
/// **主要功能**：
/// - 顯示當前頁碼 / 總頁數
/// - 視覺化進度條（LinearProgressIndicator）
/// - 顯示閱讀百分比
/// - 支持夜間模式顏色自適應
/// - 實時更新（通過響應式數據）
///
/// **設計特點**：
/// - 半透明背景（不完全遮擋內容）
/// - 陰影效果（與內容區分）
/// - 響應式佈局（適應不同螢幕寬度）
/// - 固定在底部顯示
///
/// **使用示例**：
/// ```dart
/// ReadingProgressBar(
///   currentPage: 5,
///   totalPages: 30,
///   progressPercentage: 0.15,
///   isNightMode: false,
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// 閱讀進度條 Widget
///
/// 顯示閱讀進度的視覺化組件，包含頁碼信息和進度條。
class ReadingProgressBar extends StatelessWidget {
  /// 當前頁碼（從 1 開始）
  final int currentPage;

  /// 總頁數
  final int totalPages;

  /// 閱讀進度百分比（0.0 - 1.0）
  final double progressPercentage;

  /// 是否為夜間模式
  ///
  /// 影響顏色主題：
  /// - 夜間模式：深色背景 + 琥珀色進度條
  /// - 日間模式：淺色背景 + 藍色進度條
  final bool isNightMode;

  /// 進度條高度
  final double? progressBarHeight;

  /// 文字大小
  final double? textSize;

  /// 內邊距
  final EdgeInsets? padding;

  /// 構造函數
  const ReadingProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    this.isNightMode = false,
    this.progressBarHeight = 4.0,
    this.textSize = 14.0,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    // 性能優化：使用 RepaintBoundary 隔離進度條的重繪
    // 當進度更新時，只重繪此組件，不影響其他 UI 元素
    return RepaintBoundary(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          // 半透明背景
          color: isNightMode
              ? Colors.grey[900]?.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          // 頂部陰影
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
            // 視覺化進度條
            LinearProgressIndicator(
              value: progressPercentage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isNightMode ? Colors.amber[700]! : Colors.blue,
              ),
              minHeight: progressBarHeight,
            ),

            const SizedBox(height: 8),

            // 頁碼和百分比信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左側：當前頁 / 總頁數
                Text(
                  '第 $currentPage 頁 / 共 $totalPages 頁',
                  style: TextStyle(
                    fontSize: textSize,
                    color: isNightMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),

                // 右側：閱讀百分比
                Text(
                  _formatPercentage(),
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                    color: isNightMode ? Colors.amber[700] : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化百分比顯示
  ///
  /// 返回格式：「15%」
  String _formatPercentage() {
    final percent = (progressPercentage * 100).round();
    return '$percent%';
  }
}

