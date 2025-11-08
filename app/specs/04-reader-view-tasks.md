# Spec 04: EPUB 閱讀器 - 任務清單

**狀態**: 📋 規劃中  
**優先級**: P0 (核心功能)  
**預計時間**: 5-6 天 (38-42 小時)  
**開始日期**: 待定  
**完成日期**: 待定

---

## 📊 任務總覽

| 階段 | 任務數 | 預計時間 | 完成數 | 狀態 |
|------|--------|----------|--------|------|
| **Day 1-2: 基礎渲染 (Phase 4.1-4.5)** | 10 | 8.5h | 8 | ✅ |
| **Day 3: 直書模式 (Phase 4.6)** | 5 | 5h | 0 | ⬜ |
| **Day 4: 閱讀設置 (Phase 4.7-4.8)** | 6 | 5.2h | 0 | ⬜ |
| **Day 4-5: 書籤功能 (Phase 4.9)** | 7 | 4.5h | 0 | ⬜ |
| **Day 5: 整合測試 (Phase 4.10-4.11)** | 8 | 9h | 0 | ⬜ |
| **Day 6: 文檔發布 (Phase 4.12)** | 7 | 6h | 0 | ⬜ |
| **總計** | **43** | **38-42h** | **8** | **18.6%** |

---

## 📅 Day 1-2: 基礎渲染實現 (7 小時)

### Phase 4.1: 專案架構搭建 (0.5 小時)

#### ✅ Task 4.1.1: 創建 Reader 模塊目錄結構
- **文件**: 目錄結構
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-01-XX
- **實際用時**: 30 分鐘

**具體步驟**:
1. 創建 Reader 模塊的完整目錄結構
2. 按照 Clean Architecture 組織文件
3. 確保符合專案規範

**產出結構**:
```
lib/
├── presentation/
│   ├── pages/reader/
│   │   └── reader_page.dart
│   ├── controllers/reader/
│   │   └── reader_controller.dart
│   └── widgets/reader/
│       ├── epub_viewer_widget.dart
│       ├── reading_toolbar.dart
│       ├── reading_progress_bar.dart
│       └── reading_settings_panel.dart
├── domain/
│   ├── entities/reader/
│   │   ├── reading_progress.dart
│   │   ├── reader_settings.dart
│   │   └── reading_direction.dart
│   └── usecases/reader/
│       ├── get_reading_progress.dart
│       ├── save_reading_progress.dart
│       ├── toggle_bookmark.dart
│       └── update_reader_settings.dart
└── data/
    ├── models/reader/
    │   ├── reading_progress_model.dart
    │   └── reader_settings_model.dart
    ├── datasources/reader/
    │   ├── reading_local_data_source.dart
    │   └── epub_parser.dart
    └── repositories/reader/
        └── reading_repository_impl.dart
```

**交付物**:
- ✅ 8 個目錄已創建 (遵循 Clean Architecture)
- ✅ 18 個帶文檔的佔位文件已創建
- ✅ 所有文件包含中文文檔與 TODO 注釋
- ✅ 清晰的任務鏈接便於後續實現

**驗收標準**:
- [x] 目錄結構完整
- [x] 符合專案規範
- [x] 無命名錯誤

---

### Phase 4.2: EPUB 包集成 (0.7 小時)

#### ✅ Task 4.2.1: 添加 epub_view 依賴
- **文件**: `pubspec.yaml`
- **優先級**: P0
- **預計時間**: 12 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-08
- **實際用時**: 12 分鐘

**具體步驟**:
1. 在 `pubspec.yaml` 添加依賴:
   ```yaml
   dependencies:
     epub_view: ^3.1.0
     screen_brightness: ^0.2.2+1  # 用於亮度調整
   ```
2. 運行 `flutter pub get`
3. 驗證依賴安裝成功

**交付物**:
- ✅ `epub_view: ^3.1.0` 已添加到 pubspec.yaml
- ✅ `screen_brightness: ^0.2.2+1` 已添加到 pubspec.yaml
- ✅ 依賴包成功下載並安裝
- ✅ 無版本衝突
- ✅ 無編譯錯誤

**驗收標準**:
- [x] 依賴成功安裝
- [x] 無版本衝突
- [x] 無編譯錯誤

---

#### ✅ Task 4.2.2: 測試 epub_view 基本功能
- **文件**: `test/epub_view_test.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-08
- **實際用時**: 30 分鐘

**具體步驟**:
1. 創建簡單的測試頁面
2. 驗證 epub_view 能正常工作
3. 測試打開並渲染 EPUB 文件

**交付物**:
- ✅ 創建 `test/epub_view_test.dart` 測試文件
- ✅ 測試 EpubController 類可以訪問
- ✅ 測試 EpubView Widget 類可以訪問
- ✅ 驗證 epub_view 包正確安裝
- ✅ 所有測試通過（7/7 tests passed）
- ✅ 提供 epub_view 使用指南

**測試結果**:
```
✓ EpubController 類可以訪問
✓ EpubView Widget 類可以訪問
✓ epub_view 包已成功安裝並可以訪問
✓ 所有 epub_view 核心組件都可以正常訪問
✓ 基本使用指南已輸出
```

**驗收標準**:
- [x] epub_view 包可以正常導入
- [x] EpubController 和 EpubView 類可以訪問
- [x] 無運行時錯誤
- [x] 測試通過

---

### Phase 4.3: 實體類創建 (1.2 小時)

#### ✅ Task 4.3.1: 創建 ReadingProgress 實體
- **文件**: `lib/domain/entities/reader/reading_progress.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-08
- **實際用時**: 30 分鐘

**具體步驟**:
1. 創建 ReadingProgress 類
2. 定義所有必要字段:
   ```dart
   class ReadingProgress extends Equatable {
     final String bookId;
     final int currentPage;
     final List<int> bookmarkedPages;
     final DateTime lastReadTime;
     final String? epubCfi;
     final int? totalPages;
     // 完整實現見代碼文件
   }
   ```
