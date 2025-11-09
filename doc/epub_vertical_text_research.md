# EPUB 直書模式 (Vertical Text) 技術研究報告

**任務**: Task 4.8.1 - 研究 CSS writing-mode 實現  
**日期**: 2025-11-09  
**狀態**: ✅ 已完成  
**作者**: 技術團隊

---

## 📋 執行摘要

本文檔研究如何在 Flutter epub_view 包中實現 EPUB 直書（垂直文字）模式，使用 CSS `writing-mode` 屬性將文字從傳統的橫向排列轉換為垂直排列（從右到左）。

**核心發現**：
- ✅ epub_view 3.2.0 使用 flutter_html 渲染 EPUB 內容
- ✅ CSS `writing-mode: vertical-rl` 是標準的垂直文字解決方案
- ❌ epub_view **不直接支持**自定義 CSS 注入
- 🔄 需要通過 **替代方案** 實現垂直文字效果

---

## 🔍 技術背景

### 1. epub_view 包架構

**當前使用版本**: `epub_view: ^3.2.0` (pubspec.yaml)

**核心依賴**:
```yaml
dependencies:
  - epubx: ^4.0.0           # EPUB 文件解析
  - flutter_html: ^3.0.0    # HTML/CSS 渲染引擎
  - scrollable_positioned_list: ^0.3.8  # 可定位滾動列表
```

**渲染流程**:
```
EPUB 文件 (.epub)
    ↓
epubx 解析 (提取 HTML + CSS)
    ↓
flutter_html 渲染 (將 HTML 轉換為 Flutter Widget)
    ↓
顯示在螢幕上
```

### 2. CSS Writing Modes Level 3 標準

**W3C 規範**: https://www.w3.org/TR/css-writing-modes-3/

**關鍵 CSS 屬性**:
```css
/* 垂直排列，從右到左 (Traditional Chinese) */
writing-mode: vertical-rl;

/* 垂直排列，從左到右 (Mongolian) */
writing-mode: vertical-lr;

/* 水平排列，從左到右 (Default) */
writing-mode: horizontal-tb;
```

**瀏覽器支持度**:
- ✅ Chrome/Edge: 全面支持
- ✅ Firefox: 全面支持
- ✅ Safari: 全面支持
- ✅ 移動瀏覽器: 全面支持

---

## 🔬 epub_view 能力分析

### 3.1 API 調研結果

**查閱來源**:
- pub.dev 官方文檔: https://pub.dev/packages/epub_view
- GitHub 倉庫: https://github.com/ScerIO/packages.flutter

**可用的自定義選項**:

#### ✅ **支持的自定義**:
```dart
EpubView(
  controller: _epubController,
  
  // 1. 自定義章節分隔符
  builders: EpubViewBuilders<DefaultBuilderOptions>(
    chapterDividerBuilder: (_) => Divider(),
    loaderBuilder: (_) => CircularProgressIndicator(),
    options: DefaultBuilderOptions(),  // ← 這裡可能有選項
  ),
  
  // 2. 事件回調
  onExternalLinkPressed: (href) {},
  onDocumentLoaded: (document) {},
  onChapterChanged: (chapter) {},
  onDocumentError: (error) {},
);
```

#### ❌ **不支持的自定義**:
```dart
// 以下功能在 epub_view 3.2.0 中 **不存在**
EpubView(
  // ❌ 沒有 CSS 注入接口
  customCss: 'body { writing-mode: vertical-rl; }',
  
  // ❌ 沒有樣式覆蓋接口
  styleSheet: CustomStyleSheet(),
  
  // ❌ 沒有 HTML 預處理接口
  htmlPreprocessor: (html) => modifiedHtml,
);
```

### 3.2 DefaultBuilderOptions 分析

**問題**: `DefaultBuilderOptions` 是否包含 CSS 相關選項？

**結論**: 經過文檔查閱，`DefaultBuilderOptions` 主要用於:
- 文字選擇行為
- 鏈接處理方式
- **不包含** CSS 注入或樣式自定義功能

