/// 閱讀設置面板組件
///
/// **職責**：
/// 這是一個從底部彈出的設置面板 Widget，提供閱讀器的各種設置選項。
/// 使用 BottomSheet 方式顯示，提供流暢的動畫效果。
///
/// **主要功能**：
/// - 字體大小調整（5 檔：12/14/16/18/20sp）
/// - 亮度調整（0-100%）
/// - 夜間模式切換
/// - 自動隱藏工具欄切換
/// - 圓角設計與陰影效果
/// - 支持夜間模式顏色自適應
///
/// **設計特點**：
/// - BottomSheet 彈出動畫
/// - 圓角頂部設計
/// - 分組佈局（設置項分類）
/// - 即時預覽效果
/// - 拖動關閉支持
///
/// **使用示例**：
/// ```dart
/// void _showSettingsPanel() {
///   showModalBottomSheet(
///     context: context,
///     builder: (context) => ReadingSettingsPanel(
///       fontSize: controller.fontSize.value,
///       brightness: controller.brightness.value,
///       isNightMode: controller.isNightMode.value,
///       autoHideToolbar: controller.autoHideToolbar.value,
///       onFontSizeChanged: controller.setFontSize,
///       onBrightnessChanged: controller.setBrightness,
///       onNightModeChanged: controller.toggleNightMode,
///       onAutoHideToolbarChanged: controller.setAutoHideToolbar,
///     ),
///   );
/// }
/// ```
library;

import 'package:flutter/material.dart';

/// 閱讀設置面板 Widget
///
/// 從底部彈出的設置面板，包含各種閱讀器設置選項。
class ReadingSettingsPanel extends StatelessWidget {
  /// 當前字體大小（sp）
  final double fontSize;

  /// 當前亮度（0.0 - 1.0）
  final double brightness;

  /// 是否為夜間模式
  final bool isNightMode;

  /// 是否自動隱藏工具欄
  final bool autoHideToolbar;

  /// 字體大小變化回調
  final ValueChanged<double> onFontSizeChanged;

  /// 亮度變化回調
  final ValueChanged<double> onBrightnessChanged;

  /// 夜間模式切換回調
  final ValueChanged<bool> onNightModeChanged;

  /// 自動隱藏工具欄切換回調
  final ValueChanged<bool> onAutoHideToolbarChanged;

  /// 面板高度
  final double? panelHeight;

  /// 構造函數
  const ReadingSettingsPanel({
    super.key,
    required this.fontSize,
    required this.brightness,
    required this.isNightMode,
    required this.autoHideToolbar,
    required this.onFontSizeChanged,
    required this.onBrightnessChanged,
    required this.onNightModeChanged,
    required this.onAutoHideToolbarChanged,
    this.panelHeight,
  });

  /// 字體大小預設檔位（5 檔）
  static const List<double> fontSizePresets = [12.0, 14.0, 16.0, 18.0, 20.0];

  /// 獲取字體大小標籤
  ///
  /// 將字體大小值轉換為檔位標籤（小/中/大/特大/超大）
  static String _getFontSizeLabel(double size) {
    if (size <= 12) return '小';
    if (size <= 14) return '中';
    if (size <= 16) return '大';
    if (size <= 18) return '特大';
    return '超大';
  }

  /// 獲取最接近的預設字體大小
  ///
  /// 將任意字體大小值對齊到最近的預設檔位
  static double _getNearestFontSize(double size) {
    double nearest = fontSizePresets[0];
    double minDiff = (size - nearest).abs();

    for (final preset in fontSizePresets) {
      final diff = (size - preset).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = preset;
      }
    }

    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    // 計算面板高度（自動或手動指定）
    final height = panelHeight ?? MediaQuery.of(context).size.height * 0.4;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isNightMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 頂部拖動指示器
          _buildDragHandle(),

          // 面板標題
          _buildHeader(),

          // 設置項列表
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 字體大小設置
                  _buildFontSizeSection(),

                  const SizedBox(height: 24),

                  // 亮度設置
                  _buildBrightnessSection(),

                  const SizedBox(height: 24),

                  // 夜間模式開關
                  _buildNightModeSwitch(),

                  const SizedBox(height: 16),

                  // 自動隱藏工具欄開關
                  _buildAutoHideToolbarSwitch(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 構建拖動指示器
  ///
  /// 頂部的小橫條，提示用戶可以拖動關閉面板
  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isNightMode ? Colors.grey[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 構建面板標題
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '閱讀設置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isNightMode ? Colors.white : Colors.black87,
            ),
          ),
          // 可選：添加關閉按鈕
        ],
      ),
    );
  }

  /// 構建字體大小設置區域
  Widget _buildFontSizeSection() {
    // 確保當前字體大小對齊到預設檔位
    final alignedFontSize = _getNearestFontSize(fontSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '字體大小',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isNightMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '${alignedFontSize.toInt()}sp (${_getFontSizeLabel(alignedFontSize)})',
              style: TextStyle(
                fontSize: 14,
                color: isNightMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 字體大小滑桿
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: isNightMode ? Colors.amber : Colors.blue,
            inactiveTrackColor:
                isNightMode ? Colors.grey[800] : Colors.grey[300],
            thumbColor: isNightMode ? Colors.amber : Colors.blue,
            overlayColor: (isNightMode ? Colors.amber : Colors.blue)
                .withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: alignedFontSize,
            min: fontSizePresets.first,
            max: fontSizePresets.last,
            divisions: fontSizePresets.length - 1,
            onChanged: (value) {
              // 對齊到預設檔位
              final aligned = _getNearestFontSize(value);
              onFontSizeChanged(aligned);
            },
          ),
        ),
        // 字體大小檔位標籤
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: fontSizePresets
                .map((size) => Text(
                      '${size.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: alignedFontSize == size
                            ? (isNightMode ? Colors.amber : Colors.blue)
                            : (isNightMode
                                ? Colors.grey[600]
                                : Colors.grey[500]),
                        fontWeight: alignedFontSize == size
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// 構建亮度設置區域
  Widget _buildBrightnessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '螢幕亮度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isNightMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '${(brightness * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: isNightMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 亮度滑桿
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: isNightMode ? Colors.amber : Colors.blue,
            inactiveTrackColor:
                isNightMode ? Colors.grey[800] : Colors.grey[300],
            thumbColor: isNightMode ? Colors.amber : Colors.blue,
            overlayColor: (isNightMode ? Colors.amber : Colors.blue)
                .withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: brightness,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: onBrightnessChanged,
          ),
        ),
        // 亮度範圍標籤
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '暗',
                style: TextStyle(
                  fontSize: 12,
                  color: isNightMode ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
              Text(
                '亮',
                style: TextStyle(
                  fontSize: 12,
                  color: isNightMode ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 構建夜間模式開關
  Widget _buildNightModeSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNightMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isNightMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: isNightMode ? Colors.amber : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '夜間模式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isNightMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Switch(
            value: isNightMode,
            onChanged: onNightModeChanged,
            activeColor: Colors.amber,
            activeTrackColor: Colors.amber.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  /// 構建自動隱藏工具欄開關
  Widget _buildAutoHideToolbarSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNightMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: isNightMode ? Colors.blue[300] : Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '自動隱藏工具欄',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isNightMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Switch(
            value: autoHideToolbar,
            onChanged: onAutoHideToolbarChanged,
            activeColor: isNightMode ? Colors.blue[300] : Colors.blue,
            activeTrackColor: (isNightMode ? Colors.blue[300]! : Colors.blue)
                .withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
