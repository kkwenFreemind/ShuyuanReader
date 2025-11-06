# 書苑閱讀器 APP 實施檢查清單

## 📚 系統架構說明

**核心設計**：書苑閱讀器採用「GitHub 內容託管 + APP 本地緩存」的架構

```text
GitHub Repository (內容源)
  ├── catalog/books.json    ← 書籍元數據 (50KB)
  ├── covers/*.png          ← 100+ 封面圖片
  └── epub3/*.epub          ← 100+ 電子書文件
            ↓
      HTTPS 按需下載
            ↓
Android APP (智能緩存層)
  ├── Hive 數據庫           ← 書籍元數據 + 狀態
  ├── files/books/         ← 用戶下載的 EPUB
  └── cache/covers/        ← 自動緩存的封面
```

> 📖 **詳細架構設計請參閱**：[storage_architecture.md](./storage_architecture.md)

---

## 快速導航

- [優先級矩陣](#優先級矩陣)
- [Phase 1: MVP 開發](#phase-1-mvp-開發-4-6週)
- [Phase 2: 功能增強](#phase-2-功能增強-4-6週)
- [Phase 3: 發布準備](#phase-3-發布準備-2-4週)
- [關鍵決策點](#關鍵決策點)

---

## 優先級矩陣

根據**重要性**和**緊急性**劃分的功能優先級：

### 🔴 P0 - 必須有（MVP 基礎）
- ✅ 書籍列表顯示（GridView/ListView）
- ✅ 下載 books.json 並解析
- ✅ 下載 EPUB 文件
- ✅ 基本 EPUB 閱讀器
- ✅ 本地存儲管理
- ✅ 離線模式（緩存 books.json）
- ✅ 基本錯誤處理

### 🟠 P1 - 應該有（用戶體驗）
- ⬜ 下載進度顯示
- ⬜ 暫停/恢復下載
- ⬜ 已下載書籍管理
- ⬜ 閱讀進度保存
- ⬜ 書籤功能
- ⬜ 搜索書籍
- ⬜ 網絡錯誤重試機制
- ⬜ 圖片緩存

### 🟡 P2 - 可以有（增強功能）
- ⬜ 高亮和筆記
- ⬜ 閱讀設置（字體、主題）
- ⬜ 過濾和排序
- ⬜ 目錄導航
- ⬜ 夜間模式
- ⬜ 閱讀統計
- ⬜ 文件完整性校驗（MD5）
- ⬜ 後台下載

### 🟢 P3 - 未來迭代（高級功能）
- ⬜ 雲同步
- ⬜ 社區分享
- ⬜ 多語言界面
- ⬜ 平板適配
- ⬜ iOS 版本
- ⬜ 數據分析
- ⬜ 推送通知

---

## Phase 1: MVP 開發 (4-6週)

### Week 1-2: 項目搭建與基礎功能

#### ✅ 項目初始化
- [ ] 創建 Flutter 項目
  ```bash
  flutter create --org com.shuyuan shuyuan_reader
  cd shuyuan_reader
  ```
- [ ] 配置 `pubspec.yaml`（核心依賴）
  ```yaml
  dependencies:
    get: ^4.6.5
    dio: ^5.3.3
    hive: ^2.2.3
    hive_flutter: ^1.1.0
    path_provider: ^2.1.1
    cached_network_image: ^3.3.0
    epub_view: ^3.1.0
  ```
- [ ] 設置項目結構（按架構圖組織文件夾）
- [ ] 配置 Android 權限（`AndroidManifest.xml`）

#### ✅ 網絡層實現
- [ ] 創建 `ApiClient` (使用 Dio)
  ```dart
  class ApiClient {
    static const baseUrl = 'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main';
    late Dio dio;
    
    ApiClient() {
      dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 30),
      ));
    }
    
    Future<String> fetchBooksJson() async {
      final response = await dio.get('/catalog/books.json');
      return response.data;
    }
  }
  ```
- [ ] 實現錯誤處理（`DioException`）
- [ ] 添加日誌攔截器（開發環境）

#### ✅ 數據模型
- [ ] 創建 `Book` 模型（對應 books.json）
  ```dart
  @HiveType(typeId: 0)
  class Book {
    @HiveField(0)
    final String id;
    
    @HiveField(1)
    final String title;
    
    @HiveField(2)
    final String author;
    
    @HiveField(3)
    final String language;
    
    @HiveField(4)
    final String coverUrl;
    
    @HiveField(5)
    final String epubUrl;
    
    @HiveField(6)
    String? localEpubPath;
    
    @HiveField(7)
    String? localCoverPath;
    
    @HiveField(8)
    DownloadStatus downloadStatus;
    
    @HiveField(9)
    double downloadProgress;
    
    Book({
      required this.id,
      required this.title,
      required this.author,
      required this.language,
      required this.coverUrl,
      required this.epubUrl,
      this.localEpubPath,
      this.localCoverPath,
      this.downloadStatus = DownloadStatus.notDownloaded,
      this.downloadProgress = 0.0,
    });
    
    factory Book.fromJson(Map<String, dynamic> json) {
      return Book(
        id: json['id'],
        title: json['title'],
        author: json['author'] ?? '未知作者',
        language: json['language'] ?? 'zh-TW',
        coverUrl: json['cover_url'],
        epubUrl: json['epub_url'],
      );
    }
  }
  
  @HiveType(typeId: 1)
  enum DownloadStatus {
    @HiveField(0)
    notDownloaded,
    
    @HiveField(1)
    downloading,
    
    @HiveField(2)
    downloaded,
    
    @HiveField(3)
    error,
  }
  ```
- [ ] 運行 `build_runner` 生成 Hive 適配器
  ```bash
  flutter packages pub run build_runner build
  ```

#### ✅ 本地存儲
- [ ] 初始化 Hive
  ```dart
  Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(DownloadStatusAdapter());
    await Hive.openBox<Book>('books');
  }
  ```
- [ ] 創建 `LocalDatabase` 服務
- [ ] 實現緩存管理（SharedPreferences）

### Week 3-4: 核心功能實現

#### ✅ 書籍列表頁面
- [ ] 創建 `HomePage` Widget
- [ ] 實現 `BookController` (GetX)
  ```dart
  class BookController extends GetxController {
    final books = <Book>[].obs;
    final isLoading = false.obs;
    final errorMessage = ''.obs;
    
    @override
    void onInit() {
      super.onInit();
      loadBooks();
    }
    
    Future<void> loadBooks() async {
      isLoading.value = true;
      try {
        // 1. 嘗試從網絡加載
        final json = await apiClient.fetchBooksJson();
        final data = jsonDecode(json);
        final booksList = (data['books'] as List)
            .map((b) => Book.fromJson(b))
            .toList();
        
        // 2. 保存到本地
        final box = Hive.box<Book>('books');
        await box.clear();
        await box.addAll(booksList);
        
        books.value = booksList;
      } catch (e) {
        // 3. 失敗時從本地加載
        final box = Hive.box<Book>('books');
        books.value = box.values.toList();
        
        if (books.isEmpty) {
          errorMessage.value = '無法加載書籍列表';
        }
      } finally {
        isLoading.value = false;
      }
    }
    
    Future<void> refresh() => loadBooks();
  }
  ```
- [ ] 實現 GridView 顯示
  ```dart
  GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 0.7,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    itemCount: controller.books.length,
    itemBuilder: (context, index) {
      final book = controller.books[index];
      return BookCard(book: book);
    },
  );
  ```
- [ ] 創建 `BookCard` 組件（顯示封面、標題、作者）
- [ ] 添加下拉刷新（RefreshIndicator）

#### ✅ 下載管理
- [ ] 創建 `DownloadManager` 服務
  ```dart
  class DownloadManager {
    final Dio dio = Dio();
    
    Future<void> downloadEPUB(Book book) async {
      try {
        // 更新狀態為下載中
        book.downloadStatus = DownloadStatus.downloading;
        await _updateBook(book);
        
        // 獲取保存路徑
        final appDir = await getApplicationDocumentsDirectory();
        final savePath = '${appDir.path}/books/${book.id}.epub';
        
        // 確保目錄存在
        await Directory('${appDir.path}/books').create(recursive: true);
        
        // 下載文件
        await dio.download(
          book.epubUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              book.downloadProgress = received / total;
              _updateBook(book);
            }
          },
        );
        
        // 更新狀態為已下載
        book.localEpubPath = savePath;
        book.downloadStatus = DownloadStatus.downloaded;
        book.downloadProgress = 1.0;
        await _updateBook(book);
        
      } catch (e) {
        book.downloadStatus = DownloadStatus.error;
        await _updateBook(book);
        rethrow;
      }
    }
    
    Future<void> _updateBook(Book book) async {
      final box = Hive.box<Book>('books');
      final index = box.values.toList().indexWhere((b) => b.id == book.id);
      if (index != -1) {
        await box.putAt(index, book);
      }
    }
  }
  ```
- [ ] 實現下載進度顯示
- [ ] 添加下載錯誤處理

#### ✅ EPUB 閱讀器
- [ ] 創建 `ReaderPage` Widget
- [ ] 集成 `epub_view` 包
  ```dart
  class ReaderPage extends StatefulWidget {
    final Book book;
    const ReaderPage({required this.book});
    
    @override
    State<ReaderPage> createState() => _ReaderPageState();
  }
  
  class _ReaderPageState extends State<ReaderPage> {
    late EpubController _epubController;
    
    @override
    void initState() {
      super.initState();
      _epubController = EpubController(
        document: EpubDocument.openFile(File(widget.book.localEpubPath!)),
      );
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.book.title),
        ),
        body: EpubView(
          controller: _epubController,
        ),
      );
    }
    
    @override
    void dispose() {
      _epubController.dispose();
      super.dispose();
    }
  }
  ```
- [ ] 實現基本閱讀功能（翻頁、滾動）

### Week 5-6: 優化與測試

#### ✅ 離線模式
- [ ] 實現 books.json 緩存（SharedPreferences）
- [ ] 檢測網絡狀態（connectivity_plus）
- [ ] 離線時從緩存加載

#### ✅ 錯誤處理
- [ ] 全局錯誤捕獲
  ```dart
  void main() {
    FlutterError.onError = (details) {
      print('Flutter Error: ${details.exception}');
    };
    
    runZonedGuarded(
      () => runApp(MyApp()),
      (error, stackTrace) {
        print('Uncaught Error: $error');
      },
    );
  }
  ```
- [ ] 用戶友好錯誤提示
- [ ] 網絡錯誤重試機制

#### ✅ UI 優化
- [ ] 添加加載動畫（shimmer）
- [ ] 優化封面圖片加載（cached_network_image）
- [ ] 空狀態提示（無書籍時）
- [ ] 響應式布局（手機適配）

#### ✅ 基本測試
- [ ] 單元測試（數據模型）
- [ ] Widget 測試（BookCard）
- [ ] 集成測試（下載流程）
- [ ] 真機測試（至少 3 台不同設備）

---

## Phase 2: 功能增強 (4-6週)

### Week 7-8: 書籍管理

#### ⬜ 本地書庫頁面
- [ ] 創建 "已下載" Tab
- [ ] 顯示下載時間、文件大小
- [ ] 實現刪除功能
  ```dart
  Future<void> deleteBook(Book book) async {
    final file = File(book.localEpubPath!);
    if (await file.exists()) {
      await file.delete();
    }
    
    book.localEpubPath = null;
    book.downloadStatus = DownloadStatus.notDownloaded;
    book.downloadProgress = 0.0;
    
    await _updateBook(book);
  }
  ```

#### ⬜ 搜索功能
- [ ] 添加 SearchBar
- [ ] 實現全文搜索（書名、作者）
  ```dart
  List<Book> searchBooks(String query) {
    return books.where((book) {
      return book.title.contains(query) ||
             book.author.contains(query);
    }).toList();
  }
  ```
- [ ] 搜索歷史記錄

#### ⬜ 過濾和排序
- [ ] 創建 FilterDialog
- [ ] 實現過濾（已下載/未下載、語言）
- [ ] 實現排序（書名、作者、下載時間）

#### ⬜ 閱讀進度
- [ ] 創建 `ReadingProgress` 模型
  ```dart
  @HiveType(typeId: 2)
  class ReadingProgress {
    @HiveField(0)
    String bookId;
    
    @HiveField(1)
    String cfi;  // EPUB CFI 位置
    
    @HiveField(2)
    int chapterIndex;
    
    @HiveField(3)
    double percentage;
    
    @HiveField(4)
    DateTime lastReadTime;
  }
  ```
- [ ] 自動保存閱讀位置（定時器）
- [ ] 打開書籍時恢復位置

#### ⬜ 書籤功能
- [ ] 創建 `Bookmark` 模型
- [ ] 添加書籤按鈕
- [ ] 書籤列表頁面
- [ ] 跳轉到書籤位置

### Week 9-10: 閱讀器增強

#### ⬜ 閱讀設置
- [ ] 創建 SettingsBottomSheet
- [ ] 字體大小調整（Slider）
- [ ] 字體類型選擇
- [ ] 行距調整
- [ ] 頁邊距設置
- [ ] 保存設置到 SharedPreferences

#### ⬜ 主題切換
- [ ] 實現日間/夜間模式
  ```dart
  enum ThemeType { light, dark, sepia, eyeCare }
  
  ThemeData getTheme(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return ThemeData.light();
      case ThemeType.dark:
        return ThemeData.dark();
      case ThemeType.sepia:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Color(0xFFF5E6D3),
        );
      case ThemeType.eyeCare:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Color(0xFFCCE8CC),
        );
    }
  }
  ```
- [ ] 根據系統自動切換

#### ⬜ 高亮和筆記
- [ ] 選中文字顯示菜單
- [ ] 添加高亮功能（多種顏色）
- [ ] 添加筆記功能
- [ ] 高亮列表頁面

#### ⬜ 目錄導航
- [ ] 顯示章節目錄
- [ ] 跳轉到指定章節
- [ ] 顯示當前章節進度

### Week 11-12: 性能優化

#### ⬜ 圖片優化
- [ ] 實現封面緩存策略
- [ ] 懶加載（viewport 外不加載）
- [ ] 降低內存中圖片尺寸

#### ⬜ 列表優化
- [ ] 實現分頁加載（20 本/頁）
- [ ] 優化 GridView（使用 AutomaticKeepAlive）

#### ⬜ 內存監控
- [ ] 添加內存使用監控
- [ ] EPUB 解析優化（流式讀取）

#### ⬜ 動畫優化
- [ ] 頁面切換動畫
- [ ] 下載進度動畫
- [ ] 書籍卡片動畫

---

## Phase 3: 發布準備 (2-4週)

### Week 13-14: 完善功能

#### ⬜ 多語言支持
- [ ] 添加 intl 依賴
- [ ] 創建 .arb 文件（zh_TW, zh_CN, en_US）
- [ ] 替換所有硬編碼文字

#### ⬜ 設置頁面
- [ ] 關於頁面（版本號、開發者信息）
- [ ] 隱私政策頁面
- [ ] 免責聲明頁面
- [ ] 清除緩存功能
- [ ] 存儲空間顯示

#### ⬜ 用戶反饋
- [ ] 添加反饋按鈕
- [ ] 集成郵件/GitHub Issues

#### ⬜ 完整測試
- [ ] 不同屏幕尺寸測試（小屏、大屏、平板）
- [ ] 不同 Android 版本測試（API 21+）
- [ ] 低端設備測試
- [ ] 網絡異常測試（飛行模式、慢速網絡）

### Week 15-16: 發布

#### ⬜ 應用資源
- [ ] 設計應用圖標（512x512、192x192、72x72）
- [ ] 設計啟動頁（SplashScreen）
- [ ] 準備商店截圖（至少 4 張）
- [ ] 準備宣傳橫幅（1024x500）

#### ⬜ Google Play 準備
- [ ] 填寫應用說明（繁中、簡中、英文）
- [ ] 設置內容評級
- [ ] 撰寫隱私政策（託管在 GitHub Pages）
- [ ] 創建開發者賬號（$25 註冊費）

#### ⬜ 應用打包
- [ ] 生成簽名密鑰
  ```bash
  keytool -genkey -v -keystore ~/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias shuyuan
  ```
- [ ] 配置 `android/key.properties`
- [ ] 編譯 Release APK
  ```bash
  flutter build apk --release
  ```
- [ ] 生成 AAB（App Bundle）
  ```bash
  flutter build appbundle --release
  ```

#### ⬜ 內部測試
- [ ] 上傳到 Google Play Console（內部測試軌道）
- [ ] 邀請 5-10 位測試者
- [ ] 收集反饋並修復問題
- [ ] 至少測試 1 週

#### ⬜ 正式發布
- [ ] 提交到生產軌道
- [ ] 等待審核（通常 1-3 天）
- [ ] 發布到 Google Play

---

## 關鍵決策點

### 1. EPUB 閱讀器選擇

**選項 A：使用 epub_view 包（推薦）**
- ✅ 優點：開箱即用、功能完整、社區支持
- ❌ 缺點：定制化受限

**選項 B：自行實現**
- ✅ 優點：完全控制、高度定制
- ❌ 缺點：開發時間長、複雜度高

**建議：MVP 使用 epub_view，後續根據需求考慮定制**

### 2. 狀態管理

**選項 A：GetX（推薦）**
- ✅ 輕量、簡單、性能好
- ✅ 內建路由和依賴注入

**選項 B：Provider**
- ✅ 官方推薦
- ❌ 代碼較繁瑣

**選項 C：Riverpod**
- ✅ 類型安全、測試友好
- ❌ 學習曲線陡峭

**建議：使用 GetX，適合中小型項目**

### 3. 本地數據庫

**選項 A：Hive（推薦）**
- ✅ 純 Dart、快速、易用
- ✅ 支持複雜對象

**選項 B：SQLite (sqflite)**
- ✅ 功能強大、SQL 查詢
- ❌ 較重、需要寫 SQL

**建議：Hive 適合此項目需求**

### 4. 圖片緩存

**選項 A：cached_network_image（推薦）**
- ✅ 功能完整、自動管理緩存
- ✅ 佔位符和錯誤處理

**選項 B：手動實現**
- ❌ 複雜度高、不推薦

**建議：使用 cached_network_image**

### 5. 更新檢測

**選項 A：定期檢查 books.json（推薦）**
- ✅ 簡單、無需服務器
- ❌ 可能不夠及時

**選項 B：使用 GitHub API**
- ✅ 實時檢測 commit
- ❌ 需要處理 API 限制

**建議：MVP 使用 HEAD 請求檢查 ETag/Last-Modified**

---

## 開發環境設置

### 必需工具
```bash
# 1. 安裝 Flutter SDK (最新穩定版)
flutter --version  # 確認版本 >= 3.13

# 2. 安裝 Android Studio
# - Android SDK
# - Android SDK Platform-Tools
# - Android SDK Build-Tools

# 3. 配置環境變量
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# 4. 檢查環境
flutter doctor -v

# 5. 啟用 Flutter Web（可選）
flutter config --enable-web
```

### 推薦 VS Code 擴展
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens
- GitLens

### 代碼規範
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    - avoid_print
    - prefer_single_quotes
```

---

## 進度追踪

### MVP 完成標準
- ✅ 用戶能瀏覽書籍列表
- ✅ 用戶能下載並閱讀 EPUB
- ✅ 離線模式正常工作
- ✅ 沒有嚴重 Bug
- ✅ 至少在 3 台不同設備測試通過

### 發布就緒標準
- ✅ 所有 P0 和 P1 功能完成
- ✅ 隱私政策和免責聲明完成
- ✅ 應用圖標和截圖準備完畢
- ✅ 內部測試通過（至少 1 週）
- ✅ 沒有崩潰和嚴重性能問題
- ✅ Google Play 商店資料填寫完整

---

## 常見問題

### Q: GitHub 下載速度慢怎麼辦？
A: 
1. 考慮使用 CDN（如 jsDelivr）
2. 添加重試機制和超時設置
3. 提供鏡像下載地址

### Q: EPUB 文件太大導致下載失敗？
A:
1. 增加超時時間
2. 實現斷點續傳
3. 壓縮 EPUB 文件

### Q: 如何處理不同 EPUB 格式？
A:
1. epub_view 包已經處理大部分格式
2. 對於特殊格式，添加錯誤處理
3. 提示用戶下載失敗原因

### Q: 內存溢出怎麼辦？
A:
1. 圖片使用 memCacheWidth/Height 限制大小
2. 列表使用分頁加載
3. EPUB 使用流式解析

---

## 資源連結

### 官方文檔
- [Flutter 官方文檔](https://flutter.dev/docs)
- [Dart 語言指南](https://dart.dev/guides)
- [Material Design](https://m3.material.io/)

### 重要依賴包
- [epub_view](https://pub.dev/packages/epub_view)
- [get](https://pub.dev/packages/get)
- [dio](https://pub.dev/packages/dio)
- [hive](https://pub.dev/packages/hive)
- [cached_network_image](https://pub.dev/packages/cached_network_image)

### 學習資源
- [Flutter 實戰](https://book.flutterchina.club/)
- [Flutter 開發者社群](https://flutter.cn/)
- [Pub.dev](https://pub.dev/)

---

## 結語

這個檢查清單是基於 MVP 優先的策略設計的。建議：

1. **嚴格按照 Phase 1 → Phase 2 → Phase 3 順序執行**
2. **每個 Phase 結束時進行回顧和測試**
3. **不要跳過測試環節**
4. **保持代碼整潔和文檔更新**
5. **頻繁提交 Git（每個功能點）**

祝開發順利！🚀
