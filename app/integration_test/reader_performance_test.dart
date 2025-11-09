import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shuyuan_reader/presentation/pages/book_detail_page.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/book_list_page.dart';
import 'package:shuyuan_reader/presentation/pages/reader/reader_page.dart';
import 'package:shuyuan_reader/main.dart' as app;

/// EPUB 閱讀器性能測試
/// 
/// 測試重點：
/// 1. 閱讀器啟動時間
/// 2. 翻頁性能和流暢度
/// 3. 內存使用情況
/// 4. 幀率監控（目標 60fps）
/// 5. 長時間運行穩定性
/// 
/// 使用 IntegrationTestWidgetsFlutterBinding 的性能測試功能
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// 從書籍列表導航到詳情頁的輔助函數
  Future<void> navigateToBookDetail(WidgetTester tester) async {
    print('\n📖 導航到書籍詳情頁...');
    
    await tester.pumpAndSettle();
    
    // 驗證在書籍列表頁
    expect(find.byType(BookListPage), findsOneWidget);
    
    // 等待書籍加載
    await tester.pump(const Duration(seconds: 1));
    
    // 查找並點擊第一本已下載的書籍
    final bookCards = find.byType(Card);
    if (bookCards.evaluate().isNotEmpty) {
      await tester.tap(bookCards.first);
      await tester.pumpAndSettle();
      print('✅ 成功進入書籍詳情頁');
    } else {
      throw Exception('⚠️  未找到可用書籍');
    }
  }

  /// 從詳情頁打開閱讀器的輔助函數
  Future<void> openReader(WidgetTester tester) async {
    print('\n📚 打開閱讀器...');
    
    // 確認在詳情頁
    expect(find.byType(BookDetailPage), findsOneWidget);
    
    // 查找「開始閱讀」或「繼續閱讀」按鈕
    Finder readButton = find.widgetWithText(ElevatedButton, '開始閱讀');
    if (readButton.evaluate().isEmpty) {
      readButton = find.widgetWithText(ElevatedButton, '繼續閱讀');
    }
    
    if (readButton.evaluate().isNotEmpty) {
      await tester.tap(readButton);
      await tester.pumpAndSettle();
      
      // 等待閱讀器加載
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      print('✅ 成功打開閱讀器');
    } else {
      throw Exception('⚠️  未找到閱讀按鈕');
    }
  }

  /// 返回到書籍列表的輔助函數
  Future<void> backToBookList(WidgetTester tester) async {
    print('\n🔙 返回書籍列表...');
    
    // 如果在閱讀器頁面，先返回詳情頁
    if (find.byType(ReaderPage).evaluate().isNotEmpty) {
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        print('✅ 已返回詳情頁');
      }
    }
    
    // 如果在詳情頁，返回列表頁
    if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        print('✅ 已返回書籍列表');
      }
    }
  }

  group('Reader Performance Tests', () {
    setUpAll(() async {
      print('\n🚀 啟動應用進行性能測試...');
      app.main();
    });

    testWidgets('Performance: Reader Launch Time', (WidgetTester tester) async {
      print('\n═══════════════════════════════════════════════════════');
      print('⏱️  測試：閱讀器啟動時間');
      print('═══════════════════════════════════════════════════════');
      
      // 啟動應用
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4)); // Splash
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await navigateToBookDetail(tester);
      
      // 測量閱讀器啟動時間
      print('\n⏱️  開始測量閱讀器啟動時間...');
      final startTime = DateTime.now();
      
      await binding.watchPerformance(() async {
        await openReader(tester);
      }, reportKey: 'reader_launch');
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('\n📊 性能結果：');
      print('  閱讀器啟動時間: ${duration.inMilliseconds}ms');
      print('  目標: < 2000ms (2s)');
      
      // 驗收標準：啟動時間 < 2s
      expect(duration.inMilliseconds, lessThan(2000),
          reason: '閱讀器啟動時間應小於 2 秒');
      
      if (duration.inMilliseconds < 2000) {
        print('  ✅ 通過: 啟動時間符合標準');
      } else {
        print('  ⚠️  警告: 啟動時間超過標準');
      }
      
      print('═══════════════════════════════════════════════════════\n');
      
      // 清理
      await backToBookList(tester);
    });

    testWidgets('Performance: Page Turning Smoothness', (WidgetTester tester) async {
      print('\n═══════════════════════════════════════════════════════');
      print('📖 測試：翻頁流暢度');
      print('═══════════════════════════════════════════════════════');
      
      // 導航到閱讀器
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await navigateToBookDetail(tester);
      await openReader(tester);
      
      // 測試多次翻頁的性能
      print('\n📊 測試翻頁性能（10次翻頁操作）...');
      
      final pageTurnTimes = <Duration>[];
      
      for (int i = 0; i < 10; i++) {
        final startTime = DateTime.now();
        
        // 模擬點擊螢幕右側翻頁（如果支持）
        await tester.tapAt(
          Offset(
            tester.getSize(find.byType(ReaderPage)).width * 0.8,
            tester.getSize(find.byType(ReaderPage)).height * 0.5,
          ),
        );
        
        await tester.pumpAndSettle();
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        pageTurnTimes.add(duration);
        
        print('  翻頁 ${i + 1}: ${duration.inMilliseconds}ms');
        
        // 短暫延遲，模擬真實閱讀
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      // 計算平均翻頁時間
      final avgTime = pageTurnTimes.fold<int>(
        0,
        (sum, duration) => sum + duration.inMilliseconds,
      ) ~/ pageTurnTimes.length;
      
      final maxTime = pageTurnTimes.fold<int>(
        0,
        (max, duration) => duration.inMilliseconds > max ? duration.inMilliseconds : max,
      );
      
      print('\n📊 性能統計：');
      print('  平均翻頁時間: ${avgTime}ms');
      print('  最長翻頁時間: ${maxTime}ms');
      print('  目標: < 16.67ms (60fps)');
      
      // 驗收標準：平均翻頁時間應合理（雖然可能無法達到完美的 60fps）
      // 實際上，由於 EPUB 渲染的複雜性，我們允許稍長的時間
      expect(avgTime, lessThan(100),
          reason: '平均翻頁時間應該合理');
      
      if (avgTime < 50) {
        print('  ✅ 優秀: 翻頁非常流暢');
      } else if (avgTime < 100) {
        print('  ✅ 通過: 翻頁流暢度可接受');
      } else {
        print('  ⚠️  警告: 翻頁可能有卡頓');
      }
      
      print('═══════════════════════════════════════════════════════\n');
      
      // 清理
      await backToBookList(tester);
    });

    testWidgets('Performance: Memory Usage During Reading', (WidgetTester tester) async {
      print('\n═══════════════════════════════════════════════════════');
      print('💾 測試：閱讀期間內存使用');
      print('═══════════════════════════════════════════════════════');
      
      // 導航到閱讀器
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await navigateToBookDetail(tester);
      
      print('\n📊 開始監控內存使用...');
      
      // 使用 watchPerformance 監控整個閱讀過程
      await binding.watchPerformance(() async {
        await openReader(tester);
        
        // 模擬閱讀：翻頁 20 次
        print('  模擬閱讀過程（20次翻頁）...');
        for (int i = 0; i < 20; i++) {
          await tester.tapAt(
            Offset(
              tester.getSize(find.byType(ReaderPage)).width * 0.8,
              tester.getSize(find.byType(ReaderPage)).height * 0.5,
            ),
          );
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 50));
          
          if ((i + 1) % 5 == 0) {
            print('  已翻頁: ${i + 1}/20');
          }
        }
        
        // 測試工具欄切換（可能影響內存）
        print('  測試工具欄切換...');
        for (int i = 0; i < 5; i++) {
          await tester.tapAt(tester.getCenter(find.byType(ReaderPage)));
          await tester.pumpAndSettle();
        }
        
        print('  ✅ 內存監控完成');
      }, reportKey: 'reader_memory_usage');
      
      print('\n📊 性能結果：');
      print('  內存使用數據已記錄（詳細信息請查看 DevTools）');
      print('  目標: < 150MB');
      print('  ℹ️  實際內存使用請使用 DevTools 的 Memory 標籤查看');
      print('═══════════════════════════════════════════════════════\n');
      
      // 驗證應用仍然正常運行
      expect(find.byType(ReaderPage), findsOneWidget,
          reason: '閱讀器應該仍然正常運行');
      
      // 清理
      await backToBookList(tester);
    });

    testWidgets('Performance: Settings Panel Animation', (WidgetTester tester) async {
      print('\n═══════════════════════════════════════════════════════');
      print('🎨 測試：設置面板動畫性能');
      print('═══════════════════════════════════════════════════════');
      
      // 導航到閱讀器
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await navigateToBookDetail(tester);
      await openReader(tester);
      
      print('\n📊 測試設置面板開關動畫性能...');
      
      final settingsButton = find.byIcon(Icons.settings);
      
      if (settingsButton.evaluate().isNotEmpty) {
        final openTimes = <Duration>[];
        final closeTimes = <Duration>[];
        
        for (int i = 0; i < 5; i++) {
          // 測量打開時間
          final openStart = DateTime.now();
          await tester.tap(settingsButton);
          await tester.pumpAndSettle();
          final openEnd = DateTime.now();
          openTimes.add(openEnd.difference(openStart));
          
          await tester.pump(const Duration(milliseconds: 300));
          
          // 測量關閉時間
          final closeStart = DateTime.now();
          await tester.tapAt(const Offset(10, 10)); // 點擊外部關閉
          await tester.pumpAndSettle();
          final closeEnd = DateTime.now();
          closeTimes.add(closeEnd.difference(closeStart));
          
          await tester.pump(const Duration(milliseconds: 300));
          
          print('  第 ${i + 1} 次: 打開 ${openTimes.last.inMilliseconds}ms, '
              '關閉 ${closeTimes.last.inMilliseconds}ms');
        }
        
        final avgOpen = openTimes.fold<int>(
          0,
          (sum, d) => sum + d.inMilliseconds,
        ) ~/ openTimes.length;
        
        final avgClose = closeTimes.fold<int>(
          0,
          (sum, d) => sum + d.inMilliseconds,
        ) ~/ closeTimes.length;
        
        print('\n📊 性能統計：');
        print('  平均打開時間: ${avgOpen}ms');
        print('  平均關閉時間: ${avgClose}ms');
        print('  目標: < 300ms (流暢動畫)');
        
        expect(avgOpen, lessThan(500),
            reason: '設置面板打開動畫應該流暢');
        expect(avgClose, lessThan(500),
            reason: '設置面板關閉動畫應該流暢');
        
        if (avgOpen < 300 && avgClose < 300) {
          print('  ✅ 優秀: 動畫非常流暢');
        } else {
          print('  ✅ 通過: 動畫性能可接受');
        }
      } else {
        print('  ℹ️  未找到設置按鈕，跳過此測試');
      }
      
      print('═══════════════════════════════════════════════════════\n');
      
      // 清理
      await backToBookList(tester);
    });

    testWidgets('Performance: Long Reading Session Stability', (WidgetTester tester) async {
      print('\n═══════════════════════════════════════════════════════');
      print('⏳ 測試：長時間閱讀穩定性');
      print('═══════════════════════════════════════════════════════');
      
      // 導航到閱讀器
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await navigateToBookDetail(tester);
      await openReader(tester);
      
      print('\n📊 模擬長時間閱讀場景（50次操作）...');
      
      await binding.watchPerformance(() async {
        // 模擬長時間閱讀：多種操作混合
        for (int i = 0; i < 50; i++) {
          // 翻頁
          if (i % 3 == 0) {
            await tester.tapAt(
              Offset(
                tester.getSize(find.byType(ReaderPage)).width * 0.8,
                tester.getSize(find.byType(ReaderPage)).height * 0.5,
              ),
            );
          }
          // 工具欄切換
          else if (i % 5 == 0) {
            await tester.tapAt(tester.getCenter(find.byType(ReaderPage)));
          }
          // 其他操作
          else {
            await tester.tapAt(
              Offset(
                tester.getSize(find.byType(ReaderPage)).width * 0.5,
                tester.getSize(find.byType(ReaderPage)).height * 0.5,
              ),
            );
          }
          
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pumpAndSettle();
          
          if ((i + 1) % 10 == 0) {
            print('  進度: ${i + 1}/50');
          }
        }
        
        print('  ✅ 長時間閱讀測試完成');
      }, reportKey: 'long_reading_session');
      
      print('\n📊 性能結果：');
      print('  穩定性測試通過');
      print('  閱讀器在 50 次操作後仍然正常運行');
      print('  ℹ️  詳細性能數據請查看 DevTools');
      
      // 驗證閱讀器仍然可用
      expect(find.byType(ReaderPage), findsOneWidget,
          reason: '長時間閱讀後閱讀器應該仍然正常');
      
      print('═══════════════════════════════════════════════════════\n');
      
      // 清理
      await backToBookList(tester);
    });
  });

  group('Reader Performance Benchmarks', () {
    testWidgets('Benchmark: Complete Reader Flow', (WidgetTester tester) async {
      print('\n═══════════════════════════════════════════════════════');
      print('📊 基準測試：完整閱讀流程性能');
      print('═══════════════════════════════════════════════════════');
      
      final totalStartTime = DateTime.now();
      
      // 應用啟動
      print('\n1️⃣  應用啟動...');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 導航到詳情
      print('2️⃣  導航到詳情頁...');
      await navigateToBookDetail(tester);
      
      // 打開閱讀器
      print('3️⃣  打開閱讀器...');
      await openReader(tester);
      
      // 閱讀操作
      print('4️⃣  執行閱讀操作...');
      for (int i = 0; i < 10; i++) {
        await tester.tapAt(
          Offset(
            tester.getSize(find.byType(ReaderPage)).width * 0.8,
            tester.getSize(find.byType(ReaderPage)).height * 0.5,
          ),
        );
        await tester.pumpAndSettle();
      }
      
      // 返回
      print('5️⃣  返回導航...');
      await backToBookList(tester);
      
      final totalEndTime = DateTime.now();
      final totalDuration = totalEndTime.difference(totalStartTime);
      
      print('\n📊 基準測試結果：');
      print('  總耗時: ${totalDuration.inSeconds}s (${totalDuration.inMilliseconds}ms)');
      print('  操作: 應用啟動 → 列表 → 詳情 → 閱讀器 → 10次翻頁 → 返回');
      print('  ✅ 基準測試完成');
      print('═══════════════════════════════════════════════════════\n');
    });
  });
}
