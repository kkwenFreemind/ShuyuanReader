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

  // Test books
  final testBook1 = Book(
    id: '1',
    title: '測試書籍一',
    author: '作者一',
    coverUrl: 'https://example.com/cover1.jpg',
    epubUrl: 'https://example.com/book1.epub',
    description: '這是一本測試書籍',
    language: 'zh-TW',
    fileSize: 1024000,
  );

  final testBook2 = Book(
    id: '2',
    title: '測試書籍二',
    author: '作者二',
    coverUrl: '', // No cover
    epubUrl: 'https://example.com/book2.epub',
    description: '這是另一本測試書籍',
    language: 'zh-TW',
    fileSize: 2048000,
  );

  setUp(() {
    mockGetBooksUseCase = MockGetBooksUseCase();
    mockRefreshBooksUseCase = MockRefreshBooksUseCase();
    mockGetBookByIdUseCase = MockGetBookByIdUseCase();

    // Initialize GetX
    Get.testMode = true;

    // Default stubs
    when(mockGetBooksUseCase.call(forceRefresh: anyNamed('forceRefresh')))
        .thenAnswer((_) async => []);
    when(mockRefreshBooksUseCase.call()).thenAnswer((_) async => []);

    // Create controller and register it with GetX
    controller = BookListController(
      getBooksUseCase: mockGetBooksUseCase,
      refreshBooksUseCase: mockRefreshBooksUseCase,
      getBookByIdUseCase: mockGetBookByIdUseCase,
    );
    Get.put<BookListController>(controller);
  });

  tearDown(() {
    Get.delete<BookListController>();
    Get.reset();
  });

  group('BookGridItem Golden Tests', () {
    testWidgets('1. BookGridItem with cover should match golden',
        (WidgetTester tester) async {
      controller.books.value = [testBook1];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Card).first,
        matchesGoldenFile('goldens/book_grid_item_with_cover.png'),
      );
    });

    testWidgets('2. BookGridItem without cover should match golden',
        (WidgetTester tester) async {
      controller.books.value = [testBook2];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Card).first,
        matchesGoldenFile('goldens/book_grid_item_no_cover.png'),
      );
    });

    testWidgets('3. BookGridItem grid layout should match golden',
        (WidgetTester tester) async {
      controller.books.value = [testBook1, testBook2];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GridView),
        matchesGoldenFile('goldens/book_grid_layout.png'),
      );
    });
  });

  group('BookListShimmer Golden Tests', () {
    testWidgets('4. BookListShimmer should match golden',
        (WidgetTester tester) async {
      controller.loadingState.value = LoadingState.loading;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(GridView),
        matchesGoldenFile('goldens/book_list_shimmer.png'),
      );
    });

    testWidgets('5. Shimmer card should match golden',
        (WidgetTester tester) async {
      controller.loadingState.value = LoadingState.loading;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(Card).first,
        matchesGoldenFile('goldens/shimmer_card.png'),
      );
    });
  });

  group('EmptyStateWidget Golden Tests', () {
    testWidgets('6. EmptyStateWidget should match golden',
        (WidgetTester tester) async {
      controller.books.value = [];
      controller.loadingState.value = LoadingState.empty;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Center).first,
        matchesGoldenFile('goldens/empty_state.png'),
      );
    });

    testWidgets('7. EmptyState with icon and text should match golden',
        (WidgetTester tester) async {
      controller.books.value = [];
      controller.loadingState.value = LoadingState.empty;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暫無書籍',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '點擊刷新按鈕加載書籍',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('刷新'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/empty_state_detailed.png'),
      );
    });
  });

  group('ErrorStateWidget Golden Tests', () {
    testWidgets('8. ErrorStateWidget should match golden',
        (WidgetTester tester) async {
      controller.loadingState.value = LoadingState.error;
      controller.errorMessage.value = '網絡連接失敗';

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Center).first,
        matchesGoldenFile('goldens/error_state.png'),
      );
    });

    testWidgets('9. ErrorState with icon and text should match golden',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加載失敗',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '網絡連接失敗，請檢查網絡設置',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('重試'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/error_state_detailed.png'),
      );
    });
  });

  group('Offline Banner Golden Tests', () {
    testWidgets('10. Offline banner should match golden',
        (WidgetTester tester) async {
      controller.isOffline.value = true;
      controller.books.value = [testBook1];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/offline_banner.png'),
      );
    });

    testWidgets('11. Offline banner design should match golden',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.orange[100],
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 16,
                        color: Colors.orange[800],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '離線模式 - 顯示緩存內容',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: Center(child: Text('Content'))),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Container).first,
        matchesGoldenFile('goldens/offline_banner_design.png'),
      );
    });
  });

  group('Full Layout Golden Tests', () {
    testWidgets('12. Full BookListPage loading should match golden',
        (WidgetTester tester) async {
      controller.loadingState.value = LoadingState.loading;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_page_loading.png'),
      );
    });

    testWidgets('13. Full BookListPage success should match golden',
        (WidgetTester tester) async {
      controller.books.value = [testBook1, testBook2];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_page_success.png'),
      );
    });

    testWidgets('14. Full BookListPage error should match golden',
        (WidgetTester tester) async {
      controller.loadingState.value = LoadingState.error;
      controller.errorMessage.value = '網絡連接失敗';

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_page_error.png'),
      );
    });

    testWidgets('15. Full BookListPage empty should match golden',
        (WidgetTester tester) async {
      controller.books.value = [];
      controller.loadingState.value = LoadingState.empty;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_page_empty.png'),
      );
    });
  });

  group('Responsive Layout Golden Tests', () {
    testWidgets('16. BookListPage should match golden - small screen (360x640)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      controller.books.value = [testBook1, testBook2];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/responsive_small_screen.png'),
      );
    });

    testWidgets('17. BookListPage should match golden - large screen (414x896)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      controller.books.value = [testBook1, testBook2];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/responsive_large_screen.png'),
      );
    });

    testWidgets('18. BookListPage should match golden - tablet (768x1024)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      controller.books.value = [testBook1, testBook2];
      controller.loadingState.value = LoadingState.success;

      await tester.pumpWidget(
        GetMaterialApp(
          home: BookListPage(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/responsive_tablet.png'),
      );
    });
  });
}
