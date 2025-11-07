import 'package:hive/hive.dart';

part 'book_model.g.dart';

/// BookModel - Data layer model for book entities
/// 
/// Supports both Hive storage and JSON serialization for network requests.
/// This model is used in the data layer and will be converted to domain entities.
@HiveType(typeId: 1)
class BookModel extends HiveObject {
  /// Unique identifier for the book
  @HiveField(0)
  final String id;

  /// Book title
  @HiveField(1)
  final String title;

  /// Book author
  @HiveField(2)
  final String author;

  /// URL to the book cover image
  @HiveField(3)
  final String coverUrl;

  /// URL to the EPUB file
  @HiveField(4)
  final String epubUrl;

  /// Book description
  @HiveField(5)
  final String description;

  /// Language code (e.g., 'zh-TW', 'en-US')
  @HiveField(6)
  final String language;

  /// File size in bytes
  @HiveField(7)
  final int fileSize;

  /// Timestamp when the book was downloaded (nullable)
  @HiveField(8)
  final DateTime? downloadedAt;

  /// Local file path if downloaded (nullable)
  @HiveField(9)
  final String? localPath;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.epubUrl,
    required this.description,
    required this.language,
    required this.fileSize,
    this.downloadedAt,
    this.localPath,
  });

  /// Create BookModel from JSON
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: (json['author'] as String?) ?? '未知作者',
      // Handle both snake_case and camelCase for API compatibility
      coverUrl: (json['coverUrl'] ?? json['cover_url']) as String? ?? '',
      epubUrl: (json['epubUrl'] ?? json['epub_url']) as String? ?? '',
      description: (json['description'] as String?) ?? '',
      language: json['language'] as String? ?? 'zh-TW',
      // Default file_size to 0 if not provided
      fileSize: (json['file_size'] as int?) ?? 0,
      downloadedAt: json['downloaded_at'] != null
          ? DateTime.parse(json['downloaded_at'] as String)
          : null,
      localPath: json['local_path'] as String?,
    );
  }

  /// Convert BookModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'epub_url': epubUrl,
      'description': description,
      'language': language,
      'file_size': fileSize,
      'downloaded_at': downloadedAt?.toIso8601String(),
      'local_path': localPath,
    };
  }

  /// Check if the book is downloaded locally
  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;

  /// Get formatted file size (KB or MB)
  String get fileSizeFormatted {
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Create a copy with updated fields
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    String? epubUrl,
    String? description,
    String? language,
    int? fileSize,
    DateTime? downloadedAt,
    String? localPath,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      epubUrl: epubUrl ?? this.epubUrl,
      description: description ?? this.description,
      language: language ?? this.language,
      fileSize: fileSize ?? this.fileSize,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      localPath: localPath ?? this.localPath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookModel &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.coverUrl == coverUrl &&
        other.epubUrl == epubUrl &&
        other.description == description &&
        other.language == language &&
        other.fileSize == fileSize &&
        other.downloadedAt == downloadedAt &&
        other.localPath == localPath;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        author.hashCode ^
        coverUrl.hashCode ^
        epubUrl.hashCode ^
        description.hashCode ^
        language.hashCode ^
        fileSize.hashCode ^
        downloadedAt.hashCode ^
        localPath.hashCode;
  }

  @override
  String toString() {
    return 'BookModel(id: $id, title: $title, author: $author, '
        'language: $language, fileSize: $fileSizeFormatted, '
        'isDownloaded: $isDownloaded)';
  }
}
