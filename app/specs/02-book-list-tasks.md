# Spec 02: 書籍列表頁 - 任務清單

**功能**: Book List Page  
**規格文檔**: `02-book-list.md`  
**優先級**: P0 (核心功能)  
**預計時間**: 3-4 天 (24-32 小時)  
**狀態**: 📋 待開始  
**創建日期**: 2025-11-07

---

## 📊 進度總覽

| 階段 | 任務數 | 完成數 | 進度 | 預計時間 | 實際時間 | 狀態 |
|------|--------|--------|------|----------|----------|------|
| Stage 1: 環境準備 | 2 | 1 | 50% | 2h | 0.25h | 🔄 進行中 |
| Stage 2: Data Layer | 4 | 0 | 0% | 6h | - | ⬜ 未開始 |
| Stage 3: Domain Layer | 3 | 0 | 0% | 4h | - | ⬜ 未開始 |
| Stage 4: Presentation Layer | 6 | 0 | 0% | 10h | - | ⬜ 未開始 |
| Stage 5: 測試 | 4 | 0 | 0% | 6h | - | ⬜ 未開始 |
| **總計** | **19** | **1** | **5.3%** | **28h** | **0.25h** | 🔄 進行中 |

---

## 🎯 Stage 1: 環境準備 (2 小時)

### Task 2.1.1: 配置依賴 ✅

**描述**: 在 `pubspec.yaml` 中添加必要的依賴包

**預計時間**: 0.5 小時  
**實際時間**: 0.25 小時  
**狀態**: ✅ 已完成 (2025-11-07)

**依賴**: 
- Spec 01 完成

**輸出**:
- `pubspec.yaml` 更新

**任務清單**:
- [x] 添加 `dio: ^5.3.0` (HTTP 客戶端) - 已存在 ^5.3.3
- [x] 添加 `cached_network_image: ^3.3.0` (圖片緩存) - 已存在
- [x] 添加 `shimmer: ^3.0.0` (加載動畫) - 已添加
- [x] 添加 `connectivity_plus: ^5.0.0` (網絡狀態檢測) - 已存在 ^5.0.2
- [x] 運行 `flutter pub get`
- [x] 驗證依賴安裝成功

**驗收標準**:
- ✅ 所有依賴正確添加到 `pubspec.yaml`
- ✅ `flutter pub get` 無錯誤 (Got dependencies!)
- ✅ `flutter analyze` 無新增警告（36 個 info 都是現有代碼）

**完成總結**:
1. 檢查現有依賴：`dio`, `cached_network_image`, `connectivity_plus` 已存在
2. 添加缺失依賴：`shimmer: ^3.0.0`
3. 成功運行 `flutter pub get`，所有依賴已安裝
4. `flutter analyze` 通過，無新增錯誤或警告

**實現提示**:
```yaml
dependencies:
  # 現有依賴...
  dio: ^5.3.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  connectivity_plus: ^5.0.0
```

---

### Task 2.1.2: 準備測試數據

**描述**: 創建本地測試用的 `books.json` 和封面圖片

**預計時間**: 1.5 小時

**依賴**: 
- Task 2.1.1 完成

**輸出**:
- `assets/test/books.json`
- `assets/test/covers/` (3-5 張測試封面)

**任務清單**:
- [ ] 創建 `assets/test/` 目錄
- [ ] 從 GitHub 下載 `catalog/books.json` 到本地
- [ ] 精簡為 5 本書的測試數據
- [ ] 下載對應的 5 張封面圖片
- [ ] 在 `pubspec.yaml` 中聲明資源
- [ ] 驗證資源加載成功

**驗收標準**:
- ✅ `books.json` 格式正確
- ✅ 封面圖片可訪問
- ✅ 資源在 `pubspec.yaml` 中正確聲明

**實現提示**:
```json
{
  "version": "1.0",
  "updated_at": "2025-11-07T00:00:00Z",
  "books": [
    {
      "id": "yi-meng-man-yan",
      "title": "一夢漫言",
      "author": "見月老人",
      "cover_url": "https://raw.githubusercontent.com/.../一夢漫言.png",
      "epub_url": "https://raw.githubusercontent.com/.../一夢漫言.epub",
      "description": "千華寺繼任主持見月老人的自傳",
      "language": "zh-TW",
      "file_size": 2621440
    }
  ]
}
```

---

## 🗄️ Stage 2: Data Layer (6 小時)

### Task 2.2.1: 創建 Book Model

**描述**: 實現 `BookModel` 類，支持 Hive 存儲和 JSON 序列化

