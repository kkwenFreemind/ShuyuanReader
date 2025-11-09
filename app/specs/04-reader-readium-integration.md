# 05 閱讀器整合開發任務 - Readium Kotlin 混合方案

**開始日期**: 2025-11-09  
**預計完成**: 2025-12-20 (6週)  
**優先級**: P0 (核心功能)  
**狀態**: 🚀 進行中  
**Git 分支**: `feature/reader-readium-integration`

---

## 📊 項目概述

### 目標

整合 Readium Kotlin Toolkit 到 ShuyuanReader，實現專業級的 EPUB 直書橫書閱讀功能。

### 技術架構

```
┌─────────────────────────────────────────────────────┐
│                   Flutter Layer                     │
│  (UI, 導航, 書籍管理, 設置)                         │
└──────────────────┬──────────────────────────────────┘
                   │
         Platform Channel (MethodChannel)
                   │
┌──────────────────▼──────────────────────────────────┐
│              Readium Kotlin Layer                   │
│  (EPUB 解析, 分頁計算, 內容渲染, 直書支持)          │
└─────────────────────────────────────────────────────┘
```

### 核心技術棧

**Flutter 側**:
- GetX (狀態管理)
- Platform Channel (Flutter ↔ Android 通訊)
- epubx (備用，用於元數據提取)

**Android 側**:
- Readium Kotlin Toolkit 3.1.2
  - readium-shared (數據模型)
  - readium-streamer (EPUB 解析)
  - readium-navigator (閱讀器核心)
- Kotlin Coroutines (異步處理)

---

## 📅 開發階段規劃

### Phase 5.1: 環境準備與學習 (1週)

**目標**: 搭建 Readium 開發環境，理解 API

#### ✅ Task 5.1.1: 創建新的 Git 分支
- **優先級**: P0
- **預計時間**: 5 分鐘
- **狀態**: ⬜ 待執行

**步驟**:
```bash
cd d:\SideProject\ShuyuanReader\app
git checkout -b feature/reader-readium-integration
git push -u origin feature/reader-readium-integration
```

**驗收標準**:
- [ ] 分支已創建
- [ ] 分支已推送到遠端

---

#### ⬜ Task 5.1.2: 添加 Readium Kotlin 依賴
- **優先級**: P0
- **預計時間**: 30 分鐘
- **狀態**: ⬜ 待執行

**步驟**:

1. 修改 `android/build.gradle.kts`:
```kotlin
buildscript {
    ext {
        kotlin_version = "1.9.0"
        readium_version = "3.1.2"
    }
    
    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}
```

2. 修改 `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
}

android {
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    val readium_version = rootProject.extra["readium_version"]
    
    implementation("org.readium.kotlin-toolkit:readium-shared:$readium_version")
    implementation("org.readium.kotlin-toolkit:readium-streamer:$readium_version")
    implementation("org.readium.kotlin-toolkit:readium-navigator:$readium_version")
    
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

**驗收標準**:
- [ ] 依賴已添加
- [ ] Gradle 同步成功
- [ ] 無版本衝突

---

#### ⬜ Task 5.1.3: 學習 Readium Kotlin API
- **優先級**: P1
- **預計時間**: 3 天
- **狀態**: ⬜ 待執行

**學習資源**:
- 官方文檔: https://readium.org/kotlin-toolkit/
- GitHub: https://github.com/readium/kotlin-toolkit
- 範例應用: https://github.com/readium/kotlin-toolkit/tree/main/test-app

**學習重點**:
1. ✅ Readium 架構概念
   - Publication (書籍模型)
   - Streamer (解析器)
   - Navigator (導航器/渲染器)
   
2. ✅ EPUB 解析流程
   - Asset 加載
   - Publication 創建
   - Manifest 讀取

3. ✅ 閱讀器配置
   - 直書/橫書設置
   - 分頁模式
   - 字體、字號、行距

4. ✅ 事件處理
   - 翻頁事件
   - 進度追蹤
   - 用戶交互

**交付物**:
- [ ] 學習筆記文檔 `docs/readium-learning-notes.md`
- [ ] 簡單的 Kotlin 測試代碼

---

#### ⬜ Task 5.1.4: 搭建基礎 Platform Channel
- **優先級**: P0
- **預計時間**: 2 小時
- **狀態**: ⬜ 待執行

**Flutter 側** (`lib/platform/epub_reader_channel.dart`):
```dart
import 'package:flutter/services.dart';

