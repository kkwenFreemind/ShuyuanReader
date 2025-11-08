import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/book_list/book_list_page.dart';
import '../presentation/pages/book_list/bindings/book_list_binding.dart';
import '../presentation/pages/book_detail_page.dart';
import '../presentation/controllers/book_detail_controller.dart';
import '../data/services/download_service.dart';
import '../domain/repositories/book_repository.dart';
import 'app_routes.dart';

/// 應用頁面配置
/// 
/// 定義所有頁面的路由配置，包括頁面組件和依賴注入
class AppPages {
  /// 初始路由
  static const INITIAL = Routes.SPLASH;

  /// 所有頁面的路由配置
  static final routes = [
    // 啟動頁
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashPage(),
    ),

    // 書籍列表頁
    GetPage(
      name: Routes.BOOK_LIST,
      page: () => const BookListPage(),
      binding: BookListBinding(), // 添加綁定
    ),

    // 書籍詳情頁
    GetPage(
      name: Routes.BOOK_DETAIL,
      page: () => BookDetailPage(),
      binding: BindingsBuilder(() {
        // 確保 DownloadService 已注冊為永久依賴
        if (!Get.isRegistered<DownloadService>()) {
          Get.put<DownloadService>(DownloadService(Dio()), permanent: true);
        }
        
        // 確保 BookRepository 已注冊
        // 正常情況下應該在 BookListBinding 中注冊為永久依賴
        if (!Get.isRegistered<BookRepository>()) {
          print('⚠️  [AppPages] BookRepository 未注冊');
          throw Exception('BookRepository 未注冊。請確保先導航到 BookListPage。');
        }
        
        // 懶加載方式注入 BookDetailController
        Get.lazyPut<BookDetailController>(
          () => BookDetailController(
            Get.find<DownloadService>(),
            Get.find<BookRepository>(),
          ),
        );
      }),
    ),
  ];
}