**預計時間**: 1.5 小時

**依賴**: 
- Task 2.1.1 完成

**輸出**:
- `lib/data/models/book_model.dart`
- `lib/data/models/book_model.g.dart` (生成)

**任務清單**:
- [ ] 創建 `BookModel` 類
- [ ] 添加 `@HiveType(typeId: 1)` 註解
- [ ] 實現所有字段（id, title, author, etc.）
- [ ] 實現 `fromJson()` 工廠方法
- [ ] 實現 `toJson()` 方法
- [ ] 添加 `isDownloaded` getter
- [ ] 添加 `fileSizeFormatted` getter
- [ ] 運行 `flutter packages pub run build_runner build`
- [ ] 驗證生成 `.g.dart` 文件

**驗收標準**:
- ✅ `BookModel` 類完整實現
- ✅ Hive 適配器正確生成
- ✅ JSON 序列化/反序列化工作正常
- ✅ 單元測試通過

**實現提示**:
```dart
import 'package:hive/hive.dart';

part 'book_model.g.dart';

@HiveType(typeId: 1)
class BookModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  // ... 其他字段

  BookModel({required this.id, required this.title, ...});

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    id: json['id'] as String,
    title: json['title'] as String,
    // ...
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    // ...
  };

  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;
}
```

---

### Task 2.2.2: 實現 Remote DataSource

**描述**: 實現 `BookRemoteDataSource`，從 GitHub 獲取書籍數據

**預計時間**: 2 小時

**依賴**: 
- Task 2.2.1 完成

**輸出**:
- `lib/data/datasources/book_remote_datasource.dart`

**任務清單**:
- [ ] 創建 `BookRemoteDataSource` 類
- [ ] 配置 Dio 實例（baseUrl, timeout）
- [ ] 實現 `fetchBooks()` 方法
- [ ] 處理 HTTP 錯誤（404, timeout, etc.）
- [ ] 解析 JSON 並返回 `List<BookModel>`
- [ ] 添加日誌記錄
- [ ] 實現錯誤處理（自定義異常）
- [ ] 編寫單元測試（mock Dio）

**驗收標準**:
- ✅ 能成功下載 `books.json`
- ✅ 正確解析 JSON 為 `BookModel` 列表
- ✅ 網絡錯誤正確拋出異常
- ✅ 單元測試覆蓋率 > 80%

**實現提示**:
```dart
class BookRemoteDataSource {
  static const baseUrl = 'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main';
  final Dio _dio;

  BookRemoteDataSource(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
  }

  Future<List<BookModel>> fetchBooks() async {
    try {
      final response = await _dio.get('/catalog/books.json');
      final data = response.data as Map<String, dynamic>;
      final booksJson = data['books'] as List;
      return booksJson.map((json) => BookModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
```

---

### Task 2.2.3: 實現 Local DataSource

**描述**: 實現 `BookLocalDataSource`，使用 Hive 緩存書籍數據

**預計時間**: 1.5 小時

**依賴**: 
- Task 2.2.1 完成

**輸出**:
- `lib/data/datasources/book_local_datasource.dart`

**任務清單**:
- [ ] 創建 `BookLocalDataSource` 類
- [ ] 在 `AppInitializer` 中註冊 `BookModel` 適配器
- [ ] 實現 `getCachedBooks()` 方法
- [ ] 實現 `cacheBooks()` 方法
- [ ] 實現 `getLastUpdateTime()` 方法
- [ ] 實現 `setLastUpdateTime()` 方法
- [ ] 實現 `clearCache()` 方法
- [ ] 編寫單元測試

**驗收標準**:
- ✅ Hive Box 正確初始化
- ✅ 數據正確存儲和讀取
- ✅ 時間戳正確記錄
- ✅ 單元測試通過

**實現提示**:
```dart
class BookLocalDataSource {
  final Box<BookModel> _bookBox;
  final Box<dynamic> _metaBox;

  BookLocalDataSource(this._bookBox, this._metaBox);

  Future<List<BookModel>> getCachedBooks() async {
    return _bookBox.values.toList();
  }

  Future<void> cacheBooks(List<BookModel> books) async {
    await _bookBox.clear();
    for (var book in books) {
      await _bookBox.put(book.id, book);
    }
  }

  Future<DateTime?> getLastUpdateTime() async {
    final timestamp = _metaBox.get('last_book_update');
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
}
```

---

### Task 2.2.4: 實現 Repository

**描述**: 實現 `BookRepositoryImpl`，協調遠程和本地數據源

**預計時間**: 1 小時

