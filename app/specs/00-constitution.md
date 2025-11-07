# Spec 00: 書苑閱讀器專案憲章

## 📜 Spec-Kit Constitution

**創建日期**: 2025-11-07  
**版本**: 1.0  
**狀態**: ✅ 已確立

---

## 🎯 專案目標與範圍

### 核心目標
構建一個**簡潔、高效、離線優先**的佛教經典閱讀器 Android APP，幫助用戶：
1. 輕鬆瀏覽和下載 100+ 本佛教經典
2. 優質的 EPUB 閱讀體驗
3. 完善的離線閱讀支持
4. 個人化的閱讀記錄和書籤管理

### 專案範圍
- ✅ **包含**：Android APP（API 21+）
- ✅ **包含**：EPUB 格式支持
- ✅ **包含**：離線閱讀功能
- ✅ **包含**：基本的閱讀器功能
- ❌ **不包含**：iOS 版本（未來迭代）
- ❌ **不包含**：雲端同步（未來迭代）
- ❌ **不包含**：社交功能（未來迭代）

---

## 🏗️ 技術棧選擇

### 前端框架
- **Flutter 3.13+** (Dart)
  - 原因：跨平台潛力、豐富的 UI 組件、優秀的性能

### 狀態管理
- **GetX 4.6+**
  - 原因：輕量、簡單、性能好、內建路由和依賴注入

### 本地數據庫
- **Hive 2.2+**
  - 原因：純 Dart、NoSQL、快速、易用

### 網絡請求
- **Dio 5.3+**
  - 原因：強大的功能、攔截器、錯誤處理

### EPUB 閱讀器
- **epub_view 3.1+**
  - 原因：成熟、功能完整、社區支持

### 其他核心依賴
```yaml
dependencies:
  get: ^4.6.5                    # 狀態管理
  dio: ^5.3.3                    # 網絡請求
  hive: ^2.2.3                   # 本地數據庫
  hive_flutter: ^1.1.0           # Hive Flutter 適配
  path_provider: ^2.1.1          # 文件路徑
  cached_network_image: ^3.3.0   # 圖片緩存
  epub_view: ^3.1.0              # EPUB 閱讀器
  connectivity_plus: ^5.0.0      # 網絡狀態檢測
  shimmer: ^3.0.0                # 加載動畫
```

---

## 📐 架構模式

### Clean Architecture (清潔架構)

```
lib/
├── core/                      # 核心層
│   ├── constants/            # 常量
│   ├── errors/               # 錯誤處理
│   ├── utils/                # 工具類
│   └── widgets/              # 共用組件
│
├── data/                      # 數據層
│   ├── datasources/          # 數據源
│   │   ├── remote/          # 網絡數據源
│   │   └── local/           # 本地數據源
│   ├── models/               # 數據模型
│   └── repositories/         # 倉儲實現
│
├── domain/                    # 業務層
│   ├── entities/             # 業務實體
│   ├── repositories/         # 倉儲接口
│   └── usecases/             # 用例
│
└── presentation/              # 表現層
    ├── pages/                # 頁面
    ├── widgets/              # 頁面組件
    └── controllers/          # GetX 控制器
```

### 設計原則
1. **單一職責原則** (SRP)：每個類只有一個改變的理由
2. **開閉原則** (OCP)：對擴展開放，對修改關閉
3. **依賴倒置原則** (DIP)：依賴抽象而不是具體實現
4. **關注點分離** (SoC)：UI、業務邏輯、數據層分離

---

## 📝 編碼規範

### Dart 代碼風格
```dart
// 1. 使用 lowerCamelCase 命名變量和方法
final bookTitle = 'Example';
void fetchBooks() {}

// 2. 使用 UpperCamelCase 命名類和枚舉
class BookModel {}
enum DownloadStatus {}

// 3. 使用 const 構造函數（當可能時）
const Text('Hello');

// 4. 優先使用單引號
final name = 'John';

// 5. 避免使用 print，使用 logger
logger.d('Debug message');

// 6. 使用 final 而不是 var（當不會重新賦值時）
final books = <Book>[];

// 7. 註釋使用中文，提高可讀性
/// 從 GitHub 下載書籍列表
Future<List<Book>> fetchBooks() async {}
```

