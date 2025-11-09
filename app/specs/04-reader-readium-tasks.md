# Spec 04 開發任務清單 - Readium Kotlin 閱讀器

**規格**: Spec 04 - EPUB 閱讀器（Readium Kotlin 混合方案）  
**開始日期**: 2025-11-09  
**預計完成**: 2025-12-27 (6週)  
**負責人**: 開發團隊  
**狀態**: 🔄 進行中

---

## 📊 進度總覽

| Phase | 任務數 | 預計時間 | 完成數 | 進度 | 狀態 |
|-------|-------|---------|-------|------|------|
| Phase 4.1: 環境準備 | 4 | 1週 | 1 | 25% | 🔄 進行中 |
| Phase 4.2: 核心整合 | 3 | 2週 | 0 | 0% | ⬜ 待開始 |
| Phase 4.3: Flutter 層 | 2 | 1週 | 0 | 0% | ⬜ 待開始 |
| Phase 4.4: 功能完善 | 4 | 1週 | 0 | 0% | ⬜ 待開始 |
| Phase 4.5: 測試優化 | 4 | 1週 | 0 | 0% | ⬜ 待開始 |
| **總計** | **17** | **6週** | **1** | **6%** | **🔄 進行中** |

---

## Phase 4.1: 環境準備與學習 (1週)

### ✅ Task 4.1.1: 創建 Git 分支
- **優先級**: P0
- **預計時間**: 5 分鐘
- **狀態**: ✅ 已完成
- **完成日期**: 2025-11-09

**完成內容**:
- ✅ 創建分支 `feature/reader-refactor`
- ✅ 分支已推送到遠端
- ✅ 清理了舊的 04 commits

---

### ⬜ Task 4.1.2: 添加 Readium Kotlin 依賴
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.1.1

**任務內容**:
1. 修改 `android/build.gradle.kts`
   - 添加 Kotlin 版本配置
   - 添加 Readium 版本配置
2. 修改 `android/app/build.gradle.kts`
   - 添加 Readium Kotlin 依賴
   - 配置 Kotlin 選項
3. Gradle 同步

**預期結果**:
```kotlin
// android/build.gradle.kts
buildscript {
    ext {
        kotlin_version = "1.9.0"
        readium_version = "3.1.2"
    }
}

// android/app/build.gradle.kts
dependencies {
    implementation("org.readium.kotlin-toolkit:readium-shared:$readium_version")
    implementation("org.readium.kotlin-toolkit:readium-streamer:$readium_version")
    implementation("org.readium.kotlin-toolkit:readium-navigator:$readium_version")
}
```

**驗收標準**:
- [ ] 依賴已添加到 `build.gradle.kts`
- [ ] Gradle 同步成功（無錯誤）
- [ ] 無版本衝突警告
- [ ] 可以導入 Readium 類（測試編譯）

**參考資源**:
- Readium Kotlin 安裝指南: https://readium.org/kotlin-toolkit/docs/get-started/

---

### ⬜ Task 4.1.3: 學習 Readium Kotlin API
- **優先級**: P1
- **預計時間**: 3 天
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.1.2

**學習重點**:

#### Day 1: Readium 架構概念
- [ ] Readium 整體架構
  - 三層架構：Shared, Streamer, Navigator
  - Publication 數據模型
  - Locator 位置系統
- [ ] 核心概念
  - Manifest（書籍清單）
  - ReadingOrder（閱讀順序）
  - Resources（資源管理）

#### Day 2: EPUB 解析流程
- [ ] Asset 加載機制
  - FileAsset（本地文件）
  - HttpAsset（遠端文件）
- [ ] Publication 創建流程
  - Streamer.open()
  - 錯誤處理
- [ ] 元數據提取
  - Metadata（標題、作者）
  - Cover（封面圖片）

#### Day 3: 閱讀器配置與事件
- [ ] EpubNavigator 配置
  - ReadingProgression（RTL/LTR）
  - 字體、字號、行距
  - 主題配置
- [ ] 事件處理
  - 翻頁事件（onPageChanged）
  - 位置變化（onLocationChanged）
  - 用戶交互

**交付物**:
- [ ] 學習筆記文檔 `docs/readium-learning-notes.md`
- [ ] 簡單的 Kotlin 測試代碼（驗證 API 理解）

