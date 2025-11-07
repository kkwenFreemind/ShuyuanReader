import 'package:flutter/foundation.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for retrieving books from the repository.
/// 
/// This use case encapsulates the business logic for fetching books,
/// implementing a smart caching strategy:
/// - By default, uses cached data if available and valid (< 7 days old)
/// - Set [forceRefresh] to true to bypass cache and fetch fresh data
/// - Automatically falls back to cache if network fails
/// 
/// Example usage:
/// ```dart
/// final useCase = GetBooksUseCase(repository);
/// 
/// // Get books (uses cache if valid)
/// final books = await useCase();
/// 
/// // Force refresh from remote
/// final freshBooks = await useCase(forceRefresh: true);
/// ```
class GetBooksUseCase {
  /// Repository for accessing book data
  final BookRepository _repository;

  /// Creates a GetBooksUseCase with required repository.
  /// 
  /// Parameters:
  /// - [repository]: The repository to fetch books from
  GetBooksUseCase(this._repository);

  /// Executes the use case to retrieve books.
  /// 
  /// Parameters:
  /// - [forceRefresh]: If true, bypasses cache and fetches from remote source.
  ///   Defaults to false (use cache if valid).
  /// 
  /// Returns:
  /// - List of Book entities
  /// 
  /// Throws:
  /// - [NetworkException] if network fails and no cached data available
  /// - [ServerException] if server returns an error and no cached data available
  /// - [CacheException] if cache operation fails
  /// 
  /// Behavior:
  /// 1. If [forceRefresh] is false, checks cache validity
  /// 2. If cache is valid (< 7 days old), returns cached books
  /// 3. If cache is invalid or [forceRefresh] is true, fetches from remote
  /// 4. On network error, falls back to cached data if available
  /// 5. Updates cache after successful remote fetch
  Future<List<Book>> call({bool forceRefresh = false}) async {
    debugPrint(
      '📚 [GetBooksUseCase] Fetching books list (forceRefresh: $forceRefresh)',
    );

    try {
      // Delegate to repository which handles caching strategy
      final books = await _repository.getBooks(forceRefresh: forceRefresh);

      debugPrint(
        '✅ [GetBooksUseCase] Successfully fetched ${books.length} books',
      );

      return books;
    } catch (e) {
      debugPrint('❌ [GetBooksUseCase] Failed to fetch books: $e');
      rethrow;
    }
  }
}