**依賴**: 
- Task 2.2.2, 2.2.3 完成

**輸出**:
- `lib/data/repositories/book_repository_impl.dart`

**任務清單**:
- [ ] 創建 `BookRepositoryImpl` 類
- [ ] 實現 `getBooks()` 方法（緩存策略）
- [ ] 實現 `getBookById()` 方法
- [ ] 實現 `saveBooks()` 方法
- [ ] 處理網絡錯誤時回退到緩存
- [ ] 實現 7 天緩存過期邏輯
- [ ] 編寫單元測試（mock datasources）

**驗收標準**:
- ✅ 優先使用遠程數據，失敗時使用緩存
- ✅ 緩存策略正確實現
- ✅ 錯誤處理完善
- ✅ 單元測試通過

**實現提示**:
```dart
class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource _remoteDataSource;
  final BookLocalDataSource _localDataSource;

  @override
  Future<List<Book>> getBooks({bool forceRefresh = false}) async {
    try {
      if (forceRefresh || await _shouldRefresh()) {
        final remoteBooks = await _remoteDataSource.fetchBooks();
        await _localDataSource.cacheBooks(remoteBooks);
        await _localDataSource.setLastUpdateTime(DateTime.now());
        return remoteBooks;
      }
      return await _localDataSource.getCachedBooks();
    } on NetworkException {
      final cachedBooks = await _localDataSource.getCachedBooks();
      if (cachedBooks.isNotEmpty) return cachedBooks;
      rethrow;
    }
  }

  Future<bool> _shouldRefresh() async {
    final lastUpdate = await _localDataSource.getLastUpdateTime();
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate).inDays >= 7;
  }
}
```

---

## 🎯 Stage 3: Domain Layer (4 小時)

### Task 2.3.1: 創建 Book Entity

**描述**: 定義 `Book` 實體類（純業務對象）

**預計時間**: 0.5 小時

**依賴**: 
- 無

**輸出**:
- `lib/domain/entities/book.dart`

**任務清單**:
- [ ] 創建 `Book` 類（不依賴任何框架）
- [ ] 定義所有必要字段
- [ ] 實現 `copyWith()` 方法
- [ ] 實現 `==` 和 `hashCode`
- [ ] 添加業務邏輯 getter
- [ ] 編寫單元測試

**驗收標準**:
- ✅ `Book` 類純粹，無外部依賴
- ✅ 所有字段定義清晰
- ✅ 單元測試通過

**實現提示**:
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
  final String? localPath;

  const Book({
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
  });

  bool get isDownloaded => localPath != null;
  
  String get fileSizeFormatted {
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Book copyWith({...}) => Book(...);

  @override
  bool operator ==(Object other) => ...;

  @override
  int get hashCode => ...;
}
```

---

### Task 2.3.2: 創建 Repository 接口

**描述**: 定義 `BookRepository` 抽象接口

**預計時間**: 0.5 小時

**依賴**: 
- Task 2.3.1 完成

**輸出**:
- `lib/domain/repositories/book_repository.dart`

**任務清單**:
- [ ] 創建 `BookRepository` 抽象類
- [ ] 定義 `getBooks()` 方法簽名
- [ ] 定義 `getBookById()` 方法簽名
- [ ] 定義 `saveBooks()` 方法簽名
- [ ] 添加文檔註釋

**驗收標準**:
- ✅ 接口定義清晰
- ✅ 方法簽名合理
- ✅ 文檔註釋完整

**實現提示**:
```dart
abstract class BookRepository {
  /// 獲取書籍列表
  /// 
  /// [forceRefresh] 是否強制刷新（忽略緩存）
  Future<List<Book>> getBooks({bool forceRefresh = false});

  /// 根據 ID 獲取單本書籍
  Future<Book?> getBookById(String id);

  /// 保存書籍列表到緩存
  Future<void> saveBooks(List<Book> books);
}
```

---

### Task 2.3.3: 實現 UseCases

**描述**: 實現 `GetBooksUseCase` 和 `RefreshBooksUseCase`

**預計時間**: 3 小時

**依賴**: 
- Task 2.3.2 完成

**輸出**:
- `lib/domain/usecases/get_books_usecase.dart`
- `lib/domain/usecases/refresh_books_usecase.dart`

**任務清單**:
- [ ] 創建 `GetBooksUseCase` 類
- [ ] 實現 `call()` 方法（優先使用緩存）
- [ ] 創建 `RefreshBooksUseCase` 類
- [ ] 實現 `call()` 方法（強制刷新）
- [ ] 添加日誌記錄
- [ ] 編寫單元測試（mock repository）
- [ ] 測試緩存策略
- [ ] 測試錯誤處理

**驗收標準**:
- ✅ UseCases 正確實現業務邏輯
- ✅ 緩存策略有效
- ✅ 錯誤處理完善
- ✅ 單元測試覆蓋率 > 80%

**實現提示**:
```dart
class GetBooksUseCase {
  final BookRepository _repository;

