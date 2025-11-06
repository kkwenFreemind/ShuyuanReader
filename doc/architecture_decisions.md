# 技術決策記錄 (Architecture Decision Records)

## 目錄

1. [ADR-001: 選擇 Flutter 作為跨平台框架](#adr-001-選擇-flutter-作為跨平台框架)
2. [ADR-002: 使用 GetX 進行狀態管理](#adr-002-使用-getx-進行狀態管理)
3. [ADR-003: 選擇 Hive 作為本地數據庫](#adr-003-選擇-hive-作為本地數據庫)
4. [ADR-004: 使用 epub_view 包實現 EPUB 閱讀器](#adr-004-使用-epub_view-包實現-epub-閱讀器)
5. [ADR-005: 採用離線優先策略](#adr-005-採用離線優先策略)
6. [ADR-006: 選擇 GitHub 作為內容託管平台](#adr-006-選擇-github-作為內容託管平台)
7. [ADR-007: 不實現用戶賬戶系統](#adr-007-不實現用戶賬戶系統)
8. [ADR-008: 採用 Clean Architecture 架構模式](#adr-008-採用-clean-architecture-架構模式)

---

## ADR-001: 選擇 Flutter 作為跨平台框架

### 狀態
✅ 已接受 (2025-11-06)

### 背景
需要開發一個電子書閱讀器 APP，目標平台是 Android，但未來可能擴展到 iOS。

### 決策
選擇 Flutter 作為開發框架。

### 理由

#### 優點
1. **單一代碼庫多平台**：一次開發可同時支持 Android 和 iOS
2. **高性能**：接近原生性能（60fps+ UI）
3. **豐富的 UI 組件**：Material Design 和 Cupertino 風格
4. **熱重載**：提高開發效率
5. **強大的生態系統**：pub.dev 上有大量高質量包
6. **中文社區活躍**：學習資源豐富

#### 缺點
1. **APP 體積較大**：最小約 4.5MB（但可接受）
2. **某些原生功能需要通過插件實現**

### 替代方案

#### React Native
- ❌ 性能不如 Flutter
- ❌ 橋接層可能成為瓶頸
- ✅ JavaScript 生態成熟

#### 原生開發 (Kotlin/Java)
- ✅ 最佳性能
- ✅ 完整的系統訪問權限
- ❌ 需要分別開發 Android 和 iOS 版本
- ❌ 開發成本高

### 影響
- 開發團隊需要學習 Dart 語言
- 可以快速迭代和原型開發
- 未來擴展到 iOS 的成本很低

### 相關資源
- [Flutter 官方文檔](https://flutter.dev)
- [為什麼選擇 Flutter](https://flutter.dev/showcase)

---

## ADR-002: 使用 GetX 進行狀態管理

### 狀態
✅ 已接受 (2025-11-06)

### 背景
Flutter 提供多種狀態管理方案，需要選擇一個適合本項目的方案。

### 決策
使用 GetX 作為狀態管理解決方案。

### 理由

#### 優點
1. **簡單易學**：API 簡潔，學習曲線平緩
2. **高性能**：使用 Stream 和響應式編程
3. **功能完整**：
   - 狀態管理
   - 路由管理
   - 依賴注入
   - 國際化支持
4. **代碼量少**：相比 Provider/Riverpod 更簡潔
5. **社區活躍**：豐富的教程和示例

#### 缺點
1. **過於"魔法"**：某些功能可能隱藏細節
2. **測試相對困難**：依賴全局狀態

### 替代方案

#### Provider
- ✅ 官方推薦
- ✅ 測試友好
- ❌ 代碼較繁瑣
- ❌ 需要更多樣板代碼

#### Riverpod
- ✅ 類型安全
- ✅ 測試友好
- ❌ 學習曲線陡峭
- ❌ 對初學者不友好

#### Bloc
- ✅ 架構清晰
- ✅ 適合大型項目
- ❌ 樣板代碼過多
- ❌ 學習成本高

### 實現示例

```dart
// Controller
class BookController extends GetxController {
  final books = <Book>[].obs;
  final isLoading = false.obs;
  
  Future<void> loadBooks() async {
    isLoading.value = true;
    try {
      final result = await apiClient.fetchBooks();
      books.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}

// View
class BookListPage extends StatelessWidget {
  final controller = Get.put(BookController());
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => 
      controller.isLoading.value
        ? LoadingWidget()
        : ListView(children: controller.books.map(...).toList())
    );
  }
}
```

### 影響
- 開發速度快
- 代碼簡潔
- 後期可能需要重構（如果需要更嚴格的架構）

### 相關資源
- [GetX 文檔](https://pub.dev/packages/get)
- [GetX 最佳實踐](https://medium.com/flutter-community/the-flutter-getx-ecosystem-state-management-881c7235511d)

---

## ADR-003: 選擇 Hive 作為本地數據庫

### 狀態
✅ 已接受 (2025-11-06)

### 背景
需要在本地存儲書籍元數據、下載狀態、閱讀進度等信息。

### 決策
使用 Hive 作為本地 NoSQL 數據庫。

### 理由

#### 優點
1. **純 Dart 實現**：無需原生依賴
2. **高性能**：比 SQLite 快很多
3. **類型安全**：支持自定義對象直接存儲
4. **易於使用**：API 簡單直觀
5. **輕量級**：體積小（約 2MB）
6. **支持加密**：可選的 AES-256 加密

#### 缺點
1. **不支持複雜查詢**：沒有 SQL
2. **不適合關係型數據**

### 替代方案

#### SQLite (sqflite)
- ✅ 功能強大
- ✅ 支持複雜 SQL 查詢
- ❌ 需要寫 SQL
- ❌ 性能較低
- ❌ 代碼量多

#### SharedPreferences
- ✅ 極簡單
- ❌ 只適合簡單鍵值對
- ❌ 不支持複雜對象

#### ObjectBox
- ✅ 性能最佳
- ✅ 支持關係
- ❌ 商業授權
- ❌ 文檔較少

### 數據模型示例

```dart
@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String author;
  
  @HiveField(3)
  DownloadStatus status;
  
  @HiveField(4)
  double progress;
}

// 使用
final box = await Hive.openBox<Book>('books');
await box.add(book);
final allBooks = box.values.toList();
```

### 影響
- 快速的讀寫性能
- 簡化數據持久化代碼
- 不適合需要複雜關聯查詢的場景

### 相關資源
- [Hive 文檔](https://docs.hivedb.dev/)
- [Hive vs SQLite 性能對比](https://github.com/hivedb/hive#benchmark)

---

## ADR-004: 使用 epub_view 包實現 EPUB 閱讀器

### 狀態
✅ 已接受 (2025-11-06)

### 背景
需要實現 EPUB 電子書的解析和渲染功能。

### 決策
使用 `epub_view` 包作為 EPUB 閱讀器核心。

### 理由

#### 優點
1. **開箱即用**：無需從零實現複雜的 EPUB 解析
2. **功能完整**：
   - 支持 EPUB 2.0 和 3.0
   - 支持 CFI (Canonical Fragment Identifier)
   - 內建翻頁/滾動模式
   - 支持高亮和書籤
3. **活躍維護**：定期更新
4. **性能良好**：基於 WebView 渲染
5. **社區支持**：示例豐富

#### 缺點
1. **定制化受限**：某些 UI 不易修改
2. **依賴 WebView**：可能有兼容性問題
3. **文件過大時性能下降**

### 替代方案

#### 自行實現
- ✅ 完全控制
- ✅ 可高度定制
- ❌ 開發時間長（至少 4-6 週）
- ❌ 維護成本高
- ❌ 需要深入理解 EPUB 規範

#### vocsy_epub_viewer
- ✅ 原生渲染，性能好
- ❌ 文檔較少
- ❌ iOS 支持不佳

#### folioreader
- ✅ 功能豐富
- ❌ 原生插件，依賴複雜
- ❌ 更新不活躍

### 實現示例

```dart
class ReaderPage extends StatefulWidget {
  final Book book;
  
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late EpubController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = EpubController(
      document: EpubDocument.openFile(
        File(widget.book.localPath),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EpubView(
        controller: _controller,
        onChapterChanged: (chapter) {
          // 保存閱讀進度
          _saveProgress(chapter);
        },
      ),
    );
  }
}
```

### 影響
- MVP 可快速實現
- 後期如需深度定制，可能需要 fork 或重寫
- 對於 95% 的 EPUB 文件都能正常顯示

### 相關資源
- [epub_view 包](https://pub.dev/packages/epub_view)
- [EPUB 3.3 規範](https://www.w3.org/TR/epub-33/)

---

## ADR-005: 採用離線優先策略

### 狀態
✅ 已接受 (2025-11-06)

### 背景
用戶可能在無網絡環境下使用 APP（如地鐵、飛機上）。

### 決策
採用"離線優先"的架構設計。

### 理由

#### 優點
1. **用戶體驗好**：啟動快、響應快
2. **可靠性高**：網絡問題不影響核心功能
3. **節省流量**：減少重複請求
4. **支持弱網環境**

#### 實現策略
1. **books.json 緩存**：
   - 首次下載後本地緩存
   - 定期檢查更新（ETag/Last-Modified）
   - 離線時使用緩存

2. **封面圖片緩存**：
   - 使用 `cached_network_image`
   - 永久緩存已下載書籍的封面

3. **EPUB 文件**：
   - 下載後永久存儲
   - 用戶手動刪除才移除

### 數據流程

```
啟動 APP
  ↓
檢查網絡狀態
  ↓
  是否在線？
  ├─ 是 → 檢查 books.json 更新
  │       ├─ 有更新 → 下載最新
  │       └─ 無更新 → 使用緩存
  └─ 否 → 使用緩存數據
```

### 實現示例

```dart
class CatalogService {
  Future<List<Book>> loadCatalog() async {
    final isOnline = await _checkConnectivity();
    
    if (isOnline) {
      try {
        // 嘗試從網絡加載
        final json = await apiClient.fetchBooksJson();
        await _cache.saveCatalog(json);
        return _parseCatalog(json);
      } catch (e) {
        // 網絡失敗，使用緩存
        return await _loadFromCache();
      }
    } else {
      // 離線模式，直接使用緩存
      return await _loadFromCache();
    }
  }
  
  Future<List<Book>> _loadFromCache() async {
    final cached = await _cache.getCatalog();
    if (cached == null) {
      throw Exception('無緩存數據，請連接網絡後重試');
    }
    return _parseCatalog(cached);
  }
}
```

### 影響
- 首次使用需要網絡
- 後續可完全離線使用
- 需要管理緩存大小

### 相關資源
- [Offline-First Design Pattern](https://www.dataversity.net/offline-first-a-better-approach-to-mobile-app-design/)

---

## ADR-006: 選擇 GitHub 作為內容託管平台

### 狀態
✅ 已接受 (2025-11-06)

### 背景
需要託管 EPUB 文件、封面圖片和書籍目錄 JSON。

### 決策
使用 GitHub Repository 作為內容託管平台。

### 理由

#### 優點
1. **完全免費**：公開倉庫無限空間
2. **全球 CDN**：訪問速度快
3. **版本控制**：所有更改可追溯
4. **簡單易用**：通過 Git 推送更新
5. **高可用性**：99.9% SLA
6. **HTTPS 支持**：安全可靠

#### 缺點
1. **單文件限制**：最大 100MB（可接受）
2. **API 限制**：未認證每小時 60 次（對本項目足夠）
3. **中國訪問可能較慢**（但有多種解決方案）

### 替代方案

#### 雲存儲 (S3/OSS)
- ✅ 性能最佳
- ✅ 無限空間
- ❌ 需要付費
- ❌ 需要服務器端配置

#### 自建服務器
- ✅ 完全控制
- ❌ 成本高
- ❌ 維護複雜

#### Firebase Storage
- ✅ 免費額度
- ✅ 性能好
- ❌ 需要 Google 賬號
- ❌ 中國訪問受限

### URL 結構

```
書籍目錄:
https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/catalog/books.json

封面圖片:
https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/covers/{book_id}.png

EPUB 文件:
https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/epub3/{filename}.epub
```

### 訪問速度優化

如果 GitHub 訪問慢，可使用 CDN：

```dart
// 使用 jsDelivr CDN
const cdnBaseUrl = 'https://cdn.jsdelivr.net/gh/kkwenFreemind/ShuyuanReader@main';

// 使用 Statically CDN
const cdnBaseUrl = 'https://statically.io/gh/kkwenFreemind/ShuyuanReader/main';
```

### 影響
- 無需維護服務器
- 內容更新通過 Git 推送
- 可能需要處理訪問速度問題（中國地區）

### 相關資源
- [GitHub Pages 文檔](https://docs.github.com/pages)
- [jsDelivr CDN](https://www.jsdelivr.com/)

---

## ADR-007: 不實現用戶賬戶系統

### 狀態
✅ 已接受 (2025-11-06)

### 背景
是否需要用戶註冊/登錄功能？

### 決策
MVP 不實現用戶賬戶系統，所有數據存儲在本地。

### 理由

#### 優點
1. **簡化開發**：無需後端服務器
2. **保護隱私**：不收集用戶數據
3. **無註冊門檻**：下載即用
4. **合規簡單**：無需 GDPR/CCPA 合規
5. **降低成本**：無服務器費用

#### 缺點
1. **無法跨設備同步**：換設備後數據丟失
2. **無社交功能**：無法分享閱讀筆記
3. **無數據備份**：卸載 APP 數據丟失

### 未來擴展

如果用戶需求強烈，可以考慮：

1. **可選雲同步**（Phase 4）
   - 使用 Firebase/Supabase
   - 匿名賬戶
   - 端到端加密

2. **本地備份/恢復**
   - 導出到文件
   - 通過雲盤同步

### 數據所有權

所有數據存儲位置：
```
/data/data/com.shuyuan.reader/
├── app_flutter/           # Hive 數據庫
│   ├── books.hive
│   ├── bookmarks.hive
│   └── reading_progress.hive
├── files/
│   ├── books/            # EPUB 文件
│   └── covers/           # 封面緩存
└── shared_prefs/         # 應用設置
```

### 影響
- 開發速度快
- 無服務器維護成本
- 後期可加入可選同步功能

### 相關資源
- [本地優先軟件](https://www.inkandswitch.com/local-first/)

---

## ADR-008: 採用 Clean Architecture 架構模式

### 狀態
✅ 已接受 (2025-11-06)

### 背景
需要一個清晰、可維護、可測試的代碼架構。

### 決策
採用 Clean Architecture（清潔架構）設計模式。

### 理由

#### 優點
1. **關注點分離**：UI、業務邏輯、數據層獨立
2. **易於測試**：可獨立測試每一層
3. **可維護性高**：修改一層不影響其他層
4. **可擴展性好**：容易添加新功能
5. **框架獨立**：不依賴特定框架

### 架構層次

```
┌─────────────────────────────────────────┐
│         Presentation Layer               │
│  ┌────────────┬─────────────────────┐   │
│  │   Pages    │   Controllers (GetX)│   │
│  └────────────┴─────────────────────┘   │
└─────────────────────────────────────────┘
                    ↓↑
┌─────────────────────────────────────────┐
│          Domain Layer                    │
│  ┌────────────┬──────────────────────┐  │
│  │  Entities  │   Use Cases          │  │
│  │            │  (Business Logic)    │  │
│  └────────────┴──────────────────────┘  │
└─────────────────────────────────────────┘
                    ↓↑
┌─────────────────────────────────────────┐
│           Data Layer                     │
│  ┌─────────────────┬─────────────────┐  │
│  │  Repositories   │  Data Sources   │  │
│  │  (Impl)         │  (API, DB)      │  │
│  └─────────────────┴─────────────────┘  │
└─────────────────────────────────────────┘
```

### 項目結構

```
lib/
├── core/                    # 核心功能
│   ├── error/              # 錯誤處理
│   ├── network/            # 網絡層
│   ├── storage/            # 存儲層
│   └── utils/              # 工具類
│
├── data/                   # 數據層
│   ├── models/             # 數據模型（JSON 映射）
│   ├── datasources/
│   │   ├── local/         # 本地數據源（Hive）
│   │   └── remote/        # 遠程數據源（API）
│   └── repositories/       # Repository 實現
│
├── domain/                 # 領域層
│   ├── entities/          # 業務實體
│   ├── repositories/      # Repository 接口
│   └── usecases/          # 用例（業務邏輯）
│
└── presentation/          # 表現層
    ├── pages/             # 頁面
    ├── widgets/           # 通用組件
    └── controllers/       # GetX Controllers
```

### 代碼示例

#### 1. Entity (Domain Layer)
```dart
// domain/entities/book.dart
class Book {
  final String id;
  final String title;
  final String author;
  
  Book({
    required this.id,
    required this.title,
    required this.author,
  });
}
```

#### 2. Repository Interface (Domain Layer)
```dart
// domain/repositories/book_repository.dart
abstract class BookRepository {
  Future<List<Book>> getAllBooks();
  Future<Book> getBookById(String id);
  Future<void> downloadBook(Book book);
}
```

#### 3. Use Case (Domain Layer)
```dart
// domain/usecases/get_all_books.dart
class GetAllBooks {
  final BookRepository repository;
  
  GetAllBooks(this.repository);
  
  Future<List<Book>> call() async {
    return await repository.getAllBooks();
  }
}
```

#### 4. Data Model (Data Layer)
```dart
// data/models/book_model.dart
class BookModel extends Book {
  BookModel({
    required String id,
    required String title,
    required String author,
  }) : super(id: id, title: title, author: author);
  
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
    };
  }
}
```

#### 5. Repository Implementation (Data Layer)
```dart
// data/repositories/book_repository_impl.dart
class BookRepositoryImpl implements BookRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  
  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<List<Book>> getAllBooks() async {
    try {
      // 嘗試從遠程獲取
      final books = await remoteDataSource.fetchBooks();
      // 緩存到本地
      await localDataSource.cacheBooks(books);
      return books;
    } catch (e) {
      // 失敗時從本地加載
      return await localDataSource.getBooks();
    }
  }
}
```

#### 6. Controller (Presentation Layer)
```dart
// presentation/controllers/book_controller.dart
class BookController extends GetxController {
  final GetAllBooks getAllBooksUseCase;
  
  BookController({required this.getAllBooksUseCase});
  
  final books = <Book>[].obs;
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }
  
  Future<void> loadBooks() async {
    isLoading.value = true;
    try {
      final result = await getAllBooksUseCase();
      books.value = result;
    } catch (e) {
      Get.snackbar('錯誤', '加載書籍失敗');
    } finally {
      isLoading.value = false;
    }
  }
}
```

#### 7. 依賴注入 (GetX)
```dart
// app/bindings/home_binding.dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<RemoteDataSource>(() => RemoteDataSourceImpl(dio: Get.find()));
    Get.lazyPut<LocalDataSource>(() => LocalDataSourceImpl(hive: Get.find()));
    
    // Repository
    Get.lazyPut<BookRepository>(
      () => BookRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
    );
    
    // Use Cases
    Get.lazyPut(() => GetAllBooks(Get.find<BookRepository>()));
    
    // Controller
    Get.lazyPut(() => BookController(getAllBooksUseCase: Get.find()));
  }
}
```

### 依賴規則

**關鍵原則：依賴只能由外向內**

```
Presentation → Domain ← Data
     ↓           ↑       ↑
  不可依賴    可被依賴   可被依賴
```

- Presentation 依賴 Domain
- Data 依賴 Domain
- Domain 不依賴任何層（純 Dart）

### 替代方案

#### MVC (Model-View-Controller)
- ✅ 簡單易懂
- ❌ 邏輯容易混亂
- ❌ 難以測試

#### MVVM (Model-View-ViewModel)
- ✅ 數據綁定
- ❌ ViewModel 可能過重

#### Layered Architecture
- ✅ 簡單直接
- ❌ 層次不夠清晰

### 影響
- 初期代碼量較多（需要接口和實現）
- 長期維護成本低
- 易於單元測試（可 mock 每一層）
- 團隊成員需要理解架構

### 相關資源
- [The Clean Architecture (Robert C. Martin)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Example](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

---

## 決策變更流程

當需要修改技術決策時：

1. **記錄原因**：為什麼需要變更？
2. **評估影響**：會影響哪些模塊？
3. **討論方案**：有哪些替代方案？
4. **更新 ADR**：標記舊決策為"已棄用"，創建新 ADR
5. **通知團隊**：確保所有人知曉變更

### 示例：棄用舊決策

```markdown
## ADR-XXX: 舊決策

### 狀態
❌ 已棄用 (2025-XX-XX)
↪️ 被 ADR-YYY 取代

### 棄用原因
...
```

---

## 總結

這些技術決策基於以下原則：

1. **簡單優先**：選擇易學易用的技術
2. **社區支持**：選擇活躍的開源項目
3. **性能優先**：在用戶體驗上不妥協
4. **成本控制**：優先使用免費方案
5. **可擴展性**：為未來迭代留下空間

所有決策都可根據實際情況調整，但需要記錄變更原因和過程。
