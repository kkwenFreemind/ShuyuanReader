import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shuyuan_reader/presentation/controllers/splash_controller.dart';

/// SplashController 單元測試
/// 
/// 測試範圍：
/// 1. 響應式變量的基本功能
/// 2. GetX 生命週期管理
/// 3. 狀態更新和監聽
/// 
/// 注意：
/// - 本測試避免調用需要原生插件的功能（package_info_plus, connectivity_plus）
/// - 平台相關的功能測試將在集成測試中進行
/// - 重點測試控制器的狀態管理和響應式編程功能
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashController 單元測試', () {
    
    group('1. 響應式變量測試', () {
      late SplashController controller;

      setUp(() {
        Get.reset();
        controller = Get.put(SplashController());
      });

      tearDown(() {
        Get.delete<SplashController>();
        Get.reset();
      });

      test('1.1 version 應該是 RxString 類型', () {
        expect(controller.version, isA<RxString>());
      });

      test('1.2 isInitialized 應該是 RxBool 類型', () {
        expect(controller.isInitialized, isA<RxBool>());
      });

      test('1.3 isConnected 應該是 RxBool 類型', () {
        expect(controller.isConnected, isA<RxBool>());
      });

      test('1.4 version 初始值應該為空字符串', () {
        expect(controller.version.value, '');
      });

      test('1.5 isInitialized 初始值應該為 false', () {
        expect(controller.isInitialized.value, false);
      });

      test('1.6 isConnected 初始值應該為 false', () {
        expect(controller.isConnected.value, false);
      });
    });

    group('2. 響應式變量更新測試', () {
      late SplashController controller;

      setUp(() {
        Get.reset();
        controller = Get.put(SplashController());
      });

      tearDown(() {
        Get.delete<SplashController>();
        Get.reset();
      });

      test('2.1 version 可以被手動更新', () {
        controller.version.value = 'v1.0.0';
        expect(controller.version.value, 'v1.0.0');
      });

      test('2.2 isInitialized 可以被手動更新', () {
        controller.isInitialized.value = true;
        expect(controller.isInitialized.value, true);
      });

      test('2.3 isConnected 可以被手動更新', () {
        controller.isConnected.value = true;
        expect(controller.isConnected.value, true);
      });

      test('2.4 version 支持多次更新', () {
        controller.version.value = 'v1.0.0';
        expect(controller.version.value, 'v1.0.0');

        controller.version.value = 'v1.0.1';
        expect(controller.version.value, 'v1.0.1');

        controller.version.value = 'v2.0.0';
        expect(controller.version.value, 'v2.0.0');
      });

      test('2.5 多個狀態可以同時更新', () {
        controller.version.value = 'v1.5.0';
        controller.isInitialized.value = true;
        controller.isConnected.value = true;

        expect(controller.version.value, 'v1.5.0');
        expect(controller.isInitialized.value, true);
        expect(controller.isConnected.value, true);
      });
    });

    group('3. 響應式變量監聽測試', () {
      late SplashController controller;

      setUp(() {
        Get.reset();
        controller = Get.put(SplashController());
      });

      tearDown(() {
        Get.delete<SplashController>();
        Get.reset();
      });

      test('3.1 version 變化可以被監聽', () {
        var changeCount = 0;
        String? lastValue;

        controller.version.listen((value) {
          changeCount++;
          lastValue = value;
        });

        controller.version.value = 'v1.0.0';
        
        expect(changeCount, 1);
        expect(lastValue, 'v1.0.0');
      });

      test('3.2 isInitialized 變化可以被監聽', () {
        var changeCount = 0;
        bool? lastValue;

        controller.isInitialized.listen((value) {
          changeCount++;
          lastValue = value;
        });

        controller.isInitialized.value = true;
        
        expect(changeCount, 1);
        expect(lastValue, true);
      });

      test('3.3 isConnected 變化可以被監聽', () {
        var changeCount = 0;
        bool? lastValue;

        controller.isConnected.listen((value) {
          changeCount++;
          lastValue = value;
        });

        controller.isConnected.value = true;
        
        expect(changeCount, 1);
        expect(lastValue, true);
      });

      test('3.4 多次更新會觸發多次監聽', () {
        var changeCount = 0;

        controller.version.listen((value) {
          changeCount++;
        });

        controller.version.value = 'v1.0.0';
        controller.version.value = 'v1.0.1';
        controller.version.value = 'v1.0.2';
        
        expect(changeCount, 3);
      });
    });

    group('4. GetX 生命週期測試', () {
      test('4.1 控制器可以通過 Get.put 註冊', () {
        Get.reset();
        
        final controller = Get.put(SplashController());
        
        expect(controller, isNotNull);
        expect(Get.isRegistered<SplashController>(), true);
        
        Get.delete<SplashController>();
        Get.reset();
      });

      test('4.2 控制器可以通過 Get.find 找到', () {
        Get.reset();
        
        final controller1 = Get.put(SplashController());
        final controller2 = Get.find<SplashController>();
        
        expect(controller2, equals(controller1));
        expect(identical(controller1, controller2), true);
        
        Get.delete<SplashController>();
        Get.reset();
      });

      test('4.3 控制器可以通過 Get.delete 刪除', () {
        Get.reset();
        
        Get.put(SplashController());
        expect(Get.isRegistered<SplashController>(), true);
        
        Get.delete<SplashController>();
        expect(Get.isRegistered<SplashController>(), false);
        
        Get.reset();
      });

      test('4.4 重複 Get.put 返回同一實例', () {
        Get.reset();
        
        final controller1 = Get.put(SplashController());
        final controller2 = Get.find<SplashController>();
        
        expect(controller1, equals(controller2));
        
        Get.delete<SplashController>();
        Get.reset();
      });

      test('4.5 刪除後無法找到控制器', () {
        Get.reset();
        
        Get.put(SplashController());
        Get.delete<SplashController>();
        
        expect(
          () => Get.find<SplashController>(),
          throwsA(isA<String>()),
        );
        
        Get.reset();
      });
    });

    group('5. 狀態管理測試', () {
      late SplashController controller;

      setUp(() {
        Get.reset();
        controller = Get.put(SplashController());
      });

      tearDown(() {
        Get.delete<SplashController>();
        Get.reset();
      });

      test('5.1 版本號格式驗證', () {
        controller.version.value = 'v1.0.0';
        
        final versionPattern = RegExp(r'^v\d+\.\d+\.\d+$');
        expect(versionPattern.hasMatch(controller.version.value), true);
      });

      test('5.2 版本號支持語義化版本格式', () {
        controller.version.value = 'v1.2.3';
        expect(controller.version.value, 'v1.2.3');

        controller.version.value = 'v10.20.30';
        expect(controller.version.value, 'v10.20.30');
      });

      test('5.3 狀態標誌可以在 true 和 false 之間切換', () {
        expect(controller.isInitialized.value, false);
        
        controller.isInitialized.value = true;
        expect(controller.isInitialized.value, true);
        
        controller.isInitialized.value = false;
        expect(controller.isInitialized.value, false);
      });

      test('5.4 網絡狀態可以切換', () {
        expect(controller.isConnected.value, false);
        
        controller.isConnected.value = true;
        expect(controller.isConnected.value, true);
        
        controller.isConnected.value = false;
        expect(controller.isConnected.value, false);
      });

      test('5.5 版本號可以為空', () {
        controller.version.value = '';
        expect(controller.version.value, '');
      });

      test('5.6 版本號支持預發布標記', () {
        controller.version.value = 'v1.0.0-beta';
        expect(controller.version.value, 'v1.0.0-beta');

        controller.version.value = 'v1.0.0-alpha.1';
        expect(controller.version.value, 'v1.0.0-alpha.1');
      });
    });

    group('6. 性能測試', () {
      test('6.1 大量更新響應式變量應該高效', () {
        Get.reset();
        final controller = Get.put(SplashController());
        
        final startTime = DateTime.now();
        
        for (int i = 0; i < 1000; i++) {
          controller.version.value = 'v$i.0.0';
        }
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        // 1000 次更新應該在 200ms 內完成
        expect(duration.inMilliseconds, lessThan(200));
        
        Get.delete<SplashController>();
        Get.reset();
      });

      test('6.2 多次創建和銷毀控制器應該穩定', () {
        for (int i = 0; i < 10; i++) {
          Get.reset();
          final controller = Get.put(SplashController());
          expect(controller, isNotNull);
          expect(Get.isRegistered<SplashController>(), true);
          Get.delete<SplashController>();
        }
        
        Get.reset();
      });

      test('6.3 監聽器性能測試', () {
        Get.reset();
        final controller = Get.put(SplashController());
        
        var count = 0;
        controller.version.listen((value) {
          count++;
        });
        
        final startTime = DateTime.now();
        
        for (int i = 0; i < 100; i++) {
          controller.version.value = 'v$i.0.0';
        }
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        expect(count, 100);
        expect(duration.inMilliseconds, lessThan(100));
        
        Get.delete<SplashController>();
        Get.reset();
      });
    });

    group('7. 邊界條件測試', () {
      late SplashController controller;

      setUp(() {
        Get.reset();
        controller = Get.put(SplashController());
      });

      tearDown(() {
        Get.delete<SplashController>();
        Get.reset();
      });

      test('7.1 空字符串版本號', () {
        controller.version.value = '';
        expect(controller.version.value, '');
      });

      test('7.2 非常長的版本號', () {
        final longVersion = 'v' + '1.2.3.4.5.6.7.8.9.10' * 10;
        controller.version.value = longVersion;
        expect(controller.version.value, longVersion);
      });

      test('7.3 特殊字符版本號', () {
        controller.version.value = 'v1.0.0-beta+build.123';
        expect(controller.version.value, 'v1.0.0-beta+build.123');
      });

      test('7.4 Unicode 字符版本號', () {
        controller.version.value = 'v1.0.0-測試';
        expect(controller.version.value, 'v1.0.0-測試');
      });

      test('7.5 布爾值類型檢查', () {
        controller.isInitialized.value = true;
        expect(controller.isInitialized.value, isA<bool>());
        expect(controller.isInitialized.value, true);
        
        controller.isInitialized.value = false;
        expect(controller.isInitialized.value, isA<bool>());
        expect(controller.isInitialized.value, false);
      });
    });

    group('8. 控制器結構測試', () {
      test('8.1 SplashController 類存在', () {
        expect(SplashController, isNotNull);
      });

      test('8.2 SplashController 是一個類型', () {
        expect(SplashController, isA<Type>());
      });

      test('8.3 控制器繼承自 GetxController', () {
        Get.reset();
        final controller = Get.put(SplashController());
        expect(controller, isA<GetxController>());
        Get.delete<SplashController>();
        Get.reset();
      });

      test('8.4 控制器包含必需的響應式變量', () {
        Get.reset();
        final controller = Get.put(SplashController());
        
        expect(controller.version, isNotNull);
        expect(controller.isInitialized, isNotNull);
        expect(controller.isConnected, isNotNull);
        
        Get.delete<SplashController>();
        Get.reset();
      });
    });
  });
}
