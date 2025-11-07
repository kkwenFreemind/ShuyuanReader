import 'package:hive/hive.dart';
import '../models/book_model.dart';

/// Local datasource for book caching using Hive.
/// 
/// This datasource provides local storage capabilities for books list,
/// including caching mechanisms with last update time tracking.
/// 
/// Uses two Hive boxes:
/// - `books`: Stores BookModel objects with book.id as key
/// - `metadata`: Stores cache metadata like last update time
/// 
/// Example usage:
/// ```dart
/// final bookBox = Hive.box<BookModel>('books');
/// final metaBox = Hive.box('metadata');
/// final datasource = BookLocalDataSource(bookBox, metaBox);
/// 
/// // Cache books
/// await datasource.cacheBooks(bookList);
/// 
/// // Retrieve cached books
/// final cachedBooks = await datasource.getCachedBooks();
/// 
/// // Check last update time
/// final lastUpdate = await datasource.getLastUpdateTime();
/// ```
class BookLocalDataSource {
  /// Hive box for storing BookModel objects
  final Box<BookModel> _bookBox;
  
  /// Hive box for storing metadata (cache timestamps, etc.)
  final Box<dynamic> _metaBox;
  
  /// Key for storing last update timestamp in metadata box
  static const String _lastUpdateKey = 'books_last_update';
  
  /// Creates a BookLocalDataSource with required Hive boxes.
  /// 
  /// Parameters:
  /// - [bookBox]: Hive box for BookModel storage
  /// - [metaBox]: Hive box for metadata storage
  /// 
  /// Both boxes must be already opened before creating this datasource.
  BookLocalDataSource(this._bookBox, this._metaBox);
  
  /// Retrieves all cached books from local storage.
  /// 
  /// Returns a list of all BookModel objects stored in the books box.
  /// Returns an empty list if no books are cached.
  /// 
  /// Example:
  /// ```dart
  /// final books = await datasource.getCachedBooks();
  /// print('Found ${books.length} cached books');
  /// ```
  Future<List<BookModel>> getCachedBooks() async {
    return _bookBox.values.toList();
  }
  
  /// Caches a list of books to local storage.
  /// 
  /// This method:
  /// 1. Clears all existing cached books
  /// 2. Stores each book using book.id as the key
  /// 3. Automatically sets the last update time to current time
  /// 
  /// Parameters:
  /// - [books]: List of BookModel objects to cache
  /// 
  /// Example:
  /// ```dart
  /// await datasource.cacheBooks(fetchedBooks);
  /// print('Cached ${fetchedBooks.length} books');
  /// ```
  Future<void> cacheBooks(List<BookModel> books) async {
    // Clear existing cache
    await _bookBox.clear();
    
    // Store each book with its id as key
    for (var book in books) {
      await _bookBox.put(book.id, book);
    }
    
    // Update last update timestamp
    await setLastUpdateTime(DateTime.now());
  }
  
  /// Retrieves the timestamp of the last cache update.
  /// 
  /// Returns:
  /// - [DateTime] object if timestamp exists in metadata
  /// - `null` if no timestamp is stored (cache never updated)
  /// 
  /// Example:
  /// ```dart
  /// final lastUpdate = await datasource.getLastUpdateTime();
  /// if (lastUpdate == null) {
  ///   print('Cache is empty or never updated');
  /// } else {
  ///   final age = DateTime.now().difference(lastUpdate);
  ///   print('Cache is ${age.inHours} hours old');
  /// }
  /// ```
  Future<DateTime?> getLastUpdateTime() async {
    final timestamp = _metaBox.get(_lastUpdateKey) as String?;
    if (timestamp == null) {
      return null;
    }
    
    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      // If parsing fails, return null (invalid timestamp)
      return null;
    }
  }
  
  /// Sets the timestamp of the last cache update.
  /// 
  /// Stores the timestamp as ISO8601 string format in metadata box.
  /// This method is automatically called by [cacheBooks].
  /// 
  /// Parameters:
  /// - [time]: DateTime object to store as last update time
  /// 
  /// Example:
  /// ```dart
  /// await datasource.setLastUpdateTime(DateTime.now());
  /// ```
  Future<void> setLastUpdateTime(DateTime time) async {
    await _metaBox.put(_lastUpdateKey, time.toIso8601String());
  }
  
  /// Clears all cached data.
  /// 
  /// This method:
  /// 1. Clears all books from the books box
  /// 2. Clears all metadata including last update timestamp
  /// 
  /// Use this when:
  /// - User logs out
  /// - Force refresh is needed
  /// - Cache corruption is detected
  /// 
  /// Example:
  /// ```dart
  /// await datasource.clearCache();
  /// print('All cache cleared');
  /// ```
  Future<void> clearCache() async {
    await _bookBox.clear();
    await _metaBox.clear();
  }
}
