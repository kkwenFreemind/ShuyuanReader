import 'package:hive/hive.dart';

part 'download_status.g.dart';

/// Download status enum for tracking book download states
/// 
/// This enum represents the different states a book can be in during
/// the download lifecycle, from not downloaded to fully downloaded.
@HiveType(typeId: 2)
enum DownloadStatus {
  /// Book has not been downloaded yet
  @HiveField(0)
  notDownloaded,
  
  /// Book is currently being downloaded
  @HiveField(1)
  downloading,
  
  /// Download has been paused by the user
  @HiveField(2)
  paused,
  
  /// Book has been successfully downloaded
  @HiveField(3)
  downloaded,
  
  /// Download failed due to an error
  @HiveField(4)
  failed,
}
