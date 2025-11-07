import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuyuan_reader/core/errors/exceptions.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';
import 'package:shuyuan_reader/domain/repositories/book_repository.dart';
import 'package:shuyuan_reader/domain/usecases/get_book_by_id_usecase.dart';

import 'get_book_by_id_usecase_test.mocks.dart';

@GenerateMocks([BookRepository])
void main() {
  late GetBookByIdUseCase useCase;
  late MockBookRepository mockRepository;

  setUp(() {
    mockRepository = MockBookRepository();
    useCase = GetBookByIdUseCase(mockRepository);
  });

  group('GetBookByIdUseCase', () {
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

    test('should delegate to repository with correct id', () async {
      // Arrange
      when(mockRepository.getBookById('1')).thenAnswer((_) async => tBook1);

      // Act
      await useCase.call('1');

      // Assert
      verify(mockRepository.getBookById('1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return book when found in cache', () async {
      // Arrange
      when(mockRepository.getBookById('1')).thenAnswer((_) async => tBook1);

      // Act
      final result = await useCase.call('1');

      // Assert
      expect(result, equals(tBook1));
      expect(result?.id, equals('1'));
      expect(result?.title, equals('Test Book 1'));
    });

    test('should return null when book not found', () async {
      // Arrange
      when(mockRepository.getBookById('999')).thenAnswer((_) async => null);

      // Act
      final result = await useCase.call('999');

      // Assert
      expect(result, isNull);
      verify(mockRepository.getBookById('999')).called(1);
    });

    test('should find different books by their ids', () async {
      // Arrange
      when(mockRepository.getBookById('1')).thenAnswer((_) async => tBook1);
      when(mockRepository.getBookById('2')).thenAnswer((_) async => tBook2);

      // Act
      final result1 = await useCase.call('1');
      final result2 = await useCase.call('2');

      // Assert
      expect(result1?.id, equals('1'));
      expect(result2?.id, equals('2'));
      expect(result1?.title, equals('Test Book 1'));
      expect(result2?.title, equals('Test Book 2'));
    });

    test('should propagate NetworkException when repository throws it',
        () async {
      // Arrange
      when(mockRepository.getBookById('1'))
          .thenThrow(NetworkException('No internet connection'));

      // Act & Assert
      expect(
        () => useCase.call('1'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should propagate ServerException when repository throws it',
        () async {
      // Arrange
      when(mockRepository.getBookById('1'))
          .thenThrow(ServerException('Server error', 500));

      // Act & Assert
      expect(
        () => useCase.call('1'),
        throwsA(isA<ServerException>()),
      );
    });

    test('should handle empty id string', () async {
      // Arrange
      when(mockRepository.getBookById('')).thenAnswer((_) async => null);

      // Act
      final result = await useCase.call('');

      // Assert
      expect(result, isNull);
      verify(mockRepository.getBookById('')).called(1);
    });

    test('should preserve complete book data when found', () async {
      // Arrange
      final completeBook = Book(
        id: '777',
        title: 'Complete Book',
        author: 'Complete Author',
        coverUrl: 'https://example.com/cover777.jpg',
        epubUrl: 'https://example.com/book777.epub',
        description: 'Complete book with all fields',
        language: 'zh',
        fileSize: 77777,
        downloadedAt: DateTime(2024, 2, 20, 15, 45),
        localPath: '/storage/emulated/0/books/book777.epub',
      );

      when(mockRepository.getBookById('777'))
          .thenAnswer((_) async => completeBook);

      // Act
      final result = await useCase.call('777');

      // Assert
      expect(result, isNotNull);
      expect(result?.id, equals('777'));
      expect(result?.title, equals('Complete Book'));
      expect(result?.author, equals('Complete Author'));
      expect(result?.coverUrl, equals('https://example.com/cover777.jpg'));
      expect(result?.epubUrl, equals('https://example.com/book777.epub'));
      expect(
          result?.description, equals('Complete book with all fields'));
      expect(result?.language, equals('zh'));
      expect(result?.fileSize, equals(77777));
      expect(result?.downloadedAt, equals(DateTime(2024, 2, 20, 15, 45)));
      expect(
          result?.localPath, equals('/storage/emulated/0/books/book777.epub'));
      expect(result?.isDownloaded, isTrue);
    });

    test('should handle multiple calls for same id', () async {
      // Arrange
      when(mockRepository.getBookById('1')).thenAnswer((_) async => tBook1);

      // Act
      final result1 = await useCase.call('1');
      final result2 = await useCase.call('1');
      final result3 = await useCase.call('1');

      // Assert
      expect(result1, equals(tBook1));
      expect(result2, equals(tBook1));
      expect(result3, equals(tBook1));
      verify(mockRepository.getBookById('1')).called(3);
    });

    test('should handle special characters in id', () async {
      // Arrange
      const specialId = 'book-123_特殊字符';
      final specialBook = Book(
        id: specialId,
        title: 'Special ID Book',
        author: 'Author',
        coverUrl: 'https://example.com/cover.jpg',
        epubUrl: 'https://example.com/book.epub',
        description: 'Book with special id',
        language: 'zh',
        fileSize: 1024,
      );

      when(mockRepository.getBookById(specialId))
          .thenAnswer((_) async => specialBook);

      // Act
      final result = await useCase.call(specialId);

      // Assert
      expect(result, isNotNull);
      expect(result?.id, equals(specialId));
      verify(mockRepository.getBookById(specialId)).called(1);
    });

    test('should handle very long id strings', () async {
      // Arrange
      final longId = 'id_${'a' * 1000}';
      when(mockRepository.getBookById(longId)).thenAnswer((_) async => null);

      // Act
      final result = await useCase.call(longId);

      // Assert
      expect(result, isNull);
      verify(mockRepository.getBookById(longId)).called(1);
    });

    test('should return correct book when multiple books exist', () async {
      // Arrange - Simulate repository with multiple books
      when(mockRepository.getBookById('2')).thenAnswer((_) async => tBook2);

      // Act
      final result = await useCase.call('2');

      // Assert
      expect(result, equals(tBook2));
      expect(result?.id, equals('2'));
      expect(result?.title, equals('Test Book 2'));
      verify(mockRepository.getBookById('2')).called(1);
    });

    test('should handle switching between found and not found', () async {
      // Arrange
      when(mockRepository.getBookById('1')).thenAnswer((_) async => tBook1);
      when(mockRepository.getBookById('999')).thenAnswer((_) async => null);

      // Act
      final result1 = await useCase.call('1');
      final result2 = await useCase.call('999');
      final result3 = await useCase.call('1');

      // Assert
      expect(result1, equals(tBook1));
      expect(result2, isNull);
      expect(result3, equals(tBook1));
    });
  });
}
