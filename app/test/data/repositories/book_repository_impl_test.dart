import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuyuan_reader/core/errors/exceptions.dart';
import 'package:shuyuan_reader/data/datasources/book_local_datasource.dart';
import 'package:shuyuan_reader/data/datasources/book_remote_datasource.dart';
import 'package:shuyuan_reader/data/models/book_model.dart';
import 'package:shuyuan_reader/data/repositories/book_repository_impl.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';

import 'book_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BookRemoteDataSource>(),
  MockSpec<BookLocalDataSource>(),
])
void main() {
  late BookRepositoryImpl repository;
  late MockBookRemoteDataSource mockRemoteDataSource;
  late MockBookLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockBookRemoteDataSource();
    mockLocalDataSource = MockBookLocalDataSource();
    repository = BookRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  /// Helper function to create test BookModel
  BookModel createTestBookModel({
    required String id,
    String? title,
  }) {
    return BookModel(
      id: id,
      title: title ?? 'Test Book $id',
      author: 'Test Author',
      coverUrl: 'https://example.com/cover_$id.jpg',
      epubUrl: 'https://example.com/book_$id.epub',
      description: 'Test description for book $id',
      language: 'zh',
      fileSize: 1024000,
    );
  }

  group('getBooks', () {
    final testBooks = [
      createTestBookModel(id: 'book1'),
      createTestBookModel(id: 'book2'),
      createTestBookModel(id: 'book3'),
    ];

    test('should return books from remote when forceRefresh is true', () async {
      // Arrange
      when(mockRemoteDataSource.fetchBooks()).thenAnswer((_) async => testBooks);
      when(mockLocalDataSource.cacheBooks(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.getBooks(forceRefresh: true);

      // Assert
      expect(result, isA<List<Book>>());
      expect(result.length, 3);
      expect(result[0].id, 'book1');
      verify(mockRemoteDataSource.fetchBooks()).called(1);
      verify(mockLocalDataSource.cacheBooks(testBooks)).called(1);
    });

    test('should return books from remote when cache is expired', () async {
      // Arrange
      final oldDate = DateTime.now().subtract(const Duration(days: 8));
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => oldDate);
      when(mockRemoteDataSource.fetchBooks()).thenAnswer((_) async => testBooks);
      when(mockLocalDataSource.cacheBooks(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.getBooks();

      // Assert
      expect(result.length, 3);
      verify(mockLocalDataSource.getLastUpdateTime()).called(1);
      verify(mockRemoteDataSource.fetchBooks()).called(1);
      verify(mockLocalDataSource.cacheBooks(testBooks)).called(1);
    });

    test('should return books from cache when cache is valid', () async {
      // Arrange
      final recentDate = DateTime.now().subtract(const Duration(days: 3));
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => recentDate);
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => testBooks);

      // Act
      final result = await repository.getBooks();

      // Assert
      expect(result.length, 3);
      verify(mockLocalDataSource.getLastUpdateTime()).called(1);
      verify(mockLocalDataSource.getCachedBooks()).called(1);
      verifyNever(mockRemoteDataSource.fetchBooks());
    });

    test('should return cached books when remote fails with NetworkException', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenThrow(NetworkException('No connection'));
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => testBooks);

      // Act
      final result = await repository.getBooks();

      // Assert
      expect(result.length, 3);
      verify(mockRemoteDataSource.fetchBooks()).called(1);
      verify(mockLocalDataSource.getCachedBooks()).called(1);
    });

    test('should return cached books when remote fails with ServerException', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenThrow(ServerException('Server error', 500));
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => testBooks);

      // Act
      final result = await repository.getBooks();

      // Assert
      expect(result.length, 3);
      verify(mockRemoteDataSource.fetchBooks()).called(1);
      verify(mockLocalDataSource.getCachedBooks()).called(1);
    });

    test('should throw exception when remote fails and no cached data', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenThrow(NetworkException('No connection'));
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () => repository.getBooks(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should cache books after fetching from remote', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenAnswer((_) async => testBooks);
      when(mockLocalDataSource.cacheBooks(any)).thenAnswer((_) async => {});

      // Act
      await repository.getBooks();

      // Assert
      verify(mockLocalDataSource.cacheBooks(testBooks)).called(1);
    });

    test('should handle unexpected errors by falling back to cache', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenThrow(Exception('Unexpected error'));
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => testBooks);

      // Act
      final result = await repository.getBooks();

      // Assert
      expect(result.length, 3);
      verify(mockLocalDataSource.getCachedBooks()).called(1);
    });

    test('should rethrow unexpected error when cache also fails', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenThrow(Exception('Unexpected error'));
      when(mockLocalDataSource.getCachedBooks()).thenThrow(CacheException('Cache error'));

      // Act & Assert
      expect(
        () => repository.getBooks(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getBookById', () {
    final testBook = createTestBookModel(id: 'target-book');
    final otherBooks = [
      createTestBookModel(id: 'book1'),
      createTestBookModel(id: 'book2'),
    ];

    test('should return book from cache if found', () async {
      // Arrange
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => [testBook, ...otherBooks]);

      // Act
      final result = await repository.getBookById('target-book');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'target-book');
      verify(mockLocalDataSource.getCachedBooks()).called(1);
      verifyNever(mockRemoteDataSource.fetchBooks());
    });

    test('should fetch all books if not in cache', () async {
      // Arrange
      when(mockLocalDataSource.getCachedBooks())
          .thenAnswer((_) async => otherBooks);
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks())
          .thenAnswer((_) async => [testBook, ...otherBooks]);
      when(mockLocalDataSource.cacheBooks(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.getBookById('target-book');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'target-book');
      verify(mockLocalDataSource.getCachedBooks()).called(1);
      verify(mockRemoteDataSource.fetchBooks()).called(1);
    });

    test('should return null if book not found', () async {
      // Arrange
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => otherBooks);
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenAnswer((_) async => otherBooks);
      when(mockLocalDataSource.cacheBooks(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.getBookById('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('should rethrow exception on error', () async {
      // Arrange
      when(mockLocalDataSource.getCachedBooks()).thenThrow(CacheException('Cache error'));

      // Act & Assert
      expect(
        () => repository.getBookById('any-id'),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('saveBooks', () {
    test('should save books to cache successfully', () async {
      // Arrange
      final books = [
        const Book(
          id: 'book1',
          title: 'Book 1',
          author: 'Author 1',
          coverUrl: 'url1',
          epubUrl: 'epub1',
          description: 'desc1',
          language: 'zh',
          fileSize: 1000,
        ),
      ];
      when(mockLocalDataSource.cacheBooks(any)).thenAnswer((_) async => {});

      // Act
      await repository.saveBooks(books);

      // Assert
      verify(mockLocalDataSource.cacheBooks(any)).called(1);
    });

    test('should throw CacheException on error', () async {
      // Arrange
      final books = [
        const Book(
          id: 'book1',
          title: 'Book 1',
          author: 'Author 1',
          coverUrl: 'url1',
          epubUrl: 'epub1',
          description: 'desc1',
          language: 'zh',
          fileSize: 1000,
        ),
      ];
      when(mockLocalDataSource.cacheBooks(any)).thenThrow(Exception('Save error'));

      // Act & Assert
      expect(
        () => repository.saveBooks(books),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('clearCache', () {
    test('should clear cache successfully', () async {
      // Arrange
      when(mockLocalDataSource.clearCache()).thenAnswer((_) async => {});

      // Act
      await repository.clearCache();

      // Assert
      verify(mockLocalDataSource.clearCache()).called(1);
    });

    test('should throw CacheException on error', () async {
      // Arrange
      when(mockLocalDataSource.clearCache()).thenThrow(Exception('Clear error'));

      // Act & Assert
      expect(
        () => repository.clearCache(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('shouldRefresh', () {
    test('should return true when no cached data exists', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);

      // Act
      final result = await repository.shouldRefresh();

      // Assert
      expect(result, isTrue);
    });

    test('should return true when cache is older than 7 days', () async {
      // Arrange
      final oldDate = DateTime.now().subtract(const Duration(days: 8));
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => oldDate);

      // Act
      final result = await repository.shouldRefresh();

      // Assert
      expect(result, isTrue);
    });

    test('should return false when cache is less than 7 days old', () async {
      // Arrange
      final recentDate = DateTime.now().subtract(const Duration(days: 3));
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => recentDate);

      // Act
      final result = await repository.shouldRefresh();

      // Assert
      expect(result, isFalse);
    });

    test('should return true on exactly 7 days', () async {
      // Arrange
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => sevenDaysAgo);

      // Act
      final result = await repository.shouldRefresh();

      // Assert
      expect(result, isTrue);
    });

    test('should return true on error checking cache', () async {
      // Arrange
      when(mockLocalDataSource.getLastUpdateTime()).thenThrow(Exception('Error'));

      // Act
      final result = await repository.shouldRefresh();

      // Assert
      expect(result, isTrue);
    });
  });

  group('integration scenarios', () {
    test('should handle complete refresh cycle', () async {
      // Arrange
      final books = [createTestBookModel(id: 'book1')];
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenAnswer((_) async => books);
      when(mockLocalDataSource.cacheBooks(any)).thenAnswer((_) async => {});

      // Act
      final result = await repository.getBooks();

      // Assert
      expect(result.length, 1);
      verify(mockRemoteDataSource.fetchBooks()).called(1);
      verify(mockLocalDataSource.cacheBooks(books)).called(1);
    });

    test('should use cache on subsequent calls when valid', () async {
      // Arrange
      final books = [createTestBookModel(id: 'book1')];
      final recentDate = DateTime.now().subtract(const Duration(days: 1));
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => recentDate);
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => books);

      // Act - First call
      final result1 = await repository.getBooks();
      // Act - Second call
      final result2 = await repository.getBooks();

      // Assert
      expect(result1.length, 1);
      expect(result2.length, 1);
      verify(mockLocalDataSource.getCachedBooks()).called(2);
      verifyNever(mockRemoteDataSource.fetchBooks());
    });

    test('should gracefully degrade to cache on network failure', () async {
      // Arrange
      final cachedBooks = [createTestBookModel(id: 'cached-book')];
      when(mockLocalDataSource.getLastUpdateTime()).thenAnswer((_) async => null);
      when(mockRemoteDataSource.fetchBooks()).thenThrow(NetworkException('Network error'));
      when(mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => cachedBooks);

      // Act
      final result = await repository.getBooks();

      // Assert
      expect(result.length, 1);
      expect(result[0].id, 'cached-book');
      verify(mockRemoteDataSource.fetchBooks()).called(1);
      verify(mockLocalDataSource.getCachedBooks()).called(1);
    });
  });
}
