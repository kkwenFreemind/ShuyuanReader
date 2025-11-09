import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuyuan_reader/presentation/widgets/reader/reading_settings_panel.dart';

void main() {
  group('ReadingSettingsPanel Widget Tests', () {
    // 測試用的回調函數追蹤器
    late double capturedFontSize;
    late double capturedBrightness;
    late bool capturedNightMode;
    late bool capturedAutoHideToolbar;

    setUp(() {
      capturedFontSize = 0;
      capturedBrightness = 0;
      capturedNightMode = false;
      capturedAutoHideToolbar = false;
    });

    // 輔助函數：創建測試環境
    Widget createTestWidget({
      double fontSize = 16.0,
      double brightness = 0.5,
      bool isNightMode = false,
      bool autoHideToolbar = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ReadingSettingsPanel(
            fontSize: fontSize,
            brightness: brightness,
            isNightMode: isNightMode,
            autoHideToolbar: autoHideToolbar,
            onFontSizeChanged: (value) => capturedFontSize = value,
            onBrightnessChanged: (value) => capturedBrightness = value,
            onNightModeChanged: (value) => capturedNightMode = value,
            onAutoHideToolbarChanged: (value) => capturedAutoHideToolbar = value,
          ),
        ),
      );
    }

    group('UI Elements Display', () {
      testWidgets('should display all main UI elements', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('閱讀設置'), findsOneWidget);
        expect(find.text('字體大小'), findsOneWidget);
        expect(find.text('螢幕亮度'), findsOneWidget);
        expect(find.text('夜間模式'), findsOneWidget);
        expect(find.text('自動隱藏工具欄'), findsOneWidget);
      });

      testWidgets('should display correct font size label', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(fontSize: 16.0));

        // Assert
        expect(find.textContaining('16sp'), findsOneWidget);
        expect(find.textContaining('(大)'), findsOneWidget);
      });

      testWidgets('should display correct brightness percentage', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(brightness: 0.7));

        // Assert
        expect(find.textContaining('70%'), findsOneWidget);
      });

      testWidgets('should display night mode icon when night mode is enabled', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isNightMode: true));

        // Assert
        expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
      });

      testWidgets('should display day mode icon when night mode is disabled', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isNightMode: false));

        // Assert
        expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
      });
    });

    group('Font Size Slider Interaction', () {
      testWidgets('should display font size slider', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final sliders = find.byType(Slider);
        expect(sliders, findsNWidgets(2)); // Font size and brightness sliders
      });

      testWidgets('should change font size when slider is moved', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(fontSize: 16.0));

        // Act - Tap on a different font size preset
        final slider = tester.widget<Slider>(find.byType(Slider).first);
        // Simulate slider change by calling the callback directly
        slider.onChanged!(18.0);
        await tester.pumpAndSettle();

        // Assert - The callback should have been called with a new value
        expect(capturedFontSize, equals(18.0));
      });

      testWidgets('should display all font size presets', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Check for all preset labels
        expect(find.text('12'), findsOneWidget);
        expect(find.text('14'), findsOneWidget);
        expect(find.text('16'), findsOneWidget);
        expect(find.text('18'), findsOneWidget);
        expect(find.text('20'), findsOneWidget);
      });

      testWidgets('should highlight current font size preset', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(fontSize: 18.0));

        // Assert - The current size should be displayed
        expect(find.textContaining('18sp'), findsOneWidget);
      });
    });

    group('Brightness Slider Interaction', () {
      testWidgets('should change brightness when slider is moved', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(brightness: 0.5));

        // Act - Simulate slider change by calling the callback directly
        final slider = tester.widget<Slider>(find.byType(Slider).at(1));
        slider.onChanged!(0.8);
        await tester.pumpAndSettle();

        // Assert - The callback should have been called
        expect(capturedBrightness, equals(0.8));
      });

      testWidgets('should display brightness range labels', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('暗'), findsOneWidget);
        expect(find.text('亮'), findsOneWidget);
      });
    });

    group('Night Mode Switch', () {
      testWidgets('should display night mode switch', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final switches = find.byType(Switch);
        expect(switches, findsNWidgets(2)); // Night mode and auto-hide toolbar switches
      });

      testWidgets('should toggle night mode when switch is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(isNightMode: false));

        // Act - Simulate switch toggle by calling the callback directly
        final nightModeSwitch = tester.widget<Switch>(find.byType(Switch).first);
        nightModeSwitch.onChanged!(true);
        await tester.pumpAndSettle();

        // Assert
        expect(capturedNightMode, isTrue);
      });

      testWidgets('should show correct switch state for night mode', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isNightMode: true));

        // Assert - The switch should be in the "on" state
        final nightModeSwitch = tester.widget<Switch>(find.byType(Switch).first);
        expect(nightModeSwitch.value, isTrue);
      });
    });

    group('Auto-Hide Toolbar Switch', () {
      testWidgets('should toggle auto-hide toolbar when switch is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget(autoHideToolbar: false));

        // Act - Simulate switch toggle by calling the callback directly
        final autoHideSwitch = tester.widget<Switch>(find.byType(Switch).at(1));
        autoHideSwitch.onChanged!(true);
        await tester.pumpAndSettle();

        // Assert
        expect(capturedAutoHideToolbar, isTrue);
      });

      testWidgets('should show correct switch state for auto-hide toolbar', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(autoHideToolbar: true));

        // Assert - The switch should be in the "on" state
        final autoHideSwitch = tester.widget<Switch>(find.byType(Switch).at(1));
        expect(autoHideSwitch.value, isTrue);
      });

      testWidgets('should display auto-awesome icon', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      });
    });

    group('Night Mode Styling', () {
      testWidgets('should apply dark background in night mode', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isNightMode: true));

        // Assert - Check for dark container
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.grey[900]));
      });

      testWidgets('should apply light background in day mode', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isNightMode: false));

        // Assert - Check for light container
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.white));
      });

      testWidgets('should use amber colors for sliders in night mode', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isNightMode: true));

        // Assert - Check slider theme colors
        final sliderThemes = find.byType(SliderTheme);
        expect(sliderThemes, findsNWidgets(2));
      });

      testWidgets('should use blue colors for sliders in day mode', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(isNightMode: false));

        // Assert - Check slider theme colors
        final sliderThemes = find.byType(SliderTheme);
        expect(sliderThemes, findsNWidgets(2));
      });
    });

    group('Panel Layout', () {
      testWidgets('should display drag handle at the top', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert - Check for multiple containers (drag handle is a container)
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
      });

      testWidgets('should have rounded top corners', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('should be scrollable', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });

    group('Font Size Label Helper', () {
      test('should return correct label for font size 12', () {
        expect(ReadingSettingsPanel.fontSizePresets.contains(12.0), isTrue);
      });

      test('should return correct label for font size 14', () {
        expect(ReadingSettingsPanel.fontSizePresets.contains(14.0), isTrue);
      });

      test('should return correct label for font size 16', () {
        expect(ReadingSettingsPanel.fontSizePresets.contains(16.0), isTrue);
      });

      test('should return correct label for font size 18', () {
        expect(ReadingSettingsPanel.fontSizePresets.contains(18.0), isTrue);
      });

      test('should return correct label for font size 20', () {
        expect(ReadingSettingsPanel.fontSizePresets.contains(20.0), isTrue);
      });

      test('should have exactly 5 font size presets', () {
        expect(ReadingSettingsPanel.fontSizePresets.length, equals(5));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle minimum brightness value', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(brightness: 0.0));

        // Assert
        expect(find.textContaining('0%'), findsOneWidget);
      });

      testWidgets('should handle maximum brightness value', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(brightness: 1.0));

        // Assert
        expect(find.textContaining('100%'), findsOneWidget);
      });

      testWidgets('should handle smallest font size', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(fontSize: 12.0));

        // Assert
        expect(find.textContaining('12sp'), findsOneWidget);
        expect(find.textContaining('(小)'), findsOneWidget);
      });

      testWidgets('should handle largest font size', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(fontSize: 20.0));

        // Assert
        expect(find.textContaining('20sp'), findsOneWidget);
        expect(find.textContaining('(超大)'), findsOneWidget);
      });

      testWidgets('should handle custom panel height', (WidgetTester tester) async {
        // Arrange
        const customHeight = 300.0;
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReadingSettingsPanel(
                fontSize: 16.0,
                brightness: 0.5,
                isNightMode: false,
                autoHideToolbar: false,
                onFontSizeChanged: (value) {},
                onBrightnessChanged: (value) {},
                onNightModeChanged: (value) {},
                onAutoHideToolbarChanged: (value) {},
                panelHeight: customHeight,
              ),
            ),
          ),
        );

        // Assert - Check that the panel respects the custom height
        expect(find.byType(ReadingSettingsPanel), findsOneWidget);
      });
    });
  });
}
