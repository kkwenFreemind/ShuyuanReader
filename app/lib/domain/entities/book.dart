import 'package:equatable/equatable.dart';
import '../../data/models/download_status.dart';

/// Domain entity representing a book in the application.
/// 
/// This is a pure business object with no framework dependencies.
/// It represents the core concept of a book in the domain layer.
/// 
/// All properties are immutable to ensure data consistency.
class Book extends Equatable {
  /// Unique identifier for the book
  final String id;
  
  /// Title of the book
  final String title;
  
  /// Author of the book
  final String author;
  
  /// URL to the book's cover image
  final String coverUrl;
  
  /// URL to the book's EPUB file
  final String epubUrl;
  
  /// Description or summary of the book
  final String description;
  
  /// Language code (e.g., 'zh-TW', 'en')
  final String language;
  
  /// File size in bytes
  final int fileSize;
  
  /// Timestamp when the book was downloaded (null if not downloaded)
  final DateTime? downloadedAt;
  
  /// Local file path where the book is stored (null if not downloaded)
  final String? localPath;
  
  /// Download status tracking
  final DownloadStatus downloadStatus;
  
  /// Download progress (0.0 to 1.0)
  final double downloadProgress;

  const Book({
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
    this.downloadStatus = DownloadStatus.notDownloaded,
    this.downloadProgress = 0.0,
  });

  /// Returns true if the book has been downloaded to local storage
  bool get isDownloaded => downloadStatus == DownloadStatus.downloaded;
  
  /// Returns true if the book is currently downloading
  bool get isDownloading => downloadStatus == DownloadStatus.downloading;

  /// Returns a human-readable file size string
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Returns a short description (first 100 characters)
  String get shortDescription {
    if (description.length <= 100) {
      return description;
    }
    return '${description.substring(0, 97)}...';
  }

  /// Creates a copy of this book with some properties replaced
  Book copyWith({
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
    DownloadStatus? downloadStatus,
    double? downloadProgress,
  }) {
    return Book(
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
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        coverUrl,
        epubUrl,
        description,
        language,
        fileSize,
        downloadedAt,
        localPath,
        downloadStatus,
        downloadProgress,
      ];

  @override
  bool get stringify => true;
}