class EpubReaderChannel {
  static const MethodChannel _channel =
      MethodChannel('com.shuyuan.reader/epub');

  /// 打開書籍
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

  /// 關閉書籍
  static Future<void> closeBook() async {
    await _channel.invokeMethod('closeBook');
  }

  /// 下一頁
  static Future<void> nextPage() async {
    await _channel.invokeMethod('nextPage');
  }

  /// 上一頁
  static Future<void> previousPage() async {
    await _channel.invokeMethod('previousPage');
  }

  /// 獲取當前位置
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    final result = await _channel.invokeMethod('getCurrentLocation');
    return Map<String, dynamic>.from(result);
  }

  /// 設置字體大小
  static Future<void> setFontSize(double size) async {
    await _channel.invokeMethod('setFontSize', {'size': size});
  }
}
```

**Android 側** (`android/app/src/main/kotlin/com/shuyuan/shuyuan_reader/MainActivity.kt`):
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
                    else -> result.notImplemented()
                }
            }
    }
}
```

**驗收標準**:
- [ ] Platform Channel 已創建
- [ ] 基本方法已定義
- [ ] 編譯成功

---

### Phase 5.2: Readium 核心整合 (2週)

#### ⬜ Task 5.2.1: 實現 ReadiumBridge 基礎類
- **優先級**: P0
- **預計時間**: 1 天
- **狀態**: ⬜ 待執行

**文件**: `android/app/src/main/kotlin/com/shuyuan/shuyuan_reader/ReadiumBridge.kt`

```kotlin
package com.shuyuan.shuyuan_reader

import android.content.Context
import org.readium.r2.shared.publication.Publication
import org.readium.r2.streamer.Streamer
import org.readium.r2.navigator.epub.EpubNavigatorFragment
import kotlinx.coroutines.*

class ReadiumBridge(private val context: Context) {
    private var currentPublication: Publication? = null
    private var navigator: EpubNavigatorFragment? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    suspend fun openBook(filePath: String, isVertical: Boolean) {
        // TODO: 實現書籍打開邏輯
    }

    fun closeBook() {
        currentPublication?.close()
        currentPublication = null
        navigator = null
    }

    fun nextPage() {
        navigator?.goForward()
    }

    fun previousPage() {
        navigator?.goBackward()
    }

    fun getCurrentLocation(): Map<String, Any> {
        // TODO: 返回當前位置信息
        return mapOf(
            "chapter" to 0,
            "page" to 0,
            "progress" to 0.0
        )
    }

    fun setFontSize(size: Double) {
        // TODO: 設置字體大小
    }
}
```

**驗收標準**:
- [ ] ReadiumBridge 類已創建
- [ ] 基本方法已實現
- [ ] 編譯成功

---

#### ⬜ Task 5.2.2: 實現 EPUB 解析功能
- **優先級**: P0
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行

**實現步驟**:
1. 使用 Streamer 解析 EPUB
2. 創建 Publication 對象
3. 提取書籍元數據
4. 處理直書/橫書配置

**驗收標準**:
- [ ] 可以成功解析 EPUB 文件
- [ ] 元數據提取正確
- [ ] 直書配置正確識別

---

#### ⬜ Task 5.2.3: 整合 EpubNavigator
- **優先級**: P0
- **預計時間**: 3 天
- **狀態**: ⬜ 待執行