---

## 🚧 實現方案評估

### 方案 1: 修改 EPUB 源文件 ⭐ **推薦**

**原理**: 在加載 EPUB 前，直接修改其內部的 CSS 文件

**優點**:
- ✅ 最可靠的方法
- ✅ 完全控制樣式
- ✅ 不依賴 epub_view 的限制
- ✅ 可以處理所有 EPUB 章節

**缺點**:
- ⚠️ 需要解壓縮 EPUB 文件
- ⚠️ 修改後需要重新打包（或使用臨時目錄）
- ⚠️ 增加加載時間

**實現步驟**:
```dart
// 1. 使用 archive 包解壓 EPUB
final bytes = await File(epubPath).readAsBytes();
final archive = ZipDecoder().decodeBytes(bytes);

// 2. 找到並修改 CSS 文件
for (final file in archive) {
  if (file.name.endsWith('.css')) {
    String css = utf8.decode(file.content);
    
    // 3. 注入 writing-mode
    css = '''
      body {
        writing-mode: vertical-rl !important;
        -webkit-writing-mode: vertical-rl !important;
        -ms-writing-mode: tb-rl !important;
      }
      $css
    ''';
    
    // 4. 更新文件內容
    file.content = utf8.encode(css);
  }
}

// 5. 將修改後的 EPUB 保存到臨時目錄
final modifiedEpubPath = await saveModifiedEpub(archive);

// 6. 使用修改後的 EPUB
_epubController = EpubController(
  document: EpubDocument.openFile(modifiedEpubPath),
);
```

**時間成本**: ~2-3 小時實現 + 1 小時測試

---

### 方案 2: Fork epub_view 並修改源碼

**原理**: 在 flutter_html 渲染層注入 CSS

**優點**:
- ✅ 可以實現任何自定義
- ✅ 一次修改，永久使用

**缺點**:
- ❌ 需要維護自己的 fork
- ❌ 無法獲得官方更新
- ❌ 增加技術債務
- ❌ 不適合小型項目

**結論**: ❌ **不推薦** - 對於我們的項目規模來說過度工程化

---

### 方案 3: 使用 CSS Transform 模擬垂直文字

**原理**: 旋轉整個 EPUB 視圖 90 度

```dart
Transform.rotate(
  angle: -math.pi / 2,
  child: EpubView(controller: _epubController),
)
```

**優點**:
- ✅ 實現簡單

**缺點**:
- ❌ 用戶界面混亂（滾動方向錯誤）
- ❌ 點擊區域錯位
- ❌ 無法處理混合排版

**結論**: ❌ **不推薦** - 用戶體驗差

---

### 方案 4: 等待 epub_view 官方支持

**現狀**: epub_view 沒有計劃支持 CSS 注入（GitHub Issues 查無相關討論）

**結論**: ❌ **不可行** - 無法在合理時間內實現

---

## 📝 推薦實現方案

### 最終選擇: **方案 1 - 修改 EPUB 源文件**

**理由**:
1. **可行性高**: 不依賴第三方包的限制
2. **可維護性好**: 邏輯清晰，易於理解
3. **用戶體驗佳**: 完全原生的垂直文字渲染
4. **時間成本可控**: ~3 小時即可實現

**技術實現細節**:

#### 4.1 文件結構

```
lib/
├── domain/
│   └── services/
│       └── epub_preprocessor.dart  ← 新增：EPUB 預處理器
└── presentation/
    └── controllers/reader/
        └── reader_controller.dart   ← 修改：整合預處理器
```

#### 4.2 核心代碼

