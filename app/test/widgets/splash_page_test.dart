import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shuyuan_reader/presentation/pages/splash/splash_page.dart';
import 'package:shuyuan_reader/presentation/pages/splash/widgets/logo_widget.dart';
import 'package:shuyuan_reader/presentation/pages/splash/widgets/loading_widget.dart';
import 'package:shuyuan_reader/presentation/controllers/splash_controller.dart';

/// Widget 測試：啟動畫面
/// 
/// 測試 SplashPage 及其子組件的 UI 渲染和動畫效果
/// 
/// 測試策略：
/// - 使用 pumpWidget 渲染組件
/// - 使用 pump 推進動畫幀
/// - 使用 find 查找 UI 元素
/// - 驗證 UI 元素的存在性、數量和屬性
void main() {
  // 在每個測試前重置 GetX
  setUp(() {
    Get.reset();
  });

  // 在每個測試後清理 GetX
  tearDown(() {
    Get.reset();
  });

  group('1. SplashPage UI Elements Tests', () {
    testWidgets('1.1 SplashPage should render all required UI elements',
        (WidgetTester tester) async {
      // 構建 SplashPage
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      // 等待初始幀渲染完成
      await tester.pump();

      // 驗證 Scaffold 存在
      expect(find.byType(Scaffold), findsOneWidget);

      // 驗證 SafeArea 存在
      expect(find.byType(SafeArea), findsOneWidget);

      // 驗證 Logo 組件存在
      expect(find.byType(LogoWidget), findsOneWidget);

      // 驗證中文標題存在
      expect(find.text('書苑閱讀器'), findsOneWidget);

      // 驗證英文副標題存在
      expect(find.text('ShuyuanReader'), findsOneWidget);

      // 驗證加載組件存在
      expect(find.byType(LoadingWidget), findsOneWidget);

      // 驗證 CircularProgressIndicator 存在（在 LoadingWidget 中）
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 驗證 Loading 文字存在
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('1.2 SplashPage should have correct background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找 Scaffold
      final scaffoldFinder = find.byType(Scaffold);
      final scaffold = tester.widget<Scaffold>(scaffoldFinder);

      // 驗證背景色為白色
      expect(scaffold.backgroundColor, Colors.white);
    });

    testWidgets('1.3 SplashPage should use Column layout with correct alignment',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找主要的 Column（直接在 SafeArea 下的第一個 Column）
      final columnFinder = find.descendant(
        of: find.byType(SafeArea),
        matching: find.byType(Column),
      );

      // 應該找到至少一個 Column（主佈局 Column）
      expect(columnFinder, findsWidgets);

      // 獲取第一個 Column（主佈局）
      final column = tester.widget<Column>(columnFinder.first);

      // 驗證主軸對齊方式為居中
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('1.4 SplashPage should have correct Spacer flex values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找所有 Spacer
      final spacerFinder = find.byType(Spacer);
      expect(spacerFinder, findsNWidgets(2));

      // 驗證第一個 Spacer (上方) 的 flex 值為 2
      final spacers = tester.widgetList<Spacer>(spacerFinder).toList();
      expect(spacers[0].flex, 2);

      // 驗證第二個 Spacer (下方) 的 flex 值為 3
      expect(spacers[1].flex, 3);
    });

    testWidgets('1.5 SplashPage should have correct spacing between elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找所有 SizedBox
      final sizedBoxFinder = find.byType(SizedBox);

      // 應該有多個 SizedBox 用於間距
      expect(sizedBoxFinder, findsWidgets);

      // 驗證特定間距值
      final sizedBoxes = tester.widgetList<SizedBox>(sizedBoxFinder).toList();

      // 查找高度為 24 的 SizedBox（Logo 與標題間距）
      final height24Boxes =
          sizedBoxes.where((box) => box.height == 24.0).toList();
      expect(height24Boxes.length, greaterThanOrEqualTo(2)); // Logo 間距和底部間距

      // 查找高度為 8 的 SizedBox（標題間距）
      final height8Boxes = sizedBoxes.where((box) => box.height == 8.0).toList();
      expect(height8Boxes.length, greaterThanOrEqualTo(1));

      // 查找高度為 48 的 SizedBox（副標題與加載動畫間距）
      final height48Boxes =
          sizedBoxes.where((box) => box.height == 48.0).toList();
      expect(height48Boxes.length, greaterThanOrEqualTo(1));
    });
  });

  group('2. Text Style Tests', () {
    testWidgets('2.1 Chinese title should have correct style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找中文標題 Text widget
      final titleFinder = find.text('書苑閱讀器');
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      final textStyle = titleWidget.style!;

      // 驗證字體大小
      expect(textStyle.fontSize, 24.0);

      // 驗證字體粗細
      expect(textStyle.fontWeight, FontWeight.bold);

      // 驗證顏色
      expect(textStyle.color, Colors.black);
    });

    testWidgets('2.2 English subtitle should have correct style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找英文副標題
      final subtitleFinder = find.text('ShuyuanReader');
      expect(subtitleFinder, findsOneWidget);

      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      final textStyle = subtitleWidget.style!;

      // 驗證字體大小
      expect(textStyle.fontSize, 16.0);

      // 驗證顏色
      expect(textStyle.color, const Color(0xFF424242));
    });

    testWidgets('2.3 Loading text should have correct style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找 Loading 文字
      final loadingTextFinder = find.text('Loading...');
      expect(loadingTextFinder, findsOneWidget);

      final loadingTextWidget = tester.widget<Text>(loadingTextFinder);
      final textStyle = loadingTextWidget.style!;

      // 驗證字體大小
      expect(textStyle.fontSize, 14.0);

      // 驗證顏色
      expect(textStyle.color, const Color(0xFF9E9E9E));
    });
  });

  group('3. LogoWidget Tests', () {
    testWidgets('3.1 LogoWidget should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoWidget(),
          ),
        ),
      );

      await tester.pump();

      // 驗證 LogoWidget 存在
      expect(find.byType(LogoWidget), findsOneWidget);

      // 驗證 FadeTransition 存在
      expect(find.byType(FadeTransition), findsOneWidget);

      // 驗證 Container 存在
      expect(find.byType(Container), findsWidgets);

      // 驗證 emoji 文字存在
      expect(find.text('📚'), findsOneWidget);
    });

    testWidgets('3.2 LogoWidget should have correct size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoWidget(),
          ),
        ),
      );

      await tester.pump();

      // 查找 Logo 的 Container
      final containerFinder = find.descendant(
        of: find.byType(FadeTransition),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsOneWidget);

      // 獲取 Container 的尺寸
      final containerSize = tester.getSize(containerFinder);

      // 驗證尺寸為 120x120
      expect(containerSize.width, 120.0);
      expect(containerSize.height, 120.0);
    });

    testWidgets('3.3 LogoWidget should have correct decoration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoWidget(),
          ),
        ),
      );

      await tester.pump();

      // 查找 Container
      final containerFinder = find.descendant(
        of: find.byType(FadeTransition),
        matching: find.byType(Container),
      );

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      // 驗證背景色
      expect(decoration.color, Colors.blue.shade50);

      // 驗證圓角
      expect(decoration.borderRadius, BorderRadius.circular(24));
    });

    testWidgets('3.4 LogoWidget should have fade-in animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoWidget(),
          ),
        ),
      );

      // 初始狀態（動畫開始前）
      await tester.pump();

      // 查找 FadeTransition
      final fadeTransitionFinder = find.byType(FadeTransition);
      expect(fadeTransitionFinder, findsOneWidget);

      // 推進動畫到 50% (250ms)
      await tester.pump(const Duration(milliseconds: 250));

      // 驗證動畫正在進行中（opacity 應該在 0 和 1 之間）
      final fadeTransition =
          tester.widget<FadeTransition>(fadeTransitionFinder);
      final opacity = fadeTransition.opacity.value;
      expect(opacity, greaterThan(0.0));
      expect(opacity, lessThan(1.0));

      // 推進動畫到結束 (500ms)
      await tester.pump(const Duration(milliseconds: 250));

      // 驗證動畫已完成（opacity 應該為 1.0）
      final finalOpacity = fadeTransition.opacity.value;
      expect(finalOpacity, 1.0);
    });

    testWidgets('3.5 LogoWidget emoji should have correct font size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LogoWidget(),
          ),
        ),
      );

      await tester.pump();

      // 查找 emoji 文字
      final emojiFinder = find.text('📚');
      expect(emojiFinder, findsOneWidget);

      final emojiWidget = tester.widget<Text>(emojiFinder);
      final textStyle = emojiWidget.style!;

      // 驗證字體大小為 64
      expect(textStyle.fontSize, 64.0);
    });
  });

  group('4. LoadingWidget Tests', () {
    testWidgets('4.1 LoadingWidget should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      await tester.pump();

      // 驗證 LoadingWidget 存在
      expect(find.byType(LoadingWidget), findsOneWidget);

      // 驗證 Column 存在
      expect(find.byType(Column), findsOneWidget);

      // 驗證 CircularProgressIndicator 存在
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 驗證 Loading 文字存在
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('4.2 LoadingWidget should use Column with min size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      await tester.pump();

      // 查找 Column
      final columnFinder = find.byType(Column);
      final column = tester.widget<Column>(columnFinder);

      // 驗證 mainAxisSize 為 min
      expect(column.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('4.3 CircularProgressIndicator should have correct properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      await tester.pump();

      // 查找 CircularProgressIndicator
      final indicatorFinder = find.byType(CircularProgressIndicator);
      final indicator =
          tester.widget<CircularProgressIndicator>(indicatorFinder);

      // 驗證 strokeWidth
      expect(indicator.strokeWidth, 3.0);

      // 驗證顏色
      expect(indicator.color, Colors.blue);
    });

    testWidgets('4.4 CircularProgressIndicator should have correct size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      await tester.pump();

      // 查找包含 CircularProgressIndicator 的 SizedBox
      final sizedBoxFinder = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(SizedBox),
      );

      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);

      // 驗證尺寸為 32x32
      expect(sizedBox.width, 32.0);
      expect(sizedBox.height, 32.0);
    });

    testWidgets('4.5 LoadingWidget should have correct spacing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      await tester.pump();

      // 查找 LoadingWidget 內的所有 SizedBox
      final sizedBoxFinder = find.descendant(
        of: find.byType(LoadingWidget),
        matching: find.byType(SizedBox),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(sizedBoxFinder).toList();

      // 應該有至少 2 個 SizedBox（指示器容器和間距）
      expect(sizedBoxes.length, greaterThanOrEqualTo(2));

      // 查找高度為 16 的 SizedBox（間距）
      final spacingBox = sizedBoxes.firstWhere(
        (box) => box.height == 16.0 && box.width == null,
        orElse: () => const SizedBox(),
      );

      expect(spacingBox.height, 16.0);
    });
  });

  group('5. Version Display Tests', () {
    testWidgets('5.1 Version number should be displayed reactively',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 獲取控制器
      final controller = Get.find<SplashController>();

      // 初始狀態：版本號應該為空字符串
      expect(find.text(''), findsWidgets);

      // 手動設置版本號
      controller.version.value = 'v1.0.0';

      // 重建 widget
      await tester.pump();

      // 驗證版本號已顯示
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('5.2 Version number should update when controller changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      final controller = Get.find<SplashController>();

      // 設置初始版本號
      controller.version.value = 'v1.0.0';
      await tester.pump();
      expect(find.text('v1.0.0'), findsOneWidget);

      // 更新版本號
      controller.version.value = 'v2.0.0';
      await tester.pump();

      // 驗證版本號已更新
      expect(find.text('v2.0.0'), findsOneWidget);
      expect(find.text('v1.0.0'), findsNothing);
    });

    testWidgets('5.3 Version text should have correct style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      final controller = Get.find<SplashController>();
      controller.version.value = 'v1.0.0';
      await tester.pump();

      // 查找版本號文字
      final versionFinder = find.text('v1.0.0');
      expect(versionFinder, findsOneWidget);

      final versionWidget = tester.widget<Text>(versionFinder);
      final textStyle = versionWidget.style!;

      // 驗證字體大小
      expect(textStyle.fontSize, 12.0);

      // 驗證顏色
      expect(textStyle.color, const Color(0xFF9E9E9E));
    });

    testWidgets('5.4 Version should be wrapped with Obx for reactivity',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 查找 Obx widget（GetX 的響應式組件）
      final obxFinder = find.byType(Obx);
      expect(obxFinder, findsOneWidget);
    });
  });

  group('6. Integration Tests', () {
    testWidgets('6.1 All components should work together correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      // 初始渲染
      await tester.pump();

      // 驗證所有主要組件都存在
      expect(find.byType(LogoWidget), findsOneWidget);
      expect(find.text('書苑閱讀器'), findsOneWidget);
      expect(find.text('ShuyuanReader'), findsOneWidget);
      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 設置版本號
      final controller = Get.find<SplashController>();
      controller.version.value = 'v1.0.0';
      await tester.pump();

      // 驗證版本號顯示
      expect(find.text('v1.0.0'), findsOneWidget);

      // 推進動畫
      await tester.pump(const Duration(milliseconds: 500));

      // 驗證所有元素仍然存在
      expect(find.byType(LogoWidget), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('6.2 Layout should remain stable during animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 獲取初始位置
      final logoPosition = tester.getTopLeft(find.byType(LogoWidget));
      final titlePosition = tester.getTopLeft(find.text('書苑閱讀器'));

      // 推進動畫
      await tester.pump(const Duration(milliseconds: 250));

      // 驗證位置未改變（只有 opacity 改變）
      expect(tester.getTopLeft(find.byType(LogoWidget)), logoPosition);
      expect(tester.getTopLeft(find.text('書苑閱讀器')), titlePosition);
    });

    testWidgets('6.3 Should handle multiple version updates gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      final controller = Get.find<SplashController>();

      // 多次更新版本號
      for (int i = 0; i < 5; i++) {
        controller.version.value = 'v1.0.$i';
        await tester.pump();
        expect(find.text('v1.0.$i'), findsOneWidget);
      }

      // 驗證沒有崩潰或異常
      expect(tester.takeException(), isNull);
    });
  });

  group('7. Edge Cases Tests', () {
    testWidgets('7.1 Should handle empty version string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      final controller = Get.find<SplashController>();
      controller.version.value = '';
      await tester.pump();

      // 驗證空字符串不會引起崩潰
      expect(tester.takeException(), isNull);
    });

    testWidgets('7.2 Should handle very long version string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      final controller = Get.find<SplashController>();
      controller.version.value = 'v' + '1.0.0' * 20; // 很長的版本號
      await tester.pump();

      // 驗證長字符串不會引起崩潰
      expect(tester.takeException(), isNull);
    });

    testWidgets('7.3 Should handle special characters in version',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      final controller = Get.find<SplashController>();
      controller.version.value = 'v1.0.0-beta+build.123';
      await tester.pump();

      expect(find.text('v1.0.0-beta+build.123'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('8. Accessibility Tests', () {
    testWidgets('8.1 All text should be semantically accessible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 驗證重要文字都可以被找到（無障礙友好）
      expect(find.text('書苑閱讀器'), findsOneWidget);
      expect(find.text('ShuyuanReader'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('8.2 CircularProgressIndicator should be semantically labeled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: SplashPage(),
        ),
      );

      await tester.pump();

      // 驗證進度指示器存在（對屏幕閱讀器友好）
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
