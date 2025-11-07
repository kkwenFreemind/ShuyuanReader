# Spec 02: 書籍列表頁（Book List）

**功能名稱**: Book List Page  
**優先級**: P0 (核心功能)  
**預計時間**: 3-4 天 (24-32 小時)  
**依賴**: Spec 01 (Splash Screen)  
**狀態**: 📋 規格完成，待實現  
**創建日期**: 2025-11-07

---

## 📋 目錄

1. [功能概述](#功能概述)
2. [用戶故事](#用戶故事)
3. [功能需求](#功能需求)
4. [UI/UX 設計](#uiux-設計)
5. [技術設計](#技術設計)
6. [數據模型](#數據模型)
7. [API 設計](#api-設計)
8. [狀態管理](#狀態管理)
9. [錯誤處理](#錯誤處理)
10. [性能考量](#性能考量)
11. [測試策略](#測試策略)
12. [驗收標準](#驗收標準)
13. [後續優化](#後續優化)

---

## 功能概述

### 核心價值
書籍列表頁是應用的主頁面，用戶可以：
- 📚 瀏覽所有可用的經典書籍（100+ 本）
- 🖼️ 查看書籍封面、書名、作者
- 🔄 下拉刷新獲取最新書籍列表
- ✈️ 離線模式下查看已緩存的書籍
- 📱 流暢的滾動和優雅的加載動畫

### 業務目標
- 提供直觀的書籍瀏覽體驗
- 確保離線可用性
- 優化加載性能（< 2 秒首屏）
- 支持 100+ 書籍的流暢展示

---

## 用戶故事

### US-02-01: 查看書籍列表
**作為** 一個閱讀愛好者  
**我想要** 看到所有可用的書籍列表  
**以便** 我可以選擇感興趣的書籍閱讀

**驗收標準**:
- ✅ 啟動 APP 後自動顯示書籍列表
- ✅ 每本書顯示封面、書名、作者
- ✅ 使用 GridView 2 列佈局
- ✅ 滾動流暢，無卡頓

---

### US-02-02: 下拉刷新
**作為** 一個用戶  
**我想要** 下拉刷新書籍列表  
**以便** 我可以獲取最新的書籍數據

**驗收標準**:
- ✅ 下拉顯示刷新指示器
- ✅ 刷新時顯示加載動畫
- ✅ 刷新完成後更新列表
- ✅ 刷新失敗顯示錯誤提示

---

### US-02-03: 離線模式
**作為** 一個用戶  
**我想要** 在沒有網絡時也能查看書籍列表  
**以便** 我可以在任何地方使用 APP

**驗收標準**:
- ✅ 首次加載成功後緩存數據
- ✅ 離線時從緩存加載
- ✅ 顯示"離線模式"提示
- ✅ 離線時封面使用佔位圖

---

### US-02-04: 點擊書籍
**作為** 一個用戶  
**我想要** 點擊書籍查看詳情  
**以便** 我可以了解更多信息並下載

**驗收標準**:
- ✅ 點擊書籍跳轉到詳情頁
- ✅ 使用 Hero 動畫過渡封面
- ✅ 跳轉流暢，無延遲

---

## 功能需求

### 核心功能

#### FR-02-01: 書籍列表展示
- **必須** 從 GitHub 下載 `catalog/books.json`
- **必須** 解析 JSON 並顯示書籍列表
- **必須** 使用 GridView 2 列佈局
- **必須** 顯示封面、書名、作者
- **必須** 支持垂直滾動

#### FR-02-02: 封面圖片加載
- **必須** 從 GitHub 加載封面圖片
- **必須** 使用 `cached_network_image` 緩存封面
- **必須** 顯示加載動畫（Shimmer）
- **必須** 加載失敗顯示佔位圖
- **應該** 使用 fade-in 動畫

#### FR-02-03: 下拉刷新
- **必須** 支持下拉刷新手勢
- **必須** 顯示刷新指示器
- **必須** 重新下載 `books.json`
- **必須** 刷新完成後更新列表
- **應該** 刷新時觸覺反饋

#### FR-02-04: 數據緩存
- **必須** 首次加載成功後緩存 JSON 到 Hive
- **必須** 離線時從 Hive 加載
- **必須** 記錄最後更新時間
- **應該** 緩存過期時間（7 天）

#### FR-02-05: 錯誤處理
- **必須** 網絡錯誤顯示友好提示
- **必須** 提供重試按鈕
- **必須** 解析錯誤顯示錯誤頁面
- **應該** 使用 SnackBar 顯示錯誤

#### FR-02-06: 空狀態
- **必須** 無數據時顯示空狀態頁面
- **必須** 提供"刷新"按鈕
- **應該** 顯示友好的空狀態插圖

---

## UI/UX 設計

### 頁面結構

```
┌─────────────────────────────────────────┐
│ AppBar                                  │
│  📚 書苑閱讀器        🔍  ⚙️           │
├─────────────────────────────────────────┤
│                                         │
│  RefreshIndicator                       │
│  └─ GridView.builder (2 columns)       │
│      ┌─────────┐  ┌─────────┐         │
│      │ Hero    │  │ Hero    │         │
│      │ 封面1   │  │ 封面2   │         │
│      │         │  │         │         │
│      │ 書名1   │  │ 書名2   │         │
│      │ 作者1   │  │ 作者2   │         │
│      └─────────┘  └─────────┘         │
│                                         │
│      ┌─────────┐  ┌─────────┐         │
│      │ 封面3   │  │ 封面4   │         │
│      └─────────┘  └─────────┘         │
│                                         │
│      ... (繼續滾動)                     │
│                                         │
└─────────────────────────────────────────┘
```

### 書籍卡片設計

```dart
┌───────────────────────┐
│  ┌─────────────────┐  │  ← Card
│  │                 │  │  ← Hero (cover)
│  │   Book Cover    │  │  ← 160x240 px
│  │                 │  │  ← BorderRadius(12)
│  └─────────────────┘  │
│                       │
│   📚 書名              │  ← Title (max 2 lines)
│   ✍️ 作者              │  ← Author (max 1 line)
│                       │
│   [下載狀態徽章]       │  ← Optional badge
│                       │
└───────────────────────┘
    ← Padding(16)
    ← onTap → BookDetailPage
```

### 加載狀態

#### 1. 首次加載（Shimmer）
```
┌─────────┐  ┌─────────┐
│░░░░░░░░░│  │░░░░░░░░░│  ← Shimmer effect
│░░░░░░░░░│  │░░░░░░░░░│
│░░░░░░░░░│  │░░░░░░░░░│
└─────────┘  └─────────┘
  ░░░░░░        ░░░░░░    ← Shimmer text
  ░░░            ░░░
```

#### 2. 下拉刷新
```
       ↓
   ━━━━━━━  ← CircularProgressIndicator
     ↻
```

#### 3. 加載更多（預留）
```
       ...
   ━━━━━━━  ← 底部加載指示器
```

### 錯誤狀態

```
┌─────────────────────────┐
│                         │
│      😕                 │
│   網絡連接失敗           │
│                         │
│  無法獲取書籍列表        │
│                         │
│  ┌─────────────────┐   │
│  │   🔄 重試        │   │
│  └─────────────────┘   │
│                         │
└─────────────────────────┘
```

### 空狀態

```
┌─────────────────────────┐
│                         │
│      📚                 │
│   暫無書籍              │
│                         │
│  請下拉刷新獲取書籍列表  │
│                         │
│  ┌─────────────────┐   │
│  │   ↻ 刷新         │   │
│  └─────────────────┘   │
│                         │
└─────────────────────────┘
```

### 離線提示

```
┌─────────────────────────┐
│ ℹ️ 離線模式 (上次更新: 2h前) │  ← Banner
└─────────────────────────┘
```

---

## 技術設計

### 架構設計（Clean Architecture）

```
presentation/
├── pages/
│   └── book_list/
│       ├── book_list_page.dart          ← UI 頁面
│       ├── widgets/
│       │   ├── book_grid_item.dart      ← 書籍卡片
│       │   ├── book_list_shimmer.dart   ← Shimmer 加載
│       │   ├── empty_state.dart         ← 空狀態
│       │   └── error_state.dart         ← 錯誤狀態
│       └── controllers/
│           └── book_list_controller.dart ← GetX Controller
│
domain/
├── entities/
│   └── book.dart                        ← Book 實體
├── repositories/
│   └── book_repository.dart             ← 倉庫接口
└── usecases/
    ├── get_books_usecase.dart           ← 獲取書籍用例
    └── refresh_books_usecase.dart       ← 刷新書籍用例
│
data/
├── models/
│   └── book_model.dart                  ← Book 模型（Hive）
├── repositories/
│   └── book_repository_impl.dart        ← 倉庫實現
└── datasources/
    ├── book_remote_datasource.dart      ← 遠程數據源（GitHub）
    └── book_local_datasource.dart       ← 本地數據源（Hive）
```

### 文件清單

#### 1. Presentation Layer

**`lib/presentation/pages/book_list/book_list_page.dart`**
```dart
class BookListPage extends GetView<BookListController> {
  - AppBar
  - RefreshIndicator
  - GetX<BookListController> (狀態監聽)
    - Loading → BookListShimmer
    - Empty → EmptyState
    - Error → ErrorState
    - Success → GridView.builder
}
```

**`lib/presentation/pages/book_list/widgets/book_grid_item.dart`**
```dart
class BookGridItem extends StatelessWidget {
  - Card
  - Hero (cover)
  - CachedNetworkImage
  - Title & Author
  - onTap → BookDetailPage
}
```

**`lib/presentation/pages/book_list/widgets/book_list_shimmer.dart`**
```dart
class BookListShimmer extends StatelessWidget {
  - GridView with Shimmer items
  - ShimmerPlaceholder for cover
  - ShimmerPlaceholder for text
}
```

**`lib/presentation/pages/book_list/controllers/book_list_controller.dart`**
```dart
class BookListController extends GetxController {
  - RxList<Book> books
  - Rx<LoadingState> loadingState
  - GetBooksUseCase getBooksUseCase
  - RefreshBooksUseCase refreshBooksUseCase
  
  Methods:
  - onInit() → loadBooks()
  - loadBooks() → 獲取書籍
  - refreshBooks() → 刷新書籍
  - onBookTap(Book) → 跳轉詳情
}
```

#### 2. Domain Layer

**`lib/domain/entities/book.dart`**
```dart
class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String epubUrl;
  final String description;
  final String language;
  final int fileSize;
  final DateTime? downloadedAt;
}
```

**`lib/domain/repositories/book_repository.dart`**
```dart
abstract class BookRepository {
  Future<List<Book>> getBooks({bool forceRefresh});
  Future<Book?> getBookById(String id);
  Future<void> saveBooks(List<Book> books);
}
```

**`lib/domain/usecases/get_books_usecase.dart`**
```dart
class GetBooksUseCase {
  final BookRepository repository;
  
  Future<List<Book>> call({bool forceRefresh = false});
}
```

#### 3. Data Layer

**`lib/data/models/book_model.dart`**
```dart
@HiveType(typeId: 0)
class BookModel extends Book {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  // ... 其他字段
  
  factory BookModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**`lib/data/datasources/book_remote_datasource.dart`**
```dart
class BookRemoteDataSource {
  final Dio dio;
  static const baseUrl = 'https://raw.githubusercontent.com/...';
  
  Future<List<BookModel>> fetchBooks();
}
```

**`lib/data/datasources/book_local_datasource.dart`**
```dart
class BookLocalDataSource {
  final Box<BookModel> bookBox;
  
  Future<List<BookModel>> getCachedBooks();
  Future<void> cacheBooks(List<BookModel> books);
  Future<DateTime?> getLastUpdateTime();
  Future<void> setLastUpdateTime(DateTime time);
}
```

---

## 數據模型

### Book Model (Hive)

```dart
@HiveType(typeId: 0)
class BookModel extends HiveObject {
  @HiveField(0)
  final String id;                    // 唯一標識符

  @HiveField(1)
  final String title;                 // 書名

  @HiveField(2)
  final String author;                // 作者

  @HiveField(3)
  final String coverUrl;              // 封面 URL

  @HiveField(4)
  final String epubUrl;               // EPUB 文件 URL

  @HiveField(5)
  final String description;           // 描述

  @HiveField(6)
  final String language;              // 語言（zh-TW）

  @HiveField(7)
  final int fileSize;                 // 文件大小（bytes）

  @HiveField(8)
  final DateTime? downloadedAt;       // 下載時間

  @HiveField(9)
  final String? localPath;            // 本地路徑

  @HiveField(10)
  final int? readProgress;            // 閱讀進度（百分比）

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.epubUrl,
    required this.description,
    required this.language,
    required this.fileSize,
    this.downloadedAt,
    this.localPath,
    this.readProgress,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['cover_url'] as String,
      epubUrl: json['epub_url'] as String,
      description: json['description'] as String? ?? '',
      language: json['language'] as String? ?? 'zh-TW',
      fileSize: json['file_size'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'epub_url': epubUrl,
      'description': description,
      'language': language,
      'file_size': fileSize,
    };
  }

  // 是否已下載
  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;

  // 格式化文件大小
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

### books.json 格式

```json
{
  "version": "1.0",
  "updated_at": "2025-11-07T00:00:00Z",
  "books": [
    {
      "id": "yi-meng-man-yan",
      "title": "一夢漫言",
      "author": "千華寺繼任主持 見月老人",
      "cover_url": "https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/covers/一夢漫言.png",
      "epub_url": "https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/epub3/一夢漫言.epub",
      "description": "千華寺繼任主持見月老人的自傳，記述其一生修行經歷。",
      "language": "zh-TW",
      "file_size": 2621440
    }
  ]
}
```

---

## API 設計

### GitHub Raw URL

```
Base URL: https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/

Endpoints:
- GET /catalog/books.json      → 書籍列表
- GET /covers/{filename}.png   → 封面圖片
- GET /epub3/{filename}.epub   → EPUB 文件
```

### BookRemoteDataSource

```dart
class BookRemoteDataSource {
  static const baseUrl = 'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main';
  
  final Dio _dio;

  BookRemoteDataSource(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// 獲取書籍列表
  Future<List<BookModel>> fetchBooks() async {
    try {
      final response = await _dio.get('/catalog/books.json');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final booksJson = data['books'] as List;
        
        return booksJson
            .map((json) => BookModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 處理 Dio 錯誤
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('網絡請求超時');
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkException('網絡連接失敗');
    } else {
      return ServerException('服務器錯誤: ${e.message}');
    }
  }
}
```

---

## 狀態管理

### GetX Controller

```dart
class BookListController extends GetxController {
  final GetBooksUseCase _getBooksUseCase;
  final RefreshBooksUseCase _refreshBooksUseCase;

  // 響應式狀態
  final RxList<Book> books = <Book>[].obs;
  final Rx<LoadingState> loadingState = LoadingState.loading.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOffline = false.obs;

  BookListController({
    required GetBooksUseCase getBooksUseCase,
    required RefreshBooksUseCase refreshBooksUseCase,
  })  : _getBooksUseCase = getBooksUseCase,
        _refreshBooksUseCase = refreshBooksUseCase;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }

  /// 加載書籍列表
  Future<void> loadBooks({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        loadingState.value = LoadingState.loading;
      }

      final result = await _getBooksUseCase(forceRefresh: forceRefresh);
      
      books.value = result;
      loadingState.value = LoadingState.success;
      isOffline.value = false;
      
    } on NetworkException catch (e) {
      // 網絡錯誤，嘗試使用緩存
      final cachedBooks = await _getBooksUseCase(forceRefresh: false);
      if (cachedBooks.isNotEmpty) {
        books.value = cachedBooks;
        loadingState.value = LoadingState.success;
        isOffline.value = true;
        Get.snackbar('離線模式', '正在使用緩存數據');
      } else {
        loadingState.value = LoadingState.error;
        errorMessage.value = e.message;
      }
      
    } catch (e) {
      loadingState.value = LoadingState.error;
      errorMessage.value = e.toString();
    }
  }

  /// 刷新書籍列表
  Future<void> refreshBooks() async {
    await loadBooks(forceRefresh: true);
  }

  /// 點擊書籍
  void onBookTap(Book book) {
    Get.toNamed(
      Routes.BOOK_DETAIL,
      arguments: book,
    );
  }

  /// 重試
  void retry() {
    loadBooks(forceRefresh: true);
  }
}

/// 加載狀態枚舉
enum LoadingState {
  loading,
  success,
  error,
  empty,
}
```

### UI 綁定

```dart
class BookListBinding extends Bindings {
  @override
  void dependencies() {
    // DataSources
    Get.lazyPut<BookRemoteDataSource>(
      () => BookRemoteDataSource(Get.find<Dio>()),
    );
    Get.lazyPut<BookLocalDataSource>(
      () => BookLocalDataSource(Get.find<Box<BookModel>>()),
    );

    // Repository
    Get.lazyPut<BookRepository>(
      () => BookRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
    );

    // UseCases
    Get.lazyPut(() => GetBooksUseCase(Get.find()));
    Get.lazyPut(() => RefreshBooksUseCase(Get.find()));

    // Controller
    Get.lazyPut(
      () => BookListController(
        getBooksUseCase: Get.find(),
        refreshBooksUseCase: Get.find(),
      ),
    );
  }
}
```

---

## 錯誤處理

### 自定義異常

```dart
/// 基礎異常類
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// 網絡異常
class NetworkException extends AppException {
  NetworkException([String message = '網絡連接失敗']) : super(message, 'NETWORK_ERROR');
}

/// 服務器異常
class ServerException extends AppException {
  ServerException([String message = '服務器錯誤']) : super(message, 'SERVER_ERROR');
}

/// 超時異常
class TimeoutException extends AppException {
  TimeoutException([String message = '請求超時']) : super(message, 'TIMEOUT');
}

/// 解析異常
class ParseException extends AppException {
  ParseException([String message = '數據解析失敗']) : super(message, 'PARSE_ERROR');
}

/// 緩存異常
class CacheException extends AppException {
  CacheException([String message = '緩存操作失敗']) : super(message, 'CACHE_ERROR');
}
```

### 錯誤處理策略

```dart
class BookRepositoryImpl implements BookRepository {
  @override
  Future<List<Book>> getBooks({bool forceRefresh = false}) async {
    try {
      // 1. 嘗試從遠程獲取
      if (forceRefresh || await _shouldRefresh()) {
        final remoteBooks = await _remoteDataSource.fetchBooks();
        await _localDataSource.cacheBooks(remoteBooks);
        await _localDataSource.setLastUpdateTime(DateTime.now());
        return remoteBooks;
      }

      // 2. 從緩存獲取
      final cachedBooks = await _localDataSource.getCachedBooks();
      if (cachedBooks.isNotEmpty) {
        return cachedBooks;
      }

      // 3. 緩存為空，強制從遠程獲取
      final remoteBooks = await _remoteDataSource.fetchBooks();
      await _localDataSource.cacheBooks(remoteBooks);
      return remoteBooks;
      
    } on NetworkException {
      // 網絡錯誤，嘗試使用緩存
      final cachedBooks = await _localDataSource.getCachedBooks();
      if (cachedBooks.isNotEmpty) {
        return cachedBooks;
      }
      rethrow;
      
    } catch (e) {
      // 其他錯誤
      throw ServerException(e.toString());
    }
  }

  Future<bool> _shouldRefresh() async {
    final lastUpdate = await _localDataSource.getLastUpdateTime();
    if (lastUpdate == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inDays >= 7; // 7 天過期
  }
}
```

---

## 性能考量

### 圖片優化

```dart
class BookGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // 使用 CachedNetworkImage + 圖片壓縮
          CachedNetworkImage(
            imageUrl: book.coverUrl,
            fit: BoxFit.cover,
            memCacheWidth: 300,  // 限制內存緩存大小
            memCacheHeight: 450,
            placeholder: (context, url) => const ShimmerPlaceholder(),
            errorWidget: (context, url, error) => const PlaceholderImage(),
          ),
        ],
      ),
    );
  }
}
```

### 列表優化

```dart
class BookListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // 使用 builder 模式，只渲染可見項
      itemCount: books.length,
      
      // 緩存範圍（默認 250）
      cacheExtent: 500,
      
      // 使用 const 構造函數
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      
      itemBuilder: (context, index) {
        final book = books[index];
        return BookGridItem(
          key: ValueKey(book.id),  // 使用穩定的 key
          book: book,
        );
      },
    );
  }
}
```

### 數據加載優化

```dart
class GetBooksUseCase {
  Future<List<Book>> call({bool forceRefresh = false}) async {
    // 使用緩存策略
    if (!forceRefresh) {
      final cachedBooks = await _repository.getCachedBooks();
      if (cachedBooks.isNotEmpty) {
        // 後台靜默刷新
        _repository.getBooks(forceRefresh: true).catchError((_) {});
        return cachedBooks;
      }
    }
    
    return await _repository.getBooks(forceRefresh: forceRefresh);
  }
}
```

---

## 測試策略

### 單元測試

#### 1. BookModel 測試
```dart
test('BookModel.fromJson 應該正確解析 JSON', () {
  final json = {
    'id': 'test-book',
    'title': '測試書籍',
    'author': '測試作者',
    // ...
  };
  
  final book = BookModel.fromJson(json);
  
  expect(book.id, 'test-book');
  expect(book.title, '測試書籍');
});

test('isDownloaded 應該返回正確狀態', () {
  final book = BookModel(localPath: '/path/to/book.epub');
  expect(book.isDownloaded, true);
  
  final book2 = BookModel(localPath: null);
  expect(book2.isDownloaded, false);
});
```

#### 2. Repository 測試
```dart
test('getBooks 應該先嘗試遠程，失敗時使用緩存', () async {
  when(remoteDataSource.fetchBooks()).thenThrow(NetworkException());
  when(localDataSource.getCachedBooks()).thenReturn([mockBook]);
  
  final result = await repository.getBooks();
  
  expect(result, [mockBook]);
  verify(remoteDataSource.fetchBooks()).called(1);
  verify(localDataSource.getCachedBooks()).called(1);
});
```

#### 3. Controller 測試
```dart
test('loadBooks 應該更新 books 列表', () async {
  when(getBooksUseCase()).thenReturn([mockBook]);
  
  await controller.loadBooks();
  
  expect(controller.books, [mockBook]);
  expect(controller.loadingState.value, LoadingState.success);
});
```

### Widget 測試

```dart
testWidgets('BookListPage 應該顯示書籍列表', (tester) async {
  await tester.pumpWidget(TestApp(child: BookListPage()));
  await tester.pumpAndSettle();
  
  expect(find.byType(GridView), findsOneWidget);
  expect(find.byType(BookGridItem), findsWidgets);
});

testWidgets('點擊書籍應該跳轉到詳情頁', (tester) async {
  await tester.pumpWidget(TestApp(child: BookListPage()));
  await tester.pumpAndSettle();
  
  await tester.tap(find.byType(BookGridItem).first);
  await tester.pumpAndSettle();
  
  expect(find.byType(BookDetailPage), findsOneWidget);
});
```

### Golden 測試

```dart
testWidgets('BookGridItem 應該匹配設計稿', (tester) async {
  await tester.pumpWidget(TestApp(
    child: BookGridItem(book: mockBook),
  ));
  
  await expectLater(
    find.byType(BookGridItem),
    matchesGoldenFile('goldens/book_grid_item.png'),
  );
});

testWidgets('EmptyState 應該匹配設計稿', (tester) async {
  await tester.pumpWidget(TestApp(child: EmptyState()));
  
  await expectLater(
    find.byType(EmptyState),
    matchesGoldenFile('goldens/empty_state.png'),
  );
});
```

### 集成測試

```dart
testWidgets('完整流程: 加載 → 刷新 → 點擊', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  // 1. 驗證列表加載
  expect(find.byType(BookGridItem), findsWidgets);
  
  // 2. 下拉刷新
  await tester.drag(find.byType(RefreshIndicator), Offset(0, 300));
  await tester.pumpAndSettle();
  
  // 3. 點擊書籍
  await tester.tap(find.byType(BookGridItem).first);
  await tester.pumpAndSettle();
  
  // 4. 驗證跳轉
  expect(find.byType(BookDetailPage), findsOneWidget);
});
```

---

## 驗收標準

### 功能驗收

- [ ] **AC-01**: 啟動 APP 後自動顯示書籍列表（< 2 秒）
- [ ] **AC-02**: 書籍列表使用 GridView 2 列佈局
- [ ] **AC-03**: 每本書顯示封面、書名、作者
- [ ] **AC-04**: 封面圖片正確加載（或顯示佔位圖）
- [ ] **AC-05**: 支持下拉刷新功能
- [ ] **AC-06**: 刷新時顯示加載動畫
- [ ] **AC-07**: 網絡失敗時使用緩存數據
- [ ] **AC-08**: 離線模式顯示提示 Banner
- [ ] **AC-09**: 點擊書籍跳轉到詳情頁
- [ ] **AC-10**: 使用 Hero 動畫過渡封面

### 性能驗收

- [ ] **PC-01**: 首屏加載時間 < 2 秒
- [ ] **PC-02**: 滾動幀率 > 50 FPS
- [ ] **PC-03**: 內存占用 < 150 MB
- [ ] **PC-04**: 封面圖片緩存生效
- [ ] **PC-05**: 100+ 書籍流暢顯示

### UI/UX 驗收

- [ ] **UI-01**: 首次加載顯示 Shimmer 動畫
- [ ] **UI-02**: 空狀態顯示友好提示
- [ ] **UI-03**: 錯誤狀態顯示錯誤信息和重試按鈕
- [ ] **UI-04**: 下拉刷新動畫流暢
- [ ] **UI-05**: 離線 Banner 設計友好

### 測試驗收

- [ ] **TC-01**: 單元測試覆蓋率 > 80%
- [ ] **TC-02**: Widget 測試通過
- [ ] **TC-03**: Golden 測試通過
- [ ] **TC-04**: 集成測試通過

### 代碼質量驗收

- [ ] **CQ-01**: 遵循 Clean Architecture
- [ ] **CQ-02**: 代碼通過 Linter
- [ ] **CQ-03**: 無 TODO 或 FIXME
- [ ] **CQ-04**: 關鍵邏輯有註釋

---

## 後續優化

### Phase 2 功能

#### 1. 無限滾動（Spec 02.1）
- 分頁加載書籍（每頁 20 本）
- 滾動到底部自動加載更多
- 加載更多指示器

#### 2. 骨架屏優化（Spec 02.2）
- 更精細的 Shimmer 動畫
- 按實際卡片大小顯示骨架屏
- 漸進式加載封面

#### 3. 搜索功能（Spec 06）
- 書名和作者搜索
- 實時搜索結果
- 搜索歷史

#### 4. 過濾排序（Spec 06）
- 按作者過濾
- 按語言過濾
- 按書名/作者排序
- 已下載/未下載過濾

### 技術優化

#### 1. 性能優化
- [ ] 實現圖片懶加載
- [ ] 使用 compute 解析 JSON
- [ ] 優化列表滾動性能
- [ ] 實現智能預加載

#### 2. 用戶體驗優化
- [ ] 添加下載進度指示
- [ ] 實現骨架屏過渡
- [ ] 優化錯誤提示
- [ ] 添加觸覺反饋

#### 3. 離線優化
- [ ] 實現後台靜默刷新
- [ ] 優化緩存策略
- [ ] 支持離線搜索
- [ ] 緩存管理界面

---

## 參考資料

### 設計參考
- [Material Design 3 - Cards](https://m3.material.io/components/cards)
- [Material Design 3 - Grid](https://m3.material.io/foundations/layout/grid)
- [Human Interface Guidelines - Lists](https://developer.apple.com/design/human-interface-guidelines/lists)

### 技術參考
- [GetX Documentation](https://pub.dev/packages/get)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Hive Documentation](https://docs.hivedb.dev/)
- [cached_network_image](https://pub.dev/packages/cached_network_image)
- [shimmer](https://pub.dev/packages/shimmer)

### 最佳實踐
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf)
- [Clean Architecture in Flutter](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)

---

**規格版本**: 1.0  
**創建日期**: 2025-11-07  
**最後更新**: 2025-11-07  
**下一步**: 執行 `/speckit.tasks 02-book-list` 生成任務清單