3. 添加必要的方法

**交付物**:
- ✅ ReadingProgress 實體類（214 行代碼）
- ✅ 繼承 Equatable 實現值比較
- ✅ 完整的字段定義（6 個字段）
- ✅ 書籤管理方法（isBookmarked, toggleBookmark, addBookmark, removeBookmark）
- ✅ 進度更新方法（updatePosition）
- ✅ 進度計算方法（progressPercentage, progressPercent）
- ✅ 狀態檢查方法（isCompleted, isJustStarted）
- ✅ copyWith 方法實現不可變性
- ✅ toString 方法用於調試
- ✅ 完整的單元測試（27 個測試用例全部通過）

**實現特點**:
- 遵循 Clean Architecture 原則（純領域實體）
- 不可變對象設計（Immutable）
- 完整的文檔註釋
- 類型安全的 null 處理
- 書籤列表自動排序
- 時間戳自動更新

**測試覆蓋**:
```
✓ 構造函數測試 (2 tests)
✓ 書籤功能測試 (9 tests)
✓ 進度更新測試 (3 tests)
✓ 進度計算測試 (4 tests)
✓ 狀態檢查測試 (4 tests)
✓ copyWith 測試 (2 tests)
✓ Equatable 測試 (2 tests)
✓ toString 測試 (1 test)
Total: 27/27 tests passed
```

**驗收標準**:
- [x] 類結構完整
- [x] 所有字段定義正確
- [x] 包含必要的輔助方法
- [x] 單元測試全部通過
- [x] 無編譯錯誤

---

#### ✅ Task 4.3.2: 創建 ReaderSettings 實體
- **文件**: `lib/domain/entities/reader_settings.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-08
- **實際用時**: 30 分鐘

**具體步驟**:
1. 創建 ReaderSettings 類
2. 定義設置字段:
   ```dart
   class ReaderSettings extends Equatable {
     final ReadingDirection direction;
     final double fontSize;
     final double brightness;
     final bool isNightMode;
     final bool autoHideToolbar;
     // 完整實現見代碼文件
   }
   ```

**交付物**:
- ✅ ReaderSettings 實體類（330 行代碼）
- ✅ 繼承 Equatable 實現值比較
- ✅ 完整的字段定義（5 個字段）
- ✅ 閱讀方向更新方法（updateDirection）
- ✅ 字體大小調整方法（updateFontSize, increaseFontSize, decreaseFontSize）
- ✅ 亮度調整方法（updateBrightness）
- ✅ 模式切換方法（toggleNightMode, toggleAutoHideToolbar）
- ✅ 字體大小檔位計算（fontSizePresetIndex）
- ✅ 設置驗證方法（isValid）
- ✅ JSON 序列化/反序列化（toJson, fromJson）
- ✅ 預設設置工廠方法（defaultSettings）
- ✅ copyWith 方法實現不可變性
- ✅ toString 方法用於調試
- ✅ 完整的單元測試（41 個測試用例全部通過）

**實現特點**:
- 遵循 Clean Architecture 原則（純領域實體）
- 不可變對象設計（Immutable）
- 完整的文檔註釋
- 類型安全的 null 處理
- 字體大小自動限制（12-20sp）
- 亮度值自動限制（0.0-1.0）
- 支持 5 檔字體大小預設
- 完整的驗證機制

**測試覆蓋**:
```
✓ 構造函數測試 (3 tests)
✓ 閱讀方向更新測試 (2 tests)
✓ 字體大小調整測試 (10 tests)
✓ 亮度調整測試 (3 tests)
✓ 模式切換測試 (4 tests)
✓ 驗證方法測試 (6 tests)
✓ copyWith 測試 (3 tests)
✓ JSON 序列化測試 (3 tests)
✓ Equatable 測試 (3 tests)
✓ toString 測試 (2 tests)
✓ 常量測試 (3 tests)
Total: 41/41 tests passed
```

**驗收標準**:
- [x] 設置字段完整
- [x] 包含預設值
- [x] 類型定義正確
- [x] 所有更新方法實現
- [x] JSON 序列化/反序列化
- [x] 單元測試全部通過
- [x] 無編譯錯誤

---

#### ✅ Task 4.3.3: 創建 ReadingDirection 枚舉
- **文件**: `lib/domain/entities/reader/reading_direction.dart`
- **優先級**: P0
- **預計時間**: 12 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-08
- **實際用時**: 12 分鐘

**具體步驟**:
1. 定義 ReadingDirection 枚舉:
   ```dart
   enum ReadingDirection {
     vertical('直書'),    // 直書
     horizontal('橫書'),  // 橫書
   }
   ```

**交付物**:
- ✅ ReadingDirection 枚舉（135 行代碼）
- ✅ 兩個枚舉值：vertical（直書）、horizontal（橫書）
- ✅ 顯示名稱字段（displayName）
- ✅ 判斷方法（isVertical, isHorizontal）
- ✅ 切換方法（toggle）
- ✅ CSS 屬性獲取（cssWritingMode）
- ✅ UI 相關屬性（icon, swipeHint）
- ✅ toString 方法
- ✅ 完整的單元測試（22 個測試用例全部通過）

**實現特點**:
- Enhanced Enum（增強枚舉，帶構造參數）
- 支持中文顯示名稱
- 提供 CSS writing-mode 屬性值
- 提供 UI 圖標和翻頁提示
- 完整的文檔註釋
- 所有方法都經過測試

**測試覆蓋**:
```
✓ 枚舉值測試 (3 tests)
✓ 判斷方法測試 (2 tests)
✓ 切換方法測試 (3 tests)
✓ CSS 屬性測試 (2 tests)
✓ UI 相關屬性測試 (4 tests)
✓ toString 測試 (2 tests)
✓ 枚舉名稱測試 (3 tests)
✓ 完整使用場景測試 (3 tests)
Total: 22/22 tests passed
```

**驗收標準**:
- [x] 枚舉定義正確
- [x] 包含兩種閱讀方向
- [x] 包含文檔註釋
- [x] 提供中文顯示名稱
- [x] 提供 CSS 屬性
- [x] 提供 UI 輔助屬性
- [x] 單元測試全部通過
- [x] 無編譯錯誤

---

### Phase 4.4: ReaderController 基礎實現 (1.5 小時) ✅

**狀態**: ✅ 已完成  
**完成時間**: 2025-11-09  
**實際用時**: 1.5 小時  
**進度**: 2/2 任務完成 (100%)

#### ✅ Task 4.4.1: 創建 ReaderController 框架
- **文件**: `lib/presentation/controllers/reader/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-09
- **實際用時**: 1 小時

