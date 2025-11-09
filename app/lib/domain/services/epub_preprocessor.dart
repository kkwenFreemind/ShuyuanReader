/// EPUB 預處理服務
///
/// **職責**：
/// 這個服務負責在加載 EPUB 文件之前對其進行預處理，主要用於注入自定義樣式。
/// 支持的功能包括：直書模式 CSS、字體大小調整等。
///
/// **主要功能**：
/// - 解壓縮 EPUB 文件（ZIP 格式）
/// - 在 CSS 文件中注入 writing-mode 屬性（直書模式）
/// - 在 CSS 文件中注入 font-size 屬性（字體大小）
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
/// // 使用設置處理 EPUB
/// final modifiedPath = await preprocessor.processWithSettings(
///   epubPath: '/path/to/book.epub',
///   bookId: 'book_123',
///   isVerticalText: true,
///   fontSize: 16.0,
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
/// 用於修改 EPUB 文件以支持直書模式、字體大小調整等自定義功能。
class EpubPreprocessor {
  /// 使用指定設置處理 EPUB
  ///
  /// 此方法會根據提供的設置注入相應的 CSS：
  /// 1. 解壓縮 EPUB 文件
  /// 2. 根據設置注入 CSS（直書模式、字體大小等）
  /// 3. 重新打包為新的 EPUB 文件
  /// 4. 使用快取避免重複處理
  ///
  /// **參數**：
  /// - [epubPath]: 原始 EPUB 文件路徑
  /// - [bookId]: 書籍唯一 ID，用於快取識別
  /// - [isVerticalText]: 是否啟用直書模式（預設 false）
  /// - [fontSize]: 字體大小（sp），預設 16.0
  ///
  /// **返回**：
  /// 處理後的 EPUB 文件路徑（臨時目錄）
  ///
  /// **異常**：
  /// - [FileSystemException]: 文件讀寫錯誤
  /// - [ArchiveException]: ZIP 解壓縮錯誤
  Future<String> processWithSettings({
    required String epubPath,
    required String bookId,
    bool isVerticalText = false,
    double fontSize = 16.0,
  }) async {
    // 1. 檢查快取
    final cachedPath = await _getCachedPath(
      bookId,
      isVerticalText: isVerticalText,
      fontSize: fontSize,
    );
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
          final modifiedContent = _injectCssStyles(
            file,
            isVerticalText: isVerticalText,
            fontSize: fontSize,
          );
          modifiedArchive.addFile(modifiedContent);
        } else if (fileName.endsWith('.html') ||
            fileName.endsWith('.xhtml') ||
            fileName.endsWith('.htm')) {
          // 修改 HTML 文件
          final modifiedContent = _injectHtmlStyle(
            file,
            isVerticalText: isVerticalText,
            fontSize: fontSize,
          );
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
    final outputPath = await _saveModifiedEpub(
      bookId,
      modifiedBytes!,
      isVerticalText: isVerticalText,
      fontSize: fontSize,
    );

    return outputPath;
  }

  /// 處理 EPUB 以支持直書模式（向後兼容方法）
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
  ///
  /// **注意**：
  /// 此方法已被 [processWithSettings] 取代，保留是為了向後兼容。
  @Deprecated('Use processWithSettings instead')
  Future<String> processForVerticalText({
    required String epubPath,
    required String bookId,
  }) async {
    return processWithSettings(
      epubPath: epubPath,
      bookId: bookId,
      isVerticalText: true,
      fontSize: 16.0,
    );
  }

  /// 在 CSS 文件中注入樣式（直書模式、字體大小等）
  ///
  /// 根據設置注入對應的 CSS 規則：
  /// - 直書模式：writing-mode: vertical-rl
  /// - 字體大小：font-size: {fontSize}px
  ///
  /// **參數**：
  /// - [file]: 原始 CSS 文件
  /// - [isVerticalText]: 是否啟用直書模式
  /// - [fontSize]: 字體大小（sp）
  ///
  /// **返回**：
  /// 修改後的 ArchiveFile
  ArchiveFile _injectCssStyles(
    ArchiveFile file, {
    required bool isVerticalText,
    required double fontSize,
  }) {
    try {
      // 解碼 CSS 內容
      String css = utf8.decode(file.content as List<int>, allowMalformed: true);

      // 構建注入的 CSS
      final injectedStyles = _buildInjectedCss(
        isVerticalText: isVerticalText,
        fontSize: fontSize,
      );

      // 在 CSS 開頭注入樣式
      final modifiedCss = '$injectedStyles\n\n/* 原始 CSS */\n$css';

      // 創建新的 ArchiveFile
      return ArchiveFile(
        file.name,
        modifiedCss.length,
        utf8.encode(modifiedCss),
      );
    } catch (e) {
      // 如果解碼失敗，返回原文件
      return file;
    }
  }

