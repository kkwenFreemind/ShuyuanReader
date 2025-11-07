# Spec 01: 啟動畫面（Splash Screen）

**功能名稱**: Splash Screen  
**優先級**: P0 (必須有)  
**預估時間**: 1 天 (8 小時)  
**依賴**: Spec 00 (專案設置)  
**狀態**: ⬜ 未開始  
**創建日期**: 2025-11-07

---

## 📋 概述

啟動畫面是用戶打開 APP 時看到的第一個畫面，主要用於：
1. 展示品牌標識（Logo 和名稱）
2. 初始化應用程式（Hive 數據庫、GetX 依賴）
3. 檢查系統狀態（網絡連接）
4. 提供優雅的過渡體驗

這是一個簡單但重要的功能，為用戶建立良好的第一印象。

---

## 🎯 目標

### 主要目標
1. ✅ 顯示應用程式 Logo 和名稱
2. ✅ 在後台初始化 Hive 數據庫
3. ✅ 檢查網絡連接狀態
4. ✅ 3 秒後自動跳轉到書籍列表頁面
5. ✅ 提供流暢的加載動畫

### 次要目標
- 為未來的啟動動畫預留空間
- 為未來的版本檢查預留邏輯

---

## 📐 UI 設計

### 視覺設計

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│           📚                    │
│                                 │
│       書苑閱讀器                 │
│     ShuyuanReader               │
│                                 │
│                                 │
│        Loading...               │
│      ━━━━━━━━                  │
│         (動畫)                   │
│                                 │
│                                 │
│                                 │
│                                 │
│       v1.0.0                    │
└─────────────────────────────────┘
```

### 設計規格

#### 佈局
- **Logo**: 
  - 大小: 120x120 dp
  - 位置: 垂直居中，向上偏移 20%
  - 圖標: 📚 (書籍圖標，暫用 Emoji，後期替換為自定義圖標)

- **應用名稱**:
  - 主標題「書苑閱讀器」: 24sp, 粗體
  - 副標題「ShuyuanReader」: 16sp, 常規
  - 位置: Logo 下方 24dp

- **加載動畫**:
  - 類型: CircularProgressIndicator
  - 大小: 32x32 dp
  - 位置: 應用名稱下方 48dp
  - 顏色: Primary color

- **版本號**:
  - 文字: "v1.0.0"
  - 大小: 12sp
  - 位置: 底部 24dp
  - 顏色: 灰色 (0xFF9E9E9E)

#### 顏色方案
- **背景色**: 
  - 日間: 白色 (0xFFFFFFFF)
  - 夜間: 深灰色 (0xFF121212) [Phase 2 實現]
  
- **主色調**: 
  - Primary: 藍色 (0xFF2196F3)
  - Secondary: 深藍色 (0xFF1976D2)

- **文字顏色**:
  - 標題: 黑色 (0xFF000000)
  - 副標題: 深灰色 (0xFF424242)

#### 動畫效果
1. **淡入動畫** (0-500ms):
   - Logo 和文字從透明度 0 淡入到 1
   - 使用 `FadeTransition`

2. **加載動畫** (持續):
   - 圓形進度條旋轉
   - 使用 `CircularProgressIndicator`

3. **淡出動畫** (2500-3000ms):
   - 整個頁面淡出
   - 使用 `FadeTransition`

---

## 🔧 功能需求

### FR-01: 顯示 Logo 和應用名稱
**描述**: 在啟動畫面中央顯示應用程式的 Logo 和名稱

**詳細說明**:
- Logo 使用書籍圖標 (📚) 或自定義圖標
- 主標題顯示「書苑閱讀器」
- 副標題顯示「ShuyuanReader」
- 所有元素垂直居中對齊

**驗收標準**:
- [ ] Logo 正確顯示且大小合適
- [ ] 應用名稱清晰可讀
- [ ] 元素對齊正確

---

### FR-02: 初始化 Hive 數據庫
**描述**: 在啟動畫面顯示期間，在後台初始化 Hive 數據庫

**詳細說明**:
- 調用 `Hive.initFlutter()`
- 註冊所有 Adapter（BookAdapter、DownloadStatusAdapter）
- 打開所有需要的 Box（books、settings、progress）
- 處理初始化錯誤

**驗收標準**:
- [ ] Hive 初始化成功
- [ ] 所有 Adapter 正確註冊
- [ ] 所有 Box 成功打開
- [ ] 錯誤處理正確（顯示錯誤提示）

---

### FR-03: 檢查網絡連接
**描述**: 檢測設備的網絡連接狀態

**詳細說明**:
- 使用 `connectivity_plus` 包檢測網絡
- 檢測 WiFi、移動數據、無網絡
- 將狀態保存到全局狀態管理
- 不阻塞啟動流程（僅記錄狀態）

**驗收標準**:
- [ ] 網絡狀態檢測正確
- [ ] 狀態保存到 GetX Controller
- [ ] 不影響啟動流程

---

### FR-04: 自動跳轉
**描述**: 3 秒後自動跳轉到書籍列表頁面

**詳細說明**:
- 使用 `Timer` 或 `Future.delayed` 實現延遲
- 延遲時間: 3 秒（3000ms）
- 使用 GetX 路由進行頁面跳轉
- 跳轉時使用淡入淡出過渡動畫

**驗收標準**:
- [ ] 準確在 3 秒後跳轉
- [ ] 跳轉動畫流暢
- [ ] 跳轉到正確的頁面

---

### FR-05: 顯示加載動畫
**描述**: 在初始化過程中顯示加載動畫，提供視覺反饋

**詳細說明**:
- 使用 `CircularProgressIndicator`
- 動畫位於應用名稱下方
- 顏色與主題一致
- 持續旋轉直到跳轉

**驗收標準**:
- [ ] 加載動畫正確顯示
- [ ] 動畫流暢（60fps）
- [ ] 顏色與設計一致

---

### FR-06: 顯示版本號
**描述**: 在頁面底部顯示應用版本號

**詳細說明**:
- 從 `pubspec.yaml` 讀取版本號
- 使用 `package_info_plus` 包
- 格式: "v1.0.0"
- 顯示在底部中央

**驗收標準**:
- [ ] 版本號正確顯示
- [ ] 位置正確（底部居中）
- [ ] 字體大小合適

---

## 🏗️ 技術實現

### 目錄結構

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # 應用常量
│   └── init/
│       └── app_initializer.dart        # 應用初始化邏輯
│
├── presentation/
│   ├── pages/
│   │   └── splash/
│   │       ├── splash_page.dart        # 啟動畫面頁面
│   │       └── widgets/
│   │           ├── logo_widget.dart    # Logo 組件
│   │           └── loading_widget.dart # 加載動畫組件
│   └── controllers/
│       └── splash_controller.dart      # 啟動畫面控制器
│
└── main.dart                           # 應用入口
```

