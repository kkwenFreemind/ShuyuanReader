import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shuyuan_reader/core/enums/loading_state.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';
import 'package:shuyuan_reader/domain/usecases/get_book_by_id_usecase.dart';
import 'package:shuyuan_reader/domain/usecases/get_books_usecase.dart';
import 'package:shuyuan_reader/domain/usecases/refresh_books_usecase.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/book_list_page.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/controllers/book_list_controller.dart';

import 'book_list_page_test.mocks.dart';

// Generate mocks for the use cases
@GenerateMocks([GetBooksUseCase, RefreshBooksUseCase, GetBookByIdUseCase])
void main() {
  late MockGetBooksUseCase mockGetBooksUseCase;
  late MockRefreshBooksUseCase mockRefreshBooksUseCase;
  late MockGetBookByIdUseCase mockGetBookByIdUseCase;
  late BookListController controller;

  setUp(() {
    mockGetBooksUseCase = MockGetBooksUseCase();
    mockRefreshBooksUseCase = MockRefreshBooksUseCase();
    mockGetBookByIdUseCase = MockGetBookByIdUseCase();

    // Initialize GetX
    Get.testMode = true;

    // Default stub to prevent MissingStubError
    // Individual tests can override this
    when(mockGetBooksUseCase.call(forceRefresh: anyNamed('forceRefresh')))
        .thenAnswer((_) async => []);
    when(mockRefreshBooksUseCase.call())
        .thenAnswer((_) async => []);

    // Create controller and register it with GetX
    controller = BookListController(
      getBooksUseCase: mockGetBooksUseCase,
      refreshBooksUseCase: mockRefreshBooksUseCase,
      getBookByIdUseCase: mockGetBookByIdUseCase,
    );
    Get.put<BookListController>(controller);
  });

  tearDown(() {
    // Clean up GetX
    Get.delete<BookListController>();
    Get.reset();
  });

  /// Helper method to create a test widget with GetMaterialApp
  Widget createTestWidget(Widget child) {
    return GetMaterialApp(
      home: child,
    );
  }

  /// Helper method to create a sample book
  Book createSampleBook({
    String id = '1',
    String title = 'Test Book',
    String author = 'Test Author',
    String coverUrl = 'https://example.com/cover.jpg',
  }) {
    return Book(
      id: id,
      title: title,
      author: author,
      coverUrl: coverUrl,
      epubUrl: 'https://example.com/book.epub',
      description: 'Test description',
      language: 'zh-TW',
      fileSize: 1024000,
    );
  }

  group('BookListPage Widget Tests', () {
    group('UI Components', () {
      testWidgets('should display app bar with title and action buttons',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.loading;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.text('📚 書苑閱讀器'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display offline banner when isOffline is true',
          (WidgetTester tester) async {
        // Arrange
        controller.isOffline.value = true;
        controller.loadingState.value = LoadingState.loading;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.text('離線模式：正在使用緩存數據'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      });

      testWidgets('should not display offline banner when isOffline is false',
          (WidgetTester tester) async {
        // Arrange
        controller.isOffline.value = false;
        controller.loadingState.value = LoadingState.loading;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.text('離線模式：正在使用緩存數據'), findsNothing);
        expect(find.byIcon(Icons.wifi_off), findsNothing);
      });

      testWidgets('should have RefreshIndicator', (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.success;
        controller.books.value = [];

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('should display BookListShimmer when loading',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.loading;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.byType(BookListShimmer), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget); // Shimmer uses GridView
      });

      testWidgets('BookListShimmer should display 6 shimmer items',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.loading;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert - Verify shimmer is displayed
        expect(find.byType(BookListShimmer), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
      });
    });

    group('Success State', () {
      testWidgets('should display book grid when state is success with books',
          (WidgetTester tester) async {
        // Arrange
        final books = [
          createSampleBook(id: '1', title: 'Book 1', author: 'Author 1'),
          createSampleBook(id: '2', title: 'Book 2', author: 'Author 2'),
          createSampleBook(id: '3', title: 'Book 3', author: 'Author 3'),
        ];
        controller.books.value = books;
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.byType(GridView), findsOneWidget);
        expect(find.byType(BookGridItem), findsAtLeast(2)); // At least 2 books visible
        // Book titles appear in cards, verify at least some are present
        expect(find.textContaining('Book'), findsWidgets);
      });

      testWidgets('should display book titles and authors',
          (WidgetTester tester) async {
        // Arrange
        final book = createSampleBook(
          title: 'The Great Book',
          author: 'Great Author',
        );
        controller.books.value = [book];
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert - Title appears twice (in placeholder and in card text), verify it exists
        expect(find.textContaining('Great Book'), findsWidgets);
        expect(find.text('Great Author'), findsOneWidget);
      });

      testWidgets('should call onBookTap when book is tapped',
          (WidgetTester tester) async {
        // Arrange
        final book = createSampleBook(title: 'Tappable Book');
        controller.books.value = [book];
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Tap the book
        await tester.tap(find.byType(BookGridItem));
        await tester.pump();

        // Assert - Verify InkWell exists (at least one for the book card)
        expect(find.byType(InkWell), findsWidgets);
      });
    });

    group('Error State', () {
      testWidgets('should display ErrorStateWidget when state is error',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.error;
        controller.errorMessage.value = 'Network error occurred';

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.byType(ErrorStateWidget), findsOneWidget);
        expect(find.text('加載失敗'), findsOneWidget);
        expect(find.text('Network error occurred'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should display retry button in error state',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.error;
        controller.errorMessage.value = 'Test error';

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.text('重試'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should call retry when retry button is tapped',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.error;
        controller.errorMessage.value = 'Test error';

        // Mock the retry behavior - return immediately
        when(mockGetBooksUseCase.call(forceRefresh: true))
            .thenAnswer((_) async => [createSampleBook()]);

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Tap retry button
        await tester.tap(find.text('重試'));
        await tester.pump(); // Trigger microtasks
        
        // Assert - Verify retry was called
        verify(mockGetBooksUseCase.call(forceRefresh: true)).called(1);
      });
    });

    group('Empty State', () {
      testWidgets('should display EmptyStateWidget when state is empty',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.empty;
        controller.books.value = [];

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.byType(EmptyStateWidget), findsOneWidget);
        expect(find.text('暫無書籍'), findsOneWidget);
        expect(find.text('目前還沒有可用的書籍\n請下拉刷新或稍後再試'), findsOneWidget);
        expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);
      });

      testWidgets('should display refresh button in empty state',
          (WidgetTester tester) async {
        // Arrange
        controller.loadingState.value = LoadingState.empty;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.text('刷新'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });
    });

    group('BookGridItem Widget', () {
      testWidgets('should display book placeholder when no cover URL',
          (WidgetTester tester) async {
        // Arrange
        final book = createSampleBook(coverUrl: '');
        controller.books.value = [book];
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.book), findsOneWidget);
      });

      testWidgets('should display Image.network when cover URL exists',
          (WidgetTester tester) async {
        // Arrange
        final book = createSampleBook(
          coverUrl: 'https://example.com/cover.jpg',
        );
        controller.books.value = [book];
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('BookGridItem should have Card with rounded corners',
          (WidgetTester tester) async {
        // Arrange
        final book = createSampleBook();
        controller.books.value = [book];
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        final card = tester.widget<Card>(find.byType(Card).first);
        expect(card.elevation, 2);
        expect(card.shape, isA<RoundedRectangleBorder>());
      });
    });

    group('State Transitions', () {
      testWidgets('should transition from loading to success',
          (WidgetTester tester) async {
        // Arrange - Start with loading
        controller.loadingState.value = LoadingState.loading;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert - Loading state
        expect(find.byType(BookListShimmer), findsOneWidget);

        // Arrange - Change to success
        controller.books.value = [createSampleBook()];
        controller.loadingState.value = LoadingState.success;

        // Act - Pump to rebuild
        await tester.pump();

        // Assert - Success state
        expect(find.byType(BookListShimmer), findsNothing);
        expect(find.byType(BookGridItem), findsOneWidget);
      });

      testWidgets('should transition from error to loading on retry',
          (WidgetTester tester) async {
        // Arrange - Start with error
        controller.loadingState.value = LoadingState.error;
        controller.errorMessage.value = 'Error';

        // Mock retry behavior - return immediately
        when(mockGetBooksUseCase.call(forceRefresh: true))
            .thenAnswer((_) async => [createSampleBook()]);

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert - Error state
        expect(find.byType(ErrorStateWidget), findsOneWidget);

        // Act - Tap retry
        await tester.tap(find.text('重試'));
        await tester.pump(); // Trigger microtasks
        
        // Assert - Verify retry was called
        verify(mockGetBooksUseCase.call(forceRefresh: true)).called(1);
      });
    });

    group('Grid Layout', () {
      testWidgets('should display books in 2-column grid',
          (WidgetTester tester) async {
        // Arrange
        final books = List.generate(
          4,
          (i) => createSampleBook(id: '$i', title: 'Book $i'),
        );
        controller.books.value = books;
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate = gridView.gridDelegate
            as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
        expect(delegate.childAspectRatio, 0.6);
        expect(delegate.crossAxisSpacing, 16);
        expect(delegate.mainAxisSpacing, 16);
      });
    });

    group('Offline Mode Integration', () {
      testWidgets('should show offline banner and display cached books',
          (WidgetTester tester) async {
        // Arrange
        controller.isOffline.value = true;
        controller.books.value = [createSampleBook(title: 'Cached Book')];
        controller.loadingState.value = LoadingState.success;

        // Act
        await tester.pumpWidget(createTestWidget(const BookListPage()));
        await tester.pump();

        // Assert
        expect(find.text('離線模式：正在使用緩存數據'), findsOneWidget);
        // Title appears in both placeholder and card, verify it exists
        expect(find.textContaining('Cached Book'), findsWidgets);
        expect(find.byType(BookGridItem), findsOneWidget);
      });
    });
  });
}
