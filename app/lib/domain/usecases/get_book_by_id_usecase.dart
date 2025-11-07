import 'package:flutter/foundation.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Use case for retrieving a single book by its ID.
/// 
/// This use case encapsulates the business logic for fetching a specific book.
/// It first checks the cache, and if not found, fetches all books from remote.
/// 
/// Example usage:
/// ```dart
/// final useCase = GetBookByIdUseCase(repository);
/// 
/// // Get specific book
/// final book = await useCase('book-id-123');
/// if (book == null) {
///   print('Book not found');
/// }
/// ```
class GetBookByIdUseCase {
  /// Repository for accessing book data
  final BookRepository _repository;

  /// Creates a GetBookByIdUseCase with required repository.
  /// 
  /// Parameters:
  /// - [repository]: The repository to fetch books from
  GetBookByIdUseCase(this._repository);

  /// Executes the use case to retrieve a book by its ID.
  /// 
  /// Parameters:
  /// - [id]: The unique identifier of the book to retrieve
  /// 
  /// Returns:
  /// - The Book entity if found
  /// - null if book with given ID doesn't exist
  /// 
  /// Throws:
  /// - [NetworkException] if network fails and book not in cache
  /// - [ServerException] if server returns an error
  /// 
  /// Behavior:
  /// 1. Checks cache for book with given ID
  /// 2. If not found in cache, fetches all books from remote
  /// 3. Searches for the book in the fetched list
  /// 4. Returns the book if found, null otherwise
  Future<Book?> call(String id) async {
    debugPrint('🔍 [GetBookByIdUseCase] Fetching book with id: $id');

    try {
      final book = await _repository.getBookById(id);

      if (book != null) {
        debugPrint('✅ [GetBookByIdUseCase] Successfully found book: ${book.title}');
      } else {
        debugPrint('⚠️  [GetBookByIdUseCase] Book not found with id: $id');
      }

      return book;
    } catch (e) {
      debugPrint('❌ [GetBookByIdUseCase] Failed to fetch book: $e');
      rethrow;
    }
  }
}
