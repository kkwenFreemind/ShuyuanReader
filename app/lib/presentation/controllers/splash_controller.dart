import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/init/app_initializer.dart';

/// 啟動畫面控制器
/// 
/// 負責啟動畫面的業務邏輯，包括：
/// - 加載應用版本號
/// - 初始化 Hive 數據庫
/// - 檢測網絡連接狀態
/// - 控制啟動畫面顯示時長
/// - 處理初始化錯誤
class SplashController extends GetxController {
  // ==================== 響應式變量 ====================
  
  /// 應用版本號
  /// 格式: v1.0.0
  final version = ''.obs;
  
  /// 初始化完成狀態
  /// true: 所有初始化步驟已完成
  /// false: 初始化進行中或失敗
  final isInitialized = false.obs;
  
  /// 網絡連接狀態
  /// true: 設備已連接到網絡
  /// false: 設備未連接網絡
  final isConnected = false.obs;
  
  // ==================== 生命週期方法 ====================
  
  @override
  void onInit() {
    super.onInit();
    // 開始初始化流程
    _initializeApp();
  }
  
  // ==================== 私有方法 ====================
  
  /// 初始化應用
  /// 
  /// 按順序執行以下步驟：
  /// 1. 加載版本號
  /// 2. 初始化 Hive 數據庫
  /// 3. 檢測網絡連接
  /// 4. 延遲 3 秒（展示啟動畫面）
  /// 5. 跳轉到主頁（預留）
  Future<void> _initializeApp() async {
    try {
      print('📱 [SplashController] 開始初始化應用...');
      
      // 步驟 1: 加載版本號
      await _loadVersion();
      print('✅ [SplashController] 版本號加載完成: ${version.value}');
      
      // 步驟 2: 初始化 Hive
      await _initializeHive();
      print('✅ [SplashController] Hive 初始化完成');
      
      // 步驟 3: 檢測網絡連接
      await _checkConnectivity();
      print('✅ [SplashController] 網絡檢測完成: ${isConnected.value ? "已連接" : "未連接"}');
      
      // 標記初始化完成
      isInitialized.value = true;
      print('✅ [SplashController] 應用初始化完成');
      
      // 步驟 4: 延遲 3 秒展示啟動畫面
      print('⏱️  [SplashController] 開始 3 秒延遲...');
      await Future.delayed(const Duration(seconds: 3));
      print('⏱️  [SplashController] 3 秒延遲結束');
      
      // 步驟 5: 跳轉到主頁（暫時註釋，等待主頁實現）
      // TODO: 在 Spec 02 實現書籍列表頁面後，啟用此路由跳轉
      // Get.offNamed('/home');
      print('🚀 [SplashController] 準備跳轉到主頁（當前已註釋）');
      
    } catch (e) {
      // 處理初始化過程中的任何錯誤
      print('❌ [SplashController] 初始化失敗: $e');
      _handleError(e);
    }
  }
  
  /// 加載應用版本號
  /// 
  /// 從 package_info_plus 插件獲取版本信息
  /// 並更新到 version 響應式變量
  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      version.value = 'v${packageInfo.version}';
    } catch (e) {
      // 如果獲取版本失敗，使用默認值
      version.value = 'v1.0.0';
      // 重新拋出異常以便上層處理
      rethrow;
    }
  }
  
  /// 初始化 Hive 數據庫
  /// 
  /// 調用 AppInitializer 完成 Hive 初始化
  /// 包括註冊 Adapter 和打開 Box（預留）
  Future<void> _initializeHive() async {
    try {
      await AppInitializer.initializeHive();
    } catch (e) {
      // 重新拋出異常以便上層處理
      rethrow;
    }
  }
  
  /// 檢測網絡連接狀態
  /// 
  /// 使用 connectivity_plus 插件檢測設備網絡連接
  /// 更新 isConnected 響應式變量
  Future<void> _checkConnectivity() async {
    try {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      
      // 檢查是否有任何網絡連接
      // ConnectivityResult.none 表示無網絡連接
      isConnected.value = result != ConnectivityResult.none;
    } catch (e) {
      // 網絡檢測失敗時，默認為未連接
      isConnected.value = false;
      // 注意：網絡檢測失敗不應該阻止應用啟動
      // 所以這裡不重新拋出異常
    }
  }
  
  /// 處理初始化錯誤
  /// 
  /// 顯示錯誤提示 Snackbar 給用戶
  /// 使用 GetX 的 snackbar 功能
  /// 
  /// [error] 錯誤對象或錯誤消息
  void _handleError(dynamic error) {
    Get.snackbar(
      '初始化失敗',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