  GetBooksUseCase(this._repository);

  Future<List<Book>> call({bool forceRefresh = false}) async {
    debugPrint('📚 [GetBooksUseCase] 獲取書籍列表 (forceRefresh: $forceRefresh)');
    
    try {
      final books = await _repository.getBooks(forceRefresh: forceRefresh);
      debugPrint('✅ [GetBooksUseCase] 成功獲取 ${books.length} 本書籍');
      return books;
    } catch (e) {
      debugPrint('❌ [GetBooksUseCase] 獲取失敗: $e');
      rethrow;
    }
  }
}

class RefreshBooksUseCase {
  final BookRepository _repository;

  RefreshBooksUseCase(this._repository);

  Future<List<Book>> call() async {
    debugPrint('🔄 [RefreshBooksUseCase] 刷新書籍列表');
    return await _repository.getBooks(forceRefresh: true);
  }
}
```

---

## 🎨 Stage 4: Presentation Layer (10 小時)

### Task 2.4.1: 創建 BookListController

**描述**: 實現 GetX Controller，管理書籍列表狀態

**預計時間**: 2 小時

**依賴**: 
- Task 2.3.3 完成

**輸出**:
- `lib/presentation/pages/book_list/controllers/book_list_controller.dart`

**任務清單**:
- [ ] 創建 `BookListController` 類
- [ ] 定義響應式狀態變量（books, loadingState, etc.）
- [ ] 實現 `onInit()` 方法
- [ ] 實現 `loadBooks()` 方法
- [ ] 實現 `refreshBooks()` 方法
- [ ] 實現 `onBookTap()` 方法
- [ ] 實現 `retry()` 方法
- [ ] 添加日誌記錄
- [ ] 編寫單元測試（mock usecases）

**驗收標準**:
- ✅ Controller 狀態管理正確
- ✅ 錯誤處理完善
- ✅ 離線模式支持
- ✅ 單元測試通過

**實現提示**:
```dart
class BookListController extends GetxController {
  final GetBooksUseCase _getBooksUseCase;
  final RefreshBooksUseCase _refreshBooksUseCase;

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
      // 嘗試使用緩存
      try {
        final cachedBooks = await _getBooksUseCase(forceRefresh: false);
        if (cachedBooks.isNotEmpty) {
          books.value = cachedBooks;
          loadingState.value = LoadingState.success;
          isOffline.value = true;
          Get.snackbar('離線模式', '正在使用緩存數據');
        } else {
          throw e;
        }
      } catch (_) {
        loadingState.value = LoadingState.error;
        errorMessage.value = e.message;
      }
    } catch (e) {
      loadingState.value = LoadingState.error;
      errorMessage.value = e.toString();
    }
  }

  Future<void> refreshBooks() async {
    await loadBooks(forceRefresh: true);
  }

  void onBookTap(Book book) {
    Get.toNamed(Routes.BOOK_DETAIL, arguments: book);
  }

  void retry() {
    loadBooks(forceRefresh: true);
  }
}