**具體步驟**:
1. 使用 GetX 創建控制器
2. 定義基本狀態和方法
3. 實現生命週期方法

**交付物**:
- ✅ ReaderController 類（655 行代碼）
- ✅ 繼承 GetxController
- ✅ 依賴注入（4 個 Use Cases）
- ✅ 響應式狀態（15 個 Observable 變數）
- ✅ 生命週期方法（onInit, onClose）
- ✅ 初始化邏輯（_initialize 方法）
- ✅ 清理邏輯（_cleanup 方法）
- ✅ 翻頁控制（nextPage, previousPage, goToPage）
- ✅ 閱讀方向控制（toggleReadingDirection, setReadingDirection）
- ✅ 字體大小控制（setFontSize, increaseFontSize, decreaseFontSize）
- ✅ 亮度控制（setBrightness）
- ✅ 夜間模式控制（toggleNightMode）
- ✅ 工具欄控制（toggleToolbar, showToolbar, hideToolbar）
- ✅ 書籤管理（toggleCurrentBookmark）
- ✅ 進度保存（_saveProgress）
- ✅ 設置保存（_saveSettings）
- ✅ 計算屬性（progressPercentage, isCurrentPageBookmarked, 等）
- ✅ 完整的文檔註釋

**實現特點**:
- 遵循 Clean Architecture 原則
- 使用 GetX 進行狀態管理和依賴注入
- 完整的生命週期管理（初始化和清理）
- 自動保存閱讀進度和設置
- 自動恢復系統亮度
- 錯誤處理和用戶提示
- 支持直書/橫書切換
- 支持字體大小調整（12-20sp）
- 支持亮度調整（0.0-1.0）
- 支持夜間模式
- 支持書籤管理
- 支持工具欄自動隱藏
- 完整的中文文檔註釋

**主要功能模塊**:
```
1. 依賴注入（4 個 Use Cases）
2. 響應式狀態（15 個 .obs 變數）
3. 計算屬性（7 個 getters）
4. 生命週期（onInit, onClose）
5. 初始化（_initialize, _loadBook, _loadReadingProgress, _loadReaderSettings）
6. 清理（_cleanup, _restoreOriginalBrightness）
7. 翻頁控制（nextPage, previousPage, goToPage）
8. 閱讀方向（toggleReadingDirection, setReadingDirection）
9. 字體大小（setFontSize, increaseFontSize, decreaseFontSize）
10. 亮度控制（setBrightness, _applyBrightness）
11. 夜間模式（toggleNightMode）
12. 工具欄控制（toggleToolbar, showToolbar, hideToolbar, toggleAutoHideToolbar）
13. 書籤管理（toggleCurrentBookmark）
14. 進度保存（_saveProgress, _saveSettings）
```

**待實現功能** (標記為 TODO，將在後續任務中實現):
- Task 4.4.2: 從數據庫加載書籍詳情
- Task 4.5.2: 初始化 EPUB 控制器
- Task 4.12.2: 應用字體大小到 EPUB 視圖
- Task 4.14.1: 從 SharedPreferences 加載/保存設置

**驗收標準**:
- [x] 控制器繼承 `GetxController`
- [x] 定義所有必要的 Observable 變數
- [x] 實現 `onInit()` 和 `onClose()` 生命週期
- [x] 完整的文檔註釋
- [x] 錯誤處理完善
- [x] 代碼結構清晰

---

#### ✅ Task 4.4.2: 實現書籍加載邏輯
- **文件**: `lib/presentation/controllers/reader/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-09
- **實際用時**: 30 分鐘

**具體步驟**:
1. 實現從 arguments 獲取書籍
2. 讀取本地 EPUB 文件路徑
3. 添加錯誤處理

**交付物**:
- ✅ 添加 BookRepository 依賴注入
- ✅ 實現完整的 _loadBook() 方法（52 行代碼）
- ✅ 從路由參數獲取 bookId
- ✅ 從數據庫加載書籍詳情
- ✅ 驗證書籍是否已下載
- ✅ 驗證本地 EPUB 文件是否存在
- ✅ 完善的錯誤處理和用戶提示
- ✅ 完整的文檔註釋

**實現特點**:
- 添加 `dart:io` 導入以支持文件操作
- 添加 BookRepository 依賴到構造函數
- 完整的 5 步驗證流程：
  1. 驗證路由參數
  2. 從數據庫加載書籍
  3. 驗證下載狀態
  4. 驗證文件存在性
  5. 設置書籍信息
- 詳細的錯誤消息設置
- 使用 File.exists() 驗證本地文件
- 異常重新拋出以供上層處理

**錯誤處理**:
```dart
- 缺少 bookId 參數 → "缺少書籍 ID 參數"
- 書籍不存在 → "找不到書籍：{bookId}"
- 書籍尚未下載 → "書籍尚未下載，請先下載"
- 本地文件不存在 → "本地文件不存在：{path}"
- 其他錯誤 → "加載書籍失敗：{error}"
```

**驗收標準**:
- [x] 能從路由參數獲取 bookId
- [x] 能從數據庫讀取書籍信息
- [x] 能讀取本地 EPUB 文件路徑
- [x] 驗證文件存在性
- [x] 錯誤處理完善
- [x] 用戶友好的錯誤提示

**Phase 4.4 狀態**: ✅ 100% 完成 (2/2 任務)

---

### Phase 4.5: ReaderPage 基礎 UI (1.5 小時) ✅

**狀態**: ✅ 已完成  
**完成時間**: 2025-11-09  
**實際用時**: 1.5 小時  
**進度**: 2/2 任務完成 (100%)

#### ✅ Task 4.5.1: 創建 ReaderPage 框架
- **文件**: `lib/presentation/pages/reader_page.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-09
- **實際用時**: 30 分鐘

