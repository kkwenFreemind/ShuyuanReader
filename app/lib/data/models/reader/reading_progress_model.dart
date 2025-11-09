/// 閱讀進度數據模型
/// 
/// 用於 Hive 數據持久化的模型類
/// 
/// 功能：
/// - Hive 序列化/反序列化支持
/// - 與領域實體 ReadingProgress 互相轉換
/// - 本地數據庫存儲
library;

import 'package:hive/hive.dart';
import '../../../domain/entities/reader/reading_progress.dart';

part 'reading_progress_model.g.dart';

/// 閱讀進度數據模型
///
/// 用於 Hive 持久化存儲的數據模型。
/// typeId: 3 - Hive 類型 ID（1: BookModel, 2: DownloadStatus）
@HiveType(typeId: 3)
class ReadingProgressModel extends HiveObject {
  /// 書籍 ID
  @HiveField(0)
  final String bookId;

  /// 當前頁碼（從 1 開始）
  @HiveField(1)
  final int currentPage;

  /// 書籤頁碼列表
  @HiveField(2)
  final List<int> bookmarkedPages;

  /// 最後閱讀時間（毫秒時間戳）
  @HiveField(3)
  final int lastReadTimeMillis;

  /// EPUB CFI 位置（可選）
  @HiveField(4)
  final String? epubCfi;

  /// 總頁數（可選）
  @HiveField(5)
  final int? totalPages;

  /// 構造函數
  ReadingProgressModel({
    required this.bookId,
    required this.currentPage,
    required this.bookmarkedPages,
    required this.lastReadTimeMillis,
    this.epubCfi,
    this.totalPages,
  });

  /// 從領域實體轉換為數據模型
  ///
  /// [progress] 領域層的 ReadingProgress 實體
  /// 返回 ReadingProgressModel 實例
  factory ReadingProgressModel.fromEntity(ReadingProgress progress) {
    return ReadingProgressModel(
      bookId: progress.bookId,
      currentPage: progress.currentPage,
      bookmarkedPages: List<int>.from(progress.bookmarkedPages),
      lastReadTimeMillis: progress.lastReadTime.millisecondsSinceEpoch,
      epubCfi: progress.epubCfi,
      totalPages: progress.totalPages,
    );
  }

  /// 轉換為領域實體
  ///
  /// 返回 ReadingProgress 領域實體
  ReadingProgress toEntity() {
    return ReadingProgress(
      bookId: bookId,
      currentPage: currentPage,
      bookmarkedPages: List<int>.from(bookmarkedPages),
      lastReadTime: DateTime.fromMillisecondsSinceEpoch(lastReadTimeMillis),
      epubCfi: epubCfi,
      totalPages: totalPages,
    );
  }

  /// 轉換為 JSON
  ///
  /// 用於調試或其他序列化需求
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'currentPage': currentPage,
      'bookmarkedPages': bookmarkedPages,
      'lastReadTime': DateTime.fromMillisecondsSinceEpoch(lastReadTimeMillis)
          .toIso8601String(),
      'epubCfi': epubCfi,
      'totalPages': totalPages,
    };
  }

  /// 從 JSON 創建
  ///
  /// 用於調試或其他反序列化需求
  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      bookId: json['bookId'] as String,
      currentPage: json['currentPage'] as int,
      bookmarkedPages: (json['bookmarkedPages'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      lastReadTimeMillis: json['lastReadTime'] != null
          ? DateTime.parse(json['lastReadTime'] as String)
              .millisecondsSinceEpoch
          : DateTime.now().millisecondsSinceEpoch,
      epubCfi: json['epubCfi'] as String?,
      totalPages: json['totalPages'] as int?,
    );
  }

  /// 創建副本
  ReadingProgressModel copyWith({
    String? bookId,
    int? currentPage,
    List<int>? bookmarkedPages,
    int? lastReadTimeMillis,
    String? epubCfi,
    int? totalPages,
  }) {
    return ReadingProgressModel(
      bookId: bookId ?? this.bookId,
      currentPage: currentPage ?? this.currentPage,
      bookmarkedPages: bookmarkedPages ?? this.bookmarkedPages,
      lastReadTimeMillis: lastReadTimeMillis ?? this.lastReadTimeMillis,
      epubCfi: epubCfi ?? this.epubCfi,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  String toString() {
    return 'ReadingProgressModel('
        'bookId: $bookId, '
        'currentPage: $currentPage, '
        'totalPages: $totalPages, '
        'bookmarks: ${bookmarkedPages.length}, '
        'lastRead: ${DateTime.fromMillisecondsSinceEpoch(lastReadTimeMillis)}'
        ')';
  }
}