```dart
// epub_preprocessor.dart
class EpubPreprocessor {
  /// 為 EPUB 注入直書 CSS
  Future<String> injectVerticalTextCSS(String epubPath) async {
    // 1. 讀取 EPUB 文件
    final bytes = await File(epubPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    
    // 2. 查找並修改 CSS
    final modifiedFiles = <ArchiveFile>[];
    for (final file in archive.files) {
      if (file.name.endsWith('.css')) {
        // 注入 vertical-rl CSS
        String css = utf8.decode(file.content as List<int>);
        css = _injectWritingMode(css);
        
        modifiedFiles.add(ArchiveFile(
          file.name,
          file.size,
          utf8.encode(css),
        ));
      } else {
        modifiedFiles.add(file);
      }
    }
    
    // 3. 保存到臨時文件
    final tempDir = await getTemporaryDirectory();
    final modifiedPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.epub';
    
    final encoder = ZipEncoder();
    final newArchive = Archive()..addAll(modifiedFiles);
    final bytes = encoder.encode(newArchive);
    await File(modifiedPath).writeAsBytes(bytes);
    
    return modifiedPath;
  }
  
  String _injectWritingMode(String css) {
    // 在 CSS 開頭注入 writing-mode
    return '''
      /* Auto-injected for vertical text support */
      body, html {
        writing-mode: vertical-rl !important;
        -webkit-writing-mode: vertical-rl !important;
        -ms-writing-mode: tb-rl !important;
        text-orientation: upright;
      }
      
      $css
    ''';
  }
}
```

#### 4.3 整合到 ReaderController

```dart
// reader_controller.dart
class ReaderController extends GetxController {
  final EpubPreprocessor _preprocessor = EpubPreprocessor();
  
  Future<void> loadBook(String bookPath, ReadingDirection direction) async {
    // 如果是直書模式，預處理 EPUB
    String finalPath = bookPath;
    if (direction == ReadingDirection.vertical) {
      finalPath = await _preprocessor.injectVerticalTextCSS(bookPath);
    }
    
    // 加載 EPUB
    epubController = EpubController(
      document: EpubDocument.openFile(finalPath),
    );
  }
}
```

---

## ⚠️ 潛在問題與解決方案

### 問題 1: EPUB 內部沒有外部 CSS 文件

**情況**: 某些 EPUB 將 CSS 內聯在 HTML 中

**解決方案**:
```dart
// 也需要處理 HTML 文件
if (file.name.endsWith('.html') || file.name.endsWith('.xhtml')) {
  String html = utf8.decode(file.content);
  
  // 在 <head> 中注入 <style>
  html = html.replaceFirst(
    '</head>',
    '<style>body { writing-mode: vertical-rl !important; }</style></head>',
  );
  
  modifiedFiles.add(ArchiveFile(file.name, file.size, utf8.encode(html)));
}
```

### 問題 2: 圖片方向問題

**情況**: 圖片在直書模式下可能需要旋轉

**解決方案**:
```css
/* 保持圖片水平顯示 */
img {
  writing-mode: horizontal-tb !important;
  transform: rotate(0deg);
}
```

### 問題 3: 性能問題

**情況**: 解壓縮和重新打包可能很慢

**解決方案**:
- 使用快取：只處理一次，保存結果
- 異步處理：在背景執行
- 進度提示：顯示「正在準備直書模式...」

```dart
// 添加快取機制
final cacheKey = '${bookPath}_vertical';
final cachedPath = await _cache.get(cacheKey);
if (cachedPath != null && await File(cachedPath).exists()) {
  return cachedPath;  // 使用快取
}

final modifiedPath = await _preprocessEpub(bookPath);
await _cache.set(cacheKey, modifiedPath);
return modifiedPath;
```

---

## ✅ 兼容性測試計劃

### 測試環境
- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (Chrome, Safari, Firefox)
- ✅ Windows/macOS/Linux

### 測試用例

| EPUB 類型 | 版本 | 預期結果 | 測試狀態 |
|-----------|------|----------|----------|
| 標準 EPUB | 2.0 | 文字垂直排列 | ⬜ 待測試 |
| 標準 EPUB | 3.0 | 文字垂直排列 | ⬜ 待測試 |
| 內聯 CSS | 3.0 | 文字垂直排列 | ⬜ 待測試 |
| 無 CSS | 2.0 | 文字垂直排列 | ⬜ 待測試 |
| 圖文混排 | 3.0 | 圖片正常，文字垂直 | ⬜ 待測試 |
| 英文 EPUB | 3.0 | 文字垂直排列（可讀性） | ⬜ 待測試 |

