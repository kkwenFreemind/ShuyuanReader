# Spec 03: 書籍詳情頁 (Book Detail Page)

**狀態**: 📝 規格中  
**優先級**: P0 (必須完成)  
**預計時間**: 2-3 天  
**依賴**: Spec 02 (書籍列表頁)  
**創建日期**: 2025-11-07

---

## 📋 概述

### 功能描述
書籍詳情頁是用戶查看書籍完整信息、管理下載狀態、開始閱讀的核心頁面。用戶從書籍列表點擊任一書籍後進入此頁面，可以查看書籍的詳細信息（封面、書名、作者、描述、文件大小等），並根據下載狀態執行相應操作（下載、暫停、恢復、打開閱讀）。

### 核心價值
- 📖 **信息展示**: 清晰展示書籍完整信息，幫助用戶做出閱讀決策
- 📥 **下載管理**: 統一的下載控制中心，實時顯示下載進度
- 🎯 **快速閱讀**: 已下載書籍可直接打開閱讀，無需返回列表
- ✨ **優雅過渡**: Hero 動畫提供流暢的頁面切換體驗

### 用戶故事
```
作為 經典愛好者
我想要 查看書籍的詳細信息並下載感興趣的書籍
以便 我可以離線閱讀這些經典作品
```

**驗收標準**:
- 能看到書籍的封面、書名、作者、描述、語言、文件大小
- 未下載的書籍顯示「下載」按鈕
- 下載中的書籍顯示進度條和「暫停」按鈕
- 已下載的書籍顯示「打開閱讀」按鈕
- 點擊「打開閱讀」能正確跳轉到閱讀器頁面

---

## 🎨 UI/UX 設計

### 頁面結構

```
┌─────────────────────────────────────┐
│  ← 書籍詳情               ⋮          │  ← AppBar (返回 + 更多菜單)
├─────────────────────────────────────┤
│                                     │
│          ┌─────────────┐            │
│          │             │            │
│          │   封面圖    │            │  ← Hero 動畫封面 (180x270)
│          │             │            │
│          └─────────────┘            │
│                                     │
│        📚 一夢漫言                   │  ← 書名 (fontSize: 24, bold)
│                                     │
│    ✍️ 千華寺繼任主持 見月老人         │  ← 作者 (fontSize: 16, grey)
│                                     │
│    🌐 繁體中文    💾 2.5 MB          │  ← 語言 + 文件大小
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📖 內容簡介                         │  ← 描述標題
│                                     │
│  余於庚午歲，遊居金陵...             │
│  見世人營營逐逐，如蛾投燭...         │  ← 書籍描述 (可滾動)
│  ...                                │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │   📥 下載 (未下載)            │  │  ← 下載按鈕 (未下載狀態)
│  └───────────────────────────────┘  │
│                                     │
│  或                                 │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ ━━━━━━━━━━━━━━━━━ 65%        │  │
│  │ 1.6 MB / 2.5 MB               │  │  ← 進度條 (下載中)
│  │     ⏸️ 暫停     ❌ 取消       │  │
│  └───────────────────────────────┘  │
│                                     │
│  或                                 │
│                                     │
│  ┌───────────────────────────────┐  │
│  │   📖 打開閱讀                 │  │  ← 閱讀按鈕 (已下載)
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │   🗑️ 刪除書籍                 │  │  ← 刪除按鈕
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 三種下載狀態的 UI

#### 狀態 1: 未下載 (Not Downloaded)
```dart
ElevatedButton.icon(
  icon: Icon(Icons.download),
  label: Text('下載'),
  onPressed: () => controller.startDownload(),
)
```

#### 狀態 2: 下載中 (Downloading)
```dart
Column(
  children: [
    LinearProgressIndicator(value: downloadProgress),
    Text('1.6 MB / 2.5 MB'),
    Row(
      children: [
        TextButton.icon(
          icon: Icon(Icons.pause),
          label: Text('暫停'),
          onPressed: () => controller.pauseDownload(),
        ),
        TextButton.icon(
          icon: Icon(Icons.close),
          label: Text('取消'),
          onPressed: () => controller.cancelDownload(),
        ),
      ],
    ),
  ],
)
```

#### 狀態 3: 已下載 (Downloaded)
```dart
Column(
  children: [
    ElevatedButton.icon(
      icon: Icon(Icons.menu_book),
      label: Text('打開閱讀'),
      onPressed: () => controller.openReader(),
    ),
    SizedBox(height: 8),
    OutlinedButton.icon(
      icon: Icon(Icons.delete_outline, color: Colors.red),
      label: Text('刪除書籍', style: TextStyle(color: Colors.red)),
      onPressed: () => controller.deleteBook(),
    ),
  ],
)
```

### 設計規範

#### 顏色
```dart
// 主色調
primaryColor: Color(0xFF6750A4)  // Material 3 Primary
secondaryColor: Color(0xFF625B71)  // Material 3 Secondary

