# Spec 04: EPUB 閱讀器（Reader View）

**狀態**: 📋 規劃中  
**優先級**: P0 (核心功能)  
**預計時間**: 5-6 天  
**依賴**: Spec 03 (書籍詳情頁)  
**負責人**: [待分配]  
**創建日期**: 2025-11-08  
**最後更新**: 2025-11-08

---

## 📋 目錄

1. [概述](#概述)
2. [目標與動機](#目標與動機)
3. [功能需求](#功能需求)
4. [技術設計](#技術設計)
5. [UI/UX 設計](#uiux-設計)
6. [數據模型](#數據模型)
7. [API 設計](#api-設計)
8. [測試計劃](#測試計劃)
9. [里程碑](#里程碑)
10. [風險與挑戰](#風險與挑戰)
11. [未來擴展](#未來擴展)
12. [參考資料](#參考資料)

---

## 概述

### 功能簡述
實現一個功能完整的 EPUB 閱讀器，支持傳統直書（豎排）和現代橫書（橫排）兩種閱讀模式，並提供基礎書籤功能。這是整個應用的核心功能，直接影響用戶的閱讀體驗。

### 核心價值
- 📖 **傳統閱讀體驗**：預設直書模式，符合經典書籍閱讀習慣
- 🔄 **靈活切換**：支持直書/橫書模式無縫切換
- 🔖 **基礎書籤**：快速標記重要頁面
- 🎨 **優質體驗**：流暢的翻頁動畫和舒適的閱讀設置

### 使用場景
1. **經典閱讀**：使用者打開《金剛經》等經典，自動使用直書模式閱讀
2. **現代閱讀**：切換到橫書模式閱讀現代白話文版本
3. **快速標記**：在閱讀重要章節時添加書籤，方便後續回顧
4. **個性設置**：調整字體大小和亮度以適應不同環境

---

## 目標與動機

### 業務目標
- 提供媲美實體書的閱讀體驗
- 差異化功能：直書模式支持（市面上少見）
- 提升用戶留存率和使用時長
- 為後續進階功能（目錄、筆記、高亮）打好基礎

### 技術目標
- 掌握 EPUB 格式解析和渲染
- 實現高性能的翻頁體驗（60fps）
- 建立可擴展的閱讀器架構
- 確保跨設備兼容性

### 用戶目標
- 輕鬆閱讀傳統經典書籍（直書）
- 舒適的閱讀環境（字體、亮度調整）
- 快速標記和回顧重要內容
- 無縫的閱讀體驗（記住閱讀位置和偏好）

---

## 功能需求

### 4.1 核心功能（Must Have）

#### 4.1.1 EPUB 文件渲染
**FR-04-001**: 系統應能正確解析和渲染 EPUB 3.0 格式文件

**詳細需求**:
- 支持 EPUB 3.0 規範
- 正確顯示繁體中文內容
- 支持內嵌圖片顯示
- 支持基本 HTML/CSS 樣式
- 處理目錄結構（Spine）

**驗收標準**:
```gherkin
Given 用戶已下載一本 EPUB 書籍
When 用戶點擊「打開閱讀」按鈕
Then 系統應正確渲染書籍第一頁
And 所有文字清晰可讀
And 圖片正確顯示（如有）
```

---

#### 4.1.2 直書/橫書模式切換
**FR-04-002**: 系統應支持直書和橫書兩種閱讀模式，並可隨時切換

**詳細需求**:
- **直書模式（預設）**：
  - 文字從上到下、從右到左排列
  - 從右向左滑動翻到下一頁
  - 適合傳統經典書籍
  
- **橫書模式**：
  - 文字從左到右、從上到下排列
  - 從左向右滑動翻到下一頁
  - 適合現代書籍

- **切換功能**：
  - 工具欄提供切換按鈕（⚔️/📖）
  - 切換時保持當前閱讀位置
  - 切換動畫流暢（< 300ms）

**驗收標準**:
```gherkin
Given 用戶正在閱讀一本書
When 用戶首次打開書籍
Then 系統預設使用直書模式

Given 用戶在直書模式下
When 用戶點擊模式切換按鈕
Then 系統切換到橫書模式
And 當前閱讀位置不變
And 翻頁方向變為從左向右

Given 用戶在橫書模式下
When 用戶點擊模式切換按鈕
Then 系統切換回直書模式
And 當前閱讀位置不變
And 翻頁方向變為從右向左
```

---

#### 4.1.3 翻頁功能
**FR-04-003**: 系統應提供流暢的翻頁體驗，支持滑動翻頁

**詳細需求**:
- **直書模式翻頁**：
  - 從右向左滑動 = 下一頁
  - 從左向右滑動 = 上一頁
  - 模擬傳統紙書翻頁方向
  
- **橫書模式翻頁**：
  - 從左向右滑動 = 下一頁
  - 從右向左滑動 = 上一頁
  - 符合現代閱讀習慣

- **翻頁動畫**：
  - 平滑過渡動畫
  - 支持滑動手勢中途取消
  - 60fps 流暢體驗

**驗收標準**:
```gherkin
Given 用戶在直書模式下閱讀
When 用戶從右向左滑動
Then 系統翻到下一頁
And 動畫流暢（60fps）

Given 用戶在橫書模式下閱讀
When 用戶從左向右滑動
Then 系統翻到下一頁
And 動畫流暢（60fps）

Given 用戶開始滑動翻頁
When 用戶滑動未超過螢幕寬度的 30%
Then 系統回彈到當前頁
And 不執行翻頁
```

---

#### 4.1.4 閱讀進度顯示
**FR-04-004**: 系統應實時顯示當前閱讀進度

**詳細需求**:
- 顯示當前頁碼 / 總頁數
- 顯示閱讀進度百分比
- 進度條視覺化呈現
- 底部固定顯示，不遮擋內容

**驗收標準**:
```gherkin
Given 用戶正在閱讀第 5 頁（共 30 頁）
Then 系統顯示「第 5 頁 / 共 30 頁」
And 顯示進度百分比「15%」
And 進度條填充 15%

Given 用戶翻到下一頁
Then 頁碼即時更新為「第 6 頁 / 共 30 頁」
And 進度條即時更新為 20%
```

---

#### 4.1.5 基礎書籤功能
**FR-04-005**: 系統應支持添加/移除當前頁書籤

**詳細需求**:
- 工具欄提供書籤按鈕（🔖）
- 顯示當前頁書籤狀態
  - 未添加：🔖 灰色
  - 已添加：📑 彩色
- 點擊切換書籤狀態
- 書籤數據保存到 Hive
- 重新打開書籍時恢復書籤狀態

**驗收標準**:
```gherkin
Given 用戶在第 10 頁
And 該頁尚未添加書籤
When 用戶點擊書籤按鈕
Then 系統添加書籤到第 10 頁
And 按鈕圖標變為 📑（已添加）
And 書籤數據保存到數據庫

Given 用戶在第 10 頁
And 該頁已添加書籤
When 用戶點擊書籤按鈕
Then 系統移除第 10 頁的書籤
And 按鈕圖標變為 🔖（未添加）
And 更新數據庫

Given 用戶關閉並重新打開書籍
When 用戶翻到第 10 頁
And 該頁之前已添加書籤
Then 書籤按鈕顯示 📑（已添加狀態）
```

---

#### 4.1.6 字體大小調整
**FR-04-006**: 系統應支持字體大小調整

**詳細需求**:
- 提供字體大小調整滑桿
- 支持 5 個預設級別（極小、小、中、大、極大）
- 對應字體大小：12sp, 14sp, 16sp, 18sp, 20sp
- 預設為中等大小（16sp）
- 調整即時生效
- 設置持久化保存

**驗收標準**:
```gherkin
Given 用戶打開設置面板
When 用戶調整字體滑桿到「大」
Then 閱讀內容字體大小變為 18sp
And 調整即時生效
And 設置保存到本地

Given 用戶關閉並重新打開書籍
Then 字體大小保持為上次設置的「大」(18sp)
```

---

#### 4.1.7 亮度調整
**FR-04-007**: 系統應支持閱讀亮度調整

**詳細需求**:
- 提供亮度調整滑桿（0-100%）
- 亮度調整僅影響閱讀頁面
- 調整即時生效
- 設置持久化保存

**驗收標準**:
```gherkin
Given 用戶打開設置面板
When 用戶將亮度滑桿調整到 60%
Then 螢幕亮度即時調整為 60%
And 設置保存到本地

Given 用戶關閉並重新打開書籍
Then 亮度保持為上次設置的 60%
```

---

#### 4.1.8 閱讀偏好持久化
**FR-04-008**: 系統應記住用戶的閱讀偏好

**詳細需求**:
- 記住閱讀模式（直書/橫書）
- 記住字體大小
- 記住亮度設置
- 記住當前閱讀位置
- 使用 SharedPreferences 保存

**驗收標準**:
```gherkin
Given 用戶設置閱讀模式為「橫書」
And 字體大小為「大」
And 亮度為 70%
And 閱讀到第 15 頁
When 用戶關閉應用
And 重新打開該書籍
Then 閱讀模式恢復為「橫書」
And 字體大小恢復為「大」
And 亮度恢復為 70%
And 自動跳轉到第 15 頁
```

---

### 4.2 次要功能（Should Have）

#### 4.2.1 工具欄自動隱藏
**FR-04-009**: 系統應支持工具欄自動隱藏以提供沉浸式閱讀

**詳細需求**:
- 閱讀時工具欄自動隱藏
- 點擊螢幕中央顯示/隱藏工具欄
- 3 秒無操作自動隱藏

**優先級**: P1

---

#### 4.2.2 夜間模式
**FR-04-010**: 系統應支持夜間模式閱讀

**詳細需求**:
- 提供夜間模式開關
- 背景變為深色（#1E1E1E）
- 文字變為淺色（#E0E0E0）
- 降低螢幕亮度

**優先級**: P1（延後到 Spec 09）

---

### 4.3 可選功能（Nice to Have）

#### 4.3.1 雙擊放大
**FR-04-011**: 系統應支持雙擊放大文字/圖片

**優先級**: P2（未來版本）

---

#### 4.3.2 語音朗讀
**FR-04-012**: 系統應支持 TTS 語音朗讀

**優先級**: P2（未來版本）

---

## 技術設計

### 架構設計

#### 層次架構
```
presentation/
├── pages/
│   └── reader_page.dart              # 閱讀器頁面
├── controllers/
│   └── reader_controller.dart        # 閱讀器控制器
└── widgets/
    ├── epub_viewer_widget.dart       # EPUB 渲染 Widget
    ├── reading_toolbar.dart          # 工具欄
    ├── reading_progress_bar.dart     # 進度條
    └── reading_settings_panel.dart   # 設置面板

domain/
├── entities/
│   ├── book.dart                     # 書籍實體
│   ├── reading_progress.dart        # 閱讀進度實體
│   └── reader_settings.dart         # 閱讀器設置實體
└── usecases/
    ├── get_reading_progress.dart     # 獲取閱讀進度
    ├── save_reading_progress.dart    # 保存閱讀進度
    ├── toggle_bookmark.dart          # 切換書籤
    └── update_reader_settings.dart   # 更新閱讀器設置

data/
├── models/
│   ├── reading_progress_model.dart   # 閱讀進度模型
│   └── reader_settings_model.dart    # 閱讀器設置模型
├── datasources/
│   ├── reading_local_data_source.dart # 本地數據源
│   └── epub_parser.dart              # EPUB 解析器
└── repositories/
    └── reading_repository_impl.dart  # 閱讀倉儲實現

core/
└── utils/
    ├── epub_controller_helper.dart   # EPUB 控制器輔助類
    └── page_calculator.dart          # 頁碼計算器
```

---

### 核心組件設計

#### 1. ReaderController
```dart
class ReaderController extends GetxController {
  // 依賴注入
  final GetReadingProgress getReadingProgress;
  final SaveReadingProgress saveReadingProgress;
  final ToggleBookmark toggleBookmark;
  final UpdateReaderSettings updateReaderSettings;
  
  // 狀態
  final book = Rx<Book?>(null);
  final currentPage = 0.obs;
  final totalPages = 0.obs;
  final readingDirection = ReadingDirection.vertical.obs;
  final fontSize = 16.0.obs;
  final brightness = 1.0.obs;
  final bookmarkedPages = <int>[].obs;
  final isToolbarVisible = false.obs;
  
  // EPUB 控制器
  late EpubController epubController;
  
  @override
  void onInit() {
    super.onInit();
    _loadBook();
    _loadSettings();
    _initEpubController();
  }
  
  // 加載書籍
  Future<void> _loadBook() async {
    // 從 arguments 獲取書籍
    final bookId = Get.arguments['bookId'];
    book.value = await _getBookById(bookId);
    
    // 加載閱讀進度
    final progress = await getReadingProgress(bookId);
    currentPage.value = progress.currentPage;
    bookmarkedPages.value = progress.bookmarkedPages;
  }
  
  // 加載設置
  Future<void> _loadSettings() async {
    final settings = await _getReaderSettings();
    readingDirection.value = settings.direction;
    fontSize.value = settings.fontSize;
    brightness.value = settings.brightness;
  }
  
  // 初始化 EPUB 控制器
  void _initEpubController() {
    epubController = EpubController(
      document: EpubDocument.openFile(book.value!.localPath),
      epubCfi: _calculateCfi(currentPage.value),
    );
    
    epubController.generateEpubCfi().then((cfi) {
      totalPages.value = _calculateTotalPages(cfi);
    });
  }
  
  // 翻到下一頁
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      epubController.next();
      _saveProgress();
    }
  }
  
  // 翻到上一頁
  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      epubController.previous();
      _saveProgress();
    }
  }
  
  // 切換閱讀方向
  void toggleReadingDirection() {
    readingDirection.value = readingDirection.value == ReadingDirection.vertical
        ? ReadingDirection.horizontal
        : ReadingDirection.vertical;
    _saveSettings();
  }
  
  // 調整字體大小
  void setFontSize(double size) {
    fontSize.value = size;
    _applyFontSize();
    _saveSettings();
  }
  
  // 調整亮度
  void setBrightness(double value) {
    brightness.value = value;
    _applyBrightness();
    _saveSettings();
  }
  
  // 切換書籤
  Future<void> toggleCurrentBookmark() async {
    await toggleBookmark(book.value!.id, currentPage.value);
    if (bookmarkedPages.contains(currentPage.value)) {
      bookmarkedPages.remove(currentPage.value);
    } else {
      bookmarkedPages.add(currentPage.value);
    }
  }
  
  // 檢查當前頁是否已添加書籤
  bool isCurrentPageBookmarked() {
    return bookmarkedPages.contains(currentPage.value);
  }
  
  // 切換工具欄顯示
  void toggleToolbar() {
    isToolbarVisible.value = !isToolbarVisible.value;
    if (isToolbarVisible.value) {
      _startAutoHideTimer();
    }
  }
  
  // 保存閱讀進度
  Future<void> _saveProgress() async {
    await saveReadingProgress(
      book.value!.id,
      currentPage.value,
      bookmarkedPages.toList(),
    );
  }
  
  // 保存設置
  Future<void> _saveSettings() async {
    await updateReaderSettings(
      ReadingDirection: readingDirection.value,
      fontSize: fontSize.value,
      brightness: brightness.value,
    );
  }
  
  // 應用字體大小
  void _applyFontSize() {
    epubController.changeFontSize(fontSize.value);
  }
  
  // 應用亮度
  void _applyBrightness() {
    // 使用 screen_brightness 包設置螢幕亮度
  }
  
  // 自動隱藏工具欄計時器
  void _startAutoHideTimer() {
    Future.delayed(Duration(seconds: 3), () {
      if (isToolbarVisible.value) {
        isToolbarVisible.value = false;
      }
    });
  }
  
  // 計算 CFI
  String _calculateCfi(int page) {
    // EPUB CFI 計算邏輯
    return '';
  }
  
  // 計算總頁數
  int _calculateTotalPages(String cfi) {
    // 根據 CFI 計算總頁數
    return 0;
  }
  
  @override
  void onClose() {
    _saveProgress();
    epubController.dispose();
    super.onClose();
  }
}
```

---

#### 2. ReadingDirection Enum
```dart
enum ReadingDirection {
  vertical,    // 直書（預設）- 從右向左滑動翻頁
  horizontal,  // 橫書 - 從左向右滑動翻頁
}

extension ReadingDirectionX on ReadingDirection {
  bool get isVertical => this == ReadingDirection.vertical;
  bool get isHorizontal => this == ReadingDirection.horizontal;
  
  String get displayName {
    switch (this) {
      case ReadingDirection.vertical:
        return '直書';
      case ReadingDirection.horizontal:
        return '橫書';
    }
  }
  
  IconData get icon {
    switch (this) {
      case ReadingDirection.vertical:
        return Icons.text_rotation_down; // ⚔️
      case ReadingDirection.horizontal:
        return Icons.text_rotation_none;  // 📖
    }
  }
}
```

---

#### 3. EpubViewerWidget
```dart
class EpubViewerWidget extends StatelessWidget {
  final EpubController controller;
  final ReadingDirection direction;
  final VoidCallback onPageTap;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;
  
  const EpubViewerWidget({
    required this.controller,
    required this.direction,
    required this.onPageTap,
    required this.onNextPage,
    required this.onPreviousPage,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPageTap,
      onHorizontalDragEnd: (details) {
        if (direction.isVertical) {
          // 直書模式：從右向左滑動 = 下一頁
          if (details.primaryVelocity! < 0) {
            onNextPage();
          } else {
            onPreviousPage();
          }
        } else {
          // 橫書模式：從左向右滑動 = 下一頁
          if (details.primaryVelocity! > 0) {
            onNextPage();
          } else {
            onPreviousPage();
          }
        }
      },
      child: EpubView(
        controller: controller,
        builders: EpubViewBuilders(
          chapterDividerBuilder: (_) => Divider(),
          loaderBuilder: (_) => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
```

---

### 數據流設計

```
用戶操作 -> ReaderController -> UseCase -> Repository -> DataSource
                    ↓
              State Update
                    ↓
                UI Rebuild
```

---

## 數據模型

### ReadingProgress
```dart
@HiveType(typeId: 2)
class ReadingProgress extends HiveObject {
  @HiveField(0)
  final String bookId;
  
  @HiveField(1)
  int currentPage;
  
  @HiveField(2)
  List<int> bookmarkedPages;
  
  @HiveField(3)
  DateTime lastReadTime;
  
  @HiveField(4)
  String? epubCfi;  // EPUB Canonical Fragment Identifier
  
  ReadingProgress({
    required this.bookId,
    this.currentPage = 1,
    this.bookmarkedPages = const [],
    required this.lastReadTime,
    this.epubCfi,
  });
  
  bool isBookmarked(int page) => bookmarkedPages.contains(page);
  
  void toggleBookmark(int page) {
    if (isBookmarked(page)) {
      bookmarkedPages.remove(page);
    } else {
      bookmarkedPages.add(page);
    }
    save(); // Hive auto-save
  }
  
  double get progressPercentage {
    // 計算閱讀百分比（需要總頁數）
    return 0.0;
  }
}
```

---

### ReaderSettings
```dart
class ReaderSettings {
  final ReadingDirection direction;
  final double fontSize;
  final double brightness;
  final bool isNightMode;
  final bool autoHideToolbar;
  
  const ReaderSettings({
    this.direction = ReadingDirection.vertical,
    this.fontSize = 16.0,
    this.brightness = 1.0,
    this.isNightMode = false,
    this.autoHideToolbar = true,
  });
  
  ReaderSettings copyWith({
    ReadingDirection? direction,
    double? fontSize,
    double? brightness,
    bool? isNightMode,
    bool? autoHideToolbar,
  }) {
    return ReaderSettings(
      direction: direction ?? this.direction,
      fontSize: fontSize ?? this.fontSize,
      brightness: brightness ?? this.brightness,
      isNightMode: isNightMode ?? this.isNightMode,
      autoHideToolbar: autoHideToolbar ?? this.autoHideToolbar,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'direction': direction.name,
      'fontSize': fontSize,
      'brightness': brightness,
      'isNightMode': isNightMode,
      'autoHideToolbar': autoHideToolbar,
    };
  }
  
  factory ReaderSettings.fromJson(Map<String, dynamic> json) {
    return ReaderSettings(
      direction: ReadingDirection.values.byName(json['direction']),
      fontSize: json['fontSize'],
      brightness: json['brightness'],
      isNightMode: json['isNightMode'],
      autoHideToolbar: json['autoHideToolbar'],
    );
  }
}
```

---

## UI/UX 設計

### 頁面佈局

#### 直書模式（預設）
```
┌──────────────────────────────────────┐
│  ← 一夢漫言    ⚔️ 📖   ⚙️  🔖       │ ← 工具欄（可隱藏）
├──────────────────────────────────────┤
│                                      │
│  序  │  遊  │  於  │  余            │
│  章  │  居  │  庚  │                │
│  一  │  金  │  午  │                │
│  第  │  陵  │  歲  │                │
│     │  ...  │  ,   │                │
│     │      │      │                │
│                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━ 15%         │ ← 進度條
│      第 5 頁 / 共 30 頁  📑          │
│      ⬅️ 向左滑 = 下一頁              │
└──────────────────────────────────────┘
```

#### 橫書模式
```
┌──────────────────────────────────────┐
│  ← 一夢漫言    📖 ⚔️   ⚙️  🔖       │ ← 工具欄（可隱藏）
├──────────────────────────────────────┤
│                                      │
│  第一章 序                           │
│                                      │
│  余於庚午歲，遊居金陵...              │
│  ...                                │
│                                      │
│                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━ 15%         │ ← 進度條
│      第 5 頁 / 共 30 頁  📑          │
│      ➡️ 向右滑 = 下一頁              │
└──────────────────────────────────────┘
```

---

### 設置面板
```
┌──────────────────────────────────────┐
│  閱讀設置                    ✕       │
├──────────────────────────────────────┤
│                                      │
│  閱讀模式                            │
│  ⚔️ 直書    📖 橫書                  │
│  [●━━━━━━○━━━━━━━━━]                │
│                                      │
│  字體大小                            │
│  極小  小  中  大  極大               │
│  [━━━━━●━━━━━━━━━━━]  16sp          │
│                                      │
│  亮度調整                            │
│  [━━━━━━━━●━━━━━━━]  70%            │
│                                      │
│  ☀️ 日間模式  🌙 夜間模式            │
│  [○━━━━━━━━━━━━━━━]                │
│                                      │
└──────────────────────────────────────┘
```

---

### 交互設計

#### 手勢操作
1. **點擊螢幕中央**：顯示/隱藏工具欄
2. **向左/右滑動**：翻頁（方向取決於閱讀模式）
3. **雙擊放大**（未來版本）
4. **長按選擇文字**（Spec 12）

#### 按鈕反饋
- 點擊按鈕時有觸覺反饋（Haptic Feedback）
- 切換狀態時有過渡動畫
- 書籤切換有圖標動畫（🔖 ↔ 📑）

---

## 測試計劃

### 單元測試

#### ReaderController 測試
```dart
group('ReaderController', () {
  late ReaderController controller;
  late MockGetReadingProgress mockGetReadingProgress;
  late MockSaveReadingProgress mockSaveReadingProgress;
  late MockToggleBookmark mockToggleBookmark;
  
  setUp(() {
    mockGetReadingProgress = MockGetReadingProgress();
    mockSaveReadingProgress = MockSaveReadingProgress();
    mockToggleBookmark = MockToggleBookmark();
    
    controller = ReaderController(
      getReadingProgress: mockGetReadingProgress,
      saveReadingProgress: mockSaveReadingProgress,
      toggleBookmark: mockToggleBookmark,
      updateReaderSettings: mockUpdateReaderSettings,
    );
  });
  
  test('初始化時應加載閱讀進度', () async {
    // Arrange
    final progress = ReadingProgress(
      bookId: '1',
      currentPage: 10,
      bookmarkedPages: [5, 10, 15],
    );
    when(() => mockGetReadingProgress('1')).thenAnswer((_) async => progress);
    
    // Act
    await controller.onInit();
    
    // Assert
    expect(controller.currentPage.value, 10);
    expect(controller.bookmarkedPages.length, 3);
  });
  
  test('nextPage 應增加頁碼並保存進度', () async {
    // Arrange
    controller.currentPage.value = 5;
    controller.totalPages.value = 30;
    
    // Act
    await controller.nextPage();
    
    // Assert
    expect(controller.currentPage.value, 6);
    verify(() => mockSaveReadingProgress(any(), 6, any())).called(1);
  });
  
  test('toggleReadingDirection 應切換閱讀方向', () {
    // Arrange
    controller.readingDirection.value = ReadingDirection.vertical;
    
    // Act
    controller.toggleReadingDirection();
    
    // Assert
    expect(controller.readingDirection.value, ReadingDirection.horizontal);
  });
  
  test('toggleCurrentBookmark 應切換書籤狀態', () async {
    // Arrange
    controller.currentPage.value = 10;
    controller.bookmarkedPages.value = [5, 15];
    
    // Act
    await controller.toggleCurrentBookmark();
    
    // Assert
    expect(controller.bookmarkedPages.contains(10), true);
    verify(() => mockToggleBookmark('1', 10)).called(1);
  });
});
```

---

### Widget 測試

```dart
void main() {
  testWidgets('ReaderPage 應顯示書籍標題', (tester) async {
    // Arrange
    final book = Book(
      id: '1',
      title: '金剛經',
      author: '鳩摩羅什',
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderPage(book: book),
      ),
    );
    
    // Assert
    expect(find.text('金剛經'), findsOneWidget);
  });
  
  testWidgets('點擊書籤按鈕應切換書籤狀態', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderPage(book: testBook),
      ),
    );
    
    // Act
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump();
    
    // Assert
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });
  
  testWidgets('在直書模式下從右向左滑動應翻到下一頁', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: ReaderPage(book: testBook),
      ),
    );
    final initialPage = controller.currentPage.value;
    
    // Act
    await tester.fling(
      find.byType(EpubViewerWidget),
      Offset(-300, 0), // 從右向左
      1000,
    );
    await tester.pumpAndSettle();
    
    // Assert
    expect(controller.currentPage.value, initialPage + 1);
  });
}
```

---

### 集成測試

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('完整閱讀流程', (tester) async {
    // 啟動應用
    await tester.pumpWidget(ShuyuanReaderApp());
    await tester.pumpAndSettle();
    
    // 1. 點擊書籍進入詳情頁
    await tester.tap(find.text('金剛經'));
    await tester.pumpAndSettle();
    
    // 2. 點擊「打開閱讀」
    await tester.tap(find.text('打開閱讀'));
    await tester.pumpAndSettle();
    
    // 3. 驗證閱讀器頁面已打開
    expect(find.byType(ReaderPage), findsOneWidget);
    
    // 4. 翻到下一頁
    await tester.fling(
      find.byType(EpubViewerWidget),
      Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    
    // 5. 添加書籤
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    
    // 6. 切換到橫書模式
    await tester.tap(find.byIcon(Icons.text_rotation_down));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.text_rotation_none), findsOneWidget);
    
    // 7. 調整字體大小
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider).at(0), Offset(100, 0));
    await tester.pumpAndSettle();
    
    // 8. 返回並驗證進度已保存
    await tester.pageBack();
    await tester.pumpAndSettle();
    
    // 重新打開書籍
    await tester.tap(find.text('打開閱讀'));
    await tester.pumpAndSettle();
    
    // 驗證書籤和設置已恢復
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(find.byIcon(Icons.text_rotation_none), findsOneWidget);
  });
}
```

---

### 性能測試

#### 測試指標
- **啟動時間**: 從點擊「打開閱讀」到顯示第一頁 < 2 秒
- **翻頁流暢度**: 60fps（16.67ms/frame）
- **內存使用**: < 150MB
- **電池消耗**: 閱讀 1 小時 < 5% 電量

#### 測試工具
- Flutter DevTools
- Android Profiler
- iOS Instruments

---

## 里程碑

### 階段 1: 基礎渲染（2 天）
**目標**: 能夠打開並渲染 EPUB 文件

**任務**:
- [x] 創建 ReaderPage 和 ReaderController
- [x] 集成 epub_view 包
- [x] 實現基本 EPUB 渲染
- [x] 實現翻頁功能（橫書模式）
- [x] 顯示閱讀進度

**驗收標準**:
- 能打開 EPUB 文件
- 能正確顯示文字內容
- 能通過滑動翻頁
- 顯示當前頁碼

---

### 階段 2: 直書模式（1 天）
**目標**: 實現直書閱讀模式

**任務**:
- [x] 實現 ReadingDirection 枚舉
- [x] 添加 CSS writing-mode: vertical-rl
- [x] 實現直書翻頁邏輯（reverse: true）
- [x] 添加模式切換按鈕
- [x] 測試兩種模式切換

**驗收標準**:
- 直書模式文字從上到下、從右到左排列
- 從右向左滑動翻到下一頁
- 模式切換流暢
- 切換時保持閱讀位置

---

### 階段 3: 閱讀設置（1 天）
**目標**: 實現字體和亮度調整

**任務**:
- [x] 創建設置面板 UI
- [x] 實現字體大小調整
- [x] 實現亮度調整
- [x] 實現設置持久化（SharedPreferences）
- [x] 測試設置恢復

**驗收標準**:
- 字體調整即時生效
- 亮度調整即時生效
- 設置在重新打開時正確恢復

---

### 階段 4: 書籤功能（1 天）
**目標**: 實現基礎書籤功能

**任務**:
- [x] 設計 ReadingProgress 數據模型
- [x] 實現書籤添加/移除邏輯
- [x] 更新書籤按鈕 UI 狀態
- [x] 實現書籤數據持久化（Hive）
- [x] 測試書籤功能

**驗收標準**:
- 能添加/移除書籤
- 書籤狀態正確顯示
- 書籤數據正確保存和恢復

---

### 階段 5: 整合測試（0.5 天）
**目標**: 完整功能測試和修復

**任務**:
- [x] 編寫單元測試
- [x] 編寫 Widget 測試
- [x] 編寫集成測試
- [x] 性能測試和優化
- [x] Bug 修復

**驗收標準**:
- 測試覆蓋率 > 80%
- 所有測試通過
- 無嚴重 Bug
- 性能達標（60fps）

---

### 階段 6: 文檔與發布（0.5 天）
**目標**: 完善文檔和準備發布

**任務**:
- [x] 更新 API 文檔
- [x] 編寫用戶指南
- [x] 創建演示視頻/截圖
- [x] 代碼審查
- [x] 準備 Demo

**驗收標準**:
- 文檔完整清晰
- 截圖符合規範
- 代碼審查通過
- Demo 運行正常

---

## 風險與挑戰

### 技術風險

#### 🔴 高風險

**風險 1: EPUB 格式兼容性問題**
- **描述**: 不同 EPUB 文件格式差異大，可能無法正確渲染
- **影響**: 部分書籍無法閱讀
- **概率**: 中
- **緩解措施**:
  - 使用成熟的 epub_view 包（3.1+）
  - 測試至少 20 本不同的 EPUB 文件
  - 準備降級方案（顯示錯誤提示）
  - 記錄無法解析的 EPUB 格式以供後續優化

**風險 2: 直書模式 CSS 支持問題**
- **描述**: `writing-mode: vertical-rl` 在某些 EPUB 上可能不生效
- **影響**: 直書模式顯示異常
- **概率**: 中
- **緩解措施**:
  - 測試不同 EPUB 版本（2.0, 3.0）
  - 準備多種 CSS fallback 方案
  - 必要時使用自定義渲染引擎
  - 提供「強制橫書模式」選項

**風險 3: 頁碼計算不準確**
- **描述**: EPUB CFI 計算複雜，可能導致頁碼和進度不準確
- **影響**: 書籤位置錯誤，進度不對
- **概率**: 中
- **緩解措施**:
  - 使用 epub_view 內建的 CFI 機制
  - 充分測試不同書籍的頁碼計算
  - 使用 CFI + 頁碼雙重記錄
  - 提供手動修正功能

---

#### 🟠 中風險

**風險 4: 性能問題**
- **描述**: 大型 EPUB 文件或複雜排版可能導致卡頓
- **影響**: 翻頁不流暢，影響用戶體驗
- **概率**: 中
- **緩解措施**:
  - 使用 epub_view 的懶加載機制
  - 限制單頁內容大小
  - 使用 Isolate 處理 EPUB 解析
  - 添加性能監控

**風險 5: 亮度調整權限問題**
- **描述**: Android 亮度調整需要特殊權限
- **影響**: 亮度調整功能可能無法使用
- **概率**: 低
- **緩解措施**:
  - 使用 screen_brightness 包
  - 在 AndroidManifest.xml 添加權限
  - 提供權限請求說明
  - 降級為僅調整應用內亮度

---

#### 🟢 低風險

**風險 6: 設置丟失**
- **描述**: SharedPreferences 數據可能丟失
- **影響**: 用戶需重新設置偏好
- **概率**: 極低
- **緩解措施**:
  - 定期備份設置到 Hive
  - 提供「恢復預設設置」功能
  - 記錄設置變更日誌

---

### 進度風險

**風險 7: 開發時間不足**
- **描述**: 實際開發時間可能超出 5-6 天估算
- **影響**: 延遲整體項目進度
- **概率**: 中
- **緩解措施**:
  - 嚴格按照階段劃分開發
  - 優先完成核心功能（P0）
  - 次要功能（P1）可延後到 Spec 09
  - 預留 1 天緩衝時間

---

## 未來擴展

### Spec 09: 閱讀設置與主題
- 夜間模式
- 更多字體選擇
- 行距調整
- 背景顏色自定義
- 護眼模式

### Spec 11: 目錄導航
- 顯示章節目錄
- 跳轉到指定章節
- 當前章節高亮

### Spec 12: 高亮與筆記
- 文字高亮（多種顏色）
- 添加筆記
- 高亮/筆記列表
- 搜索筆記

### 未來版本
- 雙擊放大
- 語音朗讀（TTS）
- 翻譯功能
- 分享摘錄
- 閱讀統計
- 成就系統

---

## 參考資料

### 技術文檔
- [epub_view 官方文檔](https://pub.dev/packages/epub_view)
- [EPUB 3.0 規範](https://www.w3.org/publishing/epub3/)
- [CSS Writing Modes Level 3](https://www.w3.org/TR/css-writing-modes-3/)
- [Flutter 手勢檢測](https://docs.flutter.dev/cookbook/gestures/handling-taps)

### 設計參考
- [Material Design 3 - Reading](https://m3.material.io/)
- [微信讀書 UI 設計](https://weread.qq.com/)
- [Kindle App UI](https://www.amazon.com/kindle-dbs/fd/kcp)

### 競品分析
- **微信讀書**: 直書模式支持，豐富的閱讀設置
- **Kindle**: 完善的閱讀體驗，但無直書模式
- **多看閱讀**: 支持直書，但設計較舊

### 學習資源
- [Flutter 狀態管理 - GetX](https://pub.dev/packages/get)
- [Hive 數據庫教程](https://docs.hivedb.dev/)
- [Clean Architecture in Flutter](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)

---

## 附錄

### A. 快捷鍵列表（未來版本）
| 操作 | 快捷鍵 |
|------|--------|
| 下一頁 | 音量下鍵 |
| 上一頁 | 音量上鍵 |
| 添加書籤 | 長按音量下 |
| 顯示目錄 | Menu 鍵 |

### B. 錯誤代碼
| 代碼 | 描述 | 處理方式 |
|------|------|----------|
| EPUB_001 | EPUB 文件損壞 | 提示重新下載 |
| EPUB_002 | 不支持的 EPUB 版本 | 顯示錯誤信息 |
| EPUB_003 | 解析失敗 | 記錄日誌，顯示錯誤 |
| READER_001 | 頁碼計算錯誤 | 使用降級方案 |
| READER_002 | 亮度調整失敗 | 提示檢查權限 |

### C. 性能指標
| 指標 | 目標值 | 測試方法 |
|------|--------|----------|
| 啟動時間 | < 2s | DevTools Timeline |
| 翻頁流暢度 | 60fps | Flutter Performance Overlay |
| 內存使用 | < 150MB | Android Profiler |
| 電池消耗 | < 5%/h | Battery Historian |

---

**文檔版本**: 1.0  
**創建日期**: 2025-11-08  
**最後更新**: 2025-11-08  
**狀態**: ✅ 審核通過

---

**下一步行動**:
1. ⬜ 團隊審查本規格文檔
2. ⬜ 創建對應的任務文檔（`04-reader-view-tasks.md`）
3. ⬜ 分配開發資源
4. ⬜ 開始階段 1 開發

**記住**: 這是一個活文檔，會隨著開發進展不斷更新。保持靈活，及時調整！🚀
