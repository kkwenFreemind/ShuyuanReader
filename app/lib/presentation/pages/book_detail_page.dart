import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/book_detail_controller.dart';
import '../../data/models/download_status.dart';

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
          _buildActionButtons(),
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

  /// 構建操作按鈕區域
  /// 
  /// 根據書籍的下載狀態顯示不同的操作按鈕
  Widget _buildActionButtons() {
    final book = controller.book.value;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: () {
        switch (book.downloadStatus) {
          case DownloadStatus.notDownloaded:
            return _buildDownloadButton();
          case DownloadStatus.downloading:
            return _buildDownloadingWidget();
          case DownloadStatus.paused:
            // TODO: 實現暫停狀態組件
            return const Center(child: Text('已暫停'));
          case DownloadStatus.downloaded:
            // TODO: 實現已下載組件
            return const Center(child: Text('已下載'));
          case DownloadStatus.failed:
            return _buildDownloadButton();
        }
      }(),
    );
  }

  /// 構建下載按鈕（未下載狀態）
  /// 
  /// 顯示主要的下載按鈕，點擊後開始下載書籍
  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: controller.startDownload,
        icon: const Icon(Icons.download, size: 24),
        label: const Text(
          '下載書籍',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  /// 構建下載中組件
  /// 
  /// 顯示下載進度條、百分比和暫停/取消按鈕
  Widget _buildDownloadingWidget() {
    final book = controller.book.value;
    final progress = book.downloadProgress;
    final percentage = (progress * 100).toStringAsFixed(0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 進度信息行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '下載中',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 進度條
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(height: 16),
        
        // 操作按鈕行
        Row(
          children: [
            // 暫停按鈕
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.pauseDownload,
                icon: const Icon(Icons.pause, size: 20),
                label: const Text(
                  '暫停',
                  style: TextStyle(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange[700],
                  side: BorderSide(color: Colors.orange[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 取消按鈕
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.cancelDownload,
                icon: const Icon(Icons.close, size: 20),
                label: const Text(
                  '取消',
                  style: TextStyle(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
