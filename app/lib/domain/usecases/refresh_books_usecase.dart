import 'package:flutter/foundation.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for refreshing books from the remote source.
/// 
/// This use case forces a refresh of book data, bypassing any cache.
/// It's typically used when:
/// - User explicitly requests a refresh (pull-to-refresh)
/// - App needs to ensure latest data is displayed
/// - Cache might be stale or corrupted
/// 
/// Example usage:
/// ```dart
/// final useCase = RefreshBooksUseCase(repository);
/// 
/// // Always fetches fresh data from remote
/// final freshBooks = await useCase();
/// ```
class RefreshBooksUseCase {
  /// Repository for accessing book data
  final BookRepository _repository;

  /// Creates a RefreshBooksUseCase with required repository.
  /// 
  /// Parameters:
  /// - [repository]: The repository to fetch books from
  RefreshBooksUseCase(this._repository);

  /// Executes the use case to refresh books from remote source.
  /// 
  /// This method always bypasses cache and fetches fresh data from the
  /// remote source. The fetched data will automatically update the cache.
  /// 
  /// Returns:
  /// - List of Book entities with fresh data
  /// 
  /// Throws:
  /// - [NetworkException] if network connection fails
  /// - [ServerException] if server returns an error
  /// - [ParseException] if response data is invalid
  /// 
  /// Note: Unlike GetBooksUseCase, this method does NOT fall back to cache
  /// on error, as the intent is to get fresh data. If refresh fails,
  /// the caller should handle the error appropriately (e.g., show error
  /// message and keep displaying old cached data).
  Future<List<Book>> call() async {
    debugPrint('🔄 [RefreshBooksUseCase] Refreshing books list from remote');

    try {
      // Force refresh from remote source
      final books = await _repository.getBooks(forceRefresh: true);

      debugPrint(
        '✅ [RefreshBooksUseCase] Successfully refreshed ${books.length} books',
      );

      return books;
    } catch (e) {
      debugPrint('❌ [RefreshBooksUseCase] Failed to refresh books: $e');
      rethrow;
    }
  }
}