### 測試書籍
使用專案中的測試 EPUB:
```
epub3/
├── 一夢漫言.epub
├── 六祖壇經講記.epub
├── 孔子傳.epub
└── 家家觀世音.epub
```

---

## 📦 依賴包需求

### 新增依賴

```yaml
dependencies:
  # EPUB 解壓縮和修改
  archive: ^3.4.9
  
  # 文件路徑處理
  path: ^1.8.3
```

**說明**: 
- `archive`: 用於解壓縮和重新打包 EPUB（ZIP 格式）
- `path`: 用於跨平台文件路徑處理

**安裝命令**:
```bash
cd app
flutter pub add archive path
```

---

## 📅 實施時間表

### Task 4.8.2: 實現直書 CSS 注入

**預計時間**: 3 小時

**細分任務**:

| 步驟 | 任務 | 預計時間 | 負責人 |
|------|------|----------|--------|
| 1 | 添加依賴 (archive, path) | 10 分鐘 | - |
| 2 | 實現 EpubPreprocessor | 1.5 小時 | - |
| 3 | 整合到 ReaderController | 30 分鐘 | - |
| 4 | 添加快取機制 | 30 分鐘 | - |
| 5 | 基礎測試 (3-5 本書) | 30 分鐘 | - |

**下一步**: 繼續執行 Task 4.8.2

---

## 📚 參考資料

### 技術規範
- [CSS Writing Modes Level 3](https://www.w3.org/TR/css-writing-modes-3/)
- [EPUB 3.0 規範](https://www.w3.org/publishing/epub3/)
- [epub_view 文檔](https://pub.dev/packages/epub_view)

### 相關項目
- [epub_view GitHub](https://github.com/ScerIO/packages.flutter/tree/main/packages/epub_view)
- [flutter_html GitHub](https://github.com/Sub6Resources/flutter_html)

### 學習資源
- [Vertical Text in CSS](https://developer.mozilla.org/en-US/docs/Web/CSS/writing-mode)
- [EPUB 文件結構](https://www.w3.org/publishing/epub3/epub-spec.html)

---

## 📝 附錄

### A. EPUB 文件結構

```
book.epub (ZIP 格式)
├── META-INF/
│   └── container.xml  ← 指向 content.opf
├── OEBPS/
│   ├── content.opf    ← 書籍元數據
│   ├── toc.ncx        ← 目錄
│   ├── Styles/
│   │   └── style.css  ← **這裡注入 writing-mode**
│   ├── Text/
│   │   ├── chapter1.xhtml
│   │   └── chapter2.xhtml
│   └── Images/
│       └── cover.jpg
└── mimetype
```

### B. CSS Writing Mode 屬性完整說明

```css
/* 垂直排列，從右到左（繁體中文、日文） */
writing-mode: vertical-rl;

/* 垂直排列，從左到右（蒙古文） */
writing-mode: vertical-lr;

/* 水平排列，從上到下（英文、簡體中文） */
writing-mode: horizontal-tb;

/* 文字方向（配合 vertical-rl 使用） */
text-orientation: upright;     /* 字符保持直立 */
text-orientation: sideways;    /* 字符側轉 */
text-orientation: mixed;       /* 混合（預設） */

/* 文字組合方向（繁體中文常用） */
text-combine-upright: all;     /* 數字橫排 */
```

### C. 瀏覽器前綴對照表

| 屬性 | 標準語法 | Webkit | MS |
|------|----------|--------|-----|
| writing-mode | `vertical-rl` | `-webkit-writing-mode: vertical-rl` | `-ms-writing-mode: tb-rl` |
| text-orientation | `upright` | `-webkit-text-orientation: upright` | N/A |

---

**研究完成日期**: 2025-11-09  
**文檔版本**: v1.0  
**下次更新**: Task 4.8.2 實施後
