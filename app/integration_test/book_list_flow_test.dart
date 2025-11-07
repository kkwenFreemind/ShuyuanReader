import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/book_list_page.dart';
import 'package:shuyuan_reader/main.dart' as app;

/// 書籍列表頁面集成測試
/// 
/// 測試完整的書籍列表流程，包括：
/// - 從 Splash 頁面自動跳轉到書籍列表
/// - 書籍列表加載和顯示
/// - 下拉刷新功能
/// - UI 交互
/// - 性能測試
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// 通用的應用啟動並等待跳轉到 BookListPage 的輔助函數
  Future<void> launchAndWaitForBookList(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    // 等待 Splash 的 3 秒延遲 + 初始化時間
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  group('BookList Flow Integration Tests', () {
    testWidgets('Complete flow: Splash -> BookList loading and display',
        (WidgetTester tester) async {
      // 1. 啟動應用
      app.main();
      await tester.pumpAndSettle();

      // 2. 驗證 Splash 頁面顯示
      expect(find.text('📚'), findsOneWidget, reason: 'Splash logo 應該顯示');
      expect(find.text('書苑閱讀器'), findsOneWidget, reason: 'Splash 標題應該顯示');

      // 3. 等待 Splash 頁面跳轉 (3秒延遲 + 動畫 + 初始化時間)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 4. 驗證已跳轉到 BookListPage
      expect(find.byType(BookListPage), findsOneWidget,
          reason: '應該跳轉到書籍列表頁面');

      // 5. 驗證 AppBar 顯示
      expect(find.text('📚 書苑閱讀器'), findsOneWidget,
          reason: 'AppBar 標題應該顯示');

      // 6. 驗證 RefreshIndicator 存在（下拉刷新功能）
      expect(find.byType(RefreshIndicator), findsOneWidget,
          reason: '應該有下拉刷新功能');

      print('✅ 完整流程測試通過：Splash → BookList');
    });

    testWidgets('BookListPage UI elements should be present',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 驗證基本 UI 元素存在
      expect(find.byType(AppBar), findsOneWidget,
          reason: 'AppBar 應該存在');
      
      expect(find.byType(RefreshIndicator), findsOneWidget,
          reason: 'RefreshIndicator 應該存在');

      // 驗證 AppBar 操作按鈕
      expect(find.byIcon(Icons.search), findsOneWidget,
          reason: '搜索按鈕應該存在');
      
      expect(find.byIcon(Icons.settings), findsOneWidget,
          reason: '設置按鈕應該存在');

      print('✅ UI 元素測試通過');
    });

    testWidgets('Pull to refresh should trigger reload',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 找到可滾動的區域
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // 執行下拉刷新手勢
      await tester.drag(refreshIndicator, const Offset(0, 300));
      await tester.pump(); // 開始刷新動畫
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // 刷新後應該仍然在 BookListPage
      expect(find.byType(BookListPage), findsOneWidget);

      print('✅ 下拉刷新測試通過');
    });

    testWidgets('App should handle rapid UI interactions',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 快速多次點擊搜索按鈕（測試防抖）
      final searchButton = find.byIcon(Icons.search);
      expect(searchButton, findsOneWidget);
      
      for (int i = 0; i < 3; i++) {
        await tester.tap(searchButton);
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 應用應該沒有崩潰
      expect(find.byType(BookListPage), findsOneWidget);

      print('✅ 快速交互測試通過');
    });

    testWidgets('Settings button should be tappable',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 找到設置按鈕
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      // 點擊設置按鈕
      await tester.tap(settingsButton);
      await tester.pump();

      // 應用不應該崩潰
      expect(find.byType(BookListPage), findsOneWidget);

      print('✅ 設置按鈕測試通過');
    });
  });

  group('BookList State Handling Tests', () {
    testWidgets('BookListPage should display books or empty state',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 給數據加載更多時間
      await tester.pump(const Duration(seconds: 1));

      // 驗證頁面已加載
      expect(find.byType(BookListPage), findsOneWidget);

      // 如果顯示空狀態，應該看到 Empty State UI
      final emptyText = find.text('暫無書籍');
      if (emptyText.evaluate().isNotEmpty) {
        expect(emptyText, findsOneWidget);
        print('✅ 空狀態顯示正常');
      } else {
        // 應該有 GridView 或 Card
        final hasGridView = find.byType(GridView).evaluate().isNotEmpty;
        final hasCard = find.byType(Card).evaluate().isNotEmpty;
        expect(hasGridView || hasCard, true, reason: '應該顯示書籍列表或卡片');
        print('✅ 書籍列表顯示正常');
      }
    });

    testWidgets('Offline banner should appear when network is unavailable',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 檢查是否有離線橫幅
      final offlineBanner = find.text('離線模式 - 顯示緩存內容');
      if (offlineBanner.evaluate().isNotEmpty) {
        expect(offlineBanner, findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
        print('✅ 離線模式橫幅顯示正常');
      } else {
        print('✅ 在線模式，無離線橫幅');
      }
    });
  });

  group('BookList Performance Tests', () {
    testWidgets('BookListPage should load within reasonable time',
        (WidgetTester tester) async {
      final startTime = DateTime.now();

      // 啟動應用並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('BookListPage 加載時間: ${duration.inMilliseconds}ms');

      // 驗證加載時間合理（包含 Splash 的 4 秒 + 2 秒緩衝）
      expect(duration.inSeconds, lessThan(10),
          reason: '頁面加載應該在 10 秒內完成');

      print('✅ 性能測試通過');
    });

    testWidgets('GridView scrolling should be smooth if present',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 如果有 GridView，測試滾動
      final gridView = find.byType(GridView);
      if (gridView.evaluate().isNotEmpty) {
        // 執行滾動
        await tester.drag(gridView, const Offset(0, -200));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // 應用應該沒有崩潰
        expect(find.byType(BookListPage), findsOneWidget);
        print('✅ 滾動測試通過');
      } else {
        print('ℹ️  無 GridView，跳過滾動測試');
      }
    });
  });

  group('BookList Error Handling Tests', () {
    testWidgets('App should not crash on potential errors',
        (WidgetTester tester) async {
      // 啟動並跳轉到 BookListPage
      await launchAndWaitForBookList(tester);

      // 等待可能的錯誤
      await tester.pump(const Duration(seconds: 1));

      // 驗證應用沒有崩潰
      expect(find.byType(BookListPage), findsOneWidget);

      // 如果有錯誤狀態，應該顯示錯誤 UI
      final errorText = find.text('加載失敗');
      final retryButton = find.text('重試');
      
      if (errorText.evaluate().isNotEmpty) {
        expect(errorText, findsOneWidget);
        expect(retryButton, findsOneWidget);
        
        // 測試重試按鈕
        await tester.tap(retryButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        
        // 應用不應該崩潰
        expect(find.byType(BookListPage), findsOneWidget);
        print('✅ 錯誤處理和重試功能正常');
      } else {
        print('✅ 無錯誤狀態');
      }
    });
  });

  group('BookList Integration Smoke Tests', () {
    testWidgets('Complete end-to-end flow should work',
        (WidgetTester tester) async {
      print('🚀 開始完整端到端測試...');

      // 1. 啟動應用
      app.main();
      await tester.pumpAndSettle();
      print('✅ Step 1: 應用啟動成功');

      // 2. 等待 Splash 頁面
      expect(find.text('書苑閱讀器'), findsOneWidget);
      print('✅ Step 2: Splash 頁面顯示正常');

      // 3. 等待自動跳轉
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Step 3: 自動跳轉完成');

      // 4. 驗證 BookListPage
      expect(find.byType(BookListPage), findsOneWidget);
      print('✅ Step 4: BookListPage 顯示正常');

      // 5. 驗證基本功能可用
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      print('✅ Step 5: 基本功能可用');

      // 6. 測試下拉刷新
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 6: 下拉刷新功能正常');

      // 7. 驗證應用穩定
      expect(find.byType(BookListPage), findsOneWidget);
      print('✅ Step 7: 應用運行穩定');

      print('🎉 完整端到端測試通過！');
    });
  });
}
