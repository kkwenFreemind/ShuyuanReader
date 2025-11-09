/// EPUB 預處理服務
///
/// **職責**：
/// 這個服務負責在加載 EPUB 文件之前對其進行預處理，主要用於注入自定義樣式。
/// 最重要的功能是為直書模式注入 CSS `writing-mode: vertical-rl`。
///
/// **主要功能**：
/// - 解壓縮 EPUB 文件（ZIP 格式）
/// - 在 CSS 文件中注入 writing-mode 屬性
/// - 在 HTML 文件的 <head> 中注入 <style> 標籤
/// - 重新打包 EPUB 文件
/// - 快取處理結果以提升性能
///
/// **技術細節**：
/// EPUB 是一個 ZIP 文件，包含以下結構：
/// ```
/// book.epub
/// ├── META-INF/container.xml
/// ├── OEBPS/
/// │   ├── content.opf
/// │   ├── Styles/style.css      ← 修改這裡
/// │   ├── Text/chapter1.xhtml   ← 也修改這裡（如果沒有外部 CSS）
/// │   └── Images/
/// └── mimetype
/// ```
///
/// **使用示例**：
/// ```dart
/// final preprocessor = EpubPreprocessor();
///
/// // 為直書模式處理 EPUB
/// final modifiedPath = await preprocessor.processForVerticalText(
///   epubPath: '/path/to/book.epub',
///   bookId: 'book_123',
/// );
///
/// // 使用處理後的 EPUB
/// final controller = EpubController(
///   document: EpubDocument.openFile(modifiedPath),
/// );
/// ```
library;

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// EPUB 預處理器
///
/// 用於修改 EPUB 文件以支持直書模式等自定義功能。
class EpubPreprocessor {
  /// 處理 EPUB 以支持直書模式
  ///
  /// 此方法會：
  /// 1. 解壓縮 EPUB 文件
  /// 2. 在所有 CSS 文件中注入 vertical-rl
  /// 3. 在所有 HTML/XHTML 文件的 <head> 中注入 <style>
  /// 4. 重新打包為新的 EPUB 文件
  /// 5. 使用快取避免重複處理
  ///
  /// **參數**：
  /// - [epubPath]: 原始 EPUB 文件路徑
  /// - [bookId]: 書籍唯一 ID，用於快取識別
  ///
  /// **返回**：
  /// 處理後的 EPUB 文件路徑（臨時目錄）
  ///
  /// **異常**：
  /// - [FileSystemException]: 文件讀寫錯誤
  /// - [ArchiveException]: ZIP 解壓縮錯誤
  Future<String> processForVerticalText({
    required String epubPath,
    required String bookId,
  }) async {
    // 1. 檢查快取
    final cachedPath = await _getCachedPath(bookId);
    if (cachedPath != null && await File(cachedPath).exists()) {
      return cachedPath;
    }

    // 2. 讀取原始 EPUB 文件
    final epubBytes = await File(epubPath).readAsBytes();

    // 3. 解壓縮 EPUB（本質上是 ZIP 文件）
    final archive = ZipDecoder().decodeBytes(epubBytes);

    // 4. 修改文件並重新打包
    final modifiedArchive = Archive();

    for (final file in archive) {
      if (file.isFile) {
        final fileName = file.name.toLowerCase();

        if (fileName.endsWith('.css')) {
          // 修改 CSS 文件
          final modifiedContent = _injectCssWritingMode(file);
          modifiedArchive.addFile(modifiedContent);
        } else if (fileName.endsWith('.html') ||
            fileName.endsWith('.xhtml') ||
            fileName.endsWith('.htm')) {
          // 修改 HTML 文件
          final modifiedContent = _injectHtmlStyle(file);
          modifiedArchive.addFile(modifiedContent);
        } else {
          // 其他文件保持不變
          modifiedArchive.addFile(file);
        }
      }
    }

    // 5. 編碼為新的 ZIP
    final encoder = ZipEncoder();
    final modifiedBytes = encoder.encode(modifiedArchive);

    // 6. 保存到臨時目錄
    final outputPath = await _saveModifiedEpub(bookId, modifiedBytes!);

    return outputPath;
  }