// 功能色
downloadButton: Colors.blue[600]  // 下載按鈕
readButton: Colors.green[600]     // 閱讀按鈕
deleteButton: Colors.red[600]     // 刪除按鈕
progressBar: Colors.blue[400]     // 進度條

// 文字色
titleColor: Colors.black87        // 標題
authorColor: Colors.grey[600]     // 作者
descriptionColor: Colors.black54  // 描述
```

#### 字體大小
```dart
bookTitle: 24.0     // 書名
author: 16.0        // 作者
metadata: 14.0      // 元數據（語言、大小）
description: 15.0   // 描述
buttonText: 16.0    // 按鈕文字
```

#### 間距
```dart
coverTopPadding: 24.0        // 封面距頂部
coverBottomMargin: 16.0      // 封面距書名
titleBottomMargin: 8.0       // 書名距作者
authorBottomMargin: 12.0     // 作者距元數據
metadataBottomMargin: 24.0   // 元數據距描述
descriptionPadding: 16.0     // 描述內邊距
buttonBottomMargin: 16.0     // 按鈕間距
```

### Hero 動畫

封面從列表頁到詳情頁使用 Hero 動畫：

**列表頁**:
```dart
Hero(
  tag: 'book-cover-${book.id}',
  child: CachedNetworkImage(imageUrl: book.coverUrl),
)
```

**詳情頁**:
```dart
Hero(
  tag: 'book-cover-${book.id}',
  child: CachedNetworkImage(imageUrl: book.coverUrl),
)
```

### 交互設計

#### 手勢
- **點擊返回按鈕**: 返回書籍列表
- **點擊下載按鈕**: 開始下載 EPUB
- **點擊暫停按鈕**: 暫停當前下載
- **點擊取消按鈕**: 取消下載並刪除部分文件
- **點擊打開閱讀按鈕**: 跳轉到閱讀器頁面
- **點擊刪除按鈕**: 彈出確認對話框後刪除本地文件

#### 動畫
- **頁面進入**: Hero 動畫 (封面) + Fade 動畫 (其他元素)
- **進度條**: 平滑更新 (200ms 過渡)
- **按鈕點擊**: Ripple 效果
- **狀態切換**: 淡入淡出 (300ms)

---

## 🏗️ 技術架構

### 文件結構

```
lib/
├── data/
│   ├── models/
│   │   └── book.dart                    # Book 模型（已存在）
│   ├── repositories/
│   │   └── book_repository.dart         # Book 倉庫（已存在）
│   └── services/
│       └── download_service.dart        # 🆕 下載服務
│
├── domain/
│   └── usecases/
│       ├── download_book_usecase.dart   # 🆕 下載書籍用例
│       └── delete_book_usecase.dart     # 🆕 刪除書籍用例
│
└── presentation/
    ├── pages/
    │   └── book_detail_page.dart        # 🆕 書籍詳情頁
    ├── controllers/
    │   └── book_detail_controller.dart  # 🆕 詳情頁控制器
    └── widgets/
        ├── book_info_card.dart          # 🆕 書籍信息卡片
        └── download_button.dart         # 🆕 下載按鈕組件
