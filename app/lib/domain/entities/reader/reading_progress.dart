/// 閱讀進度實體
/// 
/// 領域層的純實體類，記錄書籍的閱讀進度信息
/// 
/// 功能：
/// - 記錄當前閱讀位置（頁碼和 EPUB CFI）
/// - 管理書籤列表
/// - 追蹤最後閱讀時間
/// - 提供進度計算方法
/// 
/// 注意：這是領域層的純實體，不包含持久化邏輯
library;

import 'package:equatable/equatable.dart';

/// 閱讀進度實體
/// 
/// 記錄用戶的閱讀進度，包括當前頁碼、書籤和時間戳
class ReadingProgress extends Equatable {
  /// 書籍 ID
  final String bookId;
  
  /// 當前頁碼（從 1 開始）
  final int currentPage;
  
  /// 書籤頁碼列表
  final List<int> bookmarkedPages;
  
  /// 最後閱讀時間
  final DateTime lastReadTime;
  
  /// EPUB CFI (Canonical Fragment Identifier) 位置
  /// 
  /// 用於精確定位 EPUB 文檔中的位置，比頁碼更精確
  /// 可能為 null（對於非 EPUB 格式或未記錄的情況）
  final String? epubCfi;
  
  /// 總頁數（可選）
  /// 
  /// 用於計算閱讀進度百分比
  /// 如果未知則為 null
  final int? totalPages;

  /// 創建閱讀進度實體
  const ReadingProgress({
    required this.bookId,
    this.currentPage = 1,
    this.bookmarkedPages = const [],
    required this.lastReadTime,
    this.epubCfi,
    this.totalPages,
  });

  /// 檢查指定頁碼是否已添加書籤
  /// 
  /// [page] 要檢查的頁碼
  /// 返回 true 如果該頁已添加書籤，否則返回 false
  bool isBookmarked(int page) => bookmarkedPages.contains(page);

  /// 切換指定頁碼的書籤狀態
  /// 
  /// 如果該頁已有書籤則移除，否則添加
  /// 
  /// [page] 要切換書籤的頁碼
  /// 返回新的 ReadingProgress 實例
  ReadingProgress toggleBookmark(int page) {
    final newBookmarks = List<int>.from(bookmarkedPages);
    
    if (isBookmarked(page)) {
      newBookmarks.remove(page);
    } else {
      newBookmarks.add(page);
      newBookmarks.sort(); // 保持書籤列表有序
    }
    
    return copyWith(
      bookmarkedPages: newBookmarks,
      lastReadTime: DateTime.now(),
    );
  }

  /// 添加書籤到指定頁碼
  /// 
  /// [page] 要添加書籤的頁碼
  /// 返回新的 ReadingProgress 實例
  ReadingProgress addBookmark(int page) {
    if (isBookmarked(page)) {
      return this; // 已存在，不需要改變
    }
    
    final newBookmarks = [...bookmarkedPages, page]..sort();
    return copyWith(
      bookmarkedPages: newBookmarks,
      lastReadTime: DateTime.now(),
    );
  }

  /// 移除指定頁碼的書籤
  /// 
  /// [page] 要移除書籤的頁碼
  /// 返回新的 ReadingProgress 實例
  ReadingProgress removeBookmark(int page) {
    if (!isBookmarked(page)) {
      return this; // 不存在，不需要改變
    }
    
    final newBookmarks = List<int>.from(bookmarkedPages)..remove(page);
    return copyWith(
      bookmarkedPages: newBookmarks,
      lastReadTime: DateTime.now(),
    );
  }

  /// 更新當前閱讀位置
  /// 
  /// [page] 新的頁碼
  /// [cfi] 可選的 EPUB CFI 位置
  /// 返回新的 ReadingProgress 實例
  ReadingProgress updatePosition({
    required int page,
    String? cfi,
  }) {
    return copyWith(
      currentPage: page,
      epubCfi: cfi,
      lastReadTime: DateTime.now(),
    );
  }

  /// 計算閱讀進度百分比
  /// 
  /// 如果總頁數未知，返回 0.0
  /// 返回值範圍：0.0 - 1.0
  double get progressPercentage {
    if (totalPages == null || totalPages! <= 0) {
      return 0.0;
    }
    return (currentPage / totalPages!).clamp(0.0, 1.0);
  }

  /// 計算閱讀進度百分比（百分數形式）
  /// 
  /// 返回值範圍：0 - 100
  double get progressPercent => progressPercentage * 100;

  /// 檢查是否已完成閱讀
  /// 
  /// 當前頁碼等於總頁數時視為完成
  bool get isCompleted {
    if (totalPages == null) return false;
    return currentPage >= totalPages!;
  }

  /// 檢查是否剛開始閱讀
  bool get isJustStarted => currentPage <= 1;

  /// 書籤數量
  int get bookmarkCount => bookmarkedPages.length;

  /// 創建副本並更新指定字段
  ReadingProgress copyWith({
    String? bookId,
    int? currentPage,
    List<int>? bookmarkedPages,
    DateTime? lastReadTime,
    String? epubCfi,
    int? totalPages,
  }) {
    return ReadingProgress(
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      bookmarkedPages: bookmarkedPages ?? this.bookmarkedPages,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      epubCfi: epubCfi ?? this.epubCfi,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
        bookId,
        currentPage,
        bookmarkedPages,
        lastReadTime,
        epubCfi,
        totalPages,
      ];

  @override
  String toString() {
    return 'ReadingProgress('
        'bookId: $bookId, '
        'currentPage: $currentPage, '
        'totalPages: $totalPages, '
        'bookmarks: ${bookmarkedPages.length}, '
        'progress: ${progressPercent.toStringAsFixed(1)}%, '
        'lastRead: $lastReadTime'
        ')';
  }
}

