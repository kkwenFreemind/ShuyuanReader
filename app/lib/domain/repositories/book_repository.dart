import '../entities/book.dart';

/// Repository interface for book-related operations.
/// 
/// This interface defines the contract for accessing book data,
/// abstracting away the details of data sources (remote API, local cache, etc.).
/// 
/// Implementations should handle:
/// - Fetching books from remote source
/// - Caching books locally
/// - Smart cache refresh strategies
/// - Error handling and fallback to cache
abstract class BookRepository {
  /// Retrieves the list of all books.
  /// 
  /// By default, uses cached data if available and not expired.
  /// Set [forceRefresh] to true to bypass cache and fetch from remote source.
  /// 
  /// The method implements a smart caching strategy:
  /// - If cache is older than 7 days, automatically refreshes from remote
  /// - If network fails, falls back to cached data
  /// - If [forceRefresh] is true, always fetches from remote
  /// 
  /// Parameters:
  /// - [forceRefresh]: If true, bypasses cache and fetches fresh data
  /// 
  /// Returns:
  /// - List of Book entities
  /// 
  /// Throws:
  /// - [NetworkException] if network fails and no cached data is available
  /// - [ServerException] if server returns an error
  /// - [CacheException] if cache operation fails
  Future<List<Book>> getBooks({bool forceRefresh = false});

  /// Retrieves a single book by its ID.
  /// 
  /// First checks the cache, if not found, attempts to fetch all books
  /// and search for the requested book.
  /// 
  /// Parameters:
  /// - [id]: The unique identifier of the book
  /// 
  /// Returns:
  /// - The Book entity if found
  /// - null if book with given id doesn't exist
  /// 
  /// Throws:
  /// - [NetworkException] if network fails and book not in cache
  /// - [ServerException] if server returns an error
  Future<Book?> getBookById(String id);

  /// Manually saves/updates books in the local cache.
  /// 
  /// This can be used to:
  /// - Manually update cached data
  /// - Persist downloaded book information
  /// - Update book metadata (e.g., download status)
  /// 
  /// Parameters:
  /// - [books]: List of books to save to cache
  /// 
  /// Throws:
  /// - [CacheException] if cache operation fails
  Future<void> saveBooks(List<Book> books);

  /// Clears all cached book data.
  /// 
  /// Use this when:
  /// - User logs out
  /// - App needs to free up storage
  /// - Cache corruption is detected
  /// 
  /// Throws:
  /// - [CacheException] if cache operation fails
  Future<void> clearCache();

  /// Updates a single book in the local cache.
  /// 
  /// This method is useful for updating book metadata such as:
  /// - Download status (downloading, downloaded, failed)
  /// - Download progress (0.0 - 1.0)
  /// - Local file path after download
  /// 
  /// Parameters:
  /// - [book]: The Book entity to update
  /// 
  /// Throws:
  /// - [CacheException] if the update operation fails
  Future<void> updateBook(Book book);

  /// Checks if the cache needs to be refreshed.
  /// 
  /// Returns true if:
  /// - No cached data exists
  /// - Cache is older than 7 days
  /// 
  /// Returns:
  /// - true if cache should be refreshed
  /// - false if cache is still valid
  Future<bool> shouldRefresh();
}