### 文件命名
- **小寫 + 下劃線**：`book_model.dart`, `home_page.dart`
- **測試文件**：`book_model_test.dart`
- **常量文件**：`constants.dart`, `api_constants.dart`

### 代碼組織
```dart
// 文件內部順序
class Example {
  // 1. 常量
  static const defaultValue = 10;
  
  // 2. 靜態變量
  static final instance = Example();
  
  // 3. 實例變量
  final String name;
  int age;
  
  // 4. 構造函數
  Example({required this.name, this.age = 0});
  
  // 5. 生命週期方法（如果是 Widget）
  @override
  void initState() {}
  
  // 6. 公共方法
  void publicMethod() {}
  
  // 7. 私有方法
  void _privateMethod() {}
  
  // 8. Getters/Setters
  String get fullInfo => '$name, $age';
}
```

---

## 🔄 Git 提交規範

### Commit Message 格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 類型
- `feat`: 新功能
- `fix`: Bug 修復
- `docs`: 文檔更新
- `style`: 代碼格式（不影響代碼運行）
- `refactor`: 重構
- `test`: 測試相關
- `chore`: 構建過程或輔助工具的變動

### 範例
```bash
feat(spec-02): implement book list page with GridView

- Add BookController with GetX
- Implement GridView with book cards
- Add pull-to-refresh functionality
- Add error handling for network failures

Closes #12
```

### 分支策略
```
main           ← 主分支（穩定版本）
  ↓
develop        ← 開發分支
  ↓
feature/spec-02-book-list   ← 功能分支
```

---

## 🧪 測試策略

### 測試金字塔
```
        Integration Tests (10%)  ← 少量、慢速、關鍵流程
              ↑
       Widget Tests (30%)        ← 中等數量、中等速度
              ↑
      Unit Tests (60%)           ← 大量、快速、全面
```

### 測試覆蓋率目標
- **總體覆蓋率**: > 80%
- **核心業務邏輯**: 100%
- **UI 組件**: > 70%
- **工具類**: 100%

### 測試命名規範
```dart
// 格式：methodName_stateUnderTest_expectedBehavior
void fetchBooks_whenNetworkSuccess_returnsBooksList() {}
void downloadBook_whenNetworkFails_throwsException() {}
```

### 測試類型

#### 1. Unit Tests（單元測試）
```dart
// test/unit/models/book_model_test.dart
void main() {
  group('BookModel', () {
    test('fromJson creates valid Book instance', () {
      final json = {'id': '1', 'title': 'Test'};
      final book = Book.fromJson(json);
      expect(book.id, '1');
      expect(book.title, 'Test');
    });
  });
}
```

#### 2. Widget Tests（組件測試）
```dart
// test/widgets/book_card_test.dart
void main() {
  testWidgets('BookCard displays book information', (tester) async {
    final book = Book(id: '1', title: 'Test Book');
    await tester.pumpWidget(MaterialApp(
      home: BookCard(book: book),
    ));
    expect(find.text('Test Book'), findsOneWidget);
  });
}
```

#### 3. Golden Tests（UI 快照測試）
```dart
// test/golden/home_page_test.dart
testWidgets('HomePage golden test', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(HomePage),
    matchesGoldenFile('goldens/home_page.png'),
  );
});
```

#### 4. Integration Tests（集成測試）
```dart
// integration_test/app_flow_test.dart
testWidgets('Complete download and read flow', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  // 1. 點擊書籍
  await tester.tap(find.byType(BookCard).first);
  await tester.pumpAndSettle();
  
  // 2. 下載書籍
  await tester.tap(find.text('下載'));
  await tester.pumpAndSettle(Duration(seconds: 30));
  
  // 3. 打開閱讀
  await tester.tap(find.text('打開閱讀'));
  await tester.pumpAndSettle();
  
  expect(find.byType(ReaderPage), findsOneWidget);
});
```

