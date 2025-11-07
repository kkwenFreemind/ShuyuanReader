import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          // TODO: 添加封面圖片組件
          // TODO: 添加書籍信息組件
          // TODO: 添加操作按鈕組件
          
          // 臨時內容：顯示書籍標題
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              controller.book.value.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
