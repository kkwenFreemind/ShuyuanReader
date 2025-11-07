import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shuyuan_reader/core/enums/loading_state.dart';
import 'package:shuyuan_reader/core/errors/exceptions.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';
import 'package:shuyuan_reader/domain/usecases/get_books_usecase.dart';
import 'package:shuyuan_reader/domain/usecases/refresh_books_usecase.dart';
import 'package:shuyuan_reader/domain/usecases/get_book_by_id_usecase.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/controllers/book_list_controller.dart';

import 'book_list_controller_test.mocks.dart';

@GenerateMocks([GetBooksUseCase, RefreshBooksUseCase, GetBookByIdUseCase])
void main() {
  late BookListController controller;
  late MockGetBooksUseCase mockGetBooksUseCase;
  late MockRefreshBooksUseCase mockRefreshBooksUseCase;
  late MockGetBookByIdUseCase mockGetBookByIdUseCase;

  setUp(() {
    // Initialize GetX for testing
    Get.testMode = true;

    mockGetBooksUseCase = MockGetBooksUseCase();
    mockRefreshBooksUseCase = MockRefreshBooksUseCase();
    mockGetBookByIdUseCase = MockGetBookByIdUseCase();

    controller = BookListController(
      getBooksUseCase: mockGetBooksUseCase,
      refreshBooksUseCase: mockRefreshBooksUseCase,
      getBookByIdUseCase: mockGetBookByIdUseCase,
    );
  });

  tearDown(() {
    controller.dispose();
    Get.reset();
  });

  group('BookListController - Initialization', () {
    test('should initialize with correct default values', () {
      // Assert
      expect(controller.books, isEmpty);
      expect(controller.loadingState.value, equals(LoadingState.loading));
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.isOffline.value, isFalse);
    });

    test('should call loadBooks on init', () async {
      // Arrange
      final tBooks = [
        Book(
          id: '1',
          title: 'Test Book',
          author: 'Test Author',
          coverUrl: 'https://example.com/cover.jpg',
          epubUrl: 'https://example.com/book.epub',
          description: 'Test description',
          language: 'zh',
          fileSize: 1024,
        ),
      ];

      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenAnswer((_) async => tBooks);

      // Act
      controller.onInit();
      await Future.delayed(Duration.zero); // Wait for async operations

      // Assert
      verify(mockGetBooksUseCase.call(forceRefresh: false)).called(1);
    });
  });

  group('BookListController - loadBooks', () {
    final tBook1 = Book(
      id: '1',
      title: 'Test Book 1',
      author: 'Author 1',
      coverUrl: 'https://example.com/cover1.jpg',
      epubUrl: 'https://example.com/book1.epub',
      description: 'Description 1',
      language: 'zh',
      fileSize: 1024,
    );

    final tBook2 = Book(
      id: '2',
      title: 'Test Book 2',
      author: 'Author 2',
      coverUrl: 'https://example.com/cover2.jpg',
      epubUrl: 'https://example.com/book2.epub',
      description: 'Description 2',
      language: 'zh',
      fileSize: 2048,
    );

    final tBooks = [tBook1, tBook2];

    test('should load books successfully', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenAnswer((_) async => tBooks);

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.books, equals(tBooks));
      expect(controller.loadingState.value, equals(LoadingState.success));
      expect(controller.isOffline.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      verify(mockGetBooksUseCase.call(forceRefresh: false)).called(1);
    });

    test('should set empty state when books list is empty', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenAnswer((_) async => []);

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.books, isEmpty);
      expect(controller.loadingState.value, equals(LoadingState.empty));
      expect(controller.isOffline.value, isFalse);
    });

    test('should handle network exception with cached data', () async {
      // Arrange - Network fails on first call, cache succeeds on fallback
      var callCount = 0;
      when(mockGetBooksUseCase.call(forceRefresh: false)).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw NetworkException('No internet connection');
        }
        return tBooks;
      });

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.books, equals(tBooks));
      expect(controller.loadingState.value, equals(LoadingState.success));
      expect(controller.isOffline.value, isTrue);
    });

    test('should handle network exception without cached data', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenThrow(NetworkException('No internet connection'));

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.loadingState.value, equals(LoadingState.error));
      expect(controller.errorMessage.value, contains('網絡連接失敗'));
      expect(controller.isOffline.value, isFalse);
    });

    test('should handle server exception', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenThrow(ServerException('Server error', 500));

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.loadingState.value, equals(LoadingState.error));
      expect(controller.errorMessage.value, contains('服務器暫時無法訪問'));
    });

    test('should handle cache exception', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenThrow(CacheException('Cache error'));

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.loadingState.value, equals(LoadingState.error));
      expect(controller.errorMessage.value, contains('數據加載失敗'));
      expect(controller.isOffline.value, isFalse);
    });

    test('should force refresh when forceRefresh is true', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act
      await controller.loadBooks(forceRefresh: true);

      // Assert
      expect(controller.books, equals(tBooks));
      expect(controller.loadingState.value, equals(LoadingState.success));
      verify(mockGetBooksUseCase.call(forceRefresh: true)).called(1);
    });

    test('should not set loading state when forceRefresh is true', () async {
      // Arrange
      controller.loadingState.value = LoadingState.success;
      when(mockGetBooksUseCase.call(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act
      await controller.loadBooks(forceRefresh: true);

      // Assert - should go directly to success without showing loading
      expect(controller.loadingState.value, equals(LoadingState.success));
    });
  });

  group('BookListController - refreshBooks', () {
    final tBooks = [
      Book(
        id: '1',
        title: 'Refreshed Book',
        author: 'Author',
        coverUrl: 'https://example.com/cover.jpg',
        epubUrl: 'https://example.com/book.epub',
        description: 'Description',
        language: 'zh',
        fileSize: 1024,
      ),
    ];

    test('should refresh books successfully', () async {
      // Arrange
      when(mockRefreshBooksUseCase.call()).thenAnswer((_) async => tBooks);

      // Act
      await controller.refreshBooks();

      // Assert
      expect(controller.books, equals(tBooks));
      expect(controller.loadingState.value, equals(LoadingState.success));
      expect(controller.isOffline.value, isFalse);
      verify(mockRefreshBooksUseCase.call()).called(1);
      // Note: Snackbar display requires GetMaterialApp setup (tested in widget tests)
    });

    test('should set empty state when refresh returns empty list', () async {
      // Arrange
      when(mockRefreshBooksUseCase.call()).thenAnswer((_) async => []);

      // Act
      await controller.refreshBooks();

      // Assert
      expect(controller.books, isEmpty);
      expect(controller.loadingState.value, equals(LoadingState.empty));
    });

    test('should handle network exception during refresh', () async {
      // Arrange
      when(mockRefreshBooksUseCase.call())
          .thenThrow(NetworkException('Network error'));

      // Act
      await controller.refreshBooks();

      // Assert
      verify(mockRefreshBooksUseCase.call()).called(1);
      // Note: refreshBooks shows snackbar but doesn't change state
    });

    test('should handle server exception during refresh', () async {
      // Arrange
      when(mockRefreshBooksUseCase.call())
          .thenThrow(ServerException('Server error', 500));

      // Act
      await controller.refreshBooks();

      // Assert
      verify(mockRefreshBooksUseCase.call()).called(1);
    });

    test('should handle unknown exception during refresh', () async {
      // Arrange
      when(mockRefreshBooksUseCase.call()).thenThrow(Exception('Unknown'));

      // Act
      await controller.refreshBooks();

      // Assert
      verify(mockRefreshBooksUseCase.call()).called(1);
    });
  });

  group('BookListController - onBookTap', () {
    test('should handle book tap event', () {
      // Arrange
      final tBook = Book(
        id: '1',
        title: 'Tapped Book',
        author: 'Author',
        coverUrl: 'https://example.com/cover.jpg',
        epubUrl: 'https://example.com/book.epub',
        description: 'Description',
        language: 'zh',
        fileSize: 1024,
      );

      // Act
      controller.onBookTap(tBook);

      // Assert - method executes without error
      // TODO: Add navigation verification when routes are implemented
    });
  });

  group('BookListController - retry', () {
    final tBooks = [
      Book(
        id: '1',
        title: 'Retry Book',
        author: 'Author',
        coverUrl: 'https://example.com/cover.jpg',
        epubUrl: 'https://example.com/book.epub',
        description: 'Description',
        language: 'zh',
        fileSize: 1024,
      ),
    ];

    test('should retry loading with force refresh', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: true))
          .thenAnswer((_) async => tBooks);

      // Act
      controller.retry();
      await Future.delayed(Duration.zero); // Wait for async operations

      // Assert
      verify(mockGetBooksUseCase.call(forceRefresh: true)).called(1);
    });
  });

  group('BookListController - Offline Mode', () {
    final tBooks = [
      Book(
        id: '1',
        title: 'Cached Book',
        author: 'Author',
        coverUrl: 'https://example.com/cover.jpg',
        epubUrl: 'https://example.com/book.epub',
        description: 'Description',
        language: 'zh',
        fileSize: 1024,
      ),
    ];

    test('should enter offline mode when network fails with cache available',
        () async {
      // Arrange - First call fails, second call (fallback) succeeds
      var callCount = 0;
      when(mockGetBooksUseCase.call(forceRefresh: false)).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw NetworkException('No internet');
        }
        return tBooks;
      });

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.books, equals(tBooks));
      expect(controller.loadingState.value, equals(LoadingState.success));
      expect(controller.isOffline.value, isTrue);
    });

    test('should show error when network fails without cache', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenThrow(NetworkException('No internet'));

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.loadingState.value, equals(LoadingState.error));
      expect(controller.isOffline.value, isFalse);
    });
  });

  group('BookListController - Error Messages', () {
    test('should return correct error message for NetworkException', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenThrow(NetworkException('Network error'));

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.errorMessage.value, contains('網絡連接失敗'));
    });

    test('should return correct error message for ServerException', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenThrow(ServerException('Server error', 500));

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.errorMessage.value, contains('服務器暫時無法訪問'));
    });

    test('should return correct error message for CacheException', () async {
      // Arrange
      when(mockGetBooksUseCase.call(forceRefresh: false))
          .thenThrow(CacheException('Cache error'));

      // Act
      await controller.loadBooks();

      // Assert
      expect(controller.errorMessage.value, contains('數據加載失敗'));
    });
  });
}