  /// 構建要注入的 CSS 樣式
  ///
  /// 根據設置生成 CSS 規則字符串。
  String _buildInjectedCss({
    required bool isVerticalText,
    required double fontSize,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('/* Auto-injected custom styles */');

    // 直書模式 CSS
    if (isVerticalText) {
      buffer.writeln('''
/* 直書模式 (Vertical Text Mode) */
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
''');
    }

    // 字體大小 CSS
    buffer.writeln('''
/* 字體大小設置 (Font Size: ${fontSize}sp) */
body, p, div, span, li, td, th {
  font-size: ${fontSize}px !important;
}

/* 標題使用相對大小 */
h1 { font-size: ${fontSize * 1.8}px !important; }
h2 { font-size: ${fontSize * 1.6}px !important; }
h3 { font-size: ${fontSize * 1.4}px !important; }
h4 { font-size: ${fontSize * 1.2}px !important; }
h5 { font-size: ${fontSize * 1.1}px !important; }
h6 { font-size: ${fontSize}px !important; }
''');

    return buffer.toString();
  }

  /// 在 CSS 文件中注入 writing-mode 屬性（已棄用）
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
  ///
  /// **注意**：
  /// 此方法已被 [_injectCssStyles] 取代，保留是為了向後兼容。
  @Deprecated('Use _injectCssStyles instead')
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
  ///
  /// **參數**：
  /// - [file]: 原始 HTML 文件
  /// - [isVerticalText]: 是否啟用直書模式
  /// - [fontSize]: 字體大小（sp）
  ///
  /// **返回**：
  /// 修改後的 ArchiveFile
  ArchiveFile _injectHtmlStyle(
    ArchiveFile file, {
    required bool isVerticalText,
    required double fontSize,
  }) {
    try {
      // 解碼 HTML 內容
      String html =
          utf8.decode(file.content as List<int>, allowMalformed: true);

      // 檢查是否已經有我們的樣式（避免重複注入）
      if (html.contains('/* Auto-injected custom styles')) {
        return file;
      }

      // 構建 <style> 標籤
      final injectedStyles = _buildInjectedCss(
        isVerticalText: isVerticalText,
        fontSize: fontSize,
      );
      final styleTag = '<style>\n$injectedStyles</style>\n';

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
  /// 快取命名規則：`{bookId}_{v|h}_{fontSize}.epub`
  /// - v: vertical (直書)
  /// - h: horizontal (橫書)
  /// - fontSize: 字體大小（整數）
  ///
  /// 例如：`book123_v_16.epub`（直書，16sp）
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  /// - [isVerticalText]: 是否直書模式
  /// - [fontSize]: 字體大小
  ///
  /// **返回**：
  /// 快取文件路徑，如果不存在則返回 null
  Future<String?> _getCachedPath(
    String bookId, {
    required bool isVerticalText,
    required double fontSize,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final direction = isVerticalText ? 'v' : 'h';
      final fontSizeInt = fontSize.round();
      final cachedPath = p.join(
        tempDir.path,
        'epub_cache',
        '${bookId}_${direction}_$fontSizeInt.epub',
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
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  /// - [bytes]: EPUB 文件字節
  /// - [isVerticalText]: 是否直書模式
  /// - [fontSize]: 字體大小
  ///
  /// **返回**：
  /// 保存的文件路徑
  Future<String> _saveModifiedEpub(
    String bookId,
    List<int> bytes, {
    required bool isVerticalText,
    required double fontSize,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory(p.join(tempDir.path, 'epub_cache'));

    // 確保快取目錄存在
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    // 保存文件（使用與 _getCachedPath 相同的命名規則）
    final direction = isVerticalText ? 'v' : 'h';
    final fontSizeInt = fontSize.round();
    final outputPath = p.join(
      cacheDir.path,
      '${bookId}_${direction}_$fontSizeInt.epub',
    );
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
  ///
  /// 如果不指定設置，則清除該書籍的所有快取變體。
  ///
  /// **參數**：
  /// - [bookId]: 書籍 ID
  /// - [isVerticalText]: 可選，是否直書模式
  /// - [fontSize]: 可選，字體大小
  Future<void> clearBookCache(
    String bookId, {
    bool? isVerticalText,
    double? fontSize,
  }) async {
    try {
      if (isVerticalText != null && fontSize != null) {
        // 清除特定設置的快取
        final cachedPath = await _getCachedPath(
          bookId,
          isVerticalText: isVerticalText,
          fontSize: fontSize,
        );
        if (cachedPath != null && await File(cachedPath).exists()) {
          await File(cachedPath).delete();
        }
      } else {
        // 清除該書籍的所有快取變體
        final tempDir = await getTemporaryDirectory();
        final cacheDir = Directory(p.join(tempDir.path, 'epub_cache'));

        if (await cacheDir.exists()) {
          final files = await cacheDir.list().toList();
          for (final file in files) {
            if (file is File && file.path.contains(bookId)) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      // 忽略錯誤
    }
  }
}