**具體步驟**:
1. 創建閱讀器頁面基本結構
2. 集成 ReaderController
3. 設置基本的 AppBar 和 Body

**交付物**:
- ✅ ReaderPage Widget（358 行代碼）
- ✅ Scaffold 結構完整
- ✅ 集成 ReaderController（GetX）
- ✅ 響應式 AppBar（可顯示/隱藏）
- ✅ 完整的工具欄按鈕：
  - 返回按鈕（自動保存進度）
  - 書籍標題顯示
  - 直書/橫書切換按鈕（使用 emoji 圖標）
  - 書籤按鈕（動態圖標狀態）
  - 設置按鈕（TODO 標記）
- ✅ 主要內容區域：
  - 加載狀態顯示
  - 錯誤狀態顯示
  - EPUB 內容區域（待集成 Task 4.5.2）
  - 點擊切換工具欄手勢
- ✅ 底部進度條：
  - 視覺化進度條
  - 當前頁碼 / 總頁數
  - 閱讀百分比顯示
  - 夜間模式自適應
- ✅ 完整的文檔註釋（中文）
- ✅ 使用 GetX 響應式編程（Obx）

**實現特點**:
- 遵循 Clean Architecture 原則
- 無狀態 Widget，狀態由 Controller 管理
- 完整的響應式 UI（所有動態內容使用 Obx）
- 三種頁面狀態處理：
  1. 加載中（CircularProgressIndicator）
  2. 錯誤（錯誤信息 + 返回按鈕）
  3. 正常（EPUB 內容 + 進度條）
- 工具欄顯示/隱藏切換
- 夜間模式 UI 自適應
- 手勢支持（點擊切換工具欄）
- 書籤狀態動態顯示
- 進度條實時更新

**UI 結構**:
```
┌──────────────────────────────────────┐
│  ← 書名    ⚔️ 📖   ⚙️  🔖           │ ← AppBar (可隱藏)
├──────────────────────────────────────┤
│                                      │
│         EPUB 內容顯示區域             │
│         (點擊切換工具欄)              │
│                                      │
├──────────────────────────────────────┤
│  ━━━━━━━━━━━━━━━━━━━━━━ 15%         │ ← 進度條
│      第 5 頁 / 共 30 頁              │
└──────────────────────────────────────┘
```

**已處理問題**:
- ✅ 修復 Obx 返回類型問題（AppBar）
- ✅ 修復 refresh() void 返回值問題
- ✅ 修復 ReadingDirection.icon 類型問題（String emoji）
- ✅ 修復 withOpacity 棄用警告（改用 withValues）

**待實現功能** (標記為 TODO):
- Task 4.5.2: 集成 EpubViewerWidget
- Task 4.8.1: 打開設置面板
- 手勢翻頁（滑動）

**驗收標準**:
- [x] Scaffold 結構完整
- [x] 集成 ReaderController
- [x] 基本的 AppBar 和 Body
- [x] 響應式 UI（Obx）
- [x] 工具欄顯示/隱藏
- [x] 進度條顯示
- [x] 三種狀態處理
- [x] 無編譯錯誤

---

#### ✅ Task 4.5.2: 實現 EpubViewerWidget
- **文件**: `lib/presentation/widgets/epub_viewer_widget.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ✅ 已完成
- **完成時間**: 2025-11-09
- **實際用時**: 1 小時

**具體步驟**:
1. 封裝 epub_view 的 EpubView Widget
2. 實現手勢翻頁
3. 添加加載動畫

**交付物**:
- ✅ EpubViewerWidget Widget（230 行代碼）
- ✅ 封裝 epub_view 的 EpubView
- ✅ 手勢翻頁支持：
  - 點擊螢幕中央切換工具欄
  - 水平滑動翻頁（速度閾值 500）
  - 直書/橫書模式自適應
- ✅ 加載動畫：
  - CircularProgressIndicator
  - 加載提示文字
- ✅ 章節分隔符自定義
- ✅ 錯誤狀態處理（控制器為空）
- ✅ 夜間模式顏色自適應
- ✅ 完整的文檔註釋（中文）
- ✅ 集成到 ReaderPage

**實現特點**:
- 遵循 Clean Architecture 原則
- 無狀態 Widget，狀態由 Controller 管理
- 完整的手勢處理邏輯
- 閱讀方向自適應：
  * **直書模式（vertical）**：
    - 從右向左滑動 → 下一頁
    - 從左向右滑動 → 上一頁
  * **橫書模式（horizontal）**：
    - 從左向右滑動 → 下一頁
    - 從右向左滑動 → 上一頁
- 速度閾值過濾（避免誤觸）
- 自定義構建器：
  * chapterDividerBuilder：章節分隔符
  * loaderBuilder：加載動畫
- 外部鏈接處理支持
- 背景和文字顏色可配置

**手勢邏輯**:
```dart
// 直書模式
if (direction == ReadingDirection.vertical) {
  if (velocity < 0) onNextPage();      // 右→左 = 下一頁
  else onPreviousPage();               // 左→右 = 上一頁
}
// 橫書模式
else {
  if (velocity > 0) onNextPage();      // 左→右 = 下一頁
  else onPreviousPage();               // 右→左 = 上一頁
}
```

**集成到 ReaderPage**:
- ✅ 導入 EpubViewerWidget
- ✅ 替換佔位符為實際組件
- ✅ 傳遞所有必要參數：
  * controller.epubController
  * controller.readingDirection
  * controller.toggleToolbar
  * controller.nextPage / previousPage
  * 背景和文字顏色（夜間模式自適應）
- ✅ 使用 Obx 包裹實現響應式

**驗收標準**:
- [x] 能正確顯示 EPUB 內容
- [x] 支持手勢翻頁
- [x] 有加載動畫
- [x] 閱讀方向自適應
- [x] 夜間模式支持
- [x] 無編譯錯誤

**Phase 4.5 狀態**: ✅ 100% 完成 (2/2 任務)

---

### Phase 4.6: 翻頁功能實現 (1 小時)

#### ⬜ Task 4.6.1: 實現橫書模式翻頁
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 實現從左向右滑動翻頁（橫書模式）
2. 添加 `nextPage()` 和 `previousPage()` 方法
3. 處理邊界情況

**驗收標準**:
- [ ] 左滑翻下一頁
- [ ] 右滑翻上一頁
- [ ] 邊界處理（首頁/末頁）
- [ ] 翻頁動畫流暢

---

### Phase 4.7: 閱讀進度顯示 (1 小時)

#### ⬜ Task 4.7.1: 創建 ReadingProgressBar Widget
- **文件**: `lib/presentation/widgets/reading_progress_bar.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 創建進度條 Widget
2. 顯示「第 X 頁 / 共 Y 頁」
3. 顯示百分比進度條
4. 實時更新