enum LoadingState { loading, success, error, empty }
```

---

### Task 2.4.2: 創建 BookListPage

**描述**: 實現書籍列表主頁面

**預計時間**: 2 小時

**依賴**: 
- Task 2.4.1 完成

**輸出**:
- `lib/presentation/pages/book_list/book_list_page.dart`

**任務清單**:
- [ ] 創建 `BookListPage` 類（extends GetView）
- [ ] 實現 AppBar（標題、搜索、設置按鈕）
- [ ] 實現 RefreshIndicator
- [ ] 實現狀態監聽（Obx）
- [ ] 實現加載狀態 → Shimmer
- [ ] 實現成功狀態 → GridView
- [ ] 實現錯誤狀態 → ErrorState
- [ ] 實現空狀態 → EmptyState
- [ ] 添加離線 Banner
- [ ] 編寫 Widget 測試

**驗收標準**:
- ✅ UI 正確渲染
- ✅ 下拉刷新工作正常
- ✅ 狀態切換流暢
- ✅ Widget 測試通過

**實現提示**:
```dart
class BookListPage extends GetView<BookListController> {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 書苑閱讀器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed(Routes.SEARCH),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
      body: Column(
        children: [
          // 離線 Banner
          Obx(() => controller.isOffline.value
              ? _buildOfflineBanner()
              : const SizedBox.shrink()),
          
          // 主內容
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshBooks,
              child: Obx(() {
                switch (controller.loadingState.value) {
                  case LoadingState.loading:
                    return const BookListShimmer();
                  case LoadingState.success:
                    return _buildBookGrid();
                  case LoadingState.error:
                    return ErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.retry,
                    );
                  case LoadingState.empty:
                    return EmptyState(
                      onRefresh: controller.refreshBooks,
                    );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.books.length,
      itemBuilder: (context, index) {
        final book = controller.books[index];
        return BookGridItem(
          book: book,
          onTap: () => controller.onBookTap(book),
        );
      },
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.orange.shade100,
      child: const Text(
        'ℹ️ 離線模式 - 正在使用緩存數據',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.orange),
      ),
    );
  }
}
```

---

### Task 2.4.3: 創建 BookGridItem Widget

**描述**: 實現單個書籍卡片組件

**預計時間**: 1.5 小時

**依賴**: 
- Task 2.4.2 完成

**輸出**:
- `lib/presentation/pages/book_list/widgets/book_grid_item.dart`

**任務清單**:
- [ ] 創建 `BookGridItem` 類
- [ ] 實現 Card 佈局
- [ ] 實現 Hero 動畫（封面）
- [ ] 使用 CachedNetworkImage 加載封面
- [ ] 實現書名和作者顯示（文字截斷）
- [ ] 實現點擊效果（InkWell + 水波紋）
- [ ] 添加下載狀態徽章（可選）
- [ ] 編寫 Widget 測試
- [ ] 編寫 Golden 測試

**驗收標準**:
- ✅ 卡片設計美觀
- ✅ Hero 動畫流暢
- ✅ 圖片緩存工作正常
- ✅ Widget 測試通過
- ✅ Golden 測試通過

**實現提示**:
```dart
class BookGridItem extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookGridItem({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面圖片
            Expanded(
              child: Hero(
                tag: 'book-cover-${book.id}',
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 300,
                  memCacheHeight: 450,
                  placeholder: (context, url) => const ShimmerPlaceholder(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.book,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            
            // 書籍信息
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // 下載狀態徽章（可選）
                  if (book.isDownloaded)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            '已下載',
                            style: TextStyle(fontSize: 10, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Task 2.4.4: 創建 Shimmer 加載動畫

**描述**: 實現書籍列表的 Shimmer 加載效果

**預計時間**: 1 小時

**依賴**: 
- Task 2.4.2 完成

**輸出**:
- `lib/presentation/pages/book_list/widgets/book_list_shimmer.dart`
- `lib/presentation/widgets/shimmer_placeholder.dart`

**任務清單**:
- [ ] 創建 `BookListShimmer` 類
- [ ] 使用 `shimmer` 包實現動畫
- [ ] 創建書籍卡片骨架屏
- [ ] 模擬 GridView 佈局
- [ ] 創建可復用的 `ShimmerPlaceholder` 組件
- [ ] 編寫 Widget 測試
- [ ] 編寫 Golden 測試

**驗收標準**:
- ✅ Shimmer 動畫流暢
- ✅ 骨架屏佈局與實際卡片一致
- ✅ Widget 測試通過
- ✅ Golden 測試通過

**實現提示**:
```dart
import 'package:shimmer/shimmer.dart';

class BookListShimmer extends StatelessWidget {
  const BookListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const _ShimmerBookCard(),
    );
  }
}

class _ShimmerBookCard extends StatelessWidget {
  const _ShimmerBookCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面佔位
            Expanded(
              child: Container(
                color: Colors.white,
              ),
            ),
            
            // 文字佔位
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 80,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }
}
```

---

### Task 2.4.5: 創建 EmptyState Widget

**描述**: 實現空狀態頁面

**預計時間**: 0.5 小時

**依賴**: 
- 無

**輸出**:
- `lib/presentation/pages/book_list/widgets/empty_state.dart`

**任務清單**:
- [ ] 創建 `EmptyState` 類
- [ ] 設計友好的空狀態 UI
- [ ] 添加圖標/插圖
- [ ] 添加提示文字
- [ ] 添加"刷新"按鈕
- [ ] 編寫 Widget 測試
- [ ] 編寫 Golden 測試

**驗收標準**:
- ✅ UI 友好美觀
- ✅ 刷新按鈕工作正常
- ✅ Widget 測試通過
- ✅ Golden 測試通過

**實現提示**:
```dart
class EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暫無書籍',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '請下拉刷新獲取書籍列表',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      ),
    );
  }
}
```

---

### Task 2.4.6: 創建 ErrorState Widget

**描述**: 實現錯誤狀態頁面

**預計時間**: 1 小時

**依賴**: 
- 無

**輸出**:
- `lib/presentation/pages/book_list/widgets/error_state.dart`

**任務清單**:
- [ ] 創建 `ErrorState` 類
- [ ] 設計友好的錯誤 UI
- [ ] 顯示錯誤圖標
- [ ] 顯示錯誤信息
- [ ] 添加"重試"按鈕
- [ ] 根據錯誤類型顯示不同圖標/文字
- [ ] 編寫 Widget 測試
- [ ] 編寫 Golden 測試

**驗收標準**:
- ✅ UI 友好美觀
- ✅ 錯誤信息清晰
- ✅ 重試按鈕工作正常
- ✅ Widget 測試通過
- ✅ Golden 測試通過

**實現提示**:
```dart
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '加載失敗',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Task 2.4.7: 配置路由和依賴注入

**描述**: 配置 GetX 路由和依賴注入

**預計時間**: 2 小時

**依賴**: 
- 所有 Presentation Layer 任務完成

**輸出**:
- `lib/routes/app_pages.dart` (更新)
- `lib/routes/app_routes.dart` (更新)
- `lib/presentation/pages/book_list/bindings/book_list_binding.dart`

**任務清單**:
- [ ] 創建 `BookListBinding` 類
- [ ] 註冊所有依賴（DataSources, Repository, UseCases, Controller）
- [ ] 在 `app_routes.dart` 中添加 `BOOK_LIST` 路由
- [ ] 在 `app_pages.dart` 中添加路由配置
- [ ] 更新 `SplashController` 跳轉邏輯
- [ ] 測試路由跳轉
- [ ] 測試依賴注入

**驗收標準**:
- ✅ 所有依賴正確注入
- ✅ 路由跳轉正常
- ✅ 無循環依賴
- ✅ 集成測試通過

**實現提示**:
```dart
// book_list_binding.dart
class BookListBinding extends Bindings {
  @override
  void dependencies() {
    // Dio
    Get.lazyPut(() => Dio());

    // DataSources
    Get.lazyPut<BookRemoteDataSource>(
      () => BookRemoteDataSource(Get.find<Dio>()),
    );
    Get.lazyPut<BookLocalDataSource>(
      () => BookLocalDataSource(
        Hive.box<BookModel>('books'),
        Hive.box('metadata'),
      ),
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

// app_routes.dart
class Routes {
  static const SPLASH = '/splash';
  static const BOOK_LIST = '/book-list';  // ← 新增
  static const BOOK_DETAIL = '/book-detail';
}

// app_pages.dart
class AppPages {
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.BOOK_LIST,  // ← 新增
      page: () => const BookListPage(),
      binding: BookListBinding(),
    ),
  ];
}

// splash_controller.dart 更新
Future<void> _navigateToHome() async {
  Get.offNamed(Routes.BOOK_LIST);  // ← 更新
}
```

---

## 🧪 Stage 5: 測試 (6 小時)

### Task 2.5.1: 單元測試

**描述**: 編寫並執行單元測試

**預計時間**: 2 小時

**依賴**: 
- 所有實現任務完成

**輸出**:
- `test/data/models/book_model_test.dart`
- `test/data/datasources/book_remote_datasource_test.dart`
- `test/data/datasources/book_local_datasource_test.dart`
- `test/data/repositories/book_repository_impl_test.dart`
- `test/domain/usecases/get_books_usecase_test.dart`
- `test/domain/usecases/refresh_books_usecase_test.dart`
- `test/presentation/controllers/book_list_controller_test.dart`

**任務清單**:
- [ ] 測試 `BookModel` JSON 序列化/反序列化
- [ ] 測試 `BookRemoteDataSource` 網絡請求
- [ ] 測試 `BookLocalDataSource` Hive 操作
- [ ] 測試 `BookRepositoryImpl` 緩存策略
- [ ] 測試 `GetBooksUseCase` 業務邏輯
- [ ] 測試 `RefreshBooksUseCase` 業務邏輯
- [ ] 測試 `BookListController` 狀態管理
- [ ] 運行 `flutter test`
- [ ] 生成覆蓋率報告

**驗收標準**:
- ✅ 所有單元測試通過
- ✅ 測試覆蓋率 > 80%
- ✅ 無測試警告

**實現提示**:
```dart
// book_model_test.dart
void main() {
  group('BookModel', () {
    test('fromJson 應該正確解析 JSON', () {
      final json = {
        'id': 'test-id',
        'title': '測試書籍',
        'author': '測試作者',
        // ...
      };

      final book = BookModel.fromJson(json);

      expect(book.id, 'test-id');
      expect(book.title, '測試書籍');
      expect(book.author, '測試作者');
    });

    test('toJson 應該正確序列化為 JSON', () {
      final book = BookModel(
        id: 'test-id',
        title: '測試書籍',
        // ...
      );

      final json = book.toJson();

      expect(json['id'], 'test-id');
      expect(json['title'], '測試書籍');
    });

    test('isDownloaded 應該返回正確狀態', () {
      final book1 = BookModel(localPath: '/path/to/book.epub');
      expect(book1.isDownloaded, true);

      final book2 = BookModel(localPath: null);
      expect(book2.isDownloaded, false);
    });
  });
}
```

---

### Task 2.5.2: Widget 測試

**描述**: 編寫並執行 Widget 測試

**預計時間**: 2 小時

**依賴**: 
- Task 2.5.1 完成

**輸出**:
- `test/presentation/pages/book_list/book_list_page_test.dart`
- `test/presentation/pages/book_list/widgets/book_grid_item_test.dart`
- `test/presentation/pages/book_list/widgets/empty_state_test.dart`
- `test/presentation/pages/book_list/widgets/error_state_test.dart`

**任務清單**:
- [ ] 測試 `BookListPage` 各種狀態顯示
- [ ] 測試 `BookGridItem` 點擊事件
- [ ] 測試 `EmptyState` 刷新按鈕
- [ ] 測試 `ErrorState` 重試按鈕
- [ ] 測試下拉刷新功能
- [ ] 測試離線 Banner 顯示
- [ ] 運行 `flutter test`

**驗收標準**:
- ✅ 所有 Widget 測試通過
- ✅ UI 交互正常
- ✅ 無測試警告

**實現提示**:
```dart
// book_list_page_test.dart
void main() {
  testWidgets('BookListPage 加載狀態應該顯示 Shimmer', (tester) async {
    final controller = MockBookListController();
    when(() => controller.loadingState).thenReturn(LoadingState.loading.obs);
    when(() => controller.isOffline).thenReturn(false.obs);

    await tester.pumpWidget(TestApp(child: BookListPage()));

    expect(find.byType(BookListShimmer), findsOneWidget);
  });

  testWidgets('BookListPage 成功狀態應該顯示 GridView', (tester) async {
    final controller = MockBookListController();
    when(() => controller.loadingState).thenReturn(LoadingState.success.obs);
    when(() => controller.books).thenReturn([mockBook].obs);
    when(() => controller.isOffline).thenReturn(false.obs);

    await tester.pumpWidget(TestApp(child: BookListPage()));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(BookGridItem), findsOneWidget);
  });

  testWidgets('點擊書籍應該調用 onBookTap', (tester) async {
    final controller = MockBookListController();
    when(() => controller.onBookTap(any())).thenReturn(null);

    await tester.pumpWidget(TestApp(child: BookListPage()));
    await tester.tap(find.byType(BookGridItem).first);

    verify(() => controller.onBookTap(mockBook)).called(1);
  });
}
```

---

### Task 2.5.3: Golden 測試

**描述**: 編寫並執行 Golden 測試

**預計時間**: 1 小時

**依賴**: 
- Task 2.5.2 完成

**輸出**:
- `test/presentation/pages/book_list/widgets/book_grid_item_golden_test.dart`
- `test/presentation/pages/book_list/widgets/empty_state_golden_test.dart`
- `test/presentation/pages/book_list/widgets/error_state_golden_test.dart`
- `test/goldens/book_grid_item.png`
- `test/goldens/empty_state.png`
- `test/goldens/error_state.png`

**任務清單**:
- [ ] 測試 `BookGridItem` 外觀
- [ ] 測試 `EmptyState` 外觀
- [ ] 測試 `ErrorState` 外觀
- [ ] 測試不同狀態下的 UI
- [ ] 運行 `flutter test --update-goldens`
- [ ] 運行 `flutter test`

**驗收標準**:
- ✅ 所有 Golden 測試通過
- ✅ UI 與設計稿一致
- ✅ 無測試警告

**實現提示**:
```dart
// book_grid_item_golden_test.dart
void main() {
  testWidgets('BookGridItem 應該匹配設計稿', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: SizedBox(
          width: 200,
          height: 300,
          child: BookGridItem(
            book: mockBook,
            onTap: () {},
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(BookGridItem),
      matchesGoldenFile('goldens/book_grid_item.png'),
    );
  });

  testWidgets('BookGridItem 已下載狀態應該匹配設計稿', (tester) async {
    final downloadedBook = mockBook.copyWith(
      localPath: '/path/to/book.epub',
    );

    await tester.pumpWidget(
      TestApp(
        child: BookGridItem(book: downloadedBook, onTap: () {}),
      ),
    );

    await expectLater(
      find.byType(BookGridItem),
      matchesGoldenFile('goldens/book_grid_item_downloaded.png'),
    );
  });
}
```

---

### Task 2.5.4: 集成測試

**描述**: 編寫並執行集成測試

**預計時間**: 1 小時

**依賴**: 
- Task 2.5.3 完成

**輸出**:
- `integration_test/book_list_flow_test.dart`

**任務清單**:
- [ ] 測試完整流程：啟動 → 加載 → 顯示列表
- [ ] 測試下拉刷新流程
- [ ] 測試點擊書籍跳轉
- [ ] 測試錯誤處理流程
- [ ] 測試離線模式
- [ ] 運行集成測試

**驗收標準**:
- ✅ 集成測試通過
- ✅ 完整流程正常
- ✅ 無崩潰或異常

**實現提示**:
```dart
// book_list_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BookList 完整流程測試', () {
    testWidgets('應該成功加載並顯示書籍列表', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 等待 Splash 跳轉
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 驗證書籍列表顯示
      expect(find.byType(BookListPage), findsOneWidget);
      expect(find.byType(BookGridItem), findsWidgets);
    });

    testWidgets('下拉刷新應該重新加載數據', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 下拉刷新
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // 驗證刷新成功
      expect(find.byType(BookGridItem), findsWidgets);
    });

    testWidgets('點擊書籍應該跳轉到詳情頁', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 點擊第一本書
      await tester.tap(find.byType(BookGridItem).first);
      await tester.pumpAndSettle();

      // 驗證跳轉成功
      expect(find.byType(BookDetailPage), findsOneWidget);
    });
  });
}
```

---

## 📝 最終檢查清單

### 代碼質量

- [ ] 所有代碼通過 `flutter analyze`
- [ ] 所有代碼遵循 Clean Architecture
- [ ] 所有公開 API 有文檔註釋
- [ ] 無 TODO 或 FIXME 註釋
- [ ] 無硬編碼字符串（使用 i18n）
- [ ] 無魔法數字（使用常量）

### 測試覆蓋率

- [ ] 單元測試覆蓋率 > 80%
- [ ] Widget 測試通過
- [ ] Golden 測試通過
- [ ] 集成測試通過

### 性能

- [ ] 首屏加載時間 < 2 秒
- [ ] 滾動幀率 > 50 FPS
- [ ] 內存占用 < 150 MB
- [ ] 無內存洩漏

### 功能

- [ ] 所有用戶故事完成
- [ ] 所有驗收標準通過
- [ ] 離線模式正常工作
- [ ] 錯誤處理完善

### 文檔

- [ ] README 更新
- [ ] API 文檔完整
- [ ] 截圖已添加
- [ ] CHANGELOG 更新

---

## 🎉 完成標準

當以下所有條件滿足時，Spec 02 視為完成：

1. ✅ 所有 19 個任務完成
2. ✅ 所有測試通過（單元、Widget、Golden、集成）
3. ✅ 測試覆蓋率 > 80%
4. ✅ 代碼通過 Linter
5. ✅ 性能達標
6. ✅ 在真機測試通過
7. ✅ Code Review 通過
8. ✅ 文檔完整

---

## 📊 時間追蹤

| 日期 | 階段 | 任務 | 預計 | 實際 | 差異 | 備註 |
|------|------|------|------|------|------|------|
| - | - | - | - | - | - | - |

**總計**:
- 預計時間: 28 小時
- 實際時間: - 小時
- 差異: - 小時

---

## 🔗 相關資源

- [Spec 02 規格文檔](./02-book-list.md)
- [Spec 00 憲章](./00-constitution.md)
- [開發計劃](./development-plan.md)
- [Spec 01 任務清單](./01-splash-screen-tasks.md)

---

**任務清單版本**: 1.0  
**創建日期**: 2025-11-07  
**最後更新**: 2025-11-07  
**下一步**: 開始執行 Task 2.1.1