---

## 📚 文檔標準

### 必需文檔

#### 1. Spec 文檔
- 位置：`app/specs/`
- 格式：Markdown
- 命名：`00-constitution.md`, `01-splash-screen.md`, ...

#### 2. API 文檔
- 工具：Dart Doc
- 命令：`dart doc`
- 規範：所有公共 API 必須有文檔註釋

#### 3. README
- 專案根目錄：整體介紹
- 各模塊：功能說明

#### 4. 變更日誌
- 位置：`CHANGELOG.md`
- 格式：Keep a Changelog

### 文檔註釋規範

#### Dart Doc 格式
```dart
/// 從 GitHub 下載書籍列表。
///
/// 首先嘗試從網絡獲取，如果失敗則從本地緩存加載。
///
/// 返回 [List<Book>]，如果沒有數據則返回空列表。
///
/// 拋出 [NetworkException] 如果網絡和緩存都失敗。
///
/// 範例：
/// ```dart
/// final books = await bookRepository.fetchBooks();
/// print('找到 ${books.length} 本書');
/// ```
Future<List<Book>> fetchBooks() async {
  // 實現...
}
```

#### 複雜邏輯註釋
```dart
// 為什麼這樣做：
// 1. Hive 不支持 null safety 的預設值
// 2. 必須在 box.put 之前檢查 null
// 3. 參考：https://github.com/hivedb/hive/issues/XXX
if (book.localPath != null) {
  await box.put(book.id, book);
}
```

---

## 🔍 代碼審查標準

### 審查檢查清單

#### ✅ 功能性
- [ ] 實現了 Spec 中的所有需求
- [ ] 沒有添加 Spec 外的額外功能
- [ ] 邊界情況都有處理

#### ✅ 代碼質量
- [ ] 符合編碼規範
- [ ] 沒有重複代碼
- [ ] 命名清晰易懂
- [ ] 註釋充分

#### ✅ 測試
- [ ] 所有測試通過
- [ ] 新代碼有測試覆蓋
- [ ] 測試用例有意義

#### ✅ 性能
- [ ] 沒有明顯的性能問題
- [ ] 圖片有壓縮和緩存
- [ ] 列表有分頁或虛擬化

#### ✅ 安全
- [ ] 用戶輸入有驗證
- [ ] 敏感數據有加密
- [ ] 沒有硬編碼的密鑰

---

## 📊 持續集成/持續部署 (CI/CD)

### GitHub Actions 工作流

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.13.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## 🎯 Spec-Kit 核心原則

### 1. Spec First（規格優先）
- ✅ **先寫規格，再寫代碼** - 每個功能必須先有完整的規格文檔
- ✅ **規格即契約** - 規格文檔是開發和驗證的唯一標準
- ✅ **可視化優先** - 每個規格都必須包含 ASCII UI 設計圖

### 2. Visual Feedback（可視化反饋）
- ✅ **每個階段都有 UI 可驗證** - 不做看不見的功能
- ✅ **Golden Tests** - 自動化 UI 快照測試
- ✅ **真機驗證** - 至少在 3 台不同設備測試

### 3. Incremental（增量開發）
- ✅ **小步快跑** - 每個 Spec 控制在 1-5 天完成
- ✅ **頻繁交付** - 每個 Spec 完成後立即可用
- ✅ **及時反饋** - 每日視覺化驗證

### 4. Test Driven（測試驅動）
- ✅ **規格即測試用例** - 每個規格都包含測試代碼
- ✅ **Red-Green-Refactor** - 先寫測試，再實現，最後重構
- ✅ **自動化驗證** - CI/CD 自動運行所有測試

---

## 🚫 開發紅線

### ❌ 絕對禁止
1. **未寫 Spec 就寫代碼** - 必須先有規格文檔
2. **跳過測試** - 每個功能都必須有測試
3. **不做視覺化驗證** - 必須在真機上驗證
4. **提交未測試的代碼** - CI/CD 必須通過
5. **直接修改 main 分支** - 必須通過 PR

### ⚠️ 需要特別注意
1. **功能蔓延** - 嚴格按照 Spec 實現，不添加額外功能
2. **過度設計** - MVP 階段保持簡單
3. **忽略性能** - 每個 Spec 都需要性能檢查
4. **忽略錯誤處理** - 必須處理所有邊界情況
5. **硬編碼** - 使用常量和配置文件

---

## 📈 性能標準

### 應用啟動
- ⚡ 冷啟動：< 3 秒
- ⚡ 熱啟動：< 1 秒

### 頁面性能
- ⚡ 頁面切換：< 300ms
- ⚡ 動畫幀率：60 FPS
- ⚡ 列表滾動：流暢無卡頓

### 內存使用
- 💾 空閒狀態：< 50 MB
- 💾 閱讀狀態：< 150 MB
- 💾 無內存洩漏

### 網絡請求
- 🌐 超時設置：10s (連接), 30s (接收)
- 🌐 重試機制：最多 3 次
- 🌐 緩存策略：ETag / Last-Modified

---

## 🔐 安全標準

### 數據安全
1. **本地數據加密** - 使用 Hive 的加密功能（敏感數據）
2. **網絡傳輸** - HTTPS only
3. **輸入驗證** - 所有用戶輸入都需驗證
4. **文件完整性** - 下載後驗證 MD5/SHA256（未來實現）

### 權限管理
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />
```

