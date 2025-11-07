import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuyuan_reader/core/errors/exceptions.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';
import 'package:shuyuan_reader/domain/repositories/book_repository.dart';
import 'package:shuyuan_reader/domain/usecases/refresh_books_usecase.dart';

import 'refresh_books_usecase_test.mocks.dart';

@GenerateMocks([BookRepository])
void main() {
  late RefreshBooksUseCase useCase;
  late MockBookRepository mockRepository;

  setUp(() {
    mockRepository = MockBookRepository();
    useCase = RefreshBooksUseCase(mockRepository);
  });

  group('RefreshBooksUseCase', () {
    final tBook1 = Book(
      id: '1',
      title: 'Test Book 1',
      author: 'Author 1',
      coverUrl: 'https://example.com/cover1.jpg',
      epubUrl: 'https://example.com/book1.epub',
      description: 'Test description 1',
      language: 'zh',
      fileSize: 1024,
    );

    final tBook2 = Book(
      id: '2',
      title: 'Test Book 2',
      author: 'Author 2',
      coverUrl: 'https://example.com/cover2.jpg',
      epubUrl: 'https://example.com/book2.epub',
      description: 'Test description 2',
      language: 'zh',
      fileSize: 2048,
    );

    final tBooks = [tBook1, tBook2];

    test('should always call repository with forceRefresh=true', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act
      await useCase.call();

      // Assert
      verify(mockRepository.getBooks(forceRefresh: true)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return list of books when refresh succeeds', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, equals(tBooks));
      expect(result.length, equals(2));
      expect(result[0].id, equals('1'));
      expect(result[1].id, equals('2'));
    });

    test('should return empty list when repository returns empty list',
        () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate NetworkException when repository throws it',
        () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenThrow(NetworkException('No internet connection'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should propagate ServerException when repository throws it',
        () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenThrow(ServerException('Server error', 500));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<ServerException>()),
      );
    });

    test('should propagate ParseException when repository throws it', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenThrow(ParseException('Invalid JSON'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<ParseException>()),
      );
    });

    test('should NOT fall back to cache on network error', () async {
      // Arrange - This simulates network error with no cache fallback
      when(mockRepository.getBooks(forceRefresh: true))
          .thenThrow(NetworkException('No internet'));

      // Act & Assert - Should throw, not return cached data
      expect(
        () => useCase.call(),
        throwsA(isA<NetworkException>()),
      );

      // Verify only forceRefresh=true was called (no cache fallback)
      verify(mockRepository.getBooks(forceRefresh: true)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should preserve book data integrity through repository', () async {
      // Arrange
      final freshBook = Book(
        id: '888',
        title: 'Fresh Book',
        author: 'Fresh Author',
        coverUrl: 'https://example.com/cover888.jpg',
        epubUrl: 'https://example.com/book888.epub',
        description: 'Freshly fetched book',
        language: 'zh',
        fileSize: 88888,
        downloadedAt: null,
        localPath: null,
      );

      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => [freshBook]);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.length, equals(1));
      final book = result[0];
      expect(book.id, equals('888'));
      expect(book.title, equals('Fresh Book'));
      expect(book.author, equals('Fresh Author'));
      expect(book.coverUrl, equals('https://example.com/cover888.jpg'));
      expect(book.epubUrl, equals('https://example.com/book888.epub'));
      expect(book.description, equals('Freshly fetched book'));
      expect(book.language, equals('zh'));
      expect(book.fileSize, equals(88888));
      expect(book.downloadedAt, isNull);
      expect(book.localPath, isNull);
      expect(book.isDownloaded, isFalse);
    });

    test('should handle multiple rapid refresh calls', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act - Simulate user pulling to refresh multiple times rapidly
      final result1 = await useCase.call();
      final result2 = await useCase.call();
      final result3 = await useCase.call();

      // Assert
      expect(result1, equals(tBooks));
      expect(result2, equals(tBooks));
      expect(result3, equals(tBooks));
      verify(mockRepository.getBooks(forceRefresh: true)).called(3);
    });

    test('should handle server error differently from network error', () async {
      // Arrange - Server returns 500
      when(mockRepository.getBooks(forceRefresh: true))
          .thenThrow(ServerException('Internal server error', 500));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<ServerException>()),
      );
      verify(mockRepository.getBooks(forceRefresh: true)).called(1);
    });

    test('should handle different network scenarios', () async {
      // Arrange - Different network errors
      final scenarios = [
        NetworkException('No internet connection'),
        NetworkException('Timeout'),
        NetworkException('Connection refused'),
      ];

      for (final exception in scenarios) {
        // Arrange
        when(mockRepository.getBooks(forceRefresh: true))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsA(isA<NetworkException>()),
        );
      }

      verify(mockRepository.getBooks(forceRefresh: true)).called(3);
    });

    test('should work correctly after previous error', () async {
      // Arrange - First call fails, second succeeds
      when(mockRepository.getBooks(forceRefresh: true))
          .thenThrow(NetworkException('Network error'));

      // Act & Assert - First call fails
      expect(
        () => useCase.call(),
        throwsA(isA<NetworkException>()),
      );

      // Arrange - Now it succeeds
      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act - Second call should succeed
      final result = await useCase.call();

      // Assert
      expect(result, equals(tBooks));
      verify(mockRepository.getBooks(forceRefresh: true)).called(2);
    });
  });
}