---

### 代碼實現

#### 1. main.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/pages/splash/splash_page.dart';

void main() async {
  // 確保 Flutter 綁定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 運行應用
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '書苑閱讀器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
```

#### 2. splash_controller.dart

```dart
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/init/app_initializer.dart';

class SplashController extends GetxController {
  // 版本號
  final version = ''.obs;
  
  // 初始化狀態
  final isInitialized = false.obs;
  
  // 網絡狀態
  final isConnected = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  /// 初始化應用
  Future<void> _initializeApp() async {
    try {
      // 1. 獲取版本號
      await _loadVersion();
      
      // 2. 初始化 Hive
      await _initializeHive();
      
      // 3. 檢查網絡
      await _checkConnectivity();
      
      // 4. 標記初始化完成
      isInitialized.value = true;
      
      // 5. 等待 3 秒後跳轉
      await Future.delayed(const Duration(seconds: 3));
      
      // 6. 跳轉到主頁
      Get.offNamed('/home');
      
    } catch (e) {
      // 錯誤處理
      _handleError(e);
    }
  }
  
  /// 加載版本號
  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version.value = 'v${packageInfo.version}';
  }
  
  /// 初始化 Hive
  Future<void> _initializeHive() async {
    await AppInitializer.initializeHive();
  }
  
  /// 檢查網絡連接
  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;
  }
  
  /// 錯誤處理
  void _handleError(dynamic error) {
    Get.snackbar(
      '初始化失敗',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
```

#### 3. app_initializer.dart

```dart
import 'package:hive_flutter/hive_flutter.dart';
// import '../../data/models/book_model.dart';
// import '../../data/models/download_status.dart';

class AppInitializer {
  /// 初始化 Hive 數據庫
  static Future<void> initializeHive() async {
    // 初始化 Hive
    await Hive.initFlutter();
    
    // 註冊 Adapter
    // Hive.registerAdapter(BookAdapter());
    // Hive.registerAdapter(DownloadStatusAdapter());
    
    // 打開 Box
    // await Hive.openBox<Book>('books');
    // await Hive.openBox('settings');
    // await Hive.openBox('progress');
  }
}
```

#### 4. splash_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import 'widgets/logo_widget.dart';
import 'widgets/loading_widget.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 初始化控制器
    final controller = Get.put(SplashController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo
              const LogoWidget(),
              
              const SizedBox(height: 24),
              
              // 應用名稱
              const Text(
                '書苑閱讀器',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'ShuyuanReader',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF424242),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // 加載動畫
              const LoadingWidget(),
              
              const Spacer(flex: 3),
              
              // 版本號
              Obx(() => Text(
                controller.version.value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              )),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 5. logo_widget.dart

```dart
import 'package:flutter/material.dart';

class LogoWidget extends StatefulWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // 創建動畫控制器
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 創建淡入動畫
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    // 啟動動畫
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            '📚',
            style: TextStyle(fontSize: 64),
          ),
        ),
      ),
    );
  }
}
```

#### 6. loading_widget.dart

```dart
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}
```

---

## 🧪 測試用例

### Unit Tests (單元測試)

#### test/unit/controllers/splash_controller_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:shuyuan_reader/presentation/controllers/splash_controller.dart';

void main() {
  late SplashController controller;

  setUp(() {
    controller = SplashController();
  });

  tearDown(() {
    Get.reset();
  });

  group('SplashController', () {
    test('初始狀態應該正確', () {
      expect(controller.version.value, '');
      expect(controller.isInitialized.value, false);
      expect(controller.isConnected.value, false);
    });

    test('版本號應該正確加載', () async {
      await controller.onInit();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(controller.version.value, isNot(''));
      expect(controller.version.value, startsWith('v'));
    });

    test('初始化完成後 isInitialized 應該為 true', () async {
      await controller.onInit();
      await Future.delayed(const Duration(seconds: 1));
      
      expect(controller.isInitialized.value, true);
    });
  });
}
```