**實現步驟**:
1. 創建 EpubNavigatorFragment
2. 配置閱讀器設置（直書/橫書）
3. 處理翻頁事件
4. 實現進度追蹤

**驗收標準**:
- [ ] 閱讀器可以正常顯示
- [ ] 翻頁功能正常
- [ ] 直書模式可切換
- [ ] 進度追蹤正常

---

### Phase 5.3: Flutter 層實現 (1週)

#### ⬜ Task 5.3.1: 創建 ReadiumReaderPage
- **優先級**: P0
- **預計時間**: 1 天
- **狀態**: ⬜ 待執行

**文件**: `lib/presentation/pages/reader/readium_reader_page.dart`

使用 AndroidView 嵌入原生閱讀器視圖。

**驗收標準**:
- [ ] 頁面已創建
- [ ] AndroidView 正確嵌入
- [ ] 路由配置完成

---

#### ⬜ Task 5.3.2: 實現閱讀器控制器
- **優先級**: P0
- **預計時間**: 2 天
- **狀態**: ⬜ 待執行

**文件**: `lib/presentation/pages/reader/readium_reader_controller.dart`

整合 Platform Channel，管理閱讀狀態。

**驗收標準**:
- [ ] 控制器已創建
- [ ] Platform Channel 調用正常
- [ ] 狀態管理正確

---

### Phase 5.4: 功能完善 (1週)

#### ⬜ Task 5.4.1: 實現進度保存
#### ⬜ Task 5.4.2: 實現字體設置
#### ⬜ Task 5.4.3: 實現主題切換
#### ⬜ Task 5.4.4: 錯誤處理和日誌

---

### Phase 5.5: 測試優化 (1週)

#### ⬜ Task 5.5.1: 單元測試
#### ⬜ Task 5.5.2: 整合測試
#### ⬜ Task 5.5.3: 性能優化
#### ⬜ Task 5.5.4: 用戶測試

---

## 📈 進度追蹤

| Phase | 任務數 | 預計時間 | 完成數 | 進度 |
|-------|-------|---------|-------|------|
| Phase 5.1: 環境準備 | 4 | 1週 | 0 | ⬜ 0% |
| Phase 5.2: 核心整合 | 3 | 2週 | 0 | ⬜ 0% |
| Phase 5.3: Flutter 層 | 2 | 1週 | 0 | ⬜ 0% |
| Phase 5.4: 功能完善 | 4 | 1週 | 0 | ⬜ 0% |
| Phase 5.5: 測試優化 | 4 | 1週 | 0 | ⬜ 0% |
| **總計** | **17** | **6週** | **0** | **0%** |

---

## 🎯 里程碑

- [ ] **M1**: Readium 環境搭建完成 (Week 1)
- [ ] **M2**: 基本閱讀功能可用 (Week 3)
- [ ] **M3**: 直書橫書切換正常 (Week 4)
- [ ] **M4**: 功能完整，可測試 (Week 5)
- [ ] **M5**: 測試通過，準備發布 (Week 6)

---

## 📚 參考資源

- Readium Kotlin 官網: https://readium.org/kotlin-toolkit/
- GitHub 倉庫: https://github.com/readium/kotlin-toolkit
- 測試應用: https://github.com/readium/kotlin-toolkit/tree/main/test-app
- 文檔: https://readium.org/kotlin-toolkit/docs/
- 社群: https://readium.org/community/

---

## 🔗 相關文檔

- `specs/03-book-detail.md` - 前置任務（已完成）
- `specs/04-reader-view-tasks-archive.md` - 廢棄的純 Flutter 方案
- `specs/poc_validation_result.md` - PoC 驗證結果
- `docs/readium-learning-notes.md` - Readium 學習筆記（待創建）

---

**最後更新**: 2025-11-09  
**負責人**: 開發團隊  
**審核狀態**: 待確認