```

### 數據模型

#### Book 模型（擴展）

```dart
// lib/data/models/book.dart

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String coverUrl;

  @HiveField(4)
  final String epubUrl;

  @HiveField(5)
  final String description;  // 🆕 描述

  @HiveField(6)
  final String language;  // 🆕 語言

  @HiveField(7)
  final int fileSizeBytes;  // 🆕 文件大小（字節）

  @HiveField(8)
  DownloadStatus downloadStatus;  // 下載狀態

  @HiveField(9)
  double downloadProgress;  // 下載進度 (0.0 - 1.0)

  @HiveField(10)
  String? localPath;  // 本地文件路徑

  @HiveField(11)
  DateTime? downloadedAt;  // 下載完成時間

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.epubUrl,
    this.description = '',
    this.language = '繁體中文',
    this.fileSizeBytes = 0,
    this.downloadStatus = DownloadStatus.notDownloaded,
    this.downloadProgress = 0.0,
    this.localPath,
    this.downloadedAt,
  });

  // 格式化文件大小
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // 是否已下載
  bool get isDownloaded => downloadStatus == DownloadStatus.downloaded;

  // 是否正在下載
  bool get isDownloading => downloadStatus == DownloadStatus.downloading;
}
```

#### DownloadStatus 枚舉

```dart
// lib/data/models/download_status.dart

@HiveType(typeId: 1)
enum DownloadStatus {
  @HiveField(0)
  notDownloaded,  // 未下載

  @HiveField(1)
  downloading,    // 下載中

  @HiveField(2)
  paused,         // 已暫停

  @HiveField(3)
  downloaded,     // 已下載

  @HiveField(4)
  failed,         // 下載失敗
}
```

### 下載服務

```dart
// lib/data/services/download_service.dart

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DownloadService {
  final Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};

  DownloadService(this._dio);

  /// 下載書籍
  Future<String> downloadBook({
    required String bookId,
    required String url,
    required Function(double progress) onProgress,
  }) async {
    try {
      // 獲取應用文檔目錄
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${appDir.path}/books');
      
      // 確保目錄存在
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      // 生成本地文件路徑
      final fileName = '$bookId.epub';
      final savePath = '${booksDir.path}/$fileName';

      // 創建取消令牌
      final cancelToken = CancelToken();
      _cancelTokens[bookId] = cancelToken;

      // 開始下載
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      // 下載完成，移除取消令牌
      _cancelTokens.remove(bookId);

      return savePath;
    } on DioException catch (e) {
      _cancelTokens.remove(bookId);
      
      if (e.type == DioExceptionType.cancel) {
        throw DownloadCancelledException('下載已取消');
      } else {
        throw DownloadFailedException('下載失敗: ${e.message}');
      }
    } catch (e) {
      _cancelTokens.remove(bookId);
      throw DownloadFailedException('下載失敗: $e');
    }
  }

  /// 取消下載
  void cancelDownload(String bookId) {
    final cancelToken = _cancelTokens[bookId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('用戶取消下載');
      _cancelTokens.remove(bookId);
    }
  }

  /// 刪除本地書籍
  Future<void> deleteBook(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw DeletionFailedException('刪除失敗: $e');
    }
  }
}

// 自定義異常
class DownloadCancelledException implements Exception {
  final String message;
  DownloadCancelledException(this.message);
}

class DownloadFailedException implements Exception {
  final String message;
  DownloadFailedException(this.message);
}

class DeletionFailedException implements Exception {
  final String message;
  DeletionFailedException(this.message);
}
```

### 控制器

```dart
// lib/presentation/controllers/book_detail_controller.dart

import 'package:get/get.dart';
import '../../data/models/book.dart';
import '../../data/services/download_service.dart';
import '../../data/repositories/book_repository.dart';

class BookDetailController extends GetxController {
  final DownloadService _downloadService;
  final BookRepository _bookRepository;

  BookDetailController(this._downloadService, this._bookRepository);

  // 當前書籍
  late Rx<Book> book;

  @override
  void onInit() {
    super.onInit();
    // 從路由參數獲取書籍
    book = Rx<Book>(Get.arguments as Book);
  }

