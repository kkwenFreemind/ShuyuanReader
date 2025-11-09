/// PoC 閱讀器頁面 - 驗證 epubx + PageView + flutter_html 整合
///
/// **目的**: Task 4.3.1 - 創建 PoC 閱讀器
/// 
/// **技術棧**:
/// - epubx: EPUB 解析
/// - PageView: 分頁翻頁
/// - flutter_html: HTML 渲染
///
/// **整合方式**:
/// - 從現有路由接收 bookId
/// - 從 Hive 讀取已下載的書籍
/// - 使用 Book.localPath 讀取 EPUB 文件
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:epubx/epubx.dart';
// import 'package:flutter_html/flutter_html.dart';  // PoC 改用純文字渲染

import '../../../domain/entities/book.dart';
import '../../../domain/repositories/book_repository.dart';

/// PoC 閱讀器頁面
///
/// 這是一個概念驗證實現，用於測試新技術棧的可行性。
/// 完成驗證後，將整合到正式的 ReaderPageV2 中。
class ReaderPagePoc extends StatefulWidget {
  const ReaderPagePoc({super.key});

  @override
  State<ReaderPagePoc> createState() => _ReaderPagePocState();
}

class _ReaderPagePocState extends State<ReaderPagePoc> {
  // ==================== 狀態 ====================
  
  Book? _book;
  EpubBook? _epubBook;
  List<PageContent> _pages = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  int _currentPage = 0;
  late PageController _pageController;

  // 閱讀配置（可調整）
  double _fontSize = 18.0;
  final double _lineHeight = 1.6;
  final EdgeInsets _pageMargin = const EdgeInsets.all(24.0);

  // ==================== 生命週期 ====================
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBook();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==================== 書籍加載 ====================
  
  /// 加載書籍
  ///
  /// 流程:
  /// 1. 從路由參數獲取 bookId
  /// 2. 從 BookRepository 讀取 Book 實體
  /// 3. 使用 Book.localPath 讀取 EPUB 文件
  /// 4. 使用 epubx 解析
  /// 5. 計算分頁
  Future<void> _loadBook() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. 獲取 bookId（從路由參數）
      final arguments = Get.arguments as Map<String, dynamic>?;
      final bookId = arguments?['bookId'] as String?;
      
      if (bookId == null) {
        throw Exception('缺少必需的參數: bookId');
      }

      print('📚 開始加載書籍: $bookId');

      // 2. 從 Repository 獲取 Book
      final bookRepository = Get.find<BookRepository>();
      _book = await bookRepository.getBookById(bookId);
      
      if (_book == null) {
        throw Exception('找不到書籍: $bookId');
      }

      print('✅ 書籍信息: ${_book!.title}');

      // 3. 檢查是否已下載
      if (!_book!.isDownloaded || _book!.localPath == null) {
        throw Exception('書籍尚未下載，請先下載書籍');
      }

      print('📂 本地路徑: ${_book!.localPath}');

      // 4. 讀取 EPUB 文件
      final file = File(_book!.localPath!);
      
      if (!await file.exists()) {
        throw Exception('找不到 EPUB 文件: ${_book!.localPath}');
      }

      final bookBytes = await file.readAsBytes();
      print('✅ 讀取文件成功: ${bookBytes.length} bytes');

      // 5. 解析 EPUB
      _epubBook = await EpubReader.readBook(bookBytes);
      print('✅ EPUB 解析成功');

      // 6. 獲取章節
      final chapters = _epubBook!.Chapters ?? [];
      print('📚 找到 ${chapters.length} 個章節');

      // 7. 計算分頁
      final pages = await _calculatePages(_epubBook!, chapters);

      setState(() {
        _pages = pages;
        _isLoading = false;
      });