  /// 在 CSS 文件中注入 writing-mode 屬性
  ///
  /// 注入的 CSS：
  /// ```css
  /// body, html {
  ///   writing-mode: vertical-rl !important;
  ///   -webkit-writing-mode: vertical-rl !important;
  ///   -ms-writing-mode: tb-rl !important;
  ///   text-orientation: upright;
  /// }
  /// ```
  ArchiveFile _injectCssWritingMode(ArchiveFile file) {
    try {
      // 解碼 CSS 內容
      String css = utf8.decode(file.content as List<int>, allowMalformed: true);

      // 在 CSS 開頭注入 writing-mode
      final injectedCss = '''
/* Auto-injected for vertical text support (直書模式) */
body, html {
  writing-mode: vertical-rl !important;
  -webkit-writing-mode: vertical-rl !important;
  -ms-writing-mode: tb-rl !important;
  text-orientation: upright;
}

/* 保持圖片水平顯示 */
img {
  writing-mode: horizontal-tb !important;
}

/* 原始 CSS */
$css
''';

      // 創建新的 ArchiveFile
      return ArchiveFile(
        file.name,
        injectedCss.length,
        utf8.encode(injectedCss),
      );
    } catch (e) {
      // 如果解碼失敗，返回原文件
      return file;
    }
  }

  /// 在 HTML 文件的 <head> 中注入 <style> 標籤
  ///
  /// 這是為了處理沒有外部 CSS 文件的 EPUB。
  ArchiveFile _injectHtmlStyle(ArchiveFile file) {
    try {
      // 解碼 HTML 內容
      String html =
          utf8.decode(file.content as List<int>, allowMalformed: true);

      // 檢查是否已經有我們的樣式（避免重複注入）
      if (html.contains('/* Auto-injected for vertical text support')) {
        return file;
      }

      // 在 </head> 之前注入 <style>
      final styleTag = '''
<style>
/* Auto-injected for vertical text support (直書模式) */
body, html {
  writing-mode: vertical-rl !important;
  -webkit-writing-mode: vertical-rl !important;
  -ms-writing-mode: tb-rl !important;
  text-orientation: upright;
}

img {
  writing-mode: horizontal-tb !important;
}
</style>
''';

      // 嘗試在 </head> 前插入
      if (html.contains('</head>')) {
        html = html.replaceFirst('</head>', '$styleTag</head>');
      } else if (html.contains('<body')) {
        // 如果沒有 </head>，在 <body> 前插入
        html = html.replaceFirst('<body', '$styleTag<body');
      } else {
        // 作為最後手段，在文件開頭插入
        html = styleTag + html;
      }

      // 創建新的 ArchiveFile
      return ArchiveFile(
        file.name,
        html.length,
        utf8.encode(html),
      );
    } catch (e) {
      // 如果解碼失敗，返回原文件
      return file;
    }
  }

  /// 獲取快取的 EPUB 路徑
  ///
  /// 快取命名規則：`{bookId}_vertical.epub`
  Future<String?> _getCachedPath(String bookId) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cachedPath = p.join(
        tempDir.path,
        'epub_cache',
        '${bookId}_vertical.epub',
      );

      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 保存修改後的 EPUB 到臨時目錄
  Future<String> _saveModifiedEpub(String bookId, List<int> bytes) async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(p.join(tempDir.path, 'epub_cache'));

    // 確保快取目錄存在
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    // 保存文件
    final outputPath = p.join(cacheDir.path, '${bookId}_vertical.epub');
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(bytes);

    return outputPath;
  }

  /// 清除快取的 EPUB 文件
  ///
  /// 用於釋放存儲空間。
  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory(p.join(tempDir.path, 'epub_cache'));

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      // 忽略錯誤
    }
  }

  /// 清除特定書籍的快取
  Future<void> clearBookCache(String bookId) async {
    try {
      final cachedPath = await _getCachedPath(bookId);
      if (cachedPath != null && await File(cachedPath).exists()) {
        await File(cachedPath).delete();
      }
    } catch (e) {
      // 忽略錯誤
    }
  }
}