  /// 開始下載
  Future<void> startDownload() async {
    try {
      // 更新狀態為下載中
      book.value.downloadStatus = DownloadStatus.downloading;
      book.value.downloadProgress = 0.0;
      book.refresh();
      await _bookRepository.updateBook(book.value);

      // 開始下載
      final localPath = await _downloadService.downloadBook(
        bookId: book.value.id,
        url: book.value.epubUrl,
        onProgress: (progress) {
          book.value.downloadProgress = progress;
          book.refresh();
        },
      );

      // 下載完成
      book.value.downloadStatus = DownloadStatus.downloaded;
      book.value.downloadProgress = 1.0;
      book.value.localPath = localPath;
      book.value.downloadedAt = DateTime.now();
      book.refresh();
      await _bookRepository.updateBook(book.value);

      Get.snackbar(
        '下載完成',
        '《${book.value.title}》已下載完成',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DownloadCancelledException {
      // 用戶取消，不顯示錯誤
      book.value.downloadStatus = DownloadStatus.notDownloaded;
      book.value.downloadProgress = 0.0;
      book.refresh();
      await _bookRepository.updateBook(book.value);
    } on DownloadFailedException catch (e) {
      book.value.downloadStatus = DownloadStatus.failed;
      book.refresh();
      await _bookRepository.updateBook(book.value);

      Get.snackbar(
        '下載失敗',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 暫停下載
  void pauseDownload() {
    _downloadService.cancelDownload(book.value.id);
    book.value.downloadStatus = DownloadStatus.paused;
    book.refresh();
    _bookRepository.updateBook(book.value);
  }

  /// 取消下載
  Future<void> cancelDownload() async {
    _downloadService.cancelDownload(book.value.id);
    
    // 刪除部分下載的文件
    if (book.value.localPath != null) {
      try {
        await _downloadService.deleteBook(book.value.localPath!);
      } catch (_) {}
    }

    book.value.downloadStatus = DownloadStatus.notDownloaded;
    book.value.downloadProgress = 0.0;
    book.value.localPath = null;
    book.refresh();
    await _bookRepository.updateBook(book.value);
  }

  /// 刪除書籍
  Future<void> deleteBook() async {
    // 彈出確認對話框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('確認刪除'),
        content: Text('確定要刪除《${book.value.title}》嗎？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (book.value.localPath != null) {
        await _downloadService.deleteBook(book.value.localPath!);
      }

      book.value.downloadStatus = DownloadStatus.notDownloaded;
      book.value.downloadProgress = 0.0;
      book.value.localPath = null;
      book.value.downloadedAt = null;
      book.refresh();
      await _bookRepository.updateBook(book.value);

      Get.snackbar(
        '刪除成功',
        '《${book.value.title}》已刪除',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DeletionFailedException catch (e) {
      Get.snackbar(
        '刪除失敗',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 打開閱讀器
  void openReader() {
    if (book.value.localPath == null) {
      Get.snackbar(
        '錯誤',
        '書籍文件不存在',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 跳轉到閱讀器頁面（Spec 04）
    Get.toNamed('/reader', arguments: book.value);
  }
}
```

### 頁面實現

```dart
// lib/presentation/pages/book_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/book_detail_controller.dart';
import '../../data/models/book.dart';

class BookDetailPage extends GetView<BookDetailController> {
  const BookDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('書籍詳情'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 顯示更多選項（Spec 06 之後實現）
            },
          ),
        ],
      ),
      body: Obx(() {
        final book = controller.book.value;
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 封面圖片
              _buildCoverImage(book),
              
              SizedBox(height: 16),
              
              // 書名
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  book.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 8),
              
              // 作者
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  book.author,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: 12),
              
              // 元數據（語言 + 文件大小）
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      book.language,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.storage, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      book.fileSizeFormatted,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // 描述
              if (book.description.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '📖 內容簡介',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    book.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
              
              // 下載按鈕區域
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _buildActionButtons(book),
              ),
              
              SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCoverImage(Book book) {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: Hero(
        tag: 'book-cover-${book.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: book.coverUrl,
            width: 180,
            height: 270,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 180,
              height: 270,
              color: Colors.grey[300],
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 180,
              height: 270,
              color: Colors.grey[300],
              child: Icon(Icons.book, size: 64, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Book book) {
    switch (book.downloadStatus) {
      case DownloadStatus.notDownloaded:
      case DownloadStatus.failed:
        return _buildDownloadButton();
      
      case DownloadStatus.downloading:
        return _buildDownloadingWidget(book);
      
      case DownloadStatus.paused:
        return _buildPausedWidget(book);
      
      case DownloadStatus.downloaded:
        return _buildDownloadedButtons();
    }
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(Icons.download),
        label: Text('下載', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        onPressed: () => controller.startDownload(),
      ),
    );
  }

  Widget _buildDownloadingWidget(Book book) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: book.downloadProgress,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
        ),
        SizedBox(height: 8),
        Text(
          '${(book.downloadProgress * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.pause),
                label: Text('暫停'),
                onPressed: () => controller.pauseDownload(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.close, color: Colors.red),
                label: Text('取消', style: TextStyle(color: Colors.red)),
                onPressed: () => controller.cancelDownload(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPausedWidget(Book book) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: book.downloadProgress,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
        ),
        SizedBox(height: 8),
        Text(
          '已暫停 ${(book.downloadProgress * 100).toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.play_arrow),
                label: Text('繼續'),
                onPressed: () => controller.startDownload(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.close, color: Colors.red),
                label: Text('取消', style: TextStyle(color: Colors.red)),
                onPressed: () => controller.cancelDownload(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadedButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: Icon(Icons.menu_book),
            label: Text('打開閱讀', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            onPressed: () => controller.openReader(),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            label: Text('刪除書籍', style: TextStyle(color: Colors.red, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red),
            ),
            onPressed: () => controller.deleteBook(),
          ),
        ),
      ],
    );
  }
}
```

---

## ✅ 驗收標準

### 功能驗收

- [ ] **F1: 信息顯示**
  - [ ] 正確顯示書籍封面（Hero 動畫）
  - [ ] 正確顯示書名、作者
  - [ ] 正確顯示語言、文件大小
  - [ ] 正確顯示書籍描述（如果有）

- [ ] **F2: 下載管理**
  - [ ] 未下載狀態顯示「下載」按鈕
  - [ ] 點擊「下載」按鈕開始下載
  - [ ] 下載中顯示進度條（實時更新）
  - [ ] 下載中顯示「暫停」和「取消」按鈕
  - [ ] 點擊「暫停」按鈕暫停下載
  - [ ] 點擊「取消」按鈕取消下載並刪除部分文件
  - [ ] 下載完成後顯示「打開閱讀」按鈕

- [ ] **F3: 閱讀功能**
  - [ ] 已下載狀態顯示「打開閱讀」按鈕
  - [ ] 點擊「打開閱讀」跳轉到閱讀器頁面
  - [ ] 傳遞正確的書籍數據

- [ ] **F4: 刪除功能**
  - [ ] 已下載狀態顯示「刪除書籍」按鈕
  - [ ] 點擊「刪除」彈出確認對話框
  - [ ] 確認後刪除本地 EPUB 文件
  - [ ] 更新書籍狀態為未下載

### 性能驗收

- [ ] **P1: 頁面加載**
  - [ ] 頁面打開時間 < 500ms
  - [ ] Hero 動畫流暢（60fps）

- [ ] **P2: 下載性能**
  - [ ] 進度條更新頻率適中（不卡頓）
  - [ ] 下載過程不阻塞 UI
  - [ ] 取消下載立即生效

- [ ] **P3: 內存管理**
  - [ ] 封面圖片正確緩存
  - [ ] 頁面退出時釋放資源
  - [ ] 無內存洩漏

### UI/UX 驗收

- [ ] **U1: 視覺設計**
  - [ ] 符合 Material Design 3 規範
  - [ ] 顏色、字體、間距符合設計規範
  - [ ] 在不同屏幕尺寸下顯示正常

- [ ] **U2: 交互反饋**
  - [ ] 按鈕點擊有 Ripple 效果
  - [ ] 狀態切換有過渡動畫
  - [ ] 錯誤提示友好且明確

- [ ] **U3: 可訪問性**
  - [ ] 所有按鈕有語義化描述
  - [ ] 支持動態字體大小
  - [ ] 顏色對比度符合 WCAG 2.1 AA 標準

### 錯誤處理驗收

- [ ] **E1: 網絡錯誤**
  - [ ] 無網絡時禁用下載按鈕
  - [ ] 下載失敗顯示錯誤提示
  - [ ] 提供重試機制

- [ ] **E2: 文件錯誤**
  - [ ] 存儲空間不足時提示用戶
  - [ ] 刪除失敗顯示錯誤提示

- [ ] **E3: 數據錯誤**
  - [ ] 書籍數據缺失時顯示默認值
  - [ ] 本地文件損壞時提示重新下載

---

## 🧪 測試計劃

### Unit Tests

```dart
// test/presentation/controllers/book_detail_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';

void main() {
  late BookDetailController controller;
  late MockDownloadService mockDownloadService;
  late MockBookRepository mockBookRepository;

  setUp(() {
    mockDownloadService = MockDownloadService();
    mockBookRepository = MockBookRepository();
    controller = BookDetailController(mockDownloadService, mockBookRepository);
    
    // 設置測試書籍
    final testBook = Book(
      id: 'test-id',
      title: '測試書籍',
      author: '測試作者',
      coverUrl: 'https://example.com/cover.jpg',
      epubUrl: 'https://example.com/book.epub',
      description: '這是一本測試書籍',
      language: '繁體中文',
      fileSizeBytes: 2500000,
    );
    
    Get.testMode = true;
    controller.book = Rx<Book>(testBook);
  });

  group('startDownload', () {
    test('should update status to downloading', () async {
      // Arrange
      when(mockDownloadService.downloadBook(
        bookId: any,
        url: any,
        onProgress: any,
      )).thenAnswer((_) async => '/path/to/book.epub');

      // Act
      await controller.startDownload();

      // Assert
      expect(controller.book.value.downloadStatus, DownloadStatus.downloading);
    });

    test('should update progress during download', () async {
      // Arrange
      double? capturedProgress;
      when(mockDownloadService.downloadBook(
        bookId: any,
        url: any,
        onProgress: any,
      )).thenAnswer((invocation) async {
        final onProgress = invocation.namedArguments[Symbol('onProgress')] as Function(double);
        onProgress(0.5);
        return '/path/to/book.epub';
      });

      // Act
      await controller.startDownload();

      // Assert
      expect(controller.book.value.downloadProgress, 0.5);
    });

    test('should update status to downloaded on success', () async {
      // Arrange
      when(mockDownloadService.downloadBook(
        bookId: any,
        url: any,
        onProgress: any,
      )).thenAnswer((_) async => '/path/to/book.epub');

      // Act
      await controller.startDownload();

      // Assert
      expect(controller.book.value.downloadStatus, DownloadStatus.downloaded);
      expect(controller.book.value.localPath, '/path/to/book.epub');
      expect(controller.book.value.downloadedAt, isNotNull);
    });

    test('should handle download failure', () async {
      // Arrange
      when(mockDownloadService.downloadBook(
        bookId: any,
        url: any,
        onProgress: any,
      )).thenThrow(DownloadFailedException('Network error'));

      // Act
      await controller.startDownload();

      // Assert
      expect(controller.book.value.downloadStatus, DownloadStatus.failed);
    });
  });

  group('deleteBook', () {
    test('should delete local file and reset status', () async {
      // Arrange
      controller.book.value.downloadStatus = DownloadStatus.downloaded;
      controller.book.value.localPath = '/path/to/book.epub';
      
      when(mockDownloadService.deleteBook(any)).thenAnswer((_) async {});

      // Act (模擬用戶確認)
      // 實際測試中需要 mock Get.dialog
      
      // Assert
      // 驗證 deleteBook 被調用
    });
  });
}
```

### Widget Tests

```dart
// test/presentation/pages/book_detail_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late BookDetailController controller;
  late Book testBook;

  setUp(() {
    testBook = Book(
      id: 'test-id',
      title: '一夢漫言',
      author: '見月老人',
      coverUrl: 'https://example.com/cover.jpg',
      epubUrl: 'https://example.com/book.epub',
      description: '余於庚午歲，遊居金陵...',
      language: '繁體中文',
      fileSizeBytes: 2500000,
    );

    controller = Get.put(BookDetailController(
      MockDownloadService(),
      MockBookRepository(),
    ));
    controller.book = Rx<Book>(testBook);
  });

  testWidgets('should display book information', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: BookDetailPage(),
      ),
    );

    expect(find.text('一夢漫言'), findsOneWidget);
    expect(find.text('見月老人'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
    expect(find.text('2.4 MB'), findsOneWidget);
  });

  testWidgets('should show download button when not downloaded', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: BookDetailPage(),
      ),
    );

    expect(find.text('下載'), findsOneWidget);
    expect(find.byIcon(Icons.download), findsOneWidget);
  });

  testWidgets('should show progress when downloading', (tester) async {
    controller.book.value.downloadStatus = DownloadStatus.downloading;
    controller.book.value.downloadProgress = 0.65;
    controller.book.refresh();

    await tester.pumpWidget(
      GetMaterialApp(
        home: BookDetailPage(),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('暫停'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
  });

  testWidgets('should show read button when downloaded', (tester) async {
    controller.book.value.downloadStatus = DownloadStatus.downloaded;
    controller.book.value.localPath = '/path/to/book.epub';
    controller.book.refresh();

    await tester.pumpWidget(
      GetMaterialApp(
        home: BookDetailPage(),
      ),
    );

    expect(find.text('打開閱讀'), findsOneWidget);
    expect(find.text('刪除書籍'), findsOneWidget);
  });

  testWidgets('should trigger download on button tap', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: BookDetailPage(),
      ),
    );

    await tester.tap(find.text('下載'));
    await tester.pump();

    // 驗證 startDownload 被調用
    verify(controller.startDownload()).called(1);
  });
}
```

### Integration Tests

```dart
// integration_test/book_detail_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Book Detail Flow', () {
    testWidgets('complete download and read flow', (tester) async {
      // 1. 啟動應用
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 2. 點擊書籍列表中的第一本書
      await tester.tap(find.byType(BookCard).first);
      await tester.pumpAndSettle();

      // 3. 驗證進入詳情頁
      expect(find.text('書籍詳情'), findsOneWidget);

      // 4. 點擊下載按鈕
      await tester.tap(find.text('下載'));
      await tester.pump();

      // 5. 等待下載完成（最多 30 秒）
      await tester.pumpAndSettle(Duration(seconds: 30));

      // 6. 驗證顯示「打開閱讀」按鈕
      expect(find.text('打開閱讀'), findsOneWidget);

      // 7. 點擊打開閱讀
      await tester.tap(find.text('打開閱讀'));
      await tester.pumpAndSettle();

      // 8. 驗證進入閱讀器頁面
      expect(find.byType(ReaderPage), findsOneWidget);
    });

    testWidgets('cancel download flow', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 進入詳情頁
      await tester.tap(find.byType(BookCard).first);
      await tester.pumpAndSettle();

      // 開始下載
      await tester.tap(find.text('下載'));
      await tester.pump(Duration(seconds: 1));

      // 點擊取消
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 驗證回到未下載狀態
      expect(find.text('下載'), findsOneWidget);
    });