**參考資源**:
- 官方文檔: https://readium.org/kotlin-toolkit/docs/
- 測試應用: https://github.com/readium/kotlin-toolkit/tree/main/test-app
- API Reference: https://readium.org/kotlin-toolkit/api/

---

### ⬜ Task 4.1.4: 搭建基礎 Platform Channel
- **優先級**: P0
- **預計時間**: 2 小時
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.1.3

**任務內容**:

#### 4.1.4.1 創建 Flutter Platform Channel
**文件**: `lib/platform/epub_reader_channel.dart`

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

  static Future<void> closeBook() async {
    await _channel.invokeMethod('closeBook');
  }

  static Future<void> nextPage() async {
    await _channel.invokeMethod('nextPage');
  }

  static Future<void> previousPage() async {
    await _channel.invokeMethod('previousPage');
  }

  static Future<Map<String, dynamic>> getCurrentLocation() async {
    final result = await _channel.invokeMethod('getCurrentLocation');
    return Map<String, dynamic>.from(result);
  }

  static Future<void> setFontSize(double size) async {
    await _channel.invokeMethod('setFontSize', {'size': size});
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

#### 4.1.4.2 修改 MainActivity
**文件**: `android/app/src/main/kotlin/com/shuyuan/shuyuan_reader/MainActivity.kt`

```kotlin
package com.shuyuan.shuyuan_reader

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.shuyuan.reader/epub"
    private lateinit var readiumBridge: ReadiumBridge

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        readiumBridge = ReadiumBridge(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBook" -> {
                        val filePath = call.argument<String>("filePath")
                        val isVertical = call.argument<Boolean>("isVertical") ?: false
                        readiumBridge.openBook(filePath!!, isVertical)
                        result.success(null)
                    }
                    "closeBook" -> {
                        readiumBridge.closeBook()
                        result.success(null)
                    }
                    "nextPage" -> {
                        readiumBridge.nextPage()
                        result.success(null)
                    }
                    "previousPage" -> {
                        readiumBridge.previousPage()
                        result.success(null)
                    }
                    "getCurrentLocation" -> {
                        val location = readiumBridge.getCurrentLocation()
                        result.success(location)
                    }
                    "setFontSize" -> {
                        val size = call.argument<Double>("size")!!
                        readiumBridge.setFontSize(size)
                        result.success(null)
                    }
                    "setReadingDirection" -> {
                        val direction = call.argument<String>("direction")!!
                        readiumBridge.setReadingDirection(direction)
                        result.success(null)
                    }
                    "toggleBookmark" -> {
                        val bookmark = readiumBridge.toggleBookmark()
                        result.success(bookmark)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

#### 4.1.4.3 創建 ReadiumBridge 骨架
**文件**: `android/app/src/main/kotlin/com/shuyuan/shuyuan_reader/ReadiumBridge.kt`

```kotlin
package com.shuyuan.shuyuan_reader

import android.content.Context

class ReadiumBridge(private val context: Context) {
    
    fun openBook(filePath: String, isVertical: Boolean) {
        // TODO: 在 Task 4.2.1 實現
    }
    
    fun closeBook() {
        // TODO: 在 Task 4.2.1 實現
    }
    
    fun nextPage() {
        // TODO: 在 Task 4.2.3 實現
    }
    
    fun previousPage() {
        // TODO: 在 Task 4.2.3 實現
    }
    
    fun getCurrentLocation(): Map<String, Any> {
        // TODO: 在 Task 4.2.3 實現
        return emptyMap()
    }
    
    fun setFontSize(size: Double) {
        // TODO: 在 Task 4.4.2 實現
    }
    
    fun setReadingDirection(direction: String) {
        // TODO: 在 Task 4.2.3 實現
    }
    
    fun toggleBookmark(): Map<String, Any> {
        // TODO: 在 Task 4.4.1 實現
        return mapOf("isBookmarked" to false)
    }
}
```

**驗收標準**:
- [ ] `EpubReaderChannel` 類已創建（Flutter）
- [ ] `MainActivity` 已修改（Kotlin）
- [ ] `ReadiumBridge` 骨架已創建（Kotlin）
- [ ] Platform Channel 註冊成功（編譯通過）
- [ ] 可以調用方法（即使是空實現）

---

## Phase 4.2: Readium 核心整合 (2週)

### ⬜ Task 4.2.1: 實現 ReadiumBridge 基礎功能
- **優先級**: P0
- **預計時間**: 1 天
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.1.4

**任務內容**:
實現 `ReadiumBridge` 的核心功能：
1. Streamer 初始化
2. Publication 管理
3. Navigator 生命週期

**驗收標準**:
- [ ] Streamer 可以創建
- [ ] Publication 可以打開
- [ ] Navigator 可以初始化
- [ ] 資源正確釋放（closeBook）

---

### ⬜ Task 4.2.2: 實現 EPUB 解析功能
- **優先級**: P0
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.2.1

**任務內容**:
1. 使用 Streamer 解析 EPUB
2. 處理不同 EPUB 格式（EPUB2/EPUB3）
3. 提取元數據（標題、作者）
4. 錯誤處理（文件不存在、格式錯誤）

**驗收標準**:
- [ ] 可以解析標準 EPUB2 文件
- [ ] 可以解析標準 EPUB3 文件
- [ ] 元數據提取正確
- [ ] 錯誤處理完善

---

### ⬜ Task 4.2.3: 整合 EpubNavigator
- **優先級**: P0
- **預計時間**: 3 天
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.2.2

**任務內容**:
1. 創建 EpubNavigatorFragment
2. 配置直書/橫書模式
3. 實現翻頁功能
4. 實現位置追蹤

**驗收標準**:
- [ ] EpubNavigator 可以顯示
- [ ] 直書模式正確（RTL）
- [ ] 橫書模式正確（LTR）
- [ ] 翻頁流暢（< 100ms）
- [ ] 位置追蹤準確

---

## Phase 4.3: Flutter 層實現 (1週)

### ⬜ Task 4.3.1: 創建 ReaderPage
- **優先級**: P0
- **預計時間**: 1 天
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.2.3

**任務內容**:
創建閱讀器頁面 UI

**驗收標準**:
- [ ] ReaderPage 已創建
- [ ] AndroidView 正確嵌入
- [ ] 路由配置完成

---

### ⬜ Task 4.3.2: 實現 ReaderController
- **優先級**: P0
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行
- **依賴**: Task 4.3.1

**任務內容**:
實現閱讀器狀態管理

**驗收標準**:
- [ ] ReaderController 已創建
- [ ] 狀態管理正確
- [ ] Platform Channel 調用正常

---

## Phase 4.4: 功能完善 (1週)

### ⬜ Task 4.4.1: 實現書籤功能
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行

### ⬜ Task 4.4.2: 實現閱讀設置
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行

### ⬜ Task 4.4.3: 實現進度保存
- **預計時間**: 1 天
- **狀態**: ⬜ 待執行

### ⬜ Task 4.4.4: 錯誤處理優化
- **預計時間**: 1 天
- **狀態**: ⬜ 待執行

---

## Phase 4.5: 測試優化 (1週)

### ⬜ Task 4.5.1: 單元測試
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行

### ⬜ Task 4.5.2: 整合測試
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行

### ⬜ Task 4.5.3: 性能優化
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行

### ⬜ Task 4.5.4: 用戶測試
- **預計時間**: 1 天
- **狀態**: ⬜ 待執行

---

## 🎯 里程碑

- [x] **M1**: Git 分支創建完成 (2025-11-09)
- [ ] **M2**: Readium 環境搭建完成 (Week 1)
- [ ] **M3**: 基本閱讀功能可用 (Week 3)
- [ ] **M4**: 直書橫書切換正常 (Week 4)
- [ ] **M5**: 功能完整，可測試 (Week 5)
- [ ] **M6**: 測試通過，準備發布 (Week 6)

---

## 📝 每日進度記錄

### 2025-11-09
- ✅ Task 4.1.1: 創建 Git 分支 `feature/reader-refactor`
- ✅ 清理舊的 04 commits
- ✅ 更新開發計劃文檔
- ✅ 完成 Spec 04 規格文檔

### 下一步
- ⬜ Task 4.1.2: 添加 Readium Kotlin 依賴

---

**文檔版本**: 1.0  
**最後更新**: 2025-11-09  
**負責人**: 開發團隊
