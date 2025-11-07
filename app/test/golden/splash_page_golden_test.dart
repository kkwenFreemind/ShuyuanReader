import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuyuan_reader/presentation/pages/splash/widgets/logo_widget.dart';
import 'package:shuyuan_reader/presentation/pages/splash/widgets/loading_widget.dart';

void main() {
  group('LogoWidget Golden Tests', () {
    testWidgets('1. LogoWidget should match golden snapshot - initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Center(
              child: LogoWidget(),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(LogoWidget),
        matchesGoldenFile('goldens/logo_widget_initial.png'),
      );
    });

    testWidgets('2. LogoWidget should match golden snapshot - after animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Center(
              child: LogoWidget(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      await expectLater(
        find.byType(LogoWidget),
        matchesGoldenFile('goldens/logo_widget_after_animation.png'),
      );
    });

    testWidgets('3. LogoWidget should match golden snapshot - mid animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Center(
              child: LogoWidget(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await expectLater(
        find.byType(LogoWidget),
        matchesGoldenFile('goldens/logo_widget_mid_animation.png'),
      );
    });

    testWidgets('4. LogoWidget should match golden snapshot - with custom background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: LogoWidget(),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(LogoWidget),
        matchesGoldenFile('goldens/logo_widget_custom_bg.png'),
      );
    });
  });

  group('LoadingWidget Golden Tests', () {
    testWidgets('5. LoadingWidget should match golden snapshot',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Center(
              child: LoadingWidget(),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(LoadingWidget),
        matchesGoldenFile('goldens/loading_widget_default.png'),
      );
    });

    testWidgets('6. LoadingWidget should match golden snapshot - with custom background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.blueGrey,
            body: Center(
              child: LoadingWidget(),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(LoadingWidget),
        matchesGoldenFile('goldens/loading_widget_custom_bg.png'),
      );
    });
  });

  group('Combined Layout Golden Tests', () {
    testWidgets('7. Logo and Loading together should match golden snapshot',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoWidget(),
                  const SizedBox(height: 48),
                  LoadingWidget(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/combined_layout.png'),
      );
    });

    testWidgets('8. Full splash layout should match golden',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LogoWidget(),
                      const SizedBox(height: 48),
                      LoadingWidget(),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48,
                  child: Center(
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_splash_layout.png'),
      );
    });
  });

  group('Responsive Layout Golden Tests', () {
    testWidgets('9. Full layout should match golden - small screen (320x480)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LogoWidget(),
                      const SizedBox(height: 48),
                      LoadingWidget(),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48,
                  child: Center(
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_splash_small_screen.png'),
      );
    });

    testWidgets('10. Full layout should match golden - large screen (414x896)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LogoWidget(),
                      const SizedBox(height: 48),
                      LoadingWidget(),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48,
                  child: Center(
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_splash_large_screen.png'),
      );
    });

    testWidgets('11. Full layout should match golden - tablet (1024x768)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LogoWidget(),
                      const SizedBox(height: 48),
                      LoadingWidget(),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48,
                  child: Center(
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/full_splash_tablet.png'),
      );
    });
  });

  group('Text Styling Golden Tests', () {
    testWidgets('12. Text elements should match golden snapshot',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF232323),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'v10.22.333',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/text_styling.png'),
      );
    });
  });
}
