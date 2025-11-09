/// 帶動畫的書籤按鈕
///
/// **功能**：
/// - 書籤圖標切換動畫（縮放效果）
/// - 觸覺反饋
/// - 響應式狀態更新
///
/// **動畫效果**：
/// - 點擊時：縮小到 0.8 → 彈回到 1.0
/// - 動畫時長：150ms
/// - 曲線：Curves.easeInOut
///
/// **觸覺反饋**：
/// - 添加書籤：輕觸反饋 (HapticFeedback.lightImpact)
/// - 移除書籤：輕觸反饋 (HapticFeedback.lightImpact)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 帶動畫的書籤按鈕 Widget
///
/// 這是一個有狀態的 Widget，管理動畫控制器和觸覺反饋。
class AnimatedBookmarkButton extends StatefulWidget {
  /// 是否已添加書籤
  final bool isBookmarked;

  /// 點擊回調
  final VoidCallback onPressed;

  /// 書籤顏色（已添加時）
  final Color bookmarkedColor;

  /// 構造函數
  const AnimatedBookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onPressed,
    this.bookmarkedColor = Colors.amber,
  });

  @override
  State<AnimatedBookmarkButton> createState() =>
      _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<AnimatedBookmarkButton>
    with SingleTickerProviderStateMixin {
  /// 動畫控制器
  late AnimationController _animationController;

  /// 縮放動畫
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化動畫控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // 創建縮放動畫：1.0 → 0.8 → 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 處理按鈕點擊
  Future<void> _handleTap() async {
    // 1. 觸發觸覺反饋
    await HapticFeedback.lightImpact();

    // 2. 播放動畫
    _animationController.forward(from: 0.0);

    // 3. 觸發回調
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: widget.isBookmarked ? widget.bookmarkedColor : null,
        ),
        onPressed: _handleTap,
        tooltip: widget.isBookmarked ? '移除書籤' : '添加書籤',
      ),
    );
  }
}