---

## 🎓 團隊協作

### 溝通原則
1. **透明** - 所有決策記錄在文檔中
2. **及時** - 問題盡快溝通解決
3. **尊重** - 代碼審查時對事不對人

### 工作流程
```
1. 選擇下一個 Spec
   ↓
2. 創建 feature 分支
   ↓
3. 實現功能（TDD）
   ↓
4. 自我審查（檢查清單）
   ↓
5. 提交 Pull Request
   ↓
6. Code Review
   ↓
7. 修改（如需要）
   ↓
8. 合併到 develop
   ↓
9. 定期合併到 main
```

---

## 📅 開發節奏

### Sprint 週期
- **週期長度**：2 週
- **目標**：完成 2-3 個 Spec

### 每日工作流
- **上午**：測試、代碼審查、計劃
- **下午**：實現、測試、記錄
- **晚上**：集成測試、提交

### 每週里程碑
- **週一**：Sprint 計劃
- **週三**：進度同步
- **週五**：Demo 和回顧

---

## 🏆 Definition of Done（完成定義）

一個 Spec 只有滿足以下**所有條件**才算完成：

### ✅ 文檔
- [ ] Spec 文檔完整
- [ ] 代碼註釋清晰
- [ ] API 文檔生成

### ✅ 代碼
- [ ] 符合編碼規範
- [ ] `flutter analyze` 無警告
- [ ] 無 TODO/FIXME

### ✅ 測試
- [ ] 所有測試通過
- [ ] 覆蓋率 > 80%
- [ ] Golden 測試通過

### ✅ 視覺
- [ ] UI 驗證通過
- [ ] 3 台設備測試
- [ ] 截圖已保存

### ✅ 性能
- [ ] 無內存洩漏
- [ ] 60 FPS 動畫
- [ ] 啟動 < 3s

### ✅ CI/CD
- [ ] 所有檢查通過
- [ ] 可獨立演示

---

## 🚀 下一步

憲章已確立，接下來執行：

1. ✅ **已完成**：憲章文檔
2. ⬜ **下一步**：`/speckit.plan` - 生成總體開發計劃
3. ⬜ **然後**：`/speckit.specify` - 開始 Spec 01

---

**憲章版本**: 1.0  
**最後更新**: 2025-11-07  
**狀態**: ✅ 生效中

---

**記住：這些規則不是束縛，而是確保質量和效率的護欄。遵守它們，專案會更順利！🚀**
