/// Simple PoC Reader
/// 
/// 概念驗證閱讀器，用於驗證：
/// - epubx 解析 EPUB
/// - PageView 分頁
/// - flutter_html 渲染
/// - 基本翻頁功能
/// 
/// 運行方式：
/// flutter run -t lib/poc/simple_reader.dart -d <device_id>

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(const SimplePocReaderApp());
}

class SimplePocReaderApp extends StatelessWidget {
  const SimplePocReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoC 閱讀器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BookListPage(),
    );
  }
}

/// 書籍列表頁面
class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PoC 閱讀器 - 書籍列表'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildBookTile(
            context,
            title: '一夢漫言',
            author: '古籍',
            path: 'epub3/一夢漫言.epub',
          ),
          _buildBookTile(
            context,
            title: '六祖壇經講記',
            author: '淨空法師',
            path: 'epub3/六祖壇經講記.epub',
          ),
          _buildBookTile(
            context,
            title: '金剛經百家集註大成',
            author: '古籍',
            path: 'epub3/金剛經百家集註大成.epub',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'PoC 驗證功能',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '本 PoC 驗證以下技術：\n'
              '✅ epubx - EPUB 解析\n'
              '✅ PageView - 分頁瀏覽\n'
              '✅ flutter_html - HTML 渲染\n'
              '✅ 橫排閱讀體驗',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTile(
    BuildContext context, {
    required String title,
    required String author,
    required String path,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 60,
          color: Colors.blue[100],
          child: const Icon(Icons.book, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(author),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SimpleReaderPage(
                bookTitle: title,
                epubPath: path,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 簡單閱讀器頁面
class SimpleReaderPage extends StatefulWidget {
  final String bookTitle;
  final String epubPath;

  const SimpleReaderPage({
    required this.bookTitle,
    required this.epubPath,
    super.key,
  });

  @override
  State<SimpleReaderPage> createState() => _SimpleReaderPageState();
}

class _SimpleReaderPageState extends State<SimpleReaderPage> {
  List<PageContent> _pages = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  int _currentPage = 0;
  late PageController _pageController;

  // 閱讀配置
  final double _fontSize = 18.0;
  final double _lineHeight = 1.6;
  final EdgeInsets _pageMargin = const EdgeInsets.all(24.0);

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

  /// 加載書籍
  Future<void> _loadBook() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // PoC 測試：使用絕對路徑直接讀取 epub3 目錄
      final absolutePath = r'D:\SideProject\ShuyuanReader\' + widget.epubPath.replaceAll('/', r'\');
      final epubFile = File(absolutePath);
      
      print('📂 嘗試讀取文件: ${epubFile.path}');
      
      if (!await epubFile.exists()) {
        throw Exception('找不到文件: ${epubFile.path}');
      }

      // 2. 解析 EPUB
      final bookBytes = await epubFile.readAsBytes();
      print('✅ 讀取成功: ${bookBytes.length} bytes');
      
      final book = await EpubReader.readBook(bookBytes);
      print('✅ EPUB 解析成功');

      // 3. 獲取章節
      final chapters = book.Chapters ?? [];
      print('📚 找到 ${chapters.length} 個章節');

      // 4. 計算分頁
      final pages = await _calculatePages(book, chapters);

      setState(() {
        _pages = pages;
        _isLoading = false;
      });

      print('📚 書籍加載成功: ${book.Title}');
      print('📄 總章節數: ${chapters.length}');
      print('📖 總頁數: ${pages.length}');
    } catch (e, stackTrace) {
      print('❌ 加載書籍失敗: $e');
      print(stackTrace);
      setState(() {
        _errorMessage = '加載失敗: $e';
        _isLoading = false;
      });
    }
  }

  /// 計算分頁
  Future<List<PageContent>> _calculatePages(
    EpubBook book,
    List<EpubChapter> chapters,
  ) async {
    final pages = <PageContent>[];

    for (var i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      final html = chapter.HtmlContent ?? '';

      if (html.isEmpty) continue;

      // 簡化版分頁：每個章節一頁
      // TODO: 實現真正的分頁邏輯
      pages.add(PageContent(
        pageNumber: pages.length + 1,
        chapterIndex: i,
        chapterTitle: chapter.Title ?? '未命名章節',
        htmlContent: html,
      ));
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
        backgroundColor: Colors.blue,
        actions: [
          if (!_isLoading && _pages.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentPage + 1} / ${_pages.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
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
            Text('正在加載書籍...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
        ),
      );
    }

    if (_pages.isEmpty) {
      return const Center(
        child: Text('書籍內容為空'),
      );
    }

    return Stack(
      children: [
        // 主內容區域
        PageView.builder(
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
        ),
        
        // 底部導航提示
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentPage > 0)
                  TextButton.icon(
                    onPressed: _previousPage,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('上一頁', style: TextStyle(color: Colors.white)),
                  ),
                const SizedBox(width: 16),
                Text(
                  '第 ${_currentPage + 1} 頁 / 共 ${_pages.length} 頁',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                if (_currentPage < _pages.length - 1)
                  TextButton.icon(
                    onPressed: _nextPage,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text('下一頁', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(PageContent page) {
    return Container(
      padding: _pageMargin,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 章節標題
            if (page.chapterTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  page.chapterTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            // HTML 內容
            Html(
              data: page.htmlContent,
              style: {
                'body': Style(
                  fontSize: FontSize(_fontSize),
                  lineHeight: LineHeight(_lineHeight),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                'p': Style(
                  fontSize: FontSize(_fontSize),
                  lineHeight: LineHeight(_lineHeight),
                  margin: Margins.only(bottom: 12),
                ),
                'h1': Style(
                  fontSize: FontSize(_fontSize * 1.5),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 16, top: 16),
                ),
                'h2': Style(
                  fontSize: FontSize(_fontSize * 1.3),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 12, top: 12),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

/// 頁面內容數據模型
class PageContent {
  final int pageNumber;
  final int chapterIndex;
  final String chapterTitle;
  final String htmlContent;

  PageContent({
    required this.pageNumber,
    required this.chapterIndex,
    required this.chapterTitle,
    required this.htmlContent,
  });
}