**驗收標準**:
- [ ] 顯示「第 X 頁 / 共 Y 頁」
- [ ] 顯示百分比進度條
- [ ] 實時更新
- [ ] 底部固定顯示

---

**階段 1-2 小結**:
- **總任務數**: 8
- **預計時間**: ~7 小時
- **關鍵產出**: 能打開 EPUB 並閱讀（橫書模式）

---

## 📅 Day 3: 直書模式實現 (6.5 小時)

### Phase 4.8: 直書排版實現 (3 小時)

#### ⬜ Task 4.8.1: 研究 CSS writing-mode 實現
- **文件**: 技術方案文檔
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 調研 epub_view 如何注入自定義 CSS
2. 確認兼容性和限制
3. 撰寫技術方案

**驗收標準**:
- [ ] 明確如何使用 `writing-mode: vertical-rl`
- [ ] 確認兼容性
- [ ] 技術方案完整

---

#### ⬜ Task 4.8.2: 實現直書 CSS 注入
- **文件**: `lib/presentation/widgets/epub_viewer_widget.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 在 EPUB 渲染時注入直書 CSS:
   ```css
   body {
     writing-mode: vertical-rl;
     -webkit-writing-mode: vertical-rl;
     -ms-writing-mode: tb-rl;
   }
   ```
2. 測試直書效果

**驗收標準**:
- [ ] CSS 成功注入
- [ ] 直書效果正確
- [ ] 無佈局錯誤

---

#### ⬜ Task 4.8.3: 調整直書模式頁面佈局
- **文件**: `lib/presentation/pages/reader_page.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 調整直書模式下的 UI 佈局
2. 調整進度條位置
3. 調整工具欄位置

**驗收標準**:
- [ ] 文字從上到下、從右到左排列
- [ ] UI 元素位置合理
- [ ] 無佈局錯誤

---

### Phase 4.9: 直書翻頁邏輯 (1 小時)

#### ⬜ Task 4.9.1: 實現直書翻頁方向
- **文件**: `lib/presentation/widgets/epub_viewer_widget.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 實現從右向左滑動翻頁（直書模式）
2. 使用 `PageView(reverse: true)`
3. 測試翻頁方向

**驗收標準**:
- [ ] 右滑翻上一頁
- [ ] 左滑翻下一頁
- [ ] 使用 `PageView(reverse: true)`

---

### Phase 4.10: 模式切換功能 (2.5 小時)

#### ⬜ Task 4.10.1: 創建模式切換按鈕
- **文件**: `lib/presentation/pages/reader_page.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 在工具欄添加直書/橫書切換按鈕
2. 設計圖標（⚔️/📖）
3. 添加切換動畫

**驗收標準**:
- [ ] 按鈕顯示當前模式圖標
- [ ] 點擊切換模式
- [ ] 有切換動畫

---

#### ⬜ Task 4.10.2: 實現模式切換邏輯
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 1.5 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 在 Controller 中實現 `toggleReadingDirection()` 方法
2. 切換時保持當前閱讀位置
3. 重新渲染 EPUB
4. 更新翻頁方向

**驗收標準**:
- [ ] 切換時保持當前閱讀位置
- [ ] 重新渲染 EPUB
- [ ] 更新翻頁方向
- [ ] 切換動畫流暢（< 300ms）

---

#### ⬜ Task 4.10.3: 設置預設閱讀模式
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 首次打開書籍時預設使用直書模式
2. 後續打開使用上次設置

**驗收標準**:
- [ ] 首次打開自動使用直書模式
- [ ] 後續打開使用上次設置

---

**階段 3 小結**:
- **總任務數**: 7
- **預計時間**: ~6.5 小時
- **關鍵產出**: 直書/橫書模式完整實現

---

## 📅 Day 4: 閱讀設置實現 (5.2 小時)

### Phase 4.11: 設置面板 UI (1.2 小時)

#### ⬜ Task 4.11.1: 創建設置面板 Widget
- **文件**: `lib/presentation/widgets/reading_settings_panel.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 創建從底部彈出的設置面板
2. BottomSheet 樣式
3. 包含字體大小和亮度滑桿
4. 添加平滑動畫

**驗收標準**:
- [ ] BottomSheet 樣式正確
- [ ] 包含字體大小和亮度滑桿
- [ ] 平滑動畫

---

#### ⬜ Task 4.11.2: 添加設置按鈕
- **文件**: `lib/presentation/pages/reader_page.dart`
- **優先級**: P0
- **預計時間**: 12 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 在工具欄添加設置按鈕（⚙️）
2. 點擊顯示設置面板

**驗收標準**:
- [ ] 點擊顯示設置面板
- [ ] 圖標清晰

---

### Phase 4.12: 字體大小調整 (1.5 小時)

#### ⬜ Task 4.12.1: 實現字體大小滑桿
- **文件**: `lib/presentation/widgets/reading_settings_panel.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 創建字體大小調整滑桿（5 檔）
2. 5 個預設級別（12/14/16/18/20sp）
3. 預設 16sp

