# 書苑閱讀器 App 技術設計文檔

## 目錄
1. [系統架構概覽](#1-系統架構概覽)
2. [功能擴展與用戶體驗](#2-功能擴展與用戶體驗)
3. [技術實現與性能](#3-技術實現與性能)
4. [安全性與合規](#4-安全性與合規)
5. [測試與部署](#5-測試與部署)
6. [技術架構](#6-技術架構)
7. [開發路線圖](#7-開發路線圖)

---

## 1. 系統架構概覽

### 1.1 核心設計理念

**書苑閱讀器採用「雲端內容源 + 本地緩存」的架構**：

```
┌─────────────────────────────────────────────┐
│         GitHub Repository (內容源)           │
│  https://github.com/kkwenFreemind/         │
│  ShuyuanReader                              │
│                                             │
│  📁 catalog/books.json    ← 書籍元數據       │
│  📁 covers/*.png          ← 100+ 封面圖片    │
│  📁 epub3/*.epub          ← 100+ 電子書      │
└─────────────────────────────────────────────┘
              ↓ HTTPS 下載
              ↓ 按需獲取
┌─────────────────────────────────────────────┐
│         Android APP (智能緩存層)             │
│                                             │
│  🗄️  Hive 數據庫     ← 書籍元數據 + 狀態     │
│  📦  files/books/   ← 用戶下載的 EPUB       │
│  🖼️  cache/covers/  ← 自動緩存的封面         │
└─────────────────────────────────────────────┘
```

### 1.2 資源存放說明

| 資源類型 | 存放位置 | 大小 | 下載時機 | 保存期限 |
|---------|---------|------|---------|---------|
| **books.json** | GitHub + APP 緩存 | 50 KB | 啟動時 | 24 小時 |
| **封面圖片** | GitHub + APP 緩存 | 50-200 KB/張 | 瀏覽時 | 7 天 |
| **EPUB 文件** | GitHub + 用戶下載 | 1-5 MB/本 | 用戶主動下載 | 永久（直到刪除）|

### 1.3 用戶使用流程

```
首次啟動
  ↓
下載 books.json (50KB)
  ↓
顯示書籍列表（100+本書）
  ↓
用戶瀏覽列表
  ↓
自動下載並緩存封面圖片
  ↓
用戶點擊「下載」按鈕
  ↓
從 GitHub 下載完整 EPUB (1-5MB)
  ↓
保存到本地永久存儲
  ↓
用戶可離線閱讀
```

### 1.4 為什麼選擇這種架構？

✅ **對開發者的優勢**：
- 無需維護服務器（零成本）
- 使用 Git 管理內容（版本控制）
- GitHub 提供全球 CDN（高可用性）

✅ **對用戶的優勢**：
- APP 體積小（不內嵌任何書籍）
- 按需下載（節省流量和空間）
- 離線可用（已下載內容）

✅ **技術優勢**：
- 內容和代碼分離
- 易於擴展（添加新書只需 git push）
- 支持增量更新

> 📚 **詳細的存儲架構設計請參閱**：[storage_architecture.md](./storage_architecture.md)

---

## 2. 功能擴展與用戶體驗

### 2.1 書籍管理功能

#### 設計方案：本地書籍數據庫

> 📌 **核心概念**：APP 從 GitHub 獲取書籍列表（books.json），並將元數據存儲在本地 Hive 數據庫中。用戶可以瀏覽所有書籍，但只有下載後才能閱讀。

```yaml
技術選型: 
  - Hive (輕量級 NoSQL 數據庫)
  - 優點: 純 Dart、快速、離線支持

數據模型:
  LocalBook:
    - id: String                  # 唯一標識
    - title: String               # 書名
    - author: String              # 作者
    
    # ⭐ 遠程資源 URL (來自 GitHub)
    - remoteEpubUrl: String       # GitHub 上的 EPUB URL
    - remoteCoverUrl: String      # GitHub 上的封面 URL
    
    # ⭐ 本地資源路徑 (下載後才有)
    - localEpubPath: String?      # 本地 EPUB 絕對路徑
    - localCoverPath: String?     # 本地封面絕對路徑
    
    # 下載狀態
    - downloadStatus: enum        # notDownloaded, downloading, completed, error
    - downloadProgress: double    # 0.0 ~ 1.0
    
    # 閱讀狀態
    - readStatus: enum            # unread, reading, finished
    - lastReadPosition: String?   # 閱讀進度 (CFI)
    - lastReadTime: DateTime?
    - addedTime: DateTime
    
    # 文件信息
    - fileSizeBytes: int?
    - md5Hash: String?            # 文件完整性校驗
```

#### 功能實現
```dart
// 書籍管理服務
class BookManager {
  // 1. 獲取所有本地書籍
  Future<List<LocalBook>> getLocalBooks({
    BookFilter? filter,
    BookSort? sort,
  });
  
  // 2. 下載管理
  Future<void> downloadBook(LocalBook book);
  Future<void> deleteBook(String bookId);
  Future<void> pauseDownload(String bookId);
  Future<void> resumeDownload(String bookId);
  
  // 3. 狀態管理
  Future<void> markAsRead(String bookId);
  Future<void> markAsUnread(String bookId);
  Future<void> updateReadingProgress(String bookId, String position);
  
  // 4. 同步檢查
  Future<SyncResult> checkForUpdates();
  Future<void> syncWithRemote();
}

enum BookFilter {
  all,
  downloaded,
  notDownloaded,
  reading,
  finished,
}

enum BookSort {
  titleAsc,
  titleDesc,
  authorAsc,
  authorDesc,
  addedTimeDesc,
  lastReadTimeDesc,
}
```

#### UI 設計
```
主頁面 (HomePage)
├── AppBar
│   ├── 標題: "書苑閱讀器"
│   ├── 搜索按鈕
│   └── 過濾/排序按鈕
├── TabBar
│   ├── 全部書籍 (遠程 + 本地)
│   ├── 本地書庫 (已下載)
│   └── 正在閱讀
└── Body
    ├── RefreshIndicator (下拉刷新)
    └── GridView/ListView
        └── BookCard
            ├── 封面圖片
            ├── 下載進度指示器
            ├── 書名
            ├── 作者
            └── 狀態標記 (新書/已讀/閱讀中)

書籍詳情頁 (BookDetailPage)
├── 封面大圖
├── 書籍信息 (標題、作者、語言、描述)
├── 操作按鈕
│   ├── 下載/打開閱讀
│   ├── 分享
│   └── 刪除
└── 相關推薦
```

### 1.2 搜索與過濾功能

#### 實現方案
```dart
class SearchService {
  // 1. 全文搜索
  List<LocalBook> searchBooks({
    required String query,
    SearchField field = SearchField.all,
  }) {
    // 使用 Hive query + Dart String matching
    // 支持中文分詞（可選：使用 jieba 分詞庫）
  }
  
  // 2. 高級過濾
  List<LocalBook> filterBooks({
    String? language,
    String? author,
    DateRange? dateRange,
    BookFilter? status,
  });
}

enum SearchField {
  all,
  title,
  author,
  description,
}
```

#### UI 組件
```dart
// 搜索頁面
class SearchPage extends StatefulWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchBar(
          hintText: '搜索書名、作者...',
          onChanged: (query) => _performSearch(query),
        ),
      ),
      body: Column(
        children: [
          // 快速過濾按鈕
          FilterChips(
            filters: ['全部', '已下載', '未讀', '正在讀'],
          ),
          // 搜索結果
          Expanded(
            child: SearchResultList(),
          ),
        ],
      ),
    );
  }
}

// 過濾和排序對話框
class FilterSortDialog extends StatelessWidget {
  // 語言選擇
  // 作者篩選
  // 排序方式
  // 下載狀態
}
```

### 1.3 閱讀器增強功能

#### 核心閱讀功能
```dart
class ReaderFeatures {
  // 1. 書籤管理
  List<Bookmark> bookmarks;
  Future<void> addBookmark(Bookmark bookmark);
  Future<void> deleteBookmark(String id);
  
  // 2. 筆記和高亮
  List<Highlight> highlights;
  Future<void> addHighlight(Highlight highlight);
  Future<void> addNote(String highlightId, String note);
  
  // 3. 閱讀設置
  ReaderSettings settings;
  // - 字體大小: 12-32px
  // - 字體類型: 系統/楷體/宋體
  // - 行距: 1.0-2.0
  // - 頁邊距: 小/中/大
  // - 主題: 日間/夜間/護眼/羊皮紙
  // - 翻頁方式: 滑動/點擊/仿真
  
  // 4. 進度追蹤
  ReadingProgress progress;
  // - 當前位置 (CFI)
  // - 已讀百分比
  // - 預計剩餘時間
}

// 數據模型
class Bookmark {
  String id;
  String bookId;
  String cfi;          // EPUB CFI (Canonical Fragment Identifier)
  String chapterTitle;
  String previewText;
  DateTime createdAt;
}

class Highlight {
  String id;
  String bookId;
  String cfi;
  String text;
  String color;        // yellow, green, blue, pink
  String? note;
  DateTime createdAt;
}

class ReaderSettings {
  double fontSize;
  String fontFamily;
  double lineHeight;
  int pageMargin;
  ThemeMode themeMode;
  PageTurnAnimation animation;
}
```

#### 閱讀器 UI 結構
```
ReaderPage
├── AppBar (自動隱藏)
│   ├── 返回按鈕
│   ├── 章節標題
│   └── 更多選項 (目錄/書籤/設置)
├── Body
│   ├── GestureDetector (點擊顯示/隱藏菜單)
│   └── EPUBView (核心閱讀視圖)
│       ├── PageView/SingleChildScrollView
│       └── SelectableText (支持選中和高亮)
├── BottomBar (自動隱藏)
│   ├── 進度條 Slider
│   ├── 上一章/下一章
│   └── 閱讀進度百分比
└── 浮動菜單
    ├── 目錄 Drawer
    ├── 書籤列表
    ├── 筆記列表
    └── 設置面板
        ├── 字體調整
        ├── 主題切換
        └── 翻頁設置
```

### 1.4 多語言/國際化支持

#### 實現方案
```yaml
技術選型: flutter_localizations + intl

支持語言:
  - zh_TW: 繁體中文 (預設)
  - zh_CN: 簡體中文
  - en_US: 英文

文件結構:
  lib/l10n/
    ├── app_zh_TW.arb
    ├── app_zh_CN.arb
    └── app_en.arb
```

```dart
// 使用示例
MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('zh', 'TW'),
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ],
);

// 在代碼中使用
Text(AppLocalizations.of(context)!.bookLibrary);
```

---

## 3. 技術實現與性能

### 3.1 下載與存儲優化

> 📌 **核心流程**：從 GitHub Raw Content URL 下載資源 → 保存到 APP 本地存儲 → 更新 Hive 數據庫狀態

#### GitHub 資源 URL 配置

```dart
class GitHubConfig {
  // GitHub Repository 配置
  static const String owner = 'kkwenFreemind';
  static const String repo = 'ShuyuanReader';
  static const String branch = 'main';
  
  // Raw Content 基礎 URL
  static const String baseUrl = 
    'https://raw.githubusercontent.com/$owner/$repo/$branch';
  
  // 資源路徑
  static const String catalogPath = 'catalog/books.json';
  static const String coversPath = 'covers';
  static const String epubsPath = 'epub3';
  
  // 完整 URL
  static String get catalogUrl => '$baseUrl/$catalogPath';
  
  static String getCoverUrl(String bookId) {
    return '$baseUrl/$coversPath/$bookId.png';
  }
  
  static String getEpubUrl(String filename) {
    return '$baseUrl/$epubsPath/$filename';
  }
}

// 使用示例
final booksJsonUrl = GitHubConfig.catalogUrl;
// https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/catalog/books.json

final coverUrl = GitHubConfig.getCoverUrl('一夢漫言');
// https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/covers/一夢漫言.png

final epubUrl = GitHubConfig.getEpubUrl('一夢漫言.epub');
// https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/epub3/一夢漫言.epub
```

#### 下載管理器設計

```dart
class DownloadManager {
  final Dio dio;
  final StoragePathManager pathManager;
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, DownloadTask> _tasks = {};
  
  // 1. 下載 EPUB（從 GitHub）
  Future<void> downloadEPUB({
    required String bookId,
    required String remoteUrl,  // GitHub URL
    ProgressCallback? onProgress,
  }) async {
    // 獲取本地保存路徑
    final savePath = pathManager.getEpubPath(bookId);
    
    // 檢查是否已下載
    if (await pathManager.epubExists(bookId)) {
      print('EPUB 已存在: $savePath');
      return;
    }
    final cancelToken = CancelToken();
    _cancelTokens[bookId] = cancelToken;
    
    try {
      await dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final progress = received / total;
          onProgress?.call(progress);
          _updateDownloadProgress(bookId, progress);
        },
        options: Options(
          receiveTimeout: Duration(minutes: 10),
          headers: {
            'Accept-Encoding': 'gzip',
          },
        ),
      );
      
      // 下載完成後驗證
      await _verifyDownload(savePath, bookId);
      
    } on DioException catch (e) {
      _handleDownloadError(bookId, e);
    }
  }
  
  // 2. 文件校驗
  Future<bool> _verifyDownload(String path, String bookId) async {
    final file = File(path);
    if (!await file.exists()) return false;
    
    // MD5 校驗 (可選：從服務器獲取預期 MD5)
    final bytes = await file.readAsBytes();
    final hash = md5.convert(bytes).toString();
    
    // 保存 hash 到數據庫
    await _saveFileHash(bookId, hash);
    
    return true;
  }
  
  // 3. 暫停/恢復/取消
  void pauseDownload(String bookId) {
    _cancelTokens[bookId]?.cancel('Paused by user');
  }
  
  Future<void> resumeDownload(String bookId) async {
    // 實現斷點續傳
    final task = _tasks[bookId];
    if (task != null) {
      await downloadEPUB(
        url: task.url,
        savePath: task.savePath,
        bookId: bookId,
        onProgress: task.onProgress,
      );
    }
  }
  
  // 4. 後台下載 (Android)
  Future<void> downloadInBackground(List<String> bookIds) async {
    // 使用 flutter_downloader
    // 或者 WorkManager (Android) + BackgroundFetch (iOS)
  }
}

// 下載任務模型
class DownloadTask {
  String bookId;
  String url;
  String savePath;
  DownloadStatus status;
  double progress;
  int? totalBytes;
  int? downloadedBytes;
  DateTime? startTime;
  DateTime? endTime;
  String? errorMessage;
  ProgressCallback? onProgress;
}

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}
```

#### 存儲策略
```dart
class StorageManager {
  // 1. 路徑管理
  Future<Directory> getAppDocDir() async {
    return await getApplicationDocumentsDirectory();
  }
  
  String getEPUBPath(String bookId) {
    return '${appDocDir.path}/books/$bookId.epub';
  }
  
  String getCoverPath(String bookId) {
    return '${appDocDir.path}/covers/$bookId.png';
  }
  
  // 2. 空間管理
  Future<StorageInfo> getStorageInfo() async {
    final appDir = await getAppDocDir();
    int totalSize = 0;
    int bookCount = 0;
    
    // 計算所有 EPUB 文件大小
    final booksDir = Directory('${appDir.path}/books');
    if (await booksDir.exists()) {
      await for (var file in booksDir.list()) {
        if (file is File) {
          totalSize += await file.length();
          bookCount++;
        }
      }
    }
    
    return StorageInfo(
      totalSize: totalSize,
      bookCount: bookCount,
      availableSpace: await _getAvailableSpace(),
    );
  }
  
  // 3. 清理功能
  Future<void> clearCache() async {
    // 清除臨時文件和封面緩存
  }
  
  Future<void> deleteBook(String bookId) async {
    final epubFile = File(getEPUBPath(bookId));
    final coverFile = File(getCoverPath(bookId));
    
    if (await epubFile.exists()) await epubFile.delete();
    if (await coverFile.exists()) await coverFile.delete();
  }
}

class StorageInfo {
  int totalSize;          // bytes
  int bookCount;
  int availableSpace;     // bytes
  
  String get formattedSize => _formatBytes(totalSize);
  bool get isSpaceLow => availableSpace < 100 * 1024 * 1024; // < 100MB
}
```

### 2.2 緩存與離線模式

#### 緩存策略
```dart
class CacheManager {
  // 1. books.json 緩存
  Future<void> cacheBooksJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('books_json', json);
    await prefs.setString('books_json_timestamp', 
      DateTime.now().toIso8601String());
  }
  
  Future<String?> getCachedBooksJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('books_json');
  }
  
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString('books_json_timestamp');
    if (timestampStr == null) return false;
    
    final timestamp = DateTime.parse(timestampStr);
    return DateTime.now().difference(timestamp) < maxAge;
  }
  
  // 2. 封面圖片緩存
  Future<void> cacheImage(String url, String bookId) async {
    final cacheDir = await getTemporaryDirectory();
    final path = '${cacheDir.path}/covers/$bookId.png';
    
    await dio.download(url, path);
  }
  
  Future<File?> getCachedImage(String bookId) async {
    final cacheDir = await getTemporaryDirectory();
    final file = File('${cacheDir.path}/covers/$bookId.png');
    
    return await file.exists() ? file : null;
  }
}

// 離線模式處理
class OfflineManager {
  Future<void> checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    _isOnline = connectivity != ConnectivityResult.none;
  }
  
  Future<CatalogData> loadCatalog() async {
    if (_isOnline) {
      try {
        // 嘗試從網絡加載
        final json = await _fetchRemoteCatalog();
        await _cacheManager.cacheBooksJson(json);
        return _parseCatalog(json);
      } catch (e) {
        // 網絡失敗，回退到緩存
        return await _loadCachedCatalog();
      }
    } else {
      // 離線模式，直接使用緩存
      return await _loadCachedCatalog();
    }
  }
  
  Future<CatalogData> _loadCachedCatalog() async {
    final cached = await _cacheManager.getCachedBooksJson();
    if (cached != null) {
      return _parseCatalog(cached);
    }
    throw Exception('無緩存數據，請連接網絡後重試');
  }
}
```

#### 更新檢測機制
```dart
class UpdateChecker {
  // 1. 使用 ETag 檢測更新
  Future<bool> hasUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedETag = prefs.getString('books_json_etag');
    
    final response = await dio.head(
      'https://github.com/kkwenFreemind/ShuyuanReader/blob/main/catalog/books.json',
    );
    
    final currentETag = response.headers['etag']?.first;
    
    return currentETag != null && currentETag != savedETag;
  }
  
  // 2. 使用 Last-Modified 檢測
  Future<bool> hasUpdatesLastModified() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getString('books_json_last_modified');
    
    final response = await dio.head(catalogUrl);
    final lastModified = response.headers['last-modified']?.first;
    
    return lastModified != null && lastModified != savedTime;
  }
  
  // 3. 比較版本號（如果 books.json 包含版本字段）
  Future<bool> hasUpdatesVersion() async {
    final cached = await _cacheManager.getCachedBooksJson();
    if (cached == null) return true;
    
    final cachedData = jsonDecode(cached);
    final cachedVersion = cachedData['metadata']['version'];
    
    final remote = await _fetchRemoteCatalog();
    final remoteData = jsonDecode(remote);
    final remoteVersion = remoteData['metadata']['version'];
    
    return remoteVersion != cachedVersion;
  }
  
  // 4. 自動更新通知
  Future<void> checkAndNotify() async {
    if (await hasUpdates()) {
      // 顯示 SnackBar 或對話框
      _showUpdateDialog();
    }
  }
}
```

### 2.3 性能與內存管理

#### 懶加載和分頁
```dart
class BookListController extends GetxController {
  final int pageSize = 20;
  int currentPage = 0;
  List<LocalBook> books = [];
  bool isLoading = false;
  bool hasMore = true;
  
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;
    
    isLoading = true;
    
    try {
      final newBooks = await _bookManager.getBooks(
        offset: currentPage * pageSize,
        limit: pageSize,
      );
      
      if (newBooks.length < pageSize) {
        hasMore = false;
      }
      
      books.addAll(newBooks);
      currentPage++;
      
    } finally {
      isLoading = false;
      update();
    }
  }
}

// GridView 實現
class BookGridView extends StatelessWidget {
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
      ),
      itemCount: controller.books.length + (controller.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.books.length) {
          // 加載更多指示器
          controller.loadMore();
          return LoadingIndicator();
        }
        
        return BookCard(book: controller.books[index]);
      },
    );
  }
}
```

#### 圖片優化
```dart
class ImageCacheManager {
  // 使用 cached_network_image
  Widget buildCoverImage(String url, String bookId) {
    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: bookId,
      placeholder: (context, url) => ShimmerPlaceholder(),
      errorWidget: (context, url, error) => DefaultCoverImage(),
      memCacheWidth: 300,  // 限制內存中的圖片寬度
      memCacheHeight: 400,
      maxWidthDiskCache: 600,
      maxHeightDiskCache: 800,
      fadeInDuration: Duration(milliseconds: 300),
    );
  }
  
  // 預加載封面（在後台）
  Future<void> preloadCovers(List<String> urls) async {
    for (var url in urls) {
      await precacheImage(
        CachedNetworkImageProvider(url),
        context,
      );
    }
  }
}
```

#### EPUB 解析優化
```dart
class EPUBParser {
  // 1. 流式解析，避免一次性加載整個文件
  Stream<Chapter> parseChapters(String epubPath) async* {
    final archive = ZipDecoder().decodeBuffer(
      await File(epubPath).readAsBytes(),
    );
    
    // 逐章解析並 yield
    for (var chapter in _extractChapters(archive)) {
      yield chapter;
    }
  }
  
  // 2. 按需加載章節內容
  Future<String> loadChapterContent(String epubPath, String chapterHref) async {
    // 只解析需要的章節
    final archive = ZipDecoder().decodeBuffer(
      await File(epubPath).readAsBytes(),
    );
    
    final file = archive.findFile(chapterHref);
    if (file == null) throw Exception('Chapter not found');
    
    return utf8.decode(file.content);
  }
  
  // 3. 緩存解析結果
  final Map<String, EPUBMetadata> _metadataCache = {};
  
  Future<EPUBMetadata> getMetadata(String epubPath) async {
    if (_metadataCache.containsKey(epubPath)) {
      return _metadataCache[epubPath]!;
    }
    
    final metadata = await _parseMetadata(epubPath);
    _metadataCache[epubPath] = metadata;
    
    return metadata;
  }
}
```

---

## 3. 安全性與合規

### 3.1 數據安全

#### HTTPS 和校驗
```dart
class SecureDownloader {
  // 1. 強制 HTTPS
  late Dio dio;
  
  SecureDownloader() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://github.com',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 30),
    ));
    
    // 添加證書固定 (Certificate Pinning)
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          // 驗證證書
          return _verifyCertificate(cert, host);
        };
        return client;
      },
    );
  }
  
  // 2. 文件完整性驗證
  Future<bool> verifyFileIntegrity(
    String filePath,
    String expectedHash,
  ) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final actualHash = sha256.convert(bytes).toString();
    
    return actualHash == expectedHash;
  }
  
  // 3. 數字簽名驗證 (可選)
  Future<bool> verifySignature(
    String filePath,
    String signature,
    String publicKey,
  ) async {
    // 使用 pointycastle 進行 RSA 驗證
    // 實現略
  }
}
```

#### 本地數據加密
```dart
class SecureStorage {
  // 使用 flutter_secure_storage 存儲敏感數據
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // 存儲用戶設置
  Future<void> saveUserPreference(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  // EPUB 文件加密 (可選)
  Future<void> encryptEPUB(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    
    // 使用 AES 加密
    final encrypted = _encrypt(bytes);
    await file.writeAsBytes(encrypted);
  }
}
```

### 3.2 隱私保護

#### 隱私政策實現
```dart
class PrivacyManager {
  // 1. 首次啟動顯示隱私政策
  Future<bool> hasAcceptedPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('privacy_accepted') ?? false;
  }
  
  Future<void> acceptPrivacyPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_accepted', true);
    await prefs.setString('privacy_accepted_date', 
      DateTime.now().toIso8601String());
  }
  
  // 2. 數據收集聲明
  Map<String, bool> getDataCollectionSettings() {
    return {
      'usage_analytics': false,     // 使用情況分析
      'crash_reports': true,         // 崩潰報告
      'performance_monitoring': false, // 性能監控
    };
  }
  
  // 3. 數據刪除請求
  Future<void> deleteAllUserData() async {
    // 刪除所有本地數據
    await _deleteLocalBooks();
    await _deleteUserPreferences();
    await _deleteCache();
  }
}
```

#### Android 權限管理
```dart
class PermissionManager {
  // 1. 存儲權限 (Android 10+)
  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }
    
    final status = await Permission.storage.request();
    
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    
    return status.isGranted;
  }
  
  // 2. 通知權限 (用於下載完成通知)
  Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    
    return (await Permission.notification.request()).isGranted;
  }
}

// AndroidManifest.xml 配置
/*
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
*/
```

### 3.3 版權與合規

#### 免責聲明
```dart
class LegalNotice {
  static const String disclaimer = '''
書苑閱讀器 - 免責聲明

1. 內容來源
   本應用中的電子書內容來自公開的 GitHub 倉庫，僅供學習和研究使用。

2. 版權聲明
   所有書籍版權歸原作者所有。如有侵權，請聯繫我們刪除。

3. 使用限制
   用戶不得將本應用中的內容用於商業用途或進行二次分發。

4. 責任限制
   本應用開發者不對內容的準確性、完整性或合法性承擔責任。

聯繫方式: [email]

最後更新: 2025-11-06
''';

  static void showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('免責聲明'),
        content: SingleChildScrollView(
          child: Text(disclaimer),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('我已閱讀並同意'),
          ),
        ],
      ),
    );
  }
}
```

#### 內容評級
```yaml
# Google Play 應用評級準備
Content Rating:
  - Category: Books & Reference
  - Age Rating: Everyone
  - Content Descriptors: 
      - Educational Content
      - Traditional Chinese Literature
  - Privacy Policy URL: [待提供]
```

---

## 4. 測試與部署

### 4.1 錯誤處理

#### 全局錯誤捕獲
```dart
void main() {
  // 1. Flutter 錯誤捕獲
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logError(details.exception, details.stack);
  };
  
  // 2. Dart 異步錯誤捕獲
  PlatformDispatcher.instance.onError = (error, stack) {
    _logError(error, stack);
    return true;
  };
  
  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) {
      _logError(error, stackTrace);
    },
  );
}

// 錯誤日誌系統
class ErrorLogger {
  static void logError(dynamic error, StackTrace? stackTrace) {
    // 1. 本地日誌
    _writeToLocalLog(error, stackTrace);
    
    // 2. 上報到服務器 (可選)
    if (kReleaseMode) {
      _reportToSentry(error, stackTrace);
    }
    
    // 3. 開發環境顯示詳細錯誤
    if (kDebugMode) {
      print('Error: $error\n$stackTrace');
    }
  }
  
  static Future<void> _reportToSentry(
    dynamic error,
    StackTrace? stackTrace,
  ) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  }
}

// 友好錯誤提示
class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '連接超時，請檢查網絡';
        case DioExceptionType.receiveTimeout:
          return '接收數據超時';
        case DioExceptionType.badResponse:
          return '服務器錯誤 (${error.response?.statusCode})';
        default:
          return '網絡錯誤，請稍後重試';
      }
    }
    
    if (error is FileSystemException) {
      return '文件操作失敗，請檢查存儲空間';
    }
    
    return '發生未知錯誤';
  }
  
  static void showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('錯誤'),
          ],
        ),
        content: Text(getUserFriendlyMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('確定'),
          ),
        ],
      ),
    );
  }
}
```

### 4.2 跨設備測試

#### 響應式布局
```dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType) builder;
  
  @override
  Widget build(BuildContext context) {
    final deviceType = _getDeviceType(context);
    return builder(context, deviceType);
  }
  
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) return DeviceType.mobile;
    if (width < 900) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}

enum DeviceType { mobile, tablet, desktop }

// 使用示例
ResponsiveBuilder(
  builder: (context, deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return MobileLayout();
      case DeviceType.tablet:
        return TabletLayout();
      case DeviceType.desktop:
        return DesktopLayout();
    }
  },
);
```

#### 屏幕適配
```dart
class ScreenAdapter {
  static double sp(double size) {
    // 使用 flutter_screenutil
    return size.sp;
  }
  
  static double width(double size) {
    return size.w;
  }
  
  static double height(double size) {
    return size.h;
  }
}

// 初始化
ScreenUtil.init(
  designSize: Size(375, 812),  // iPhone X 設計尺寸
  minTextAdapt: true,
);
```

### 4.3 App 生命週期管理

#### Splash Screen
```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    // 1. 初始化數據庫
    await _initDatabase();
    
    // 2. 檢查權限
    await _checkPermissions();
    
    // 3. 加載書籍目錄
    await _loadCatalog();
    
    // 4. 檢查更新
    await _checkForUpdates();
    
    // 5. 導航到主頁
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
```

#### 閱讀進度保存
```dart
class ReadingProgressManager {
  Timer? _saveTimer;
  
  void startAutoSave(String bookId, String Function() getCurrentPosition) {
    _saveTimer = Timer.periodic(
      Duration(seconds: 10),
      (_) async {
        final position = getCurrentPosition();
        await _saveProgress(bookId, position);
      },
    );
  }
  
  void stopAutoSave() {
    _saveTimer?.cancel();
  }
  
  @override
  void dispose() {
    stopAutoSave();
    super.dispose();
  }
}

// 在 ReaderPage 中使用
class ReaderPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _progressManager.startAutoSave(widget.bookId, _getCurrentCFI);
  }
  
  @override
  void dispose() {
    _progressManager.stopAutoSave();
    // 最後保存一次
    _saveProgress();
    super.dispose();
  }
}
```

---

## 5. 技術架構

### 5.1 整體架構
```
┌─────────────────────────────────────────────────┐
│                   Presentation Layer             │
│  ┌──────────┬──────────┬──────────┬──────────┐  │
│  │   Home   │  Search  │  Reader  │ Settings │  │
│  └──────────┴──────────┴──────────┴──────────┘  │
│                     GetX State Management         │
└─────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────┐
│                  Business Logic Layer            │
│  ┌──────────────┬──────────────┬─────────────┐  │
│  │ BookManager  │DownloadMgr   │ ReaderLogic │  │
│  ├──────────────┼──────────────┼─────────────┤  │
│  │ SearchSvc    │ CacheMgr     │ SyncService │  │
│  └──────────────┴──────────────┴─────────────┘  │
└─────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────┐
│                    Data Layer                    │
│  ┌──────────────┬──────────────┬─────────────┐  │
│  │ Hive DB      │ SharedPrefs  │ FileSystem  │  │
│  ├──────────────┼──────────────┼─────────────┤  │
│  │ Network (Dio)│ Cache        │ SecureStore │  │
│  └──────────────┴──────────────┴─────────────┘  │
└─────────────────────────────────────────────────┘
```

### 5.2 項目結構
```
lib/
├── main.dart
├── app/
│   ├── routes/                 # 路由配置
│   ├── themes/                 # 主題
│   └── constants/              # 常量
├── core/
│   ├── network/               # 網絡層
│   ├── storage/               # 存儲層
│   ├── utils/                 # 工具類
│   └── errors/                # 錯誤處理
├── data/
│   ├── models/                # 數據模型
│   ├── repositories/          # 數據倉庫
│   └── datasources/           # 數據源
│       ├── remote/            # 遠程數據
│       └── local/             # 本地數據
├── domain/
│   ├── entities/              # 業務實體
│   ├── usecases/              # 用例
│   └── repositories/          # 倉庫接口
└── presentation/
    ├── pages/                 # 頁面
    │   ├── home/
    │   ├── search/
    │   ├── reader/
    │   └── settings/
    ├── widgets/               # 通用組件
    └── controllers/           # 控制器 (GetX)
```

### 5.3 核心依賴
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 狀態管理
  get: ^4.6.5
  
  # 網絡
  dio: ^5.3.3
  connectivity_plus: ^5.0.1
  
  # 本地存儲
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  flutter_secure_storage: ^9.0.0
  
  # 圖片緩存
  cached_network_image: ^3.3.0
  
  # EPUB 處理
  epub_view: ^3.1.0
  archive: ^3.4.9
  
  # UI
  flutter_screenutil: ^5.9.0
  shimmer: ^3.0.0
  loading_animation_widget: ^1.2.0
  
  # 功能
  permission_handler: ^11.0.1
  url_launcher: ^6.2.1
  share_plus: ^7.2.1
  
  # 工具
  intl: ^0.18.1
  crypto: ^3.0.3
  
  # 錯誤追踪
  sentry_flutter: ^7.13.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
  flutter_lints: ^3.0.0
```

---

## 6. 開發路線圖

### Phase 1: MVP (4-6 週)
**目標：基本可用的閱讀器**

Week 1-2: 基礎架構
- [x] 項目初始化和架構搭建
- [x] 網絡層和數據層實現
- [x] 書籍列表頁面 (GridView)
- [x] books.json 解析和緩存

Week 3-4: 核心功能
- [x] 書籍下載管理
- [x] 本地存儲實現
- [x] EPUB 閱讀器集成
- [x] 基本閱讀功能（翻頁、進度）

Week 5-6: 優化和測試
- [x] 錯誤處理
- [x] 離線模式
- [x] UI 優化
- [x] 基本測試

### Phase 2: 增強功能 (4-6 週)
**目標：完善用戶體驗**

Week 7-8: 書籍管理
- [ ] 搜索和過濾功能
- [ ] 書籤和筆記
- [ ] 閱讀歷史
- [ ] 本地書庫管理

Week 9-10: 閱讀器增強
- [ ] 字體和主題設置
- [ ] 高亮和註釋
- [ ] 目錄導航
- [ ] 閱讀統計

Week 11-12: 性能優化
- [ ] 圖片懶加載和緩存
- [ ] 內存優化
- [ ] 響應式布局
- [ ] 動畫優化

### Phase 3: 完善和發布 (2-4 週)
**目標：上架 Google Play**

Week 13-14: 最後優化
- [ ] 多語言支持
- [ ] 隱私政策頁面
- [ ] 用戶反饋機制
- [ ] 完整測試（包括不同設備）

Week 15-16: 發布準備
- [ ] 應用圖標和啟動頁
- [ ] Google Play 商店資料準備
- [ ] 應用簽名和打包
- [ ] 內部測試版發布

### Phase 4: 後續迭代 (持續)
**目標：根據用戶反饋優化**

- [ ] 雲同步功能（可選）
- [ ] 社區分享功能
- [ ] 更多主題和字體
- [ ] iOS 版本（如果需要）
- [ ] 平板優化

---

## 7. 風險和挑戰

### 7.1 技術風險
1. **EPUB 解析複雜性**
   - 風險：不同 EPUB 格式兼容性
   - 緩解：使用成熟的 epub_view 包，充分測試

2. **性能問題**
   - 風險：大文件處理可能導致內存溢出
   - 緩解：流式解析、分頁加載、內存監控

3. **網絡穩定性**
   - 風險：GitHub 訪問可能不穩定
   - 緩解：實現完善的離線模式和緩存機制

### 7.2 非技術風險
1. **版權問題**
   - 風險：書籍版權爭議
   - 緩解：明確免責聲明、僅限學習用途

2. **應用商店審核**
   - 風險：Google Play 可能拒絕上架
   - 緩解：遵守所有政策、提供完整隱私政策

3. **用戶期望**
   - 風險：功能不足或體驗不佳
   - 緩解：MVP 快速迭代、收集用戶反饋

---

## 8. 總結

這個設計方案涵蓋了從 MVP 到成熟產品的完整路徑。關鍵要點：

1. **優先級明確**：先實現核心閱讀功能，再逐步增強
2. **技術選型合理**：使用成熟的 Flutter 生態包
3. **用戶體驗優先**：離線支持、流暢動畫、友好錯誤提示
4. **可擴展性好**：架構清晰，易於後續添加功能
5. **合規性重視**：隱私保護、版權聲明、權限管理

建議從 Phase 1 開始，快速實現 MVP 並進行用戶測試，根據反饋調整後續開發計劃。
