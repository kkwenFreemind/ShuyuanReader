import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shuyuan_reader/data/datasources/book_local_datasource.dart';
import 'package:shuyuan_reader/data/models/book_model.dart';

void main() {
  late Box<BookModel> bookBox;
  late Box<dynamic> metaBox;
  late BookLocalDataSource datasource;
  late Directory testDir;

  setUpAll(() async {
    // Create a temporary directory for Hive test data
    testDir = Directory.systemTemp.createTempSync('hive_test_');
    
    // Initialize Hive with test directory
    Hive.init(testDir.path);
    
    // Register BookModel adapter
    Hive.registerAdapter(BookModelAdapter());
  });

  setUp(() async {
    // Open boxes before each test
    bookBox = await Hive.openBox<BookModel>('test_books');
    metaBox = await Hive.openBox('test_metadata');
    
    // Create datasource instance
    datasource = BookLocalDataSource(bookBox, metaBox);
  });

  tearDown(() async {
    // Clear and close boxes after each test
    await bookBox.clear();
    await metaBox.clear();
    await bookBox.close();
    await metaBox.close();
  });

  tearDownAll(() async {
    // Delete Hive boxes and test directory
    await Hive.deleteBoxFromDisk('test_books');
    await Hive.deleteBoxFromDisk('test_metadata');
    await Hive.close();
    
    // Clean up test directory
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true);
    }
  });

  /// Helper function to create test BookModel
  BookModel createTestBook({
    required String id,
    String? title,
    String? author,
  }) {
    return BookModel(
      id: id,
      title: title ?? 'Test Book $id',
      author: author ?? 'Test Author',
      coverUrl: 'https://example.com/cover_$id.jpg',
      epubUrl: 'https://example.com/book_$id.epub',
      description: 'Test description for book $id',
      language: 'zh',
      fileSize: 1024000,
    );
  }

  group('getCachedBooks', () {
    test('should return empty list when no books are cached', () async {
      // Act
      final result = await datasource.getCachedBooks();

      // Assert
      expect(result, isEmpty);
    });

    test('should return all cached books', () async {
      // Arrange
      final book1 = createTestBook(id: 'book1');
      final book2 = createTestBook(id: 'book2');
      final book3 = createTestBook(id: 'book3');

      await bookBox.put(book1.id, book1);
      await bookBox.put(book2.id, book2);
      await bookBox.put(book3.id, book3);

      // Act
      final result = await datasource.getCachedBooks();

      // Assert
      expect(result.length, 3);
      expect(result, contains(book1));
      expect(result, contains(book2));
      expect(result, contains(book3));
    });

    test('should return books in order they were stored', () async {
      // Arrange
      final book1 = createTestBook(id: 'book1', title: 'First Book');
      final book2 = createTestBook(id: 'book2', title: 'Second Book');
      final book3 = createTestBook(id: 'book3', title: 'Third Book');

      await bookBox.put(book1.id, book1);
      await bookBox.put(book2.id, book2);
      await bookBox.put(book3.id, book3);

      // Act
      final result = await datasource.getCachedBooks();

      // Assert
      expect(result[0].id, 'book1');
      expect(result[1].id, 'book2');
      expect(result[2].id, 'book3');
    });
  });

  group('cacheBooks', () {
    test('should cache books successfully', () async {
      // Arrange
      final books = [
        createTestBook(id: 'book1'),
        createTestBook(id: 'book2'),
      ];

      // Act
      await datasource.cacheBooks(books);

      // Assert
      expect(bookBox.length, 2);
      expect(bookBox.get('book1'), isNotNull);
      expect(bookBox.get('book2'), isNotNull);
    });

    test('should clear existing cache before caching new books', () async {
      // Arrange
      final oldBooks = [
        createTestBook(id: 'old1'),
        createTestBook(id: 'old2'),
      ];
      await datasource.cacheBooks(oldBooks);

      final newBooks = [
        createTestBook(id: 'new1'),
        createTestBook(id: 'new2'),
      ];

      // Act
      await datasource.cacheBooks(newBooks);

      // Assert
      expect(bookBox.length, 2);
      expect(bookBox.get('old1'), isNull);
      expect(bookBox.get('old2'), isNull);
      expect(bookBox.get('new1'), isNotNull);
      expect(bookBox.get('new2'), isNotNull);
    });

    test('should use book.id as key for storage', () async {
      // Arrange
      final book = createTestBook(id: 'unique-book-id-123');

      // Act
      await datasource.cacheBooks([book]);

      // Assert
      final cachedBook = bookBox.get('unique-book-id-123');
      expect(cachedBook, isNotNull);
      expect(cachedBook!.id, 'unique-book-id-123');
    });

    test('should automatically set last update time', () async {
      // Arrange
      final books = [createTestBook(id: 'book1')];
      final beforeCache = DateTime.now();

      // Act
      await datasource.cacheBooks(books);
      final afterCache = DateTime.now();

      // Assert
      final lastUpdate = await datasource.getLastUpdateTime();
      expect(lastUpdate, isNotNull);
      expect(
        lastUpdate!.isAfter(beforeCache.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        lastUpdate.isBefore(afterCache.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('should handle empty list', () async {
      // Arrange
      final books = <BookModel>[];

      // Act
      await datasource.cacheBooks(books);

      // Assert
      expect(bookBox.length, 0);
      final lastUpdate = await datasource.getLastUpdateTime();
      expect(lastUpdate, isNotNull); // Timestamp should still be set
    });

    test('should handle large number of books', () async {
      // Arrange
      final books = List.generate(
        100,
        (index) => createTestBook(id: 'book_$index'),
      );

      // Act
      await datasource.cacheBooks(books);

      // Assert
      expect(bookBox.length, 100);
      final cachedBooks = await datasource.getCachedBooks();
      expect(cachedBooks.length, 100);
    });
  });

  group('getLastUpdateTime', () {
    test('should return null when no update time is set', () async {
      // Act
      final result = await datasource.getLastUpdateTime();

      // Assert
      expect(result, isNull);
    });

    test('should return correct timestamp after cacheBooks', () async {
      // Arrange
      final books = [createTestBook(id: 'book1')];
      final beforeCache = DateTime.now();

      // Act
      await datasource.cacheBooks(books);
      final lastUpdate = await datasource.getLastUpdateTime();
      final afterCache = DateTime.now();

      // Assert
      expect(lastUpdate, isNotNull);
      expect(lastUpdate!.isAfter(beforeCache.subtract(const Duration(seconds: 1))), isTrue);
      expect(lastUpdate.isBefore(afterCache.add(const Duration(seconds: 1))), isTrue);
    });

    test('should return correct timestamp after setLastUpdateTime', () async {
      // Arrange
      final testTime = DateTime(2024, 1, 1, 12, 0, 0);

      // Act
      await datasource.setLastUpdateTime(testTime);
      final result = await datasource.getLastUpdateTime();

      // Assert
      expect(result, isNotNull);
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 1);
      expect(result.hour, 12);
    });

    test('should return null when timestamp format is invalid', () async {
      // Arrange
      // Manually set an invalid timestamp
      await metaBox.put('books_last_update', 'invalid-date-format');

      // Act
      final result = await datasource.getLastUpdateTime();

      // Assert
      expect(result, isNull);
    });

    test('should parse ISO8601 timestamp correctly', () async {
      // Arrange
      final testTime = DateTime(2024, 11, 7, 15, 30, 45);
      await datasource.setLastUpdateTime(testTime);

      // Act
      final result = await datasource.getLastUpdateTime();

      // Assert
      expect(result, isNotNull);
      expect(result!.year, testTime.year);
      expect(result.month, testTime.month);
      expect(result.day, testTime.day);
      expect(result.hour, testTime.hour);
      expect(result.minute, testTime.minute);
      expect(result.second, testTime.second);
    });
  });

  group('setLastUpdateTime', () {
    test('should store timestamp successfully', () async {
      // Arrange
      final testTime = DateTime(2024, 11, 7, 10, 30, 0);

      // Act
      await datasource.setLastUpdateTime(testTime);

      // Assert
      final stored = metaBox.get('books_last_update');
      expect(stored, isNotNull);
      expect(stored, isA<String>());
    });

    test('should store timestamp in ISO8601 format', () async {
      // Arrange
      final testTime = DateTime(2024, 11, 7, 10, 30, 0);

      // Act
      await datasource.setLastUpdateTime(testTime);

      // Assert
      final stored = metaBox.get('books_last_update') as String;
      expect(stored, contains('2024-11-07'));
      expect(stored, contains('T')); // ISO8601 date-time separator
    });

    test('should overwrite existing timestamp', () async {
      // Arrange
      final firstTime = DateTime(2024, 1, 1);
      final secondTime = DateTime(2024, 11, 7);

      // Act
      await datasource.setLastUpdateTime(firstTime);
      await datasource.setLastUpdateTime(secondTime);

      // Assert
      final result = await datasource.getLastUpdateTime();
      expect(result!.year, 2024);
      expect(result.month, 11);
      expect(result.day, 7);
    });

    test('should handle current time', () async {
      // Arrange
      final now = DateTime.now();

      // Act
      await datasource.setLastUpdateTime(now);
      final result = await datasource.getLastUpdateTime();

      // Assert
      expect(result, isNotNull);
      expect(result!.year, now.year);
      expect(result.month, now.month);
      expect(result.day, now.day);
    });
  });

  group('clearCache', () {
    test('should clear all books from cache', () async {
      // Arrange
      final books = [
        createTestBook(id: 'book1'),
        createTestBook(id: 'book2'),
        createTestBook(id: 'book3'),
      ];
      await datasource.cacheBooks(books);

      // Act
      await datasource.clearCache();

      // Assert
      expect(bookBox.length, 0);
      final cachedBooks = await datasource.getCachedBooks();
      expect(cachedBooks, isEmpty);
    });

    test('should clear metadata including last update time', () async {
      // Arrange
      final books = [createTestBook(id: 'book1')];
      await datasource.cacheBooks(books);
      final lastUpdateBefore = await datasource.getLastUpdateTime();
      expect(lastUpdateBefore, isNotNull);

      // Act
      await datasource.clearCache();

      // Assert
      expect(metaBox.length, 0);
      final lastUpdateAfter = await datasource.getLastUpdateTime();
      expect(lastUpdateAfter, isNull);
    });

    test('should work when cache is already empty', () async {
      // Act & Assert (should not throw)
      await datasource.clearCache();
      expect(bookBox.length, 0);
      expect(metaBox.length, 0);
    });

    test('should allow caching after clearing', () async {
      // Arrange
      final firstBooks = [createTestBook(id: 'book1')];
      await datasource.cacheBooks(firstBooks);
      await datasource.clearCache();

      // Act
      final secondBooks = [createTestBook(id: 'book2')];
      await datasource.cacheBooks(secondBooks);

      // Assert
      expect(bookBox.length, 1);
      final cached = await datasource.getCachedBooks();
      expect(cached.length, 1);
      expect(cached[0].id, 'book2');
    });
  });

  group('integration scenarios', () {
    test('should handle complete cache refresh workflow', () async {
      // 1. Initial cache
      final initialBooks = [
        createTestBook(id: 'book1', title: 'Book 1'),
        createTestBook(id: 'book2', title: 'Book 2'),
      ];
      await datasource.cacheBooks(initialBooks);

      // 2. Verify cache
      var cached = await datasource.getCachedBooks();
      expect(cached.length, 2);

      // 3. Update cache with new data
      final updatedBooks = [
        createTestBook(id: 'book3', title: 'Book 3'),
        createTestBook(id: 'book4', title: 'Book 4'),
        createTestBook(id: 'book5', title: 'Book 5'),
      ];
      await datasource.cacheBooks(updatedBooks);

      // 4. Verify new cache
      cached = await datasource.getCachedBooks();
      expect(cached.length, 3);
      expect(cached.any((b) => b.id == 'book1'), isFalse);
      expect(cached.any((b) => b.id == 'book3'), isTrue);
    });

    test('should handle cache expiry check workflow', () async {
      // 1. Cache books with known timestamp
      final books = [createTestBook(id: 'book1')];
      final cacheTime = DateTime(2024, 11, 1, 10, 0, 0);
      await datasource.cacheBooks(books);
      await datasource.setLastUpdateTime(cacheTime);

      // 2. Check if cache is expired (older than 1 day)
      final lastUpdate = await datasource.getLastUpdateTime();
      final now = DateTime(2024, 11, 7, 10, 0, 0); // 6 days later
      final cacheAge = now.difference(lastUpdate!);
      final isExpired = cacheAge.inDays > 1;

      // Assert
      expect(isExpired, isTrue);
      expect(cacheAge.inDays, 6);
    });

    test('should handle book update by id', () async {
      // 1. Cache initial book
      final book1 = createTestBook(id: 'book1', title: 'Original Title');
      await datasource.cacheBooks([book1]);

      // 2. Update specific book
      final updatedBook = createTestBook(id: 'book1', title: 'Updated Title');
      await bookBox.put(updatedBook.id, updatedBook);

      // 3. Verify update
      final cached = await datasource.getCachedBooks();
      expect(cached.length, 1);
      expect(cached[0].title, 'Updated Title');
    });

    test('should maintain data integrity across operations', () async {
      // 1. Cache books
      final books = [
        createTestBook(id: 'book1', author: 'Author A'),
        createTestBook(id: 'book2', author: 'Author B'),
      ];
      await datasource.cacheBooks(books);

      // 2. Get cached books
      final cached = await datasource.getCachedBooks();

      // 3. Verify all fields are preserved
      final cachedBook1 = cached.firstWhere((b) => b.id == 'book1');
      expect(cachedBook1.id, 'book1');
      expect(cachedBook1.author, 'Author A');
      expect(cachedBook1.coverUrl, 'https://example.com/cover_book1.jpg');
      expect(cachedBook1.epubUrl, 'https://example.com/book_book1.epub');
      expect(cachedBook1.language, 'zh');
      expect(cachedBook1.fileSize, 1024000);
    });
  });
}