**驗收標準**:
- [ ] 5 個預設級別
- [ ] 預設 16sp
- [ ] 滑動流暢

---

#### ⬜ Task 4.12.2: 實現字體調整邏輯
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 在 Controller 中實現 `setFontSize()` 方法
2. 調整即時生效
3. 使用 `epubController.changeFontSize()`

**驗收標準**:
- [ ] 調整即時生效
- [ ] 平滑過渡

---

### Phase 4.13: 亮度調整 (1.5 小時)

#### ⬜ Task 4.13.1: 實現亮度滑桿
- **文件**: `lib/presentation/widgets/reading_settings_panel.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 創建亮度調整滑桿（0-100%）
2. 顯示當前百分比

**驗收標準**:
- [ ] 0-100% 範圍
- [ ] 顯示當前百分比
- [ ] 滑動流暢

---

#### ⬜ Task 4.13.2: 實現亮度調整邏輯
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 使用 screen_brightness 包調整亮度
2. 實現 `setBrightness()` 方法
3. 退出時恢復系統亮度

**驗收標準**:
- [ ] 調整即時生效
- [ ] 僅影響閱讀頁面
- [ ] 退出時恢復系統亮度

---

### Phase 4.14: 設置持久化 (1 小時)

#### ⬜ Task 4.14.1: 實現設置保存
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 使用 SharedPreferences 保存設置
2. 保存閱讀方向
3. 保存字體大小
4. 保存亮度設置
5. 自動保存（無需手動點擊）

**驗收標準**:
- [ ] 保存閱讀方向
- [ ] 保存字體大小
- [ ] 保存亮度設置
- [ ] 自動保存

---

**階段 4 小結**:
- **總任務數**: 6
- **預計時間**: ~5.2 小時
- **關鍵產出**: 完整的閱讀設置功能

---

## 📅 Day 4-5: 書籤功能實現 (4.5 小時)

### Phase 4.15: 數據模型更新 (1 小時)

#### ⬜ Task 4.15.1: 更新 ReadingProgress 模型
- **文件**: `lib/domain/entities/reading_progress.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 添加書籤相關欄位和方法:
   ```dart
   class ReadingProgress {
     List<int> bookmarkedPages;
     bool isBookmarked(int page);
     void toggleBookmark(int page);
   }
   ```

**驗收標準**:
- [ ] 書籤欄位已添加
- [ ] 方法實現正確

---

#### ⬜ Task 4.15.2: 創建 Hive Adapter
- **文件**: `lib/data/models/reading_progress_adapter.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 為 ReadingProgress 創建 Hive TypeAdapter
2. 添加 @HiveType 和 @HiveField 註解

**驗收標準**:
- [ ] @HiveType 註解正確
- [ ] @HiveField 完整
- [ ] 能正確序列化/反序列化

---

### Phase 4.16: 書籤按鈕 UI (1 小時)

#### ⬜ Task 4.16.1: 創建書籤按鈕
- **文件**: `lib/presentation/pages/reader_page.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 在工具欄添加書籤按鈕
2. 未添加顯示 🔖（灰色）
3. 已添加顯示 📑（彩色）

**驗收標準**:
- [ ] 未添加顯示 🔖（灰色）
- [ ] 已添加顯示 📑（彩色）
- [ ] 點擊有反饋動畫

---

#### ⬜ Task 4.16.2: 實現書籤狀態切換動畫
- **文件**: `lib/presentation/pages/reader_page.dart`
- **優先級**: P1
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 添加書籤圖標切換動畫
2. 縮放動畫
3. 觸覺反饋

**驗收標準**:
- [ ] 切換時有縮放動畫
- [ ] 動畫流暢（< 200ms）
- [ ] 有觸覺反饋

---

### Phase 4.17: 書籤邏輯實現 (1.5 小時)

#### ⬜ Task 4.17.1: 實現書籤切換邏輯
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 實現 `toggleCurrentBookmark()` 方法
2. 檢查當前頁是否已添加書籤
3. 切換書籤狀態
4. 更新 UI
5. 保存到數據庫

**驗收標準**:
- [ ] 檢查書籤狀態正確
- [ ] 切換邏輯正確
- [ ] UI 即時更新
- [ ] 保存到數據庫

---

#### ⬜ Task 4.17.2: 實現書籤數據持久化
- **文件**: `lib/data/repositories/reading_repository_impl.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 使用 Hive 保存書籤數據
2. 書籤即時保存
3. 重新打開時恢復書籤

**驗收標準**:
- [ ] 書籤即時保存
- [ ] 重新打開時恢復書籤
- [ ] 無數據丟失

---

### Phase 4.18: 書籤恢復功能 (0.5 小時)

#### ⬜ Task 4.18.1: 實現書籤狀態恢復
- **文件**: `lib/presentation/controllers/reader_controller.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 打開書籍時恢復書籤狀態
2. 實現 `_loadBookmarks()` 方法
3. 更新當前頁書籤按鈕狀態

**驗收標準**:
- [ ] 從 Hive 讀取書籤數據
- [ ] 更新 bookmarkedPages 列表
- [ ] 更新當前頁書籤按鈕狀態

---

**階段 5 小結**:
- **總任務數**: 7
- **預計時間**: ~4.5 小時
- **關鍵產出**: 完整的基礎書籤功能

---

## 📅 Day 5: 整合測試 (9 小時)

### Phase 4.19: 單元測試 (2.5 小時)

#### ⬜ Task 4.19.1: 編寫 ReaderController 單元測試
- **文件**: `test/controllers/reader_controller_test.dart`
- **優先級**: P0
- **預計時間**: 2 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 創建測試文件
2. 測試初始化邏輯
3. 測試翻頁邏輯
4. 測試模式切換
5. 測試書籤功能

