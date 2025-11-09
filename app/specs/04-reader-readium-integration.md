# Spec 04: EPUB 閱讀器 - Readium Kotlin 混合方案

**規格 ID**: 04  
**規格名稱**: EPUB Reader View (Readium Kotlin Integration)  
**開始日期**: 2025-11-09  
**預計完成**: 2025-12-27 (6週)  
**優先級**: P0 (核心功能)  
**狀態**: 🔄 進行中  
**依賴**: Spec 03 (書籍詳情頁)  
**Git 分支**: `feature/reader-refactor`  
**文件版本**: 1.0  
**最後更新**: 2025-11-09

---

## 📋 目錄

- [1. 概述](#1-概述)
- [2. 技術架構](#2-技術架構)
- [3. 功能規格](#3-功能規格)
- [4. 開發任務](#4-開發任務)
- [5. 測試計劃](#5-測試計劃)
- [6. 驗收標準](#6-驗收標準)
- [7. 風險評估](#7-風險評估)
- [8. 參考資源](#8-參考資源)

---

## 1. 概述

### 1.1 目標與背景

**目標**:
整合 Readium Kotlin Toolkit 到 ShuyuanReader，實現專業級的 EPUB 直書橫書閱讀功能。

**背景**:
經過 PoC 驗證（詳見 `specs/archive/poc_validation_result.md`），純 Flutter 方案（epubx + PageView）在以下方面存在限制：
- ❌ 分頁連貫性無法完美解決（HTML 標籤高度計算不準確）
- ❌ 複雜 EPUB 渲染品質不佳
- ❌ 直書模式支持需要大量自定義

**決策**:
採用業界成熟的 Readium Kotlin Toolkit + Platform Channel 混合方案：
- ✅ 專業級 EPUB 渲染品質（100+ 應用使用）
- ✅ 原生直書橫書支持（`ReadingProgression.RTL/LTR`）
- ✅ 完整 EPUB3 支持（Reflow, Fixed Layout, Media Overlays）
- ✅ 精確分頁和書籤定位（基於 Locator）

### 1.2 技術決策

| 決策點 | 選項 A (已選) | 選項 B (已棄) | 理由 |
|--------|-------------|-------------|------|
| EPUB 渲染 | Readium Kotlin | epubx + flutter_html | Readium 是業界標準，渲染品質更好 |
| 直書支持 | Readium ReadingProgression | CSS writing-mode | Readium 原生支持更穩定 |
| 架構 | Platform Channel 混合 | 純 Flutter | 混合方案平衡了性能和靈活性 |
| 書籤定位 | Readium Locator | 頁碼 | Locator 更精確，支持重排 |

### 1.3 成功標準

**MVP 標準** (Phase 4.1-4.3):
- ✅ 可以打開並渲染 EPUB 文件
- ✅ 支持直書/橫書切換
- ✅ 翻頁流暢（無明顯延遲）
- ✅ 閱讀進度正確追蹤

**完整功能標準** (Phase 4.4-4.5):
- ✅ 字體大小可調整
- ✅ 主題切換（日間/夜間）
- ✅ 書籤添加/移除
- ✅ 閱讀偏好持久化
- ✅ 錯誤處理完善
- ✅ 測試覆蓋率 > 80%

**性能標準**:
- ✅ EPUB 打開時間 < 2 秒
- ✅ 翻頁響應時間 < 100ms
- ✅ 無內存洩漏
- ✅ 動畫幀率 60fps

---

## 2. 技術架構

### 2.1 系統架構圖

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter UI Layer                       │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  ReaderPage (UI)                                      │ │
│  │  - 閱讀器視圖（AndroidView）                          │ │
│  │  - 工具欄（設置、書籤、進度）                         │ │
│  │  - 進度條、章節列表                                   │ │
│  └───────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  ReaderController (GetX)                              │ │
│  │  - 狀態管理（閱讀位置、設置）                         │ │
│  │  - 業務邏輯（書籤、進度保存）                         │ │
│  │  - Platform Channel 調用                              │ │
│  └───────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  EpubReaderChannel (Platform Channel)                 │ │
│  │  - openBook(), closeBook()                            │ │
│  │  - nextPage(), previousPage()                         │ │
│  │  - setReadingDirection(), setFontSize()               │ │
│  │  - toggleBookmark(), getCurrentLocation()             │ │
│  └───────────────────────────────────────────────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │
              MethodChannel (Flutter ↔ Kotlin)
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                  Android Native Layer                       │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  MainActivity (FlutterActivity)                       │ │
│  │  - MethodChannel 註冊                                 │ │
│  │  - 方法調用路由                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  ReadiumBridge (核心橋接層)                          │ │
│  │  - Readium API 封裝                                   │ │
│  │  - Publication 管理                                   │ │
│  │  - Navigator 生命週期                                │ │
│  └───────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Readium Kotlin Toolkit 3.1.2                         │ │
│  │  - readium-shared (數據模型)                          │ │
│  │  - readium-streamer (EPUB 解析)                       │ │
│  │  - readium-navigator (閱讀器核心)                     │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 核心技術棧

**Flutter 側**:
- **Flutter SDK**: 3.13+
- **Dart**: 3.0+
- **狀態管理**: GetX 4.6+
- **本地存儲**: Hive 2.2+ (書籤、進度)
- **Platform Channel**: MethodChannel

**Android 側**:
- **Kotlin**: 1.9.0
- **Readium Kotlin Toolkit**: 3.1.2
  - `readium-shared`: 核心數據模型
  - `readium-streamer`: EPUB 解析
  - `readium-navigator`: 閱讀器渲染
- **Kotlin Coroutines**: 1.7.3 (異步處理)
- **AndroidX**: Core-KTX, AppCompat

### 2.3 Platform Channel 設計

**Channel 名稱**: `com.shuyuan.reader/epub`

**方法列表**:

| 方法名 | 參數 | 返回值 | 說明 |
|--------|------|--------|------|
| `openBook` | filePath: String<br>isVertical: Boolean | void | 打開 EPUB 書籍 |
| `closeBook` | - | void | 關閉當前書籍 |
| `nextPage` | - | void | 下一頁 |
| `previousPage` | - | void | 上一頁 |
| `goToLocation` | locatorJson: String | void | 跳轉到指定位置 |
| `getCurrentLocation` | - | Map<String, Any> | 獲取當前位置 |
| `setReadingDirection` | direction: String | void | 設置閱讀方向 (rtl/ltr) |
| `setFontSize` | size: Double | void | 設置字體大小 |
| `setBrightness` | brightness: Double | void | 設置亮度 |
| `setTheme` | theme: String | void | 設置主題 (light/dark/sepia) |
| `toggleBookmark` | - | Map<String, Any> | 切換書籤（返回當前狀態） |
| `getTableOfContents` | - | List<Map> | 獲取目錄 |

---

## 3. 功能規格

### 3.1 核心閱讀功能

#### 3.1.1 打開書籍

**功能描述**:
從本地文件系統打開 EPUB 文件，使用 Readium 解析並渲染。

**UI 流程**:
1. 用戶在書籍詳情頁點擊「打開閱讀」
2. 顯示加載動畫
3. Readium 解析 EPUB（1-2 秒）
4. 跳轉到閱讀器頁面
5. 恢復上次閱讀位置（如有）

**技術實現**:
```dart
// Flutter 側
await EpubReaderChannel.openBook(
  filePath: book.localPath,
  isVertical: settings.isVerticalReading,
);
```

```kotlin
// Kotlin 側
suspend fun openBook(filePath: String, isVertical: Boolean) {
    val file = File(filePath)
    val asset = FileAsset(file)
    
    val publication = streamer.open(asset, allowUserInteraction = false)
        .getOrThrow()
    
    currentPublication = publication
    
    val progression = if (isVertical) 
        ReadingProgression.RTL 
    else 
        ReadingProgression.LTR
    
    // 創建 Navigator
    navigator = EpubNavigatorFragment.createFactory(
        publication = publication,
        initialLocator = null,
        readingProgression = progression
    )
}
```

**驗收標準**:
- [ ] 可以打開標準 EPUB2/EPUB3 文件
- [ ] 加載時間 < 2 秒
- [ ] 錯誤處理（文件不存在、格式不支持）
- [ ] 加載動畫流暢

#### 3.1.2 翻頁操作

**功能描述**:
支持滑動翻頁、點擊翻頁、音量鍵翻頁。

**交互方式**:
- **滑動翻頁**: 
  - 直書模式：從右向左滑動 = 下一頁
  - 橫書模式：從左向右滑動 = 下一頁
- **點擊翻頁**: 
  - 點擊右側區域 = 下一頁
  - 點擊左側區域 = 上一頁
  - 點擊中間區域 = 顯示/隱藏工具欄
- **音量鍵**: 
  - 音量下 = 下一頁
  - 音量上 = 上一頁

**技術實現**:
```dart
// Flutter 側
void nextPage() async {
  await EpubReaderChannel.nextPage();
  // 更新進度
  final location = await EpubReaderChannel.getCurrentLocation();
  _updateProgress(location);
}
```

**驗收標準**:
- [ ] 滑動翻頁流暢（< 100ms 響應）
- [ ] 點擊翻頁區域劃分正確
- [ ] 音量鍵翻頁正常工作
- [ ] 直書/橫書翻頁方向正確

#### 3.1.3 進度追蹤

**功能描述**:
實時追蹤閱讀進度，顯示進度條和頁碼。

**UI 顯示**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━ 35%
第 15 頁 / 共 42 頁
```

**數據模型**:
```dart
class ReadingProgress {
  final String bookId;
  final String locatorJson;      // Readium Locator JSON
  final double progressPercentage; // 0.0 - 1.0
  final int currentPage;
  final int totalPages;
  final DateTime lastReadAt;
}
```

**技術實現**:
```kotlin
// Kotlin 側
fun getCurrentLocation(): Map<String, Any> {
    val locator = navigator?.currentLocator() ?: return emptyMap()
    
    return mapOf(
        "locatorJson" to locator.toJSON().toString(),
        "progress" to (locator.locations.progression ?: 0.0),
        "title" to (locator.title ?: "")
    )
}
```

**驗收標準**:
- [ ] 進度百分比計算正確
- [ ] 頁碼顯示準確
- [ ] 進度自動保存（每翻頁一次）
- [ ] 重新打開時恢復到上次位置

### 3.2 直書橫書切換

#### 3.2.1 閱讀方向切換

**功能描述**:
支持直書（從右向左）和橫書（從左向右）兩種閱讀方向。

**UI 設計**:
```
工具欄按鈕：
[📖] = 橫書模式（當前）
[⚔️] = 直書模式（當前）

點擊切換
```

**技術實現**:
```dart
// Flutter 側
enum ReadingDirection {
  vertical,   // 直書（RTL）
  horizontal, // 橫書（LTR）
}

Future<void> toggleReadingDirection() async {
  final newDirection = currentDirection == ReadingDirection.vertical
      ? ReadingDirection.horizontal
      : ReadingDirection.vertical;
  
  await EpubReaderChannel.setReadingDirection(
    newDirection == ReadingDirection.vertical ? 'rtl' : 'ltr'
  );
  
  // 保存偏好
  await prefs.setString('reading_direction', newDirection.toString());
}
```

```kotlin
// Kotlin 側
fun setReadingDirection(direction: String) {
    val progression = when (direction) {
        "rtl" -> ReadingProgression.RTL  // 直書
        "ltr" -> ReadingProgression.LTR  // 橫書
        else -> ReadingProgression.LTR
    }
    
    navigator?.readingProgression = progression
}
```

**驗收標準**:
- [ ] 切換按鈕正確顯示當前狀態
- [ ] 切換後翻頁方向正確
- [ ] 文字排版正確（直書：上→下、右→左）
- [ ] 偏好設置正確保存和恢復

#### 3.2.2 預設直書模式

**功能描述**:
首次打開書籍時，預設使用直書模式（適合經典書籍）。

**邏輯**:
```dart
Future<void> openBook(Book book) async {
  // 檢查用戶偏好
  final savedDirection = prefs.getString('reading_direction_${book.id}');
  
  final isVertical = savedDirection != null
      ? savedDirection == 'vertical'
      : true; // 預設直書
  
  await EpubReaderChannel.openBook(
    filePath: book.localPath,
    isVertical: isVertical,
  );
}
```

**驗收標準**:
- [ ] 首次打開使用直書模式
- [ ] 記住每本書的閱讀方向偏好
- [ ] 全局預設設置可修改

### 3.3 書籤系統

#### 3.3.1 添加/移除書籤

**功能描述**:
在當前頁面添加或移除書籤。

**UI 交互**:
```
工具欄按鈕：
[🔖] = 未添加書籤
[📑] = 已添加書籤（紅色）

點擊切換
```

**數據模型**:
```dart
@HiveType(typeId: 2)
class Bookmark extends HiveObject {
  @HiveField(0)
  final String bookId;
  
  @HiveField(1)
  final String locatorJson; // Readium Locator JSON
  
  @HiveField(2)
  final String title;       // 章節標題
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final String? note;       // 可選筆記（延後實現）
}
```

**技術實現**:
```dart
// Flutter 側
Future<void> toggleBookmark() async {
  final result = await EpubReaderChannel.toggleBookmark();
  
  final locatorJson = result['locatorJson'] as String;
  final isBookmarked = result['isBookmarked'] as bool;
  
  if (isBookmarked) {
    // 添加到 Hive
    final bookmark = Bookmark(
      bookId: currentBook.id,
      locatorJson: locatorJson,
      title: result['title'] as String,
      createdAt: DateTime.now(),
    );
    await bookmarksBox.add(bookmark);
  } else {
    // 從 Hive 移除
    final existing = bookmarksBox.values.firstWhere(
      (b) => b.locatorJson == locatorJson,
    );
    await existing.delete();
  }
}
```

**驗收標準**:
- [ ] 書籤按鈕正確顯示狀態
- [ ] 添加/移除功能正常
- [ ] 書籤數據正確保存到 Hive
- [ ] 重新打開時書籤狀態正確

### 3.4 閱讀設置

#### 3.4.1 字體大小調整

**功能描述**:
支持調整字體大小（10 個級別）。

**UI 設計**:
```
字體大小設置面板：
[A-] ━━━━●━━━━ [A+]
     小        大
```

**技術實現**:
```dart
Future<void> setFontSize(double size) async {
  await EpubReaderChannel.setFontSize(size);
  await prefs.setDouble('font_size', size);
}
```

**驗收標準**:
- [ ] 字體大小實時調整
- [ ] 調整後不影響閱讀位置
- [ ] 設置正確保存和恢復

#### 3.4.2 主題切換

**功能描述**:
支持日間、夜間、護眼三種主題。

**主題配色**:
- **日間**: 白底黑字 (#FFFFFF / #000000)
- **夜間**: 黑底白字 (#1A1A1A / #E0E0E0)
- **護眼**: 米黃底黑字 (#F5E6D3 / #3C3C3C)

**驗收標準**:
- [ ] 主題切換流暢
- [ ] 顏色配置正確
- [ ] 設置正確保存

---

## 4. 開發任務

### Phase 4.1: 環境準備與學習 (1週)

#### ✅ Task 4.1.1: Git 分支已創建
- **狀態**: ✅ 已完成
- **分支**: `feature/reader-refactor`

#### ⬜ Task 4.1.2: 添加 Readium Kotlin 依賴
- **優先級**: P0
- **預計時間**: 30 分鐘

**步驟**:
1. 修改 `android/build.gradle.kts`
2. 修改 `android/app/build.gradle.kts`
3. Gradle 同步

**驗收標準**:
- [ ] 依賴已添加
- [ ] Gradle 同步成功
- [ ] 無版本衝突

#### ⬜ Task 4.1.3: 學習 Readium Kotlin API
- **優先級**: P1
- **預計時間**: 3 天

**學習重點**:
1. Readium 架構概念
2. EPUB 解析流程
3. 閱讀器配置
4. 事件處理

**交付物**:
- [ ] 學習筆記文檔

#### ⬜ Task 4.1.4: 搭建基礎 Platform Channel
- **優先級**: P0
- **預計時間**: 2 小時

**交付物**:
- [ ] `EpubReaderChannel` 類（Flutter）
- [ ] `MainActivity` 修改（Kotlin）
- [ ] 編譯成功

### Phase 4.2: Readium 核心整合 (2週)

#### ⬜ Task 4.2.1: 實現 ReadiumBridge 基礎類
- **預計時間**: 1 天

#### ⬜ Task 4.2.2: 實現 EPUB 解析功能
- **預計時間**: 2 天

#### ⬜ Task 4.2.3: 整合 EpubNavigator
- **預計時間**: 3 天

### Phase 4.3: Flutter 層實現 (1週)

#### ⬜ Task 4.3.1: 創建 ReadiumReaderPage
- **預計時間**: 1 天

#### ⬜ Task 4.3.2: 實現閱讀器控制器
- **預計時間**: 2 天

### Phase 4.4: 功能完善 (1週)

#### ⬜ Task 4.4.1: 實現進度保存
#### ⬜ Task 4.4.2: 實現字體設置
#### ⬜ Task 4.4.3: 實現主題切換
#### ⬜ Task 4.4.4: 錯誤處理和日誌

### Phase 4.5: 測試優化 (1週)

#### ⬜ Task 4.5.1: 單元測試
#### ⬜ Task 4.5.2: 整合測試
#### ⬜ Task 4.5.3: 性能優化
#### ⬜ Task 4.5.4: 用戶測試

---

## 5. 測試計劃

### 5.1 單元測試

**覆蓋目標**: > 80%

**測試範圍**:
- `EpubReaderChannel` 方法調用
- `ReaderController` 狀態管理
- `Bookmark` 數據模型
- `ReadingProgress` 數據模型

### 5.2 整合測試

**測試場景**:
- 打開/關閉書籍
- 翻頁操作
- 直書/橫書切換
- 書籤添加/移除
- 進度保存/恢復

### 5.3 性能測試

**測試指標**:
- EPUB 打開時間
- 翻頁響應時間
- 內存使用
- 動畫幀率

### 5.4 兼容性測試

**測試設備**:
- Android 5.0 (API 21)
- Android 8.0 (API 26)
- Android 11 (API 30)
- Android 13 (API 33)

**測試 EPUB**:
- 標準 EPUB2
- 標準 EPUB3
- 固定版面 EPUB
- 繁體中文經典書籍

---

## 6. 驗收標準

### 6.1 功能驗收

- [ ] **核心閱讀**
  - [ ] 可以打開並渲染 EPUB 文件
  - [ ] 翻頁流暢（< 100ms）
  - [ ] 進度追蹤準確

- [ ] **直書橫書**
  - [ ] 預設使用直書模式
  - [ ] 直書模式：從右向左滑動 = 下一頁
  - [ ] 橫書模式：從左向右滑動 = 下一頁
  - [ ] 閱讀方向切換正常工作

- [ ] **書籤系統**
  - [ ] 書籤按鈕顯示當前頁書籤狀態
  - [ ] 點擊可添加/移除書籤
  - [ ] 書籤數據正確保存到 Hive
  - [ ] 重新打開時書籤狀態正確恢復

- [ ] **閱讀設置**
  - [ ] 字體大小可調整
  - [ ] 主題切換（日間/夜間/護眼）
  - [ ] 亮度調整
  - [ ] 設置正確保存和恢復

### 6.2 性能驗收

- [ ] EPUB 打開時間 < 2 秒
- [ ] 翻頁響應時間 < 100ms
- [ ] 無內存洩漏
- [ ] 動畫幀率 60fps

### 6.3 測試驗收

- [ ] 單元測試通過
- [ ] 整合測試通過
- [ ] 測試覆蓋率 > 80%
- [ ] 至少 3 台設備測試通過

---

## 7. 風險評估

### 7.1 技術風險

| 風險 | 概率 | 影響 | 應對措施 |
|------|------|------|----------|
| Readium API 學習曲線陡峭 | 中 | 高 | 預留 3 天學習時間，參考官方範例 |
| Platform Channel 通訊不穩定 | 低 | 中 | 完善錯誤處理，添加重試機制 |
| 直書模式在某些 EPUB 上異常 | 中 | 中 | 充分測試，準備降級方案 |
| 性能不達標 | 低 | 高 | 使用 Readium 優化方案，進行性能測試 |

### 7.2 進度風險

| 風險 | 概率 | 影響 | 應對措施 |
|------|------|------|----------|
| Phase 4.2 整合時間超出預期 | 中 | 中 | 預留 20% 緩衝時間 |
| 測試發現重大 Bug | 中 | 高 | 優先修復 P0 Bug，P1/P2 延後 |

---

## 8. 參考資源

### 8.1 官方資源

- **Readium 官網**: https://readium.org/
- **Readium Kotlin Toolkit**: https://readium.org/kotlin-toolkit/
- **GitHub 倉庫**: https://github.com/readium/kotlin-toolkit
- **API 文檔**: https://readium.org/kotlin-toolkit/api/
- **測試應用**: https://github.com/readium/kotlin-toolkit/tree/main/test-app

### 8.2 學習資源

- **Readium Architecture**: https://readium.org/architecture/
- **EPUB 規範**: https://www.w3.org/publishing/epub3/
- **Flutter Platform Channels**: https://flutter.dev/docs/development/platform-integration/platform-channels

### 8.3 社群資源

- **Readium Slack**: https://readium.org/community/
- **GitHub Discussions**: https://github.com/readium/kotlin-toolkit/discussions

---

## 附錄 A: 代碼範例

### A.1 Flutter EpubReaderChannel

```dart
import 'package:flutter/services.dart';

class EpubReaderChannel {
  static const MethodChannel _channel =
      MethodChannel('com.shuyuan.reader/epub');

  static Future<void> openBook(String filePath, bool isVertical) async {
    try {
      await _channel.invokeMethod('openBook', {
        'filePath': filePath,
        'isVertical': isVertical,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to open book: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> getCurrentLocation() async {
    final result = await _channel.invokeMethod('getCurrentLocation');
    return Map<String, dynamic>.from(result);
  }

  static Future<void> setReadingDirection(String direction) async {
    await _channel.invokeMethod('setReadingDirection', {
      'direction': direction,
    });
  }

  static Future<Map<String, dynamic>> toggleBookmark() async {
    final result = await _channel.invokeMethod('toggleBookmark');
    return Map<String, dynamic>.from(result);
  }
}
```

### A.2 Kotlin ReadiumBridge

```kotlin
package com.shuyuan.shuyuan_reader

import android.content.Context
import org.readium.r2.shared.publication.Publication
import org.readium.r2.streamer.Streamer
import org.readium.r2.navigator.epub.EpubNavigatorFragment
import kotlinx.coroutines.*
import java.io.File

class ReadiumBridge(private val context: Context) {
    private var currentPublication: Publication? = null
    private var navigator: EpubNavigatorFragment? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    suspend fun openBook(filePath: String, isVertical: Boolean) {
        val file = File(filePath)
        val asset = FileAsset(file)
        
        val publication = streamer.open(asset, allowUserInteraction = false)
            .getOrThrow()
        
        currentPublication = publication
        
        val progression = if (isVertical) 
            ReadingProgression.RTL 
        else 
            ReadingProgression.LTR
        
        navigator = EpubNavigatorFragment.createFactory(
            publication = publication,
            initialLocator = null,
            readingProgression = progression
        )
    }

    fun setReadingDirection(direction: String) {
        val progression = when (direction) {
            "rtl" -> ReadingProgression.RTL
            "ltr" -> ReadingProgression.LTR
            else -> ReadingProgression.LTR
        }
        navigator?.readingProgression = progression
    }

    fun getCurrentLocation(): Map<String, Any> {
        val locator = navigator?.currentLocator() ?: return emptyMap()
        return mapOf(
            "locatorJson" to locator.toJSON().toString(),
            "progress" to (locator.locations.progression ?: 0.0),
            "title" to (locator.title ?: "")
        )
    }
}
```

---

**文檔狀態**: ✅ 已完成  
**下一步**: 開始 Task 4.1.2 - 添加 Readium Kotlin 依賴
