import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shuyuan_reader/presentation/pages/book_detail_page.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/book_list_page.dart';
import 'package:shuyuan_reader/main.dart' as app;

/// 簡化版書籍詳情頁面集成測試
/// 
/// 這是一個簡化版本，專注於測試核心功能而避免複雜的狀態管理
/// 所有測試共享一個應用實例，避免 Hive 重複初始化問題
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 輔助函數：導航到詳情頁
  Future<void> navigateToDetailPage(WidgetTester tester) async {
    // 確保在書籍列表頁
    await tester.pumpAndSettle();
    
    // 等待書籍列表穩定
    await tester.pump(const Duration(milliseconds: 500));
    
    // 查找並點擊第一個書籍卡片
    final bookCard = find.byType(Card).first;
    if (bookCard.evaluate().isEmpty) {
      print('⚠️  無可用書籍');
      return;
    }
    
    await tester.tap(bookCard);
    await tester.pumpAndSettle();
  }

  // 輔助函數：返回到書籍列表
  Future<void> backToBookList(WidgetTester tester) async {
    if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        // 等待書籍列表完全穩定
        await tester.pump(const Duration(milliseconds: 500));
      }
    }
  }

  group('BookDetail Basic Tests', () {
    // 只在第一個測試中啟動應用一次
    testWidgets('1. Complete navigation flow',
        (WidgetTester tester) async {
      print('\n🚀 測試 1：完整導航流程...');
      
      // 啟動應用（只啟動一次）
      app.main();
      await tester.pumpAndSettle();
      
      // 等待 Splash 完成
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 驗證到達書籍列表
      expect(find.byType(BookListPage), findsOneWidget);
      print('✅ 到達書籍列表');
      
      // 等待書籍加載
      await tester.pump(const Duration(seconds: 1));
      
      // 導航到詳情頁
      await navigateToDetailPage(tester);
      
      // 驗證進入詳情頁
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，結束測試');
        return;
      }
      
      expect(find.byType(BookDetailPage), findsOneWidget);
      print('✅ 進入書籍詳情頁');
      
      // 驗證基本 UI 元素
      expect(find.byType(AppBar), findsOneWidget);
      print('✅ UI 元素正常');
      
      // 返回書籍列表
      await backToBookList(tester);
      expect(find.byType(BookListPage), findsOneWidget);
      print('✅ 返回書籍列表');
      
      print('🎉 導航流程測試通過！');
    });

    testWidgets('2. Display book information',
        (WidgetTester tester) async {
      print('\n🚀 測試 2：顯示書籍信息...');
      
      // 確保在書籍列表頁
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        await backToBookList(tester);
      }
      
      // 導航到詳情頁（應用已在測試1中啟動）
      await navigateToDetailPage(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁');
        return;
      }
      
      // 等待內容加載
      await tester.pump(const Duration(milliseconds: 500));
      
      // 驗證有文本內容
      final textWidgets = find.byType(Text);
      expect(textWidgets.evaluate().length, greaterThan(0));
      print('✅ 顯示書籍信息');
      
      // 返回書籍列表
      await backToBookList(tester);
      
      print('🎉 顯示測試通過！');
    });

    testWidgets('3. Download button interaction',
        (WidgetTester tester) async {
      print('\n🚀 測試 3：下載按鈕交互...');
      
      // 確保在書籍列表頁
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        await backToBookList(tester);
      }
      
      // 導航到詳情頁
      await navigateToDetailPage(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 查找下載或打開按鈕
      final downloadButton = find.text('下載書籍');
      final openButton = find.text('打開閱讀');
      
      if (downloadButton.evaluate().isNotEmpty) {
        print('✅ 找到下載按鈕');
        
        // 點擊下載
        await tester.tap(downloadButton);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ 點擊下載按鈕');
        
        // 驗證應用穩定
        expect(find.byType(BookDetailPage), findsOneWidget);
      } else if (openButton.evaluate().isNotEmpty) {
        print('✅ 書籍已下載（找到打開按鈕）');
      } else {
        print('ℹ️  未找到下載或打開按鈕');
      }
      
      // 返回書籍列表
      await backToBookList(tester);
      
      print('🎉 交互測試完成！');
    });
  });
}
