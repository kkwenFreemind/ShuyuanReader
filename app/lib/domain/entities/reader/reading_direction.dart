/// 閱讀方向枚舉
///
/// 定義兩種閱讀模式：傳統直書和現代橫書。
///
/// **閱讀方向說明**：
/// - **vertical（直書）**：
///   - 傳統中文閱讀方式
///   - 文字從上到下排列
///   - 翻頁從右向左
///   - 適合閱讀古典文學、詩詞等
///
/// - **horizontal（橫書）**：
///   - 現代閱讀方式
///   - 文字從左到右排列
///   - 翻頁從左向右
///   - 適合閱讀現代書籍
///
/// **使用示例**：
/// ```dart
/// // 創建直書模式
/// final direction = ReadingDirection.vertical;
///
/// // 判斷是否為直書
/// if (direction.isVertical) {
///   print('使用直書模式');
/// }
///
/// // 切換模式
/// final newDirection = direction.toggle();
/// ```
library;

/// 閱讀方向枚舉
///
/// 此枚舉定義了兩種閱讀方向，用於控制 EPUB 閱讀器的文字排版和翻頁方向。
enum ReadingDirection {
  /// 直書模式（從上到下，從右到左）
  ///
  /// 傳統中文閱讀方式：
  /// - 文字垂直排列（從上到下）
  /// - 從右向左翻頁
  /// - 使用 CSS writing-mode: vertical-rl
  vertical('直書'),

  /// 橫書模式（從左到右，從上到下）
  ///
  /// 現代閱讀方式：
  /// - 文字水平排列（從左到右）
  /// - 從左向右翻頁
  /// - 使用標準 CSS 佈局
  horizontal('橫書');

  /// 閱讀方向的中文顯示名稱
  final String displayName;

  /// 構造函數
  const ReadingDirection(this.displayName);

  /// 判斷是否為直書模式
  ///
  /// **返回**：
  /// true 如果是直書模式，否則 false
  bool get isVertical => this == ReadingDirection.vertical;

  /// 判斷是否為橫書模式
  ///
  /// **返回**：
  /// true 如果是橫書模式，否則 false
  bool get isHorizontal => this == ReadingDirection.horizontal;

  /// 切換閱讀方向
  ///
  /// 如果當前是直書，則切換為橫書；反之亦然。
  ///
  /// **返回**：
  /// 切換後的閱讀方向
  ///
  /// **示例**：
  /// ```dart
  /// final vertical = ReadingDirection.vertical;
  /// final horizontal = vertical.toggle(); // ReadingDirection.horizontal
  /// ```
  ReadingDirection toggle() {
    return this == ReadingDirection.vertical
        ? ReadingDirection.horizontal
        : ReadingDirection.vertical;
  }

  /// 獲取 CSS writing-mode 屬性值
  ///
  /// 用於在 EPUB 渲染時設置正確的 CSS 屬性。
  ///
  /// **返回**：
  /// - vertical: 'vertical-rl'
  /// - horizontal: 'horizontal-tb'
  String get cssWritingMode {
    switch (this) {
      case ReadingDirection.vertical:
        return 'vertical-rl';
      case ReadingDirection.horizontal:
        return 'horizontal-tb';
    }
  }

  /// 獲取翻頁方向的圖標
  ///
  /// **返回**：
  /// - vertical: '⚔️' (豎排圖標)
  /// - horizontal: '📖' (橫排圖標)
  String get icon {
    switch (this) {
      case ReadingDirection.vertical:
        return '⚔️';
      case ReadingDirection.horizontal:
        return '📖';
    }
  }

  /// 獲取翻頁手勢提示文字
  ///
  /// **返回**：
  /// 適合當前閱讀方向的翻頁提示
  String get swipeHint {
    switch (this) {
      case ReadingDirection.vertical:
        return '⬅️ 向左滑 = 下一頁';
      case ReadingDirection.horizontal:
        return '➡️ 向右滑 = 下一頁';
    }
  }

  /// 轉換為字符串表示（用於調試）
  @override
  String toString() => 'ReadingDirection.$name($displayName)';
}