    testWidgets('delete book flow', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 假設書籍已下載，進入詳情頁
      await tester.tap(find.byType(BookCard).first);
      await tester.pumpAndSettle();

      // 點擊刪除
      await tester.tap(find.text('刪除書籍'));
      await tester.pumpAndSettle();

      // 確認刪除
      await tester.tap(find.text('刪除'));
      await tester.pumpAndSettle();

      // 驗證回到未下載狀態
      expect(find.text('下載'), findsOneWidget);
    });
  });
}
```

---

## 📦 依賴項

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 狀態管理
  get: ^4.6.6
  
  # 本地存儲
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1
  
  # 網絡請求
  dio: ^5.3.3
  
  # 圖片緩存
  cached_network_image: ^3.3.0
  
  # UI
  flutter_spinkit: ^5.2.0  # 加載動畫（可選）

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # 測試
  mockito: ^5.4.2
  build_runner: ^2.4.6
  integration_test:
    sdk: flutter
  
  # Hive 代碼生成
  hive_generator: ^2.0.1
```

### 生成 Hive Adapters

```bash
flutter pub run build_runner build
```

---

## 🚀 實現步驟

### Day 1: 數據層實現 (4-5 小時)

1. **擴展 Book 模型** (1 小時)
   - [ ] 添加 `description`, `language`, `fileSizeBytes` 字段
   - [ ] 添加 `downloadStatus`, `downloadProgress`, `localPath`, `downloadedAt`
   - [ ] 實現 `fileSizeFormatted` getter
   - [ ] 重新生成 Hive adapters