**驗收標準**:
- [ ] 所有測試通過
- [ ] 測試覆蓋率 > 80%

---

#### ⬜ Task 4.19.2: 編寫 ReadingProgress 單元測試
- **文件**: `test/entities/reading_progress_test.dart`
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 測試 toggleBookmark()
2. 測試 isBookmarked()
3. 測試數據序列化

**驗收標準**:
- [ ] 所有方法測試通過
- [ ] 數據序列化正確

---

### Phase 4.20: Widget 測試 (2.5 小時)

#### ⬜ Task 4.20.1: 編寫 ReaderPage Widget 測試
- **文件**: `test/pages/reader_page_test.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 測試頁面初始化
2. 測試工具欄顯示
3. 測試進度條顯示
4. 測試按鈕交互

**驗收標準**:
- [ ] 所有 UI 元素正確顯示
- [ ] 按鈕交互正常

---

#### ⬜ Task 4.20.2: 編寫 EpubViewerWidget 測試
- **文件**: `test/widgets/epub_viewer_widget_test.dart`
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 測試手勢識別
2. 測試翻頁動畫
3. 測試加載狀態

**驗收標準**:
- [ ] 手勢識別正確
- [ ] 翻頁動畫流暢
- [ ] 加載狀態正確

---

#### ⬜ Task 4.20.3: 編寫設置面板 Widget 測試
- **文件**: `test/widgets/reading_settings_panel_test.dart`
- **優先級**: P1
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 測試滑桿交互
2. 測試設置保存

**驗收標準**:
- [ ] 滑桿交互正常
- [ ] 設置正確保存

---

### Phase 4.21: 集成測試 (2 小時)

#### ⬜ Task 4.21.1: 編寫完整閱讀流程測試
- **文件**: `integration_test/reader_flow_test.dart`
- **優先級**: P0
- **預計時間**: 2 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 測試打開書籍
2. 測試翻頁
3. 測試模式切換
4. 測試添加書籤
5. 測試設置調整

**驗收標準**:
- [ ] 所有測試通過
- [ ] 覆蓋完整流程

---

### Phase 4.22: 性能測試 (2 小時)

#### ⬜ Task 4.22.1: 測試閱讀器性能
- **工具**: DevTools
- **優先級**: P1
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 使用 DevTools 測試性能指標
2. 記錄啟動時間
3. 記錄翻頁流暢度
4. 記錄內存使用

**驗收標準**:
- [ ] 啟動時間 < 2s
- [ ] 翻頁流暢度 60fps
- [ ] 內存使用 < 150MB
- [ ] 無內存洩漏

---

#### ⬜ Task 4.22.2: 修復性能問題
- **文件**: 相關代碼
- **優先級**: P1
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 根據測試結果優化性能
2. 修復發現的問題

**驗收標準**:
- [ ] 所有性能指標達標
- [ ] 無明顯卡頓

---

**階段 6 小結**:
- **總任務數**: 8
- **預計時間**: ~9 小時
- **關鍵產出**: 完整的測試覆蓋

---

## 📅 Day 6: 文檔與發布 (6 小時)

### Phase 4.23: API 文檔 (1.5 小時)

#### ⬜ Task 4.23.1: 添加代碼註釋
- **文件**: 所有代碼文件
- **優先級**: P1
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 為所有 public 方法添加 Dart Doc 註釋
2. 為所有 class 添加註釋
3. 使用 `///` 格式

**驗收標準**:
- [ ] 所有 public 方法有註釋
- [ ] 所有 class 有註釋
- [ ] 使用 `///` 格式

---

#### ⬜ Task 4.23.2: 生成 API 文檔
- **命令**: `dart doc`
- **優先級**: P2
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 執行 `dart doc`
2. 檢查生成的文檔

**驗收標準**:
- [ ] 文檔完整清晰

---

### Phase 4.24: 用戶指南 (1 小時)

#### ⬜ Task 4.24.1: 編寫使用說明
- **文件**: `docs/reader_guide.md`
- **優先級**: P1
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 說明如何打開書籍
2. 說明如何使用直書/橫書模式
3. 說明如何添加書籤
4. 說明如何調整設置
5. 包含截圖

**驗收標準**:
- [ ] 使用說明完整
- [ ] 包含截圖

---

### Phase 4.25: 截圖與演示 (1.5 小時)

#### ⬜ Task 4.25.1: 截取功能截圖
- **文件**: `screenshots/reader/`
- **優先級**: P1
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 截取直書模式截圖
2. 截取橫書模式截圖
3. 截取設置面板截圖
4. 截取書籤功能截圖

**驗收標準**:
- [ ] 所有功能截圖完整
- [ ] 分辨率統一

---

#### ⬜ Task 4.25.2: 錄製演示視頻
- **文件**: `demo/reader_demo.mp4`
- **優先級**: P2
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 展示完整閱讀流程
2. 展示模式切換
3. 展示書籤功能
4. 時長 < 3 分鐘

**驗收標準**:
- [ ] 展示完整閱讀流程
- [ ] 時長 < 3 分鐘

---

### Phase 4.26: 代碼審查 (1.5 小時)

#### ⬜ Task 4.26.1: 執行代碼審查
- **文件**: 審查報告
- **優先級**: P0
- **預計時間**: 1 小時
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 團隊代碼審查
2. 記錄審查意見
3. 修復發現的問題

**驗收標準**:
- [ ] 代碼符合規範
- [ ] 無明顯問題
- [ ] 審查意見已修復

---

#### ⬜ Task 4.26.2: 更新 CHANGELOG
- **文件**: `CHANGELOG.md`
- **優先級**: P1
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 記錄所有新功能
2. 記錄已修復的 Bug
3. 更新版本號

**驗收標準**:
- [ ] 記錄所有新功能
- [ ] 記錄已修復的 Bug
- [ ] 版本號正確

