import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shuyuan_reader/data/datasources/book_local_datasource.dart';
import 'package:shuyuan_reader/data/datasources/book_remote_datasource.dart';
import 'package:shuyuan_reader/data/models/book_model.dart';
import 'package:shuyuan_reader/data/repositories/book_repository_impl.dart';
import 'package:shuyuan_reader/domain/repositories/book_repository.dart';
import 'package:shuyuan_reader/domain/usecases/get_books_usecase.dart';
import 'package:shuyuan_reader/domain/usecases/refresh_books_usecase.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/controllers/book_list_controller.dart';

/// BookList 頁面的依賴綁定
/// 
/// 當跳轉到 BookListPage 時，自動初始化所需的依賴：
/// - 數據源（本地和遠程）
/// - 倉庫
/// - 用例
/// - Controller
class BookListBinding implements Bindings {
  @override
  void dependencies() {
    // 獲取 Hive boxes（應該已經在 AppInitializer 中打開）
    final bookBox = Hive.box<BookModel>('books');
    final metaBox = Hive.box('metadata');

    // 初始化數據源
    final localDataSource = BookLocalDataSource(bookBox, metaBox);
    final dio = Dio();
    final remoteDataSource = BookRemoteDataSource(dio);

    // 初始化倉庫並全局注冊為永久依賴（供其他頁面使用，如 BookDetailPage）
    if (!Get.isRegistered<BookRepository>()) {
      final repository = BookRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
      // permanent: true 確保在頁面切換時不會被銷毀
      Get.put<BookRepository>(repository, permanent: true);
    }

    // 初始化用例
    final getBooksUseCase = GetBooksUseCase(Get.find<BookRepository>());
    final refreshBooksUseCase = RefreshBooksUseCase(Get.find<BookRepository>());

    // 初始化 Controller
    Get.lazyPut<BookListController>(
      () => BookListController(
        getBooksUseCase: getBooksUseCase,
        refreshBooksUseCase: refreshBooksUseCase,
      ),
    );
  }
}