2. **創建 DownloadStatus 枚舉** (30 分鐘)
   - [ ] 定義 5 個狀態
   - [ ] 添加 Hive 註解
   - [ ] 生成 adapter

3. **實現 DownloadService** (2-3 小時)
   - [ ] 實現 `downloadBook` 方法
   - [ ] 實現進度回調
   - [ ] 實現 `cancelDownload` 方法
   - [ ] 實現 `deleteBook` 方法
   - [ ] 實現異常處理
   - [ ] 編寫 Unit Tests

4. **更新 BookRepository** (30 分鐘)
   - [ ] 添加 `updateBook` 方法
   - [ ] 測試更新功能

### Day 2: 控制器與頁面實現 (5-6 小時)

1. **實現 BookDetailController** (2-3 小時)
   - [ ] 實現 `startDownload` 方法
   - [ ] 實現 `pauseDownload` 方法
   - [ ] 實現 `cancelDownload` 方法
   - [ ] 實現 `deleteBook` 方法
   - [ ] 實現 `openReader` 方法
   - [ ] 編寫 Unit Tests

2. **實現 BookDetailPage** (3 小時)
   - [ ] 實現頁面佈局
   - [ ] 實現 Hero 動畫
   - [ ] 實現三種下載狀態 UI
   - [ ] 實現確認對話框
   - [ ] 編寫 Widget Tests