---

### Widget Tests (組件測試)

#### test/widgets/splash_page_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shuyuan_reader/presentation/pages/splash/splash_page.dart';

void main() {
  testWidgets('SplashPage 應該正確顯示', (WidgetTester tester) async {
    // 建立測試環境
    await tester.pumpWidget(
      const GetMaterialApp(
        home: SplashPage(),
      ),
    );

    // 驗證 Logo 存在
    expect(find.text('📚'), findsOneWidget);

    // 驗證應用名稱
    expect(find.text('書苑閱讀器'), findsOneWidget);
    expect(find.text('ShuyuanReader'), findsOneWidget);

    // 驗證加載動畫
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 驗證 Loading 文字
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('Logo 應該有淡入動畫', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: SplashPage(),
      ),
    );

    // 驗證 FadeTransition 存在
    expect(find.byType(FadeTransition), findsOneWidget);
  });

  testWidgets('版本號應該顯示', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: SplashPage(),
      ),
    );

    // 等待版本號加載
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // 驗證版本號格式（v 開頭）
    final versionFinder = find.textContaining('v');
    expect(versionFinder, findsOneWidget);
  });
}
```

---

### Integration Tests (集成測試)

#### integration_test/splash_flow_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shuyuan_reader/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('啟動畫面完整流程測試', () {
    testWidgets('應該顯示啟動畫面並自動跳轉', (WidgetTester tester) async {
      // 啟動應用
      app.main();
      await tester.pumpAndSettle();

      // 1. 驗證啟動畫面顯示
      expect(find.text('書苑閱讀器'), findsOneWidget);
      expect(find.text('ShuyuanReader'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2. 等待 3 秒（自動跳轉時間）
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. 驗證已跳轉到主頁（暫時會失敗，因為主頁還未實現）
      // expect(find.text('書苑閱讀器'), findsNothing);
      // expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('初始化失敗應該顯示錯誤', (WidgetTester tester) async {
      // 此測試需要 mock 初始化失敗的情況
      // 留待後續實現
    });
  });
}
```

