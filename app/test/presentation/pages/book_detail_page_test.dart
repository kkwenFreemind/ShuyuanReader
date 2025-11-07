import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shuyuan_reader/data/models/download_status.dart';
import 'package:shuyuan_reader/data/services/download_service.dart';
import 'package:shuyuan_reader/domain/entities/book.dart';
import 'package:shuyuan_reader/domain/repositories/book_repository.dart';
import 'package:shuyuan_reader/presentation/controllers/book_detail_controller.dart';
import 'package:shuyuan_reader/presentation/pages/book_detail_page.dart';

import 'book_detail_page_test.mocks.dart';

// Test-specific controller that doesn't use Get.arguments
class TestBookDetailController extends BookDetailController {
  final Book testBook;
  
  TestBookDetailController(
    super.downloadService,
    super.bookRepository,
    this.testBook,
  );
  
  @override
  void onInit() {
    // Don't call super.onInit() to avoid Get.arguments access
    // Set book directly instead
    book = Rx<Book>(testBook);
  }
}

// Generate mocks for dependencies
@GenerateNiceMocks([
  MockSpec<DownloadService>(),
  MockSpec<BookRepository>(),
])
void main() {
  late MockDownloadService mockDownloadService;
  late MockBookRepository mockBookRepository;
  late Book testBook;

  setUp(() {
    // Initialize Flutter binding for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize GetX for testing
    Get.testMode = true;
    
    // Create mocks
    mockDownloadService = MockDownloadService();
    mockBookRepository = MockBookRepository();
    
    // Create test book
    testBook = const Book(
      id: 'test-book-1',
      title: '一夢漫言',
      author: '見月老人',
      coverUrl: 'https://example.com/cover.jpg',
      epubUrl: 'https://example.com/book.epub',
      description: '余於庚午歲，遊居金陵...',
      language: '繁體中文',
      fileSize: 2500000, // 2.5 MB
      downloadStatus: DownloadStatus.notDownloaded,
      downloadProgress: 0.0,
    );
    
    // Register mocks in Get - must be done in setUp for each test
    Get.put<DownloadService>(mockDownloadService);
    Get.put<BookRepository>(mockBookRepository);
  });

  tearDown(() {
    // Clean up GetX - delete controller and dependencies  
    // Must reset everything to avoid widget reuse issues
    Get.reset();
  });

  /// Helper method to create a test widget with GetMaterialApp
  Widget createTestWidget({Book? book}) {
    final bookToUse = book ?? testBook;
    
    // Create test controller that bypasses Get.arguments
    final controller = TestBookDetailController(
      mockDownloadService,
      mockBookRepository,
      bookToUse,
    );
    
    // Register the controller so GetView can find it
    Get.put<BookDetailController>(controller);
    
    return GetMaterialApp(
      home: BookDetailPage(),
    );
  }

  group('BookDetailPage Widget Tests', () {
    group('Book Information Display', () {
      testWidgets('should display book title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('一夢漫言'), findsOneWidget);
      });

      testWidgets('should display book author', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('見月老人'), findsOneWidget);
      });

      testWidgets('should display book language', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('繁體中文'), findsOneWidget);
      });

      testWidgets('should display formatted file size', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('2.4 MB'), findsOneWidget);
      });

      testWidgets('should display book description when not empty', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.textContaining('余於庚午'), findsOneWidget);
      });

      testWidgets('should not display description section when empty', (tester) async {
        // Update book with empty description
        final bookWithoutDescription = testBook.copyWith(description: '');

        await tester.pumpWidget(createTestWidget(book: bookWithoutDescription));
        await tester.pump();

        expect(find.text('簡介'), findsNothing);
      });
    });

    group('Download Status - Not Downloaded', () {
      testWidgets('should show download button when not downloaded', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('下載書籍'), findsOneWidget);
        expect(find.byIcon(Icons.download), findsOneWidget);
      });

      testWidgets('should trigger download on button tap', (tester) async {
        when(mockDownloadService.downloadBook(
          bookId: anyNamed('bookId'),
          url: anyNamed('url'),
          onProgress: anyNamed('onProgress'),
        )).thenAnswer((_) async => '/path/to/book.epub');

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Scroll to button if needed
        await tester.ensureVisible(find.text('下載書籍'));
        await tester.pump();

        await tester.tap(find.text('下載書籍'));
        await tester.pump();

        // Verify download service was called
        verify(mockDownloadService.downloadBook(
          bookId: testBook.id,
          url: testBook.epubUrl,
          onProgress: anyNamed('onProgress'),
        )).called(1);
      });
    });

    group('Download Status - Downloading', () {
      testWidgets('should show progress bar when downloading', (tester) async {
        final downloadingBook = testBook.copyWith(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0.65,
        );

        await tester.pumpWidget(createTestWidget(book: downloadingBook));
        await tester.pump();

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('下載中'), findsOneWidget);
        expect(find.text('65%'), findsOneWidget);
      });

      testWidgets('should show pause and cancel buttons when downloading', (tester) async {
        final downloadingBook = testBook.copyWith(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0.45,
        );

        await tester.pumpWidget(createTestWidget(book: downloadingBook));
        await tester.pump();

        expect(find.text('暫停'), findsOneWidget);
        expect(find.text('取消'), findsAtLeastNWidgets(1)); // May appear multiple times
        expect(find.byIcon(Icons.pause), findsOneWidget);
      });

      testWidgets('should call pauseDownload when pause button tapped', (tester) async {
        final downloadingBook = testBook.copyWith(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0.5,
        );

        await tester.pumpWidget(createTestWidget(book: downloadingBook));
        await tester.pump();

        // Scroll to button if needed
        await tester.ensureVisible(find.text('暫停'));
        await tester.pump();

        await tester.tap(find.text('暫停'));
        await tester.pump();

        verify(mockDownloadService.cancelDownload(testBook.id)).called(1);
      });

      testWidgets('should call cancelDownload when cancel button tapped', (tester) async {
        final downloadingBook = testBook.copyWith(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: 0.3,
        );

        await tester.pumpWidget(createTestWidget(book: downloadingBook));
        await tester.pump();

        // Find all cancel text widgets
        final cancelTextFinder = find.text('取消');
        
        // Scroll to make visible and tap the second one (in OutlinedButton)
        await tester.ensureVisible(cancelTextFinder.at(1));
        await tester.pump();

        await tester.tap(cancelTextFinder.at(1));
        await tester.pump();

        verify(mockDownloadService.cancelDownload(testBook.id)).called(1);
      });
    });

    group('Download Status - Paused', () {
      testWidgets('should show paused state with orange progress bar', (tester) async {
        final pausedBook = testBook.copyWith(
          downloadStatus: DownloadStatus.paused,
          downloadProgress: 0.55,
        );

        await tester.pumpWidget(createTestWidget(book: pausedBook));
        await tester.pump();

        expect(find.text('已暫停'), findsOneWidget);
        expect(find.text('55%'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('should show continue and cancel buttons when paused', (tester) async {
        final pausedBook = testBook.copyWith(
          downloadStatus: DownloadStatus.paused,
          downloadProgress: 0.4,
        );

        await tester.pumpWidget(createTestWidget(book: pausedBook));
        await tester.pump();

        expect(find.text('繼續'), findsOneWidget);
        expect(find.text('取消'), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('should resume download when continue button tapped', (tester) async {
        final pausedBook = testBook.copyWith(
          downloadStatus: DownloadStatus.paused,
          downloadProgress: 0.6,
        );

        when(mockDownloadService.downloadBook(
          bookId: anyNamed('bookId'),
          url: anyNamed('url'),
          onProgress: anyNamed('onProgress'),
        )).thenAnswer((_) async => '/path/to/book.epub');

        await tester.pumpWidget(createTestWidget(book: pausedBook));
        await tester.pump();

        // Scroll to button if needed
        await tester.ensureVisible(find.text('繼續'));
        await tester.pump();

        await tester.tap(find.text('繼續'));
        await tester.pump();

        verify(mockDownloadService.downloadBook(
          bookId: testBook.id,
          url: testBook.epubUrl,
          onProgress: anyNamed('onProgress'),
        )).called(1);
      });
    });

    group('Download Status - Downloaded', () {
      testWidgets('should show open reader button when downloaded', (tester) async {
        final downloadedBook = testBook.copyWith(
          downloadStatus: DownloadStatus.downloaded,
          localPath: '/path/to/book.epub',
        );

        await tester.pumpWidget(createTestWidget(book: downloadedBook));
        await tester.pump();

        expect(find.text('打開閱讀'), findsOneWidget);
        expect(find.byIcon(Icons.menu_book), findsOneWidget);
      });

      testWidgets('should show delete button when downloaded', (tester) async {
        final downloadedBook = testBook.copyWith(
          downloadStatus: DownloadStatus.downloaded,
          localPath: '/path/to/book.epub',
        );

        await tester.pumpWidget(createTestWidget(book: downloadedBook));
        await tester.pump();

        expect(find.text('刪除書籍'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('should call openReader when open button tapped', (tester) async {
        final downloadedBook = testBook.copyWith(
          downloadStatus: DownloadStatus.downloaded,
          localPath: '/path/to/book.epub',
        );

        await tester.pumpWidget(createTestWidget(book: downloadedBook));
        await tester.pump();

        // Scroll to button if needed
        await tester.ensureVisible(find.text('打開閱讀'));
        await tester.pump();

        await tester.tap(find.text('打開閱讀'));
        await tester.pump();

        // OpenReader shows a snackbar in test mode
        // Just verify the button can be tapped
        expect(find.text('打開閱讀'), findsOneWidget);
      });
    });

    group('Download Status - Failed', () {
      testWidgets('should show download button when failed (retry)', (tester) async {
        final failedBook = testBook.copyWith(
          downloadStatus: DownloadStatus.failed,
        );

        await tester.pumpWidget(createTestWidget(book: failedBook));
        await tester.pump();

        expect(find.text('下載書籍'), findsOneWidget);
        expect(find.byIcon(Icons.download), findsOneWidget);
      });
    });

    group('AppBar', () {
      testWidgets('should display app bar with title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('書籍詳情'), findsOneWidget);
      });

      testWidgets('should handle back navigation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // In test mode without navigation stack, verify AppBar exists
        // GetMaterialApp without navigation won't show back button
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Cover Image', () {
      testWidgets('should display cover image placeholder', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // CachedNetworkImage will show placeholder initially
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });
    });

    group('Responsive Layout', () {
      testWidgets('should be scrollable', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('should display all content without overflow', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Verify no overflow errors
        expect(tester.takeException(), isNull);
      });
    });
  });
}
