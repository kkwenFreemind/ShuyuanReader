import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuyuan_reader/core/errors/exceptions.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';
import 'package:shuyuan_reader/domain/repositories/book_repository.dart';
import 'package:shuyuan_reader/domain/usecases/get_books_usecase.dart';

import 'get_books_usecase_test.mocks.dart';

@GenerateMocks([BookRepository])
void main() {
  late GetBooksUseCase useCase;
  late MockBookRepository mockRepository;

  setUp(() {
    mockRepository = MockBookRepository();
    useCase = GetBooksUseCase(mockRepository);
  });

  group('GetBooksUseCase', () {
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

    test('should delegate to repository with forceRefresh=false by default',
        () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: false))
          .thenAnswer((_) async => tBooks);

      // Act
      await useCase.call();

      // Assert
      verify(mockRepository.getBooks(forceRefresh: false)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should delegate to repository with forceRefresh=true when specified',
        () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act
      await useCase.call(forceRefresh: true);

      // Assert
      verify(mockRepository.getBooks(forceRefresh: true)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return list of books when repository succeeds', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: false))
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
      when(mockRepository.getBooks(forceRefresh: false))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate NetworkException when repository throws it',
        () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: false))
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
      when(mockRepository.getBooks(forceRefresh: false))
          .thenThrow(ServerException('Server error', 500));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<ServerException>()),
      );
    });

    test('should propagate CacheException when repository throws it', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: false))
          .thenThrow(CacheException('Cache error'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<CacheException>()),
      );
    });

    test('should work with force refresh enabled', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act
      final result = await useCase.call(forceRefresh: true);

      // Assert
      expect(result, equals(tBooks));
      verify(mockRepository.getBooks(forceRefresh: true)).called(1);
    });

    test('should handle network error with force refresh', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: true))
          .thenThrow(NetworkException('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(forceRefresh: true),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should preserve book data integrity through repository', () async {
      // Arrange
      final bookWithAllFields = Book(
        id: '999',
        title: 'Complete Book',
        author: 'Complete Author',
        coverUrl: 'https://example.com/cover999.jpg',
        epubUrl: 'https://example.com/book999.epub',
        description: 'Complete description with all fields',
        language: 'zh',
        fileSize: 99999,
        downloadedAt: DateTime(2024, 1, 15, 10, 30),
        localPath: '/storage/emulated/0/books/book999.epub',
      );

      when(mockRepository.getBooks(forceRefresh: false))
          .thenAnswer((_) async => [bookWithAllFields]);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.length, equals(1));
      final book = result[0];
      expect(book.id, equals('999'));
      expect(book.title, equals('Complete Book'));
      expect(book.author, equals('Complete Author'));
      expect(book.coverUrl, equals('https://example.com/cover999.jpg'));
      expect(book.epubUrl, equals('https://example.com/book999.epub'));
      expect(book.description, equals('Complete description with all fields'));
      expect(book.language, equals('zh'));
      expect(book.fileSize, equals(99999));
      expect(book.downloadedAt, equals(DateTime(2024, 1, 15, 10, 30)));
      expect(book.localPath, equals('/storage/emulated/0/books/book999.epub'));
      expect(book.isDownloaded, isTrue);
    });

    test('should handle multiple rapid calls independently', () async {
      // Arrange
      when(mockRepository.getBooks(forceRefresh: false))
          .thenAnswer((_) async => tBooks);

      // Act
      final result1 = await useCase.call();
      final result2 = await useCase.call();
      final result3 = await useCase.call();

      // Assert
      expect(result1, equals(tBooks));
      expect(result2, equals(tBooks));
      expect(result3, equals(tBooks));
      verify(mockRepository.getBooks(forceRefresh: false)).called(3);
    });
  });
}