      print('✅ 加載完成: ${_pages.length} 頁');
    } catch (e, stackTrace) {
      print('❌ 加載書籍失敗: $e');
      print('堆疊追蹤: $stackTrace');
      setState(() {
        _errorMessage = '加載失敗: $e';
        _isLoading = false;
      });
    }
  }

  // ==================== 分頁計算 ====================
  
  /// 計算分頁
  ///
  /// 改進版本，解決以下問題：
  /// 1. 過濾掉 "開始" 等非內文元素
  /// 2. 確保每頁內容不超過可視區域（禁止 ScrollView）
  /// 3. 支持動態字體大小調整
  /// 4. 避免最後一行被切斷
  Future<List<PageContent>> _calculatePages(
    EpubBook book,
    List<EpubChapter> chapters,
  ) async {
    final pages = <PageContent>[];
    
    // 獲取螢幕尺寸
    final screenSize = MediaQuery.of(context).size;
    final availableWidth = screenSize.width - _pageMargin.left - _pageMargin.right;
    
    // 計算可用高度：螢幕高度 - AppBar - 上下邊距 - 底部工具欄
    final availableHeight = screenSize.height - 
      _pageMargin.top - 
      _pageMargin.bottom - 
      kToolbarHeight - 
      80; // 預留底部工具欄空間（含上下 padding）

    print('📐 可用尺寸: 寬度 $availableWidth, 高度 $availableHeight');

    // 計算每頁可容納的內容
    final lineHeightPixels = _fontSize * _lineHeight;
    final maxLinesPerPage = (availableHeight / lineHeightPixels).floor();
    final charsPerLine = (availableWidth / (_fontSize * 0.6)).floor(); // 中文字約為字體大小的 0.6 倍寬

    print('📏 每行字數: $charsPerLine, 每頁最多行數: $maxLinesPerPage');

    // 遍歷章節，將內容分頁
    for (final chapter in chapters) {
      if (chapter.HtmlContent == null || chapter.HtmlContent!.isEmpty) {
        continue;
      }

      // 提取純文字內容（保留段落結構）
      final content = _extractTextContent(chapter.HtmlContent!);
      
      if (content.isEmpty) {
        continue;
      }

      // 新的分頁策略：將內容分割成邏輯行，然後按行數分頁
      final logicalLines = _splitIntoLogicalLines(content, charsPerLine);
      
      // 按行數分頁
      int currentLineIndex = 0;
      final chapterStartPageNumber = pages.length; // 記錄這個章節的起始頁碼
      
      while (currentLineIndex < logicalLines.length) {
        // 取出這一頁的行
        final endLineIndex = (currentLineIndex + maxLinesPerPage).clamp(0, logicalLines.length);
        final pageLines = logicalLines.sublist(currentLineIndex, endLineIndex);
        
        // 合併成頁面文字
        String pageText = pageLines.join('\n').trim();
        
        // 如果這不是最後一頁，嘗試在更好的位置切割
        if (endLineIndex < logicalLines.length) {
          // 檢查最後幾行，看看能否在段落邊界處切割
          int adjustedEndIndex = endLineIndex;
          
          // 向前查找空行（段落分隔）
          for (int i = endLineIndex - 1; i >= endLineIndex - 3 && i >= currentLineIndex; i--) {
            if (logicalLines[i].trim().isEmpty) {
              adjustedEndIndex = i;
              pageText = logicalLines.sublist(currentLineIndex, adjustedEndIndex).join('\n').trim();
              break;
            }
          }
          
          // 如果沒找到空行，檢查句子結尾
          if (adjustedEndIndex == endLineIndex && pageLines.isNotEmpty) {
            final lastLine = pageLines.last.trim();
            if (lastLine.isNotEmpty && !_endsWithSentence(lastLine)) {
              // 最後一行不是句子結尾，向前查找句子結尾
              for (int i = pageLines.length - 2; i >= 0 && i >= pageLines.length - 5; i--) {
                if (_endsWithSentence(pageLines[i].trim())) {
                  adjustedEndIndex = currentLineIndex + i + 1;
                  pageText = logicalLines.sublist(currentLineIndex, adjustedEndIndex).join('\n').trim();
                  break;
                }
              }
            }
          }
          
          currentLineIndex = adjustedEndIndex;
        } else {
          currentLineIndex = endLineIndex;
        }
        
        // 只在章節第一頁顯示章節標題
        final isFirstPageOfChapter = (pages.length == chapterStartPageNumber);
        final showTitle = isFirstPageOfChapter && (chapter.Title?.isNotEmpty ?? false);
        
        pages.add(PageContent(
          chapterTitle: showTitle ? chapter.Title! : '',
          textContent: pageText,
          pageNumber: pages.length + 1,
        ));
      }
    }

    print('✅ 分頁完成: ${pages.length} 頁');
    return pages;
  }

  /// 提取 HTML 中的純文字內容
  ///
  /// 保留標題和段落結構，因為標題會佔用更多空間
  /// 過濾掉 "開始" 等導航元素
  String _extractTextContent(String html) {
    String text = html;
    
    // 1. 先處理標題標籤 - 標題前後添加換行，模擬標題的額外空間
    // h1-h3 標題通常字體較大，佔用 2-3 行的空間
    text = text.replaceAllMapped(
      RegExp(r'<h[123][^>]*>(.*?)</h[123]>', caseSensitive: false),
      (match) => '\n\n${match.group(1)}\n\n', // 前後各添加 2 個換行
    );
    
    // h4-h6 標題字體較小，佔用 1.5-2 行的空間
    text = text.replaceAllMapped(
      RegExp(r'<h[456][^>]*>(.*?)</h[456]>', caseSensitive: false),
      (match) => '\n${match.group(1)}\n', // 前後各添加 1 個換行
    );
    
    // 2. 處理段落標籤 - 段落之間添加換行
    text = text.replaceAllMapped(
      RegExp(r'<p[^>]*>(.*?)</p>', caseSensitive: false),
      (match) => '${match.group(1)}\n',
    );
    
    // 3. 處理換行標籤
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    
    // 4. 處理列表項 - 添加縮排和換行
    text = text.replaceAllMapped(
      RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false),
      (match) => '  ${match.group(1)}\n',
    );
    
    // 5. 移除剩餘的 HTML 標籤
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // 6. 解碼 HTML 實體
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    
    // 7. 規範化空白 - 保留換行，但合併連續空格
    text = text.replaceAll(RegExp(r'[ \t]+'), ' '); // 合併空格和 tab
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // 最多保留 2 個連續換行
    text = text.trim();
    
    // 8. 過濾掉常見的導航元素
    final navigationWords = ['開始', '目錄', '下一頁', '上一頁', '返回', 'Start', 'Contents'];
    for (final word in navigationWords) {
      if (text == word || text.startsWith('$word ') || text.endsWith(' $word')) {
        return ''; // 如果整個內容就是導航詞，返回空字串
      }
    }
    
    return text;
  }

  /// 將文字內容分割成邏輯行
  ///
  /// 考慮實際的換行符和每行字數限制
  /// 返回一個字串列表，每個元素代表一個邏輯行
  List<String> _splitIntoLogicalLines(String content, int charsPerLine) {
    final lines = <String>[];
    
    // 先按實際換行符分割
    final paragraphs = content.split('\n');
    
    for (final paragraph in paragraphs) {
      final trimmed = paragraph.trim();
      
      if (trimmed.isEmpty) {
        // 保留空行（段落分隔）
        lines.add('');
        continue;
      }
      
      // 如果段落太長，按字數切割成多行
      if (trimmed.length <= charsPerLine) {
        lines.add(trimmed);
      } else {
        // 長段落需要換行
        int start = 0;
        while (start < trimmed.length) {
          int end = (start + charsPerLine).clamp(0, trimmed.length);
          
          // 如果不是最後一部分，嘗試在標點或空格處切割
          if (end < trimmed.length) {
            // 向前查找最近的標點或空格
            int cutPoint = end;
            for (int i = end - 1; i >= start + (charsPerLine * 0.7).floor() && i > start; i--) {
              final char = trimmed[i];
              if (char == ' ' || char == '，' || char == '。' || char == '、' || 
                  char == '；' || char == '：' || char == '！' || char == '？' ||
                  char == ',' || char == '.' || char == ';' || char == ':' ||
                  char == '!' || char == '?') {
                cutPoint = i + 1;
                break;
              }
            }
            end = cutPoint;
          }
          
          lines.add(trimmed.substring(start, end).trim());
          start = end;
        }
      }
    }
    
    return lines;
  }

  /// 檢查一行文字是否以句子結尾標點結束
  bool _endsWithSentence(String line) {
    if (line.isEmpty) return false;
    
    final lastChar = line[line.length - 1];
    return lastChar == '。' || lastChar == '！' || lastChar == '？' ||
           lastChar == '.' || lastChar == '!' || lastChar == '?';
  }

  /// 尋找最佳的文字切割點（已不使用，保留以備用）
  ///
  /// 優先級：
  /// 1. 段落結尾（雙換行）
  /// 2. 句子結尾（。！？）
  /// 3. 標點符號（，、；：）
  /// 4. 空格
  /// 5. 如果都找不到，使用預定位置
  int _findBestCutPoint(String text, int start, int idealEnd) {
    // 確保不超出範圍
    if (idealEnd >= text.length) {
      return text.length;
    }
    
    // 在 idealEnd 前後搜索最佳切割點的範圍
    final searchRadius = 50; // 前後搜索 50 個字符
    final searchStart = (idealEnd - searchRadius).clamp(start, text.length);
    final searchEnd = (idealEnd + searchRadius).clamp(start, text.length);
    
    // 1. 優先尋找段落結尾（連續的空格或換行）
    final paragraphPattern = RegExp(r'\s{2,}');
    final paragraphMatches = paragraphPattern.allMatches(
      text.substring(searchStart, searchEnd),
    );
    
    if (paragraphMatches.isNotEmpty) {
      // 找最接近 idealEnd 的段落結尾
      int bestMatch = searchStart;
      int minDistance = searchRadius * 2;
      
      for (final match in paragraphMatches) {
        final matchEnd = searchStart + match.end;
        final distance = (matchEnd - idealEnd).abs();
        if (distance < minDistance) {
          minDistance = distance;
          bestMatch = matchEnd;
        }
      }
      
      if (bestMatch > start) {
        return bestMatch;
      }
    }
    
    // 2. 尋找句子結尾標點
    final sentenceEndings = ['。', '！', '？', '.', '!', '?', '. ', '! ', '? '];
    int closestEnd = -1;
    int minDistance = searchRadius * 2;
    
    for (final ending in sentenceEndings) {
      final pos = text.lastIndexOf(ending, searchEnd);
      if (pos >= searchStart) {
        final distance = (pos + ending.length - idealEnd).abs();
        if (distance < minDistance) {
          minDistance = distance;
          closestEnd = pos + ending.length;
        }
      }
    }
    
    if (closestEnd > start) {
      return closestEnd;
    }
    
    // 3. 尋找其他標點符號
    final punctuations = ['，', '、', '；', '：', ',', ';', ':', ', ', '; ', ': '];
    closestEnd = -1;
    minDistance = searchRadius * 2;
    
    for (final punct in punctuations) {
      final pos = text.lastIndexOf(punct, searchEnd);
      if (pos >= searchStart) {
        final distance = (pos + punct.length - idealEnd).abs();
        if (distance < minDistance) {
          minDistance = distance;
          closestEnd = pos + punct.length;
        }
      }
    }
    
    if (closestEnd > start) {
      return closestEnd;
    }
    
    // 4. 尋找空格
    int spacePos = text.lastIndexOf(' ', searchEnd);
    if (spacePos >= searchStart && spacePos > start) {
      return spacePos + 1;
    }
    
    // 5. 找不到合適的切割點，使用預定位置
    return idealEnd;
  }

  /// 重新計算分頁（當字體大小改變時調用）
  Future<void> _recalculatePages() async {
    if (_epubBook == null) return;
    
    setState(() {
      _isLoading = true;
    });

    final chapters = _epubBook!.Chapters ?? [];
    final pages = await _calculatePages(_epubBook!, chapters);

    setState(() {
      _pages = pages;
      _currentPage = 0; // 重置到第一頁
      _isLoading = false;
    });

    _pageController.jumpToPage(0);
  }

  // ==================== UI 構建 ====================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_book?.title ?? 'PoC 閱讀器'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加載中...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBook,
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    if (_pages.isEmpty) {
      return const Center(
        child: Text('沒有內容可顯示'),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _pages.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildPage(_pages[index]);
      },
    );
  }

  /// 構建單頁內容
  Widget _buildPage(PageContent page) {
    return Container(
      margin: _pageMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 章節標題（只在章節第一頁顯示）
          if (page.chapterTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                page.chapterTitle,
                style: TextStyle(
                  fontSize: _fontSize + 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // 純文字內容（不使用 ScrollView，確保內容完全可見）
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                page.textContent,
                style: TextStyle(
                  fontSize: _fontSize,
                  height: _lineHeight,
                ),
                overflow: TextOverflow.clip, // 裁剪超出的內容，不顯示省略號
                maxLines: null, // 允許多行
              ),
            ),
          ),
          
          // 底部工具欄
          _buildPageControls(),
        ],
      ),
    );
  }

  /// 構建頁面控制欄
  Widget _buildPageControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 字體大小調整
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _fontSize > 12 ? () {
                  setState(() {
                    _fontSize -= 2;
                  });
                  _recalculatePages();
                } : null,
                tooltip: '縮小字體',
              ),
              Text('${_fontSize.toInt()}', style: const TextStyle(fontSize: 12)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _fontSize < 32 ? () {
                  setState(() {
                    _fontSize += 2;
                  });
                  _recalculatePages();
                } : null,
                tooltip: '放大字體',
              ),
            ],
          ),
          
          // 頁碼
          Text(
            '${_currentPage + 1}/${_pages.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// 頁面內容數據模型
class PageContent {
  final String chapterTitle;
  final String textContent;  // 改為純文字
  final int pageNumber;

  PageContent({
    required this.chapterTitle,
    required this.textContent,
    required this.pageNumber,
  });
}