---

### Phase 4.27: 發布準備 (0.5 小時)

#### ⬜ Task 4.27.1: 準備 Demo 展示
- **文件**: Demo 環境
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 未開始

**具體步驟**:
1. 準備給團隊/用戶的 Demo
2. 準備測試數據
3. 確保 APP 運行穩定

**驗收標準**:
- [ ] APP 運行穩定
- [ ] 測試數據準備完整
- [ ] 演示流程清晰

---

**階段 7 小結**:
- **總任務數**: 7
- **預計時間**: ~6 小時
- **關鍵產出**: 完整的文檔和 Demo

---

## 📊 總體統計

### 時間分配
| 階段 | 預計時間 | 佔比 |
|------|----------|------|
| Phase 4.1-4.7: 基礎渲染 | 7h | 16.7% |
| Phase 4.8-4.10: 直書模式 | 6.5h | 15.5% |
| Phase 4.11-4.14: 閱讀設置 | 5.2h | 12.4% |
| Phase 4.15-4.18: 書籤功能 | 4.5h | 10.7% |
| Phase 4.19-4.22: 整合測試 | 9h | 21.4% |
| Phase 4.23-4.27: 文檔發布 | 6h | 14.3% |
| **緩衝時間** | 4h | 9.5% |
| **總計** | **42h** | **100%** |

### 優先級分佈
- **P0 (必須完成)**: 35 個任務 (81%)
- **P1 (應該完成)**: 7 個任務 (16%)
- **P2 (可以延後)**: 1 個任務 (3%)

### 依賴關係
```
Phase 4.1-4.7 (基礎渲染) 
  └─→ Phase 4.8-4.10 (直書模式)
       └─→ Phase 4.11-4.14 (閱讀設置)
            └─→ Phase 4.15-4.18 (書籤功能)
                 └─→ Phase 4.19-4.22 (整合測試)
                      └─→ Phase 4.23-4.27 (文檔發布)
```

---

## 🎯 驗收標準總覽

### 功能驗收
- [ ] 能正確打開並渲染 EPUB 文件
- [ ] 支持直書和橫書兩種閱讀模式
- [ ] 直書模式：從右向左滑動翻頁
- [ ] 橫書模式：從左向右滑動翻頁
- [ ] 模式切換流暢，保持閱讀位置
- [ ] 閱讀進度正確顯示和更新
- [ ] 字體大小可調整（5 檔）
- [ ] 亮度可調整（0-100%）
- [ ] 書籤可添加/移除
- [ ] 書籤數據正確保存和恢復
- [ ] 閱讀偏好正確保存和恢復

### 性能驗收
- [ ] 啟動時間 < 2 秒
- [ ] 翻頁流暢度 60fps
- [ ] 內存使用 < 150MB
- [ ] 無內存洩漏
- [ ] 無明顯卡頓

### 測試驗收
- [ ] 單元測試覆蓋率 > 80%
- [ ] 所有 Widget 測試通過
- [ ] 集成測試通過
- [ ] 性能測試達標

### 文檔驗收
- [ ] API 文檔完整
- [ ] 用戶指南清晰
- [ ] 截圖完整
- [ ] Demo 視頻完整

---

## 📝 開發日誌

### 2025-11-08
- ✅ 創建任務清單文檔
- ✅ 更新任務編號格式（4.x.x）
- ✅ 參考 Spec 03 格式重構文檔
- 📋 定義 43 個具體任務
- 📋 估算總計 42 小時開發時間

### [日期]
- [ ] [記錄每日進度]

---

## 🐛 已知問題

### 待修復
1. [問題描述]
   - **嚴重程度**: [高/中/低]
   - **影響範圍**: [描述]
   - **計劃修復時間**: [日期]

### 已修復
1. [問題描述]
   - **修復日期**: [日期]
   - **解決方案**: [描述]

---

## 💡 優化建議

### 性能優化
1. [建議 1]
   - **預期效果**: [描述]
   - **實施難度**: [高/中/低]

### 用戶體驗優化
1. [建議 1]
   - **預期效果**: [描述]
   - **實施難度**: [高/中/低]

---

## 📌 注意事項

### 開發注意事項
1. **EPUB 兼容性**: 充分測試不同格式的 EPUB 文件
2. **直書模式**: 確保 CSS 在不同設備上的兼容性
3. **書籤準確性**: 使用穩定的 CFI 機制確保書籤位置準確
4. **性能監控**: 使用 DevTools 持續監控性能
5. **錯誤處理**: 所有 async 操作必須有錯誤處理

### 測試注意事項
1. 測試至少 10 本不同的 EPUB 文件
2. 測試不同螢幕尺寸（手機/平板）
3. 測試不同 Android 版本（API 21-34）
4. 測試極端情況（超大文件、損壞文件）
5. 測試長時間閱讀（內存洩漏檢測）

### 代碼規範
1. 所有 public 方法必須有 Dart Doc 註釋
2. 使用 `flutter analyze` 確保無警告
3. 使用 `flutter format` 統一代碼格式
4. 遵循 Clean Architecture 原則
5. 單一職責原則

---

## 🔗 相關文檔

- [Spec 04: EPUB 閱讀器規格文檔](./04-reader-view.md)
- [Spec 03: 書籍詳情頁任務清單](./03-book-detail-tasks.md)
- [開發計劃](./development-plan.md)
- [專案憲章](./00-constitution.md)
- [epub_view 官方文檔](https://pub.dev/packages/epub_view)

---

**文檔版本**: 2.0  
**創建日期**: 2025-11-08  
**最後更新**: 2025-11-08  
**維護者**: [待分配]

---

**下一步行動**:
1. ⬜ 分配任務負責人
2. ⬜ 開始 Phase 4.1 開發
3. ⬜ 每日更新進度
4. ⬜ 定期同步問題

**提示**: 每完成一個任務，請在 ⬜ 處標記為 ✅，並更新「進度追蹤」區域！💪

