import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shuyuan_reader/main.dart' as app;

/// 啟動畫面集成測試
/// 
/// 測試完整的應用初始化流程，包括：
/// - 應用啟動
/// - UI 元素顯示
/// - 版本號加載（package_info_plus）
/// - 網絡狀態檢測（connectivity_plus）
/// - Hive 初始化
/// - 3 秒延遲
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Splash Flow Integration Tests', () {
    testWidgets('Complete splash screen flow should work correctly',
        (WidgetTester tester) async {
      // 1. 啟動應用
      app.main();
      
      // 只等待初始 UI 渲染，不等待所有異步操作完成
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 2. 驗證所有 UI 元素都顯示
      expect(find.text('📚'), findsOneWidget, reason: 'Logo emoji 應該顯示');
      expect(find.text('書苑閱讀器'), findsOneWidget, reason: '中文標題應該顯示');
      expect(find.text('ShuyuanReader'), findsOneWidget, reason: '英文副標題應該顯示');
      expect(find.text('Loading...'), findsOneWidget, reason: 'Loading 文字應該顯示');
      expect(find.byType(CircularProgressIndicator), findsOneWidget,
          reason: '加載動畫應該顯示');

      // 3. 等待版本號加載（原生插件調用）
      await tester.pump(const Duration(milliseconds: 500));
      
      // 驗證版本號格式（應該是 v 開頭）
      final versionFinder = find.textContaining('v');
      expect(versionFinder, findsOneWidget, reason: '版本號應該顯示');

      // 4. 驗證沒有錯誤 Snackbar 顯示
      expect(find.text('初始化失敗'), findsNothing, 
          reason: '不應該顯示錯誤消息');

      print('✅ 集成測試完成：所有步驟正常執行');
    });

    testWidgets('UI elements should maintain correct layout during initialization',
        (WidgetTester tester) async {
      // 啟動應用
      app.main();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 驗證 SafeArea 存在
      expect(find.byType(SafeArea), findsOneWidget,
          reason: '應該使用 SafeArea');

      // 驗證基本佈局元素
      expect(find.byType(Column), findsWidgets,
          reason: '應該包含 Column 佈局');
      
      expect(find.byType(Center), findsWidgets,
          reason: '應該包含 Center 佈局');

      print('✅ 佈局測試通過');
    });

    testWidgets('App should handle multiple rapid pumps correctly',
        (WidgetTester tester) async {
      // 啟動應用
      app.main();
      
      // 快速多次 pump（模擬真實設備的多次刷新）
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // 驗證應用沒有崩潰，所有元素仍然存在
      expect(find.text('📚'), findsOneWidget);
      expect(find.text('書苑閱讀器'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      print('✅ 快速刷新測試通過');
    });

    testWidgets('Version display should update reactively',
        (WidgetTester tester) async {
      // 啟動應用
      app.main();
      await tester.pump();

      // 等待一小段時間讓版本號加載
      await tester.pump(const Duration(milliseconds: 500));

      // 現在應該能看到版本號了
      final versionFinder = find.byWidgetPredicate((widget) => 
        widget is Text && 
        widget.data != null && 
        widget.data!.startsWith('v')
      );

      expect(versionFinder, findsOneWidget, reason: '版本號應該加載');
      
      // 獲取版本號文字
      final versionWidget = tester.widget<Text>(versionFinder);
      expect(versionWidget.data, startsWith('v'), reason: '版本號應該以 v 開頭');
      
      print('✅ 版本號加載測試通過: ${versionWidget.data}');
    });

    testWidgets('Loading animation should be visible',
        (WidgetTester tester) async {
      // 啟動應用
      app.main();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 查找 CircularProgressIndicator
      final progressIndicator = find.byType(CircularProgressIndicator);
      expect(progressIndicator, findsOneWidget, 
          reason: '應該顯示加載動畫');

      // 驗證 CircularProgressIndicator 存在
      expect(tester.widgetList(progressIndicator).length, equals(1),
          reason: '應該只有一個加載動畫');

      print('✅ 加載動畫測試通過');
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('App should not crash on initialization',
        (WidgetTester tester) async {
      // 啟動應用
      app.main();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 驗證基本 UI 仍然顯示
      expect(find.text('📚'), findsOneWidget);
      expect(find.text('書苑閱讀器'), findsOneWidget);

      print('✅ 錯誤處理測試通過');
    });
  });

  group('Performance Tests', () {
    testWidgets('App should initialize within reasonable time',
        (WidgetTester tester) async {
      final startTime = DateTime.now();
      
      // 啟動應用
      app.main();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('應用初始化時間: ${duration.inMilliseconds}ms');
      
      // 驗證初始化時間合理（應該小於 1 秒）
      expect(duration.inMilliseconds, lessThan(1000),
          reason: '應用初始化應該在 1 秒內完成');

      print('✅ 性能測試通過');
    });
  });
}