---

### Golden Tests (UI 快照測試)

#### test/golden/splash_page_golden_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shuyuan_reader/presentation/pages/splash/splash_page.dart';

void main() {
  testWidgets('SplashPage golden test', (WidgetTester tester) async {
    // 建立測試環境
    await tester.pumpWidget(
      const GetMaterialApp(
        home: SplashPage(),
      ),
    );

    // 等待動畫完成
    await tester.pumpAndSettle();

    // 比對 Golden 文件
    await expectLater(
      find.byType(SplashPage),
      matchesGoldenFile('goldens/splash_page.png'),
    );
  });
}
```

**運行 Golden 測試**:
```bash
# 生成 Golden 文件
flutter test --update-goldens test/golden/

# 驗證 Golden 文件
flutter test test/golden/
```

---

## ✅ 驗收標準

### 功能性驗收

- [ ] **FR-01**: Logo 和應用名稱正確顯示
  - [ ] Logo 大小為 120x120 dp
  - [ ] 應用名稱「書苑閱讀器」正確顯示
  - [ ] 副標題「ShuyuanReader」正確顯示
  - [ ] 元素垂直居中對齊

- [ ] **FR-02**: Hive 數據庫初始化成功
  - [ ] Hive.initFlutter() 執行成功
  - [ ] 所有 Adapter 正確註冊
  - [ ] 所有 Box 成功打開
  - [ ] 無初始化錯誤

- [ ] **FR-03**: 網絡連接檢測正常
  - [ ] connectivity_plus 正確檢測網絡狀態
  - [ ] 狀態保存到 Controller
  - [ ] 不阻塞啟動流程

- [ ] **FR-04**: 自動跳轉功能正常
  - [ ] 準確在 3 秒後跳轉
  - [ ] 使用 GetX 路由跳轉
  - [ ] 跳轉動畫流暢

- [ ] **FR-05**: 加載動畫正確顯示
  - [ ] CircularProgressIndicator 顯示
  - [ ] 動畫流暢（60fps）
  - [ ] 顏色為 Primary color

- [ ] **FR-06**: 版本號正確顯示
  - [ ] 從 package_info_plus 讀取版本
  - [ ] 格式為 "v1.0.0"
  - [ ] 位於底部中央

### UI/UX 驗收

- [ ] **佈局正確**
  - [ ] 所有元素按設計稿對齊
  - [ ] 間距符合設計規格
  - [ ] 響應式適配不同屏幕

- [ ] **顏色符合設計**
  - [ ] 背景色為白色
  - [ ] 主色調為藍色
  - [ ] 文字顏色正確

- [ ] **動畫流暢**
  - [ ] Logo 淡入動畫 (500ms)
  - [ ] 加載動畫持續旋轉
  - [ ] 整體動畫 60fps

- [ ] **字體大小適中**
  - [ ] 主標題 24sp
  - [ ] 副標題 16sp
  - [ ] 版本號 12sp

### 性能驗收

- [ ] **啟動速度**
  - [ ] 冷啟動 < 2 秒
  - [ ] 熱啟動 < 1 秒

- [ ] **內存使用**
  - [ ] 啟動畫面內存 < 30 MB

- [ ] **動畫性能**
  - [ ] 所有動畫 60fps
  - [ ] 無卡頓和掉幀

### 測試驗收

- [ ] **單元測試**
  - [ ] SplashController 測試通過
  - [ ] 測試覆蓋率 > 80%

- [ ] **Widget 測試**
  - [ ] SplashPage 測試通過
  - [ ] LogoWidget 測試通過
  - [ ] LoadingWidget 測試通過

- [ ] **Golden 測試**
  - [ ] Golden 文件生成
  - [ ] Golden 測試通過

- [ ] **集成測試**
  - [ ] 完整流程測試通過

### 真機測試

- [ ] **設備測試**
  - [ ] 在至少 3 台不同設備測試
  - [ ] 不同屏幕尺寸正常顯示
  - [ ] 不同 Android 版本正常運行

- [ ] **邊界情況**
  - [ ] 無網絡時正常初始化
  - [ ] Hive 初始化失敗時顯示錯誤
  - [ ] 快速點擊不影響跳轉

---

## 🎨 視覺化驗證

### UI 呈現檢查清單

- [ ] **佈局正確**
  - [ ] Logo 位置正確（居中偏上）
  - [ ] 應用名稱位置正確
  - [ ] 加載動畫位置正確
  - [ ] 版本號位置正確（底部）
  - [ ] 所有元素對齊正確

- [ ] **顏色符合設計**
  - [ ] 背景色為白色
  - [ ] Logo 背景色為淡藍色
  - [ ] 主標題為黑色
  - [ ] 副標題為深灰色
  - [ ] 版本號為淺灰色
  - [ ] 進度條為藍色

- [ ] **字體大小適中**
  - [ ] 主標題 24sp 清晰可讀
  - [ ] 副標題 16sp 清晰可讀
  - [ ] 版本號 12sp 清晰可讀
  - [ ] 所有文字不模糊

- [ ] **間距合理**
  - [ ] Logo 與標題間距 24dp
  - [ ] 標題與副標題間距 8dp
  - [ ] 副標題與加載動畫間距 48dp
  - [ ] 版本號距底部 24dp

- [ ] **響應式適配**
  - [ ] 小屏手機（4.7"）正常顯示
  - [ ] 中屏手機（5.5"）正常顯示
  - [ ] 大屏手機（6.5"）正常顯示
  - [ ] 平板（可選）正常顯示

### 交互反饋檢查清單

- [ ] **動畫流暢**
  - [ ] Logo 淡入動畫流暢
  - [ ] 加載動畫持續旋轉
  - [ ] 無卡頓和掉幀
  - [ ] 動畫幀率 60fps

- [ ] **加載狀態顯示**
  - [ ] 加載動畫始終可見
  - [ ] Loading 文字正確顯示

- [ ] **自動跳轉**
  - [ ] 3 秒後自動跳轉
  - [ ] 跳轉動畫流暢
  - [ ] 無閃爍現象

### 邊界情況檢查清單

- [ ] **無網絡**
  - [ ] 仍能正常顯示
  - [ ] 仍能初始化 Hive
  - [ ] 仍能跳轉到主頁

- [ ] **初始化失敗**
  - [ ] 顯示錯誤提示（Snackbar）
  - [ ] 錯誤信息清晰
  - [ ] 不會崩潰

- [ ] **快速點擊**
  - [ ] 不影響正常流程
  - [ ] 不會重複跳轉

- [ ] **系統返回鍵**
  - [ ] 按返回鍵可退出 APP

---

## 📸 截圖記錄

### 正常狀態
- 文件: `design/screenshots/spec-01/01-normal-state.png`
- 描述: 啟動畫面正常顯示狀態

### 加載狀態
- 文件: `design/screenshots/spec-01/02-loading-state.png`
- 描述: 顯示加載動畫

### 淡入動畫
- 文件: `design/screenshots/spec-01/03-fade-in-animation.gif`
- 描述: Logo 淡入動畫效果

### 不同設備
- 文件: `design/screenshots/spec-01/04-device-1-small.png`
- 描述: 小屏設備（4.7"）

- 文件: `design/screenshots/spec-01/05-device-2-medium.png`
- 描述: 中屏設備（5.5"）

- 文件: `design/screenshots/spec-01/06-device-3-large.png`
- 描述: 大屏設備（6.5"）

---

## 📹 Demo 視頻

- 文件: `demo/spec-01-splash-screen.mp4`
- 時長: 5 秒
- 內容: 從啟動到跳轉的完整流程

---

## ⏱️ 時間估算

### 預估時間: 8 小時

| 任務 | 預估時間 | 說明 |
|------|----------|------|
| UI 實現 | 2 小時 | SplashPage、LogoWidget、LoadingWidget |
| 控制器實現 | 2 小時 | SplashController、初始化邏輯 |
| Hive 初始化 | 1 小時 | AppInitializer、Adapter 註冊 |
| 測試編寫 | 2 小時 | Unit、Widget、Golden 測試 |
| 真機測試 | 1 小時 | 3 台設備測試 |

### 實際時間: _____ 小時

（實施後填寫）

---

## 💡 遇到的問題

### 問題 1: [問題描述]
**解決方案**: [解決方案描述]

### 問題 2: [問題描述]
**解決方案**: [解決方案描述]

---

## 🔗 相關 Spec

### 前置 Spec
- [Spec 00: 專案設置與憲章](./00-constitution.md)

### 後續 Spec
- [Spec 02: 書籍列表頁](./02-book-list.md) (依賴此 Spec)

---

## 📝 注意事項

### 重要提醒
1. ⚠️ **不要硬編碼路由**: 使用 GetX 的命名路由
2. ⚠️ **處理初始化錯誤**: 必須有錯誤處理機制
3. ⚠️ **避免阻塞 UI**: 所有初始化操作應在後台執行
4. ⚠️ **測試覆蓋**: 確保測試覆蓋率 > 80%

### 最佳實踐
1. ✅ 使用 `const` 構造函數優化性能
2. ✅ 使用 `GetX` 進行狀態管理和路由
3. ✅ 分離 Widget（LogoWidget、LoadingWidget）提高可維護性
4. ✅ 使用 `package_info_plus` 動態獲取版本號

### 未來優化
1. 🔮 Phase 2: 添加夜間模式支持
2. 🔮 Phase 2: 添加版本檢查功能
3. 🔮 Phase 3: 添加啟動廣告（可選）
4. 🔮 Phase 3: 自定義 Logo 動畫

---

## 📚 參考資源

### Flutter 官方文檔
- [SplashScreen Guide](https://flutter.dev/docs/development/ui/splash-screen)
- [AnimationController](https://api.flutter.dev/flutter/animation/AnimationController-class.html)
- [GetX Documentation](https://pub.dev/packages/get)

### 依賴包文檔
- [hive_flutter](https://pub.dev/packages/hive_flutter)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- [package_info_plus](https://pub.dev/packages/package_info_plus)

### 設計參考
- [Material Design - Launch Screen](https://material.io/design/communication/launch-screen.html)

---

## ✅ Spec 完成檢查清單

### 開發階段
- [ ] UI 實現完成
- [ ] 控制器實現完成
- [ ] Hive 初始化完成
- [ ] 所有功能需求實現

### 測試階段
- [ ] 單元測試通過
- [ ] Widget 測試通過
- [ ] Golden 測試通過
- [ ] 集成測試通過
- [ ] 真機測試通過

### 文檔階段
- [ ] 代碼註釋完整
- [ ] 截圖已保存
- [ ] Demo 視頻已錄製
- [ ] 實際時間已記錄

### 審查階段
- [ ] 代碼審查通過
- [ ] 所有驗收標準滿足
- [ ] 無已知 Bug
- [ ] 準備進入下一個 Spec

---

**Spec 狀態**: ⬜ 未開始  
**創建日期**: 2025-11-07  
**開始日期**: _____  
**完成日期**: _____  
**實際工時**: _____ 小時

---

**記住**: 這是你的第一個 Spec，打好基礎很重要！按照步驟逐一實現，不要跳過測試。加油！🚀