### Day 3: 集成測試與優化 (4-5 小時)

1. **集成測試** (2 小時)
   - [ ] 編寫完整下載流程測試
   - [ ] 編寫取消下載測試
   - [ ] 編寫刪除書籍測試
   - [ ] 測試錯誤處理

2. **UI 優化** (1-2 小時)
   - [ ] 調整動畫時長
   - [ ] 優化進度條顯示
   - [ ] 調整顏色和間距
   - [ ] 響應式佈局測試

3. **錯誤處理優化** (1 小時)
   - [ ] 改進錯誤提示文案
   - [ ] 添加重試機制
   - [ ] 處理邊界情況

4. **文檔與截圖** (30 分鐘)
   - [ ] 更新 README
   - [ ] 截取頁面截圖
   - [ ] 記錄已知問題

---

## 🐛 已知問題與限制

### 當前限制

1. **單任務下載**: 一次只能下載一本書（多任務下載在 Spec 07 實現）
2. **無斷點續傳**: 暫停後重新下載會從頭開始（後續優化）
3. **無下載隊列**: 不支持排隊下載（Spec 07 實現）

### 潛在問題

1. **大文件下載**: 超大 EPUB (>50MB) 可能需要優化
2. **網絡切換**: Wi-Fi 切換到移動數據可能中斷
3. **存儲空間**: 未檢查可用存儲空間

---

## 📚 參考資料

- [Dio 官方文檔](https://pub.dev/packages/dio)
- [path_provider 文檔](https://pub.dev/packages/path_provider)
- [Hero 動畫指南](https://docs.flutter.dev/ui/animations/hero-animations)
- [Material Design 3 - Cards](https://m3.material.io/components/cards/overview)
- [GetX 狀態管理](https://pub.dev/packages/get)

---

## 🎯 下一步

完成 Spec 03 後，執行：

```bash
/speckit.tasks 03
```

然後開始實現 **Spec 04: EPUB 閱讀器** 🚀

---

**規格版本**: 1.0  
**創建日期**: 2025-11-07  
**狀態**: 📝 待審查

