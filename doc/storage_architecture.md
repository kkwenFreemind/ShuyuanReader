# 書苑閱讀器 - 儲存架構設計

## 目錄

1. [整體架構概覽](#整體架構概覽)
2. [遠程資源（GitHub）](#遠程資源github)
3. [本地存儲（APP）](#本地存儲app)
4. [數據流程](#數據流程)
5. [存儲路徑規範](#存儲路徑規範)
6. [實現代碼](#實現代碼)

---

## 整體架構概覽

### 核心理念

```
┌─────────────────────────────────────────────────┐
│                 GitHub Repository                │
│            (唯一的內容來源和真相源)                │
│                                                  │
│  catalog/books.json  ← 書籍元數據               │
│  covers/*.png        ← 所有書籍封面              │
│  epub3/*.epub        ← 所有電子書文件             │
└─────────────────────────────────────────────────┘
                        ↓
                   網絡下載
                        ↓
┌─────────────────────────────────────────────────┐
│              Android APP 本地存儲                 │
│           (僅緩存用戶需要的內容)                   │
│                                                  │
│  數據庫(Hive)         ← 書籍元數據和狀態          │
│  files/books/        ← 用戶下載的 EPUB           │
│  cache/covers/       ← 緩存的封面圖片             │
│  cache/books.json    ← 緩存的書籍列表             │
└─────────────────────────────────────────────────┘
```

### 設計原則

1. **GitHub = 唯一真相源**
   - 所有內容託管在 GitHub
   - APP 不自帶任何電子書或封面
   - 所有資源都是按需下載

2. **APP = 智能緩存層**
   - 只下載用戶需要的書籍
   - 自動緩存已查看的封面
   - 離線時使用本地緩存

3. **按需下載策略**
   - 首次啟動：下載 books.json
   - 瀏覽列表：按需下載封面（懶加載）
   - 閱讀書籍：下載完整 EPUB 文件

---

## 遠程資源（GitHub）

### GitHub Repository 結構

```
https://github.com/kkwenFreemind/ShuyuanReader/
├── catalog/
│   └── books.json          # 書籍目錄（約 50KB）
│
├── covers/                 # 封面目錄
│   ├── 一夢漫言.png
│   ├── 三世因果目蓮救母經.png
│   ├── 世風集錄.png
│   └── ... (100 個封面圖片)
│
└── epub3/                  # 電子書目錄
    ├── 一夢漫言.epub
    ├── 三世因果目蓮救母經.epub
    ├── 世風集錄.epub
    └── ... (100 個 EPUB 文件)
```

### 資源 URL 模式

#### 使用 Raw Content URL（推薦）

```dart
class GitHubUrls {
  static const String baseUrl = 
    'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main';
  
  // 書籍目錄
  static const String booksJsonUrl = '$baseUrl/catalog/books.json';
  
  // 封面圖片
  static String getCoverUrl(String bookId) {
    return '$baseUrl/covers/$bookId.png';
  }
  
  // EPUB 文件
  static String getEpubUrl(String filename) {
    return '$baseUrl/epub3/$filename';
  }
}

// 使用示例
final catalogUrl = GitHubUrls.booksJsonUrl;
// https://raw.githubusercontent.com/.../catalog/books.json

final coverUrl = GitHubUrls.getCoverUrl('一夢漫言');
// https://raw.githubusercontent.com/.../covers/一夢漫言.png

final epubUrl = GitHubUrls.getEpubUrl('一夢漫言.epub');
// https://raw.githubusercontent.com/.../epub3/一夢漫言.epub
```

#### 可選：使用 CDN 加速（中國地區訪問優化）

```dart
class GitHubUrls {
  // 方案 1: jsDelivr CDN
  static const String cdnUrl = 
    'https://cdn.jsdelivr.net/gh/kkwenFreemind/ShuyuanReader@main';
  
  // 方案 2: Statically CDN
  static const String cdnUrl2 = 
    'https://statically.io/gh/kkwenFreemind/ShuyuanReader/main';
  
  // 自動選擇最快的 URL
  static String getBestBaseUrl() {
    // 可以根據網絡測試選擇最快的
    return cdnUrl;  // 或 baseUrl
  }
}
```

### books.json 結構（遠程）

```json
{
  "metadata": {
    "title": "書苑閱讀器書目",
    "version": "1.0.0",
    "generated_at": "2025-11-06T10:00:00Z",
    "total_books": 100,
    "base_url": "https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main"
  },
  "books": [
    {
      "id": "一夢漫言",
      "title": "一夢漫言",
      "author": "千華寺繼任主持 見月老人自述",
      "language": "tw",
      "description": "",
      "publisher": "",
      "date": "",
      
      // ⭐ 關鍵：相對路徑或完整 URL
      "epubUrl": "epub3/一夢漫言.epub",           // 相對路徑
      "coverUrl": "covers/一夢漫言.png",          // 相對路徑
      
      // 或者使用完整 URL
      "epubUrl": "https://raw.githubusercontent.com/.../epub3/一夢漫言.epub",
      "coverUrl": "https://raw.githubusercontent.com/.../covers/一夢漫言.png",
      
      "metadata": {
        "creator": "千華寺繼任主持 見月老人自述",
        "language": "tw",
        "identifier": "urn:uuid:731e3d50-212c-4873-bae5-a4b57d664064"
      }
    }
  ]
}
```

### 資源訪問特性

| 特性 | 說明 |
|------|------|
| **訪問方式** | HTTP GET（無需認證） |
| **緩存策略** | 使用 HTTP Cache Headers (ETag, Last-Modified) |
| **流量限制** | 無限制（公開倉庫） |
| **下載速度** | 全球 CDN，通常 1-5 MB/s |
| **可用性** | 99.9% SLA |
| **成本** | 完全免費 |

---

## 本地存儲（APP）

### Android APP 存儲結構

```
/data/data/com.shuyuan.reader/
│
├── app_flutter/                    # Hive 數據庫
│   ├── books.hive                  # 書籍元數據
│   ├── bookmarks.hive              # 書籤數據
│   ├── reading_progress.hive      # 閱讀進度
│   └── reader_settings.hive       # 閱讀設置
│
├── files/                          # 應用私有文件
│   └── books/                      # 已下載的 EPUB
│       ├── 一夢漫言.epub            # ⭐ 用戶主動下載
│       ├── 心經略說.epub
│       └── ...
│
├── cache/                          # 緩存目錄
│   ├── covers/                     # 封面圖片緩存
│   │   ├── 一夢漫言.png            # ⭐ 自動緩存
│   │   ├── 三世因果目蓮救母經.png
│   │   └── ...
│   │
│   └── catalog/
│       └── books.json              # books.json 緩存
│
└── shared_prefs/                   # 應用設置
    └── FlutterSharedPreferences.xml
```

### 存儲空間管理

#### 1. EPUB 文件（永久存儲）

- **位置**: `files/books/`
- **特點**: 
  - 用戶主動下載
  - 永久保存，直到用戶刪除
  - 平均大小：1-5 MB/本
- **生命週期**: 
  - 下載：用戶點擊"下載"按鈕
  - 保留：長期保存
  - 刪除：用戶手動刪除

#### 2. 封面圖片（臨時緩存）

- **位置**: `cache/covers/`
- **特點**: 
  - 自動下載並緩存
  - 可被系統清理
  - 平均大小：50-200 KB/張
- **生命週期**: 
  - 下載：用戶滾動到該書籍時
  - 保留：7 天或空間不足時清理
  - 刪除：自動清理或用戶清除緩存

#### 3. books.json（臨時緩存）

- **位置**: `cache/catalog/books.json`
- **特點**: 
  - 啟動時自動下載
  - 離線時使用緩存
  - 大小：約 50 KB
- **生命週期**: 
  - 下載：首次啟動或手動刷新
  - 保留：24 小時
  - 更新：每次啟動檢查更新

### 本地數據庫（Hive）

#### books.hive - 書籍元數據

```dart
@HiveType(typeId: 0)
class LocalBook extends HiveObject {
  // 基本信息（來自 books.json）
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String author;
  
  @HiveField(3)
  String language;
  
  // ⭐ 遠程資源 URL
  @HiveField(4)
  String remoteEpubUrl;      // GitHub 上的 EPUB URL
  
  @HiveField(5)
  String remoteCoverUrl;     // GitHub 上的封面 URL
  
  // ⭐ 本地資源路徑（如果已下載）
  @HiveField(6)
  String? localEpubPath;     // 本地 EPUB 絕對路徑
  
  @HiveField(7)
  String? localCoverPath;    // 本地封面絕對路徑
  
  // 下載狀態
  @HiveField(8)
  DownloadStatus downloadStatus;
  
  @HiveField(9)
  double downloadProgress;   // 0.0 ~ 1.0
  
  // 閱讀狀態
  @HiveField(10)
  ReadStatus readStatus;
  
  @HiveField(11)
  DateTime? lastReadTime;
  
  @HiveField(12)
  DateTime addedToLibraryTime;
  
  // 文件信息
  @HiveField(13)
  int? fileSizeBytes;
  
  @HiveField(14)
  String? md5Hash;
  
  // 判斷是否已下載
  bool get isDownloaded => 
    downloadStatus == DownloadStatus.completed && 
    localEpubPath != null;
  
  // 判斷是否有本地封面
  bool get hasCachedCover => localCoverPath != null;
}

@HiveType(typeId: 1)
enum DownloadStatus {
  @HiveField(0)
  notDownloaded,    // 未下載
  
  @HiveField(1)
  downloading,      // 下載中
  
  @HiveField(2)
  completed,        // 已完成
  
  @HiveField(3)
  paused,          // 已暫停
  
  @HiveField(4)
  failed,          // 下載失敗
}

@HiveType(typeId: 2)
enum ReadStatus {
  @HiveField(0)
  unread,          // 未讀
  
  @HiveField(1)
  reading,         // 閱讀中
  
  @HiveField(2)
  finished,        // 已讀完
}
```

---

## 數據流程

### 流程 1: 首次啟動 APP

```
用戶打開 APP
    ↓
顯示 Splash Screen
    ↓
初始化 Hive 數據庫
    ↓
檢查網絡連接
    ↓
    是否在線？
    ├─ 是 → 下載 books.json (50KB)
    │       ↓
    │   解析並保存到 Hive
    │       ↓
    │   緩存 books.json 到本地
    │       ↓
    │   顯示書籍列表（只有書名，無封面）
    │
    └─ 否 → 檢查是否有緩存
            ├─ 有 → 從緩存加載
            └─ 無 → 提示"請連接網絡"
```

### 流程 2: 瀏覽書籍列表

```
用戶滾動列表
    ↓
書籍卡片進入視野（Lazy Loading）
    ↓
檢查本地是否有封面緩存
    ├─ 有 → 直接顯示本地封面
    │
    └─ 無 → 顯示占位圖
            ↓
        從 GitHub 下載封面 (50-200KB)
            ↓
        緩存到 cache/covers/
            ↓
        顯示封面
```

### 流程 3: 下載並閱讀電子書

```
用戶點擊書籍卡片
    ↓
顯示書籍詳情頁
    ↓
用戶點擊"下載"按鈕
    ↓
檢查存儲空間
    ├─ 空間不足 → 提示用戶清理
    │
    └─ 空間充足 → 開始下載
            ↓
        從 GitHub 下載 EPUB (1-5MB)
            ↓
        顯示下載進度條
            ↓
        保存到 files/books/{bookId}.epub
            ↓
        更新 Hive 數據庫
        - downloadStatus = completed
        - localEpubPath = 本地路徑
            ↓
        按鈕變為"打開閱讀"
            ↓
        用戶點擊"打開閱讀"
            ↓
        從本地路徑打開 EPUB
            ↓
        進入閱讀頁面
```

### 流程 4: 離線使用

```
用戶在無網絡環境打開 APP
    ↓
檢測到離線
    ↓
從本地緩存加載 books.json
    ↓
顯示書籍列表
    ├─ 已下載的書籍：顯示封面 + "已下載"標記
    └─ 未下載的書籍：顯示占位圖 + "需要網絡"標記
    ↓
用戶只能閱讀已下載的書籍
```

### 流程 5: 檢查更新

```
用戶下拉刷新 / APP 啟動（超過6小時未檢查）
    ↓
發送 HEAD 請求到 GitHub
    ↓
檢查 books.json 的 ETag
    ├─ ETag 未變 → 提示"已是最新"
    │
    └─ ETag 已變 → 有更新可用
            ↓
        下載最新 books.json
            ↓
        比較本地和遠程書籍列表
            ↓
        顯示更新摘要
        - 新增了 X 本書
        - 更新了 Y 本書的信息
            ↓
        用戶確認更新
            ↓
        更新本地數據庫
```

---

## 存儲路徑規範

### 路徑管理器實現

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StoragePathManager {
  static StoragePathManager? _instance;
  static StoragePathManager get instance => _instance ??= StoragePathManager._();
  
  StoragePathManager._();
  
  // 緩存的目錄對象
  Directory? _appDocDir;
  Directory? _cacheDir;
  
  // ========== 初始化 ==========
  
  Future<void> initialize() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _cacheDir = await getTemporaryDirectory();
    
    // 創建必要的目錄
    await _createDirectories();
  }
  
  Future<void> _createDirectories() async {
    await Directory('${_appDocDir!.path}/books').create(recursive: true);
    await Directory('${_cacheDir!.path}/covers').create(recursive: true);
    await Directory('${_cacheDir!.path}/catalog').create(recursive: true);
  }
  
  // ========== EPUB 文件路徑（永久存儲）==========
  
  /// 獲取 EPUB 存儲目錄
  String getEpubDirectory() {
    return '${_appDocDir!.path}/books';
  }
  
  /// 獲取指定書籍的 EPUB 完整路徑
  /// 例如: /data/data/com.shuyuan.reader/files/books/一夢漫言.epub
  String getEpubPath(String bookId) {
    return '${getEpubDirectory()}/$bookId.epub';
  }
  
  /// 檢查 EPUB 是否存在
  Future<bool> epubExists(String bookId) async {
    final file = File(getEpubPath(bookId));
    return await file.exists();
  }
  
  /// 獲取 EPUB 文件大小
  Future<int> getEpubSize(String bookId) async {
    final file = File(getEpubPath(bookId));
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
  
  // ========== 封面圖片路徑（緩存）==========
  
  /// 獲取封面緩存目錄
  String getCoverCacheDirectory() {
    return '${_cacheDir!.path}/covers';
  }
  
  /// 獲取指定書籍的封面緩存路徑
  /// 例如: /data/data/com.shuyuan.reader/cache/covers/一夢漫言.png
  String getCoverCachePath(String bookId) {
    return '${getCoverCacheDirectory()}/$bookId.png';
  }
  
  /// 檢查封面緩存是否存在
  Future<bool> coverCacheExists(String bookId) async {
    final file = File(getCoverCachePath(bookId));
    return await file.exists();
  }
  
  // ========== books.json 緩存路徑 ==========
  
  /// 獲取 books.json 緩存路徑
  String getBooksJsonCachePath() {
    return '${_cacheDir!.path}/catalog/books.json';
  }
  
  /// 檢查 books.json 緩存是否存在
  Future<bool> booksJsonCacheExists() async {
    final file = File(getBooksJsonCachePath());
    return await file.exists();
  }
  
  // ========== 存儲空間管理 ==========
  
  /// 獲取存儲空間信息
  Future<StorageSpaceInfo> getStorageInfo() async {
    int totalEpubSize = 0;
    int epubCount = 0;
    int totalCoverSize = 0;
    int coverCount = 0;
    
    // 計算 EPUB 文件大小
    final epubDir = Directory(getEpubDirectory());
    if (await epubDir.exists()) {
      await for (var file in epubDir.list()) {
        if (file is File && file.path.endsWith('.epub')) {
          totalEpubSize += await file.length();
          epubCount++;
        }
      }
    }
    
    // 計算封面緩存大小
    final coverDir = Directory(getCoverCacheDirectory());
    if (await coverDir.exists()) {
      await for (var file in coverDir.list()) {
        if (file is File) {
          totalCoverSize += await file.length();
          coverCount++;
        }
      }
    }
    
    return StorageSpaceInfo(
      totalEpubSize: totalEpubSize,
      epubCount: epubCount,
      totalCoverSize: totalCoverSize,
      coverCount: coverCount,
    );
  }
  
  /// 清除所有緩存
  Future<void> clearAllCache() async {
    // 清除封面緩存
    final coverDir = Directory(getCoverCacheDirectory());
    if (await coverDir.exists()) {
      await coverDir.delete(recursive: true);
      await coverDir.create();
    }
    
    // 清除 books.json 緩存
    final catalogFile = File(getBooksJsonCachePath());
    if (await catalogFile.exists()) {
      await catalogFile.delete();
    }
  }
  
  /// 清除指定書籍的封面緩存
  Future<void> clearCoverCache(String bookId) async {
    final file = File(getCoverCachePath(bookId));
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  /// 刪除指定書籍的 EPUB 文件
  Future<void> deleteEpub(String bookId) async {
    final file = File(getEpubPath(bookId));
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  /// 刪除指定書籍的所有本地數據（EPUB + 封面）
  Future<void> deleteBookData(String bookId) async {
    await deleteEpub(bookId);
    await clearCoverCache(bookId);
  }
}

// 存儲空間信息
class StorageSpaceInfo {
  final int totalEpubSize;      // bytes
  final int epubCount;
  final int totalCoverSize;     // bytes
  final int coverCount;
  
  StorageSpaceInfo({
    required this.totalEpubSize,
    required this.epubCount,
    required this.totalCoverSize,
    required this.coverCount,
  });
  
  int get totalSize => totalEpubSize + totalCoverSize;
  
  String get formattedEpubSize => _formatBytes(totalEpubSize);
  String get formattedCoverSize => _formatBytes(totalCoverSize);
  String get formattedTotalSize => _formatBytes(totalSize);
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

---

## 實現代碼

### 完整的資源管理器

```dart
import 'package:dio/dio.dart';

class ResourceManager {
  final Dio dio;
  final StoragePathManager pathManager;
  
  ResourceManager({
    required this.dio,
    required this.pathManager,
  });
  
  // ========== 下載 books.json ==========
  
  Future<String> downloadBooksJson() async {
    try {
      final response = await dio.get(GitHubUrls.booksJsonUrl);
      final jsonString = response.data.toString();
      
      // 緩存到本地
      final cachePath = pathManager.getBooksJsonCachePath();
      await File(cachePath).writeAsString(jsonString);
      
      return jsonString;
    } catch (e) {
      throw Exception('下載 books.json 失敗: $e');
    }
  }
  
  // ========== 下載封面 ==========
  
  Future<String> downloadCover(String bookId, String coverUrl) async {
    final savePath = pathManager.getCoverCachePath(bookId);
    
    // 如果已經有緩存，直接返回
    if (await pathManager.coverCacheExists(bookId)) {
      return savePath;
    }
    
    try {
      await dio.download(
        coverUrl,
        savePath,
        options: Options(
          receiveTimeout: Duration(seconds: 30),
        ),
      );
      
      return savePath;
    } catch (e) {
      throw Exception('下載封面失敗: $e');
    }
  }
  
  // ========== 下載 EPUB ==========
  
  Future<String> downloadEpub({
    required String bookId,
    required String epubUrl,
    ProgressCallback? onProgress,
  }) async {
    final savePath = pathManager.getEpubPath(bookId);
    
    // 如果已經下載，直接返回
    if (await pathManager.epubExists(bookId)) {
      return savePath;
    }
    
    try {
      await dio.download(
        epubUrl,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(
          receiveTimeout: Duration(minutes: 10),
        ),
      );
      
      return savePath;
    } catch (e) {
      // 下載失敗，刪除不完整的文件
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }
      throw Exception('下載 EPUB 失敗: $e');
    }
  }
  
  // ========== 獲取資源路徑 ==========
  
  /// 獲取封面路徑（優先本地，其次遠程）
  Future<String> getCoverPath(String bookId, String remoteCoverUrl) async {
    // 先檢查本地緩存
    if (await pathManager.coverCacheExists(bookId)) {
      return pathManager.getCoverCachePath(bookId);
    }
    
    // 沒有緩存，返回遠程 URL
    return remoteCoverUrl;
  }
  
  /// 獲取 EPUB 路徑（只返回本地，如果沒有則返回 null）
  Future<String?> getEpubPath(String bookId) async {
    if (await pathManager.epubExists(bookId)) {
      return pathManager.getEpubPath(bookId);
    }
    return null;
  }
}
```

### 使用示例

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. 初始化路徑管理器
  await StoragePathManager.instance.initialize();
  
  // 2. 初始化資源管理器
  final resourceManager = ResourceManager(
    dio: Dio(),
    pathManager: StoragePathManager.instance,
  );
  
  // 3. 首次啟動：下載 books.json
  try {
    final jsonString = await resourceManager.downloadBooksJson();
    print('✅ books.json 下載成功');
  } catch (e) {
    print('❌ books.json 下載失敗: $e');
  }
  
  // 4. 下載封面（懶加載）
  final coverPath = await resourceManager.downloadCover(
    '一夢漫言',
    'https://raw.githubusercontent.com/.../covers/一夢漫言.png',
  );
  print('封面保存在: $coverPath');
  
  // 5. 下載 EPUB
  await resourceManager.downloadEpub(
    bookId: '一夢漫言',
    epubUrl: 'https://raw.githubusercontent.com/.../epub3/一夢漫言.epub',
    onProgress: (received, total) {
      final progress = (received / total * 100).toStringAsFixed(0);
      print('下載進度: $progress%');
    },
  );
  
  // 6. 獲取存儲空間信息
  final storageInfo = await StoragePathManager.instance.getStorageInfo();
  print('已下載 ${storageInfo.epubCount} 本書');
  print('佔用空間: ${storageInfo.formattedTotalSize}');
  
  runApp(MyApp());
}
```

---

## 總結

### 關鍵設計決策

1. **GitHub = 唯一內容源**
   - ✅ 無需維護服務器
   - ✅ 全球 CDN 加速
   - ✅ 完全免費
   - ✅ 版本控制

2. **按需下載**
   - ✅ 節省用戶流量
   - ✅ 減少 APP 體積
   - ✅ 更快的首次啟動

3. **智能緩存**
   - ✅ 封面自動緩存（7天）
   - ✅ books.json 緩存（24小時）
   - ✅ EPUB 永久保存（用戶控制）

4. **離線支持**
   - ✅ 已下載的書籍可離線閱讀
   - ✅ 書籍列表離線可查看
   - ✅ 封面緩存離線可顯示

### 存儲空間估算

| 用戶使用場景 | 本地存儲佔用 |
|-------------|-------------|
| **首次安裝** | < 10 MB (APP 本體 + 數據庫) |
| **瀏覽 100 本書** | + 10 MB (100張封面緩存) |
| **下載 10 本書** | + 20-50 MB (10本 EPUB) |
| **下載 50 本書** | + 100-250 MB (50本 EPUB) |
| **重度用戶 (100本)** | + 200-500 MB (100本 EPUB) |

### 優勢總結

✅ **對開發者**：
- 無服務器維護成本
- 使用 Git 管理內容
- 自動版本控制和備份

✅ **對用戶**：
- 按需下載，節省空間
- 離線可用已下載內容
- 快速響應（本地緩存）

✅ **可擴展性**：
- 輕鬆添加新書（Git push）
- 支持 CDN 加速
- 支持增量更新
