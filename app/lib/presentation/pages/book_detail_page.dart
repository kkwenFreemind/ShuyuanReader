import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/book_detail_controller.dart';

/// 書籍詳情頁面
/// 
/// 顯示書籍的詳細信息，包括：
/// - 封面圖片（帶 Hero 動畫）
/// - 書籍基本信息（書名、作者、語言、文件大小）
/// - 下載狀態和操作按鈕
/// 
/// 使用 GetView 自動注入 BookDetailController
class BookDetailPage extends GetView<BookDetailController> {
  const BookDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('書籍詳情'),
        centerTitle: true,
      ),
      body: Obx(() => _buildBody()),
    );
  }

  /// 構建頁面主體內容
  /// 
  /// 使用 SingleChildScrollView 支持滾動
  /// 內容包括封面、書籍信息和操作按鈕
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverImage(),
          _buildBookInfo(),
          // TODO: 添加操作按鈕組件
        ],
      ),
    );
  }

  /// 構建封面圖片組件
  /// 
  /// 使用 Hero 動畫實現從列表頁到詳情頁的平滑過渡
  /// 使用 CachedNetworkImage 加載網絡圖片並提供緩存
  Widget _buildCoverImage() {
    final book = controller.book.value;
    
    return Hero(
      tag: 'book-cover-${book.id}',
      child: Container(
        width: double.infinity,
        height: 400,
        color: Colors.grey[200],
        child: CachedNetworkImage(
          imageUrl: book.coverUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '封面加載失敗',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 構建書籍信息區域
  /// 
  /// 顯示書名、作者、語言、文件大小和描述信息
  Widget _buildBookInfo() {
    final book = controller.book.value;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 書名
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          
          // 作者
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  book.author,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 語言
          Row(
            children: [
              Icon(
                Icons.language,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                book.language,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 24),
              
              // 文件大小
              Icon(
                Icons.insert_drive_file_outlined,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                book.fileSizeFormatted,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          // 描述（如果有）
          if (book.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              '簡介',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
