import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_local_datasource.dart';
import '../datasources/book_remote_datasource.dart';
import '../mappers/book_mapper.dart';

/// Implementation of the BookRepository interface.
/// 
/// This class coordinates between remote and local data sources,
/// implementing smart caching strategies and error handling.
/// 
/// Caching Strategy:
/// - Cached data expires after 7 days
/// - On network error, falls back to cached data
/// - [forceRefresh] bypasses cache and fetches fresh data
/// 
/// Example usage:
/// ```dart
/// final repository = BookRepositoryImpl(
///   remoteDataSource: remoteDataSource,
///   localDataSource: localDataSource,
/// );
/// 
/// // Get books (uses cache if valid)
/// final books = await repository.getBooks();
/// 
/// // Force refresh from remote
/// final freshBooks = await repository.getBooks(forceRefresh: true);
/// 
/// // Get specific book
/// final book = await repository.getBookById('book-id-123');
/// ```
class BookRepositoryImpl implements BookRepository {
  /// Remote data source for fetching books from API
  final BookRemoteDataSource _remoteDataSource;
  
  /// Local data source for caching books
  final BookLocalDataSource _localDataSource;
  
  /// Cache expiration duration (7 days)
  static const Duration _cacheExpiration = Duration(days: 7);

  /// Creates a BookRepositoryImpl with required data sources.
  /// 
  /// Parameters:
  /// - [remoteDataSource]: Data source for fetching from remote API
  /// - [localDataSource]: Data source for local caching
  BookRepositoryImpl({
    required BookRemoteDataSource remoteDataSource,
    required BookLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<Book>> getBooks({bool forceRefresh = false}) async {
    try {
      // Check if we should refresh from remote
      if (forceRefresh || await shouldRefresh()) {
        debugPrint('[BookRepository] Fetching books from remote source');
        
        // Fetch from remote
        final remoteBooks = await _remoteDataSource.fetchBooks();
        debugPrint('[BookRepository] Fetched ${remoteBooks.length} books from remote');
        
        // Cache the fetched books
        await _localDataSource.cacheBooks(remoteBooks);
        debugPrint('[BookRepository] Cached ${remoteBooks.length} books locally');
        
        // Convert models to entities and return
        return remoteBooks.toEntities();
      } else {
        // Use cached data
        debugPrint('[BookRepository] Using cached books');
        final cachedBooks = await _localDataSource.getCachedBooks();
        debugPrint('[BookRepository] Loaded ${cachedBooks.length} books from cache');
        
        return cachedBooks.toEntities();
      }
    } on NetworkException catch (e) {
      debugPrint('[BookRepository] Network error: ${e.message}, attempting to use cache');
      
      // Network failed, try to use cached data
      final cachedBooks = await _localDataSource.getCachedBooks();
      
      if (cachedBooks.isNotEmpty) {
        debugPrint('[BookRepository] Fallback to ${cachedBooks.length} cached books');
        return cachedBooks.toEntities();
      }
      
      // No cached data available, rethrow the exception
      debugPrint('[BookRepository] No cached data available, rethrowing network exception');
      rethrow;
    } on ServerException catch (e) {
      debugPrint('[BookRepository] Server error: ${e.message}, attempting to use cache');
      
      // Server error, try to use cached data
      final cachedBooks = await _localDataSource.getCachedBooks();
      
      if (cachedBooks.isNotEmpty) {
        debugPrint('[BookRepository] Fallback to ${cachedBooks.length} cached books after server error');
        return cachedBooks.toEntities();
      }
      
      // No cached data available, rethrow the exception
      debugPrint('[BookRepository] No cached data available, rethrowing server exception');
      rethrow;
    } catch (e) {
      debugPrint('[BookRepository] Unexpected error: $e');
      
      // For any other error, try cached data as last resort
      try {
        final cachedBooks = await _localDataSource.getCachedBooks();
        if (cachedBooks.isNotEmpty) {
          debugPrint('[BookRepository] Fallback to ${cachedBooks.length} cached books after unexpected error');
          return cachedBooks.toEntities();
        }
      } catch (cacheError) {
        debugPrint('[BookRepository] Cache fallback also failed: $cacheError');
      }
      
      // If cache also fails, rethrow original error
      rethrow;
    }
  }

  @override
  Future<Book?> getBookById(String id) async {
    try {
      // First, try to get from cache
      final cachedBooks = await _localDataSource.getCachedBooks();
      final cachedBook = cachedBooks.where((book) => book.id == id).firstOrNull;
      
      if (cachedBook != null) {
        debugPrint('[BookRepository] Found book $id in cache');
        return cachedBook.toEntity();
      }
      
      // Not in cache, fetch all books (which will cache them)
      debugPrint('[BookRepository] Book $id not in cache, fetching all books');
      final allBooks = await getBooks();
      
      // Search for the book in the fetched list
      final book = allBooks.where((book) => book.id == id).firstOrNull;
      
      if (book != null) {
        debugPrint('[BookRepository] Found book $id after fetching');
        return book;
      }
      
      debugPrint('[BookRepository] Book $id not found');
      return null;
    } catch (e) {
      debugPrint('[BookRepository] Error getting book $id: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveBooks(List<Book> books) async {
    try {
      debugPrint('[BookRepository] Saving ${books.length} books to cache');
      
      // Convert entities to models and cache
      final models = books.toModels();
      await _localDataSource.cacheBooks(models);
      
      debugPrint('[BookRepository] Successfully saved ${books.length} books');
    } catch (e) {
      debugPrint('[BookRepository] Error saving books: $e');
      throw CacheException('Failed to save books: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      debugPrint('[BookRepository] Clearing cache');
      await _localDataSource.clearCache();
      debugPrint('[BookRepository] Cache cleared successfully');
    } catch (e) {
      debugPrint('[BookRepository] Error clearing cache: $e');
      throw CacheException('Failed to clear cache: $e');
    }
  }

  /// Updates a single book in the local cache.
  /// 
  /// This method is useful for updating book metadata such as:
  /// - Download status (downloading, downloaded, failed)
  /// - Download progress (0.0 - 1.0)
  /// - Local file path after download
  /// 
  /// The book must be a HiveObject that is already stored in the cache.
  /// If the book is not in cache, this method will fail.
  /// 
  /// Parameters:
  /// - [book]: The Book entity to update
  /// 
  /// Example usage:
  /// ```dart
  /// // Update book download status
  /// final updatedBook = book.copyWith(
  ///   downloadStatus: DownloadStatus.downloaded,
  ///   localPath: '/path/to/book.epub',
  /// );
  /// await repository.updateBook(updatedBook);
  /// ```
  /// 
  /// Throws:
  /// - [CacheException] if the update operation fails
  Future<void> updateBook(Book book) async {
    try {
      debugPrint('[BookRepository] Updating book ${book.id}');
      
      // Convert entity to model
      final model = book.toModel();
      
      // Use HiveObject's save method to update the book
      await model.save();
      
      debugPrint('[BookRepository] Successfully updated book ${book.id}');
    } catch (e) {
      debugPrint('[BookRepository] Error updating book ${book.id}: $e');
      throw CacheException('Failed to update book: $e');
    }
  }

  @override
  Future<bool> shouldRefresh() async {
    try {
      // Get last update time from cache
      final lastUpdate = await _localDataSource.getLastUpdateTime();
      
      // If no cached data, we should refresh
      if (lastUpdate == null) {
        debugPrint('[BookRepository] No cached data, should refresh');
        return true;
      }
      
      // Check if cache has expired (older than 7 days)
      final now = DateTime.now();
      final cacheAge = now.difference(lastUpdate);
      final isExpired = cacheAge >= _cacheExpiration;
      
      if (isExpired) {
        debugPrint('[BookRepository] Cache expired (${cacheAge.inDays} days old), should refresh');
      } else {
        debugPrint('[BookRepository] Cache still valid (${cacheAge.inDays} days old)');
      }
      
      return isExpired;
    } catch (e) {
      debugPrint('[BookRepository] Error checking cache expiration: $e');
      // If we can't determine, assume we should refresh
      return true;
    }
  }
}
