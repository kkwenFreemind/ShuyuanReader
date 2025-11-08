import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/book_model.dart';
import '../../data/models/download_status.dart';

/// 應用初始化器
/// 
/// 負責應用啟動時的各項初始化工作
/// 目前包含 Hive 數據庫初始化
class AppInitializer {
  /// 初始化 Hive 數據庫
  /// 
  /// 執行以下操作：
  /// 1. 初始化 Hive Flutter 插件
  /// 2. 創建測試 Box 驗證 Hive 正常工作
  /// 3. 註冊 Adapter（預留，待後續 Spec 實現）
  /// 4. 打開 Box（預留，待後續 Spec 實現）
  /// 
  /// 拋出 [Exception] 如果初始化失敗
  static Future<void> initializeHive() async {
    try {
      // 步驟 1: 初始化 Hive
      await Hive.initFlutter();
      print('📦 [AppInitializer] Hive Flutter 初始化完成');
      
      // 步驟 2: 創建測試 Box 驗證功能
      // 打開測試 Box
      final testBox = await Hive.openBox('test');
      print('🗄️  [AppInitializer] 測試 Box 已打開');
      
      // 寫入測試數據
      await testBox.put('initialized', true);
      await testBox.put('timestamp', DateTime.now().toIso8601String());
      await testBox.put('app_name', '書苑閱讀器');
      print('✍️  [AppInitializer] 測試數據已寫入');
      
      // 讀取並驗證測試數據
      final isInit = testBox.get('initialized', defaultValue: false);
      final timestamp = testBox.get('timestamp', defaultValue: 'unknown');
      final appName = testBox.get('app_name', defaultValue: '');
      
      // 輸出驗證信息
      print('✅ [AppInitializer] Hive 初始化成功驗證:');
      print('   - 初始化狀態: $isInit');
      print('   - 時間戳: $timestamp');
      print('   - 應用名稱: $appName');
      print('   - Box 路徑: ${testBox.path}');
      print('   - 數據條目數: ${testBox.length}');
      
      // 步驟 3: 註冊 Adapter
      // 註冊 BookModel Adapter 用於書籍列表緩存
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(BookModelAdapter());
        print('📝 [AppInitializer] BookModel Adapter 已註冊');
      } else {
        print('ℹ️  [AppInitializer] BookModel Adapter 已存在，跳過註冊');
      }
      
      // 註冊 DownloadStatus Adapter 用於下載狀態管理
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(DownloadStatusAdapter());
        print('📝 [AppInitializer] DownloadStatus Adapter 已註冊');
      } else {
        print('ℹ️  [AppInitializer] DownloadStatus Adapter 已存在，跳過註冊');
      }
      
      // 步驟 4: 打開應用所需的 Box
      // 打開書籍列表緩存 Box
      await Hive.openBox<BookModel>('books');
      print('📚 [AppInitializer] Books Box 已打開');
      
      // 打開元數據 Box (用於存儲緩存時間等信息)
      await Hive.openBox('metadata');
      print('🔖 [AppInitializer] Metadata Box 已打開');
      
      // TODO: 打開其他 Box (預留給後續 Spec)
      // 例如：
      // await Hive.openBox('settings');
      // await Hive.openBox('reading_progress');
      // await Hive.openBox('user_preferences');
      
    } catch (e) {
      // 將錯誤包裝為更具描述性的異常
      print('❌ [AppInitializer] Hive 初始化失敗: $e');
      throw Exception('Hive 初始化失敗: $e');
    }
  }
  
  /// 初始化所有必要的服務
  /// 
  /// 此方法可在未來擴展以包含其他初始化任務
  /// 例如：權限請求、推送通知、分析服務等
  static Future<void> initializeAll() async {
    // 初始化 Hive
    await initializeHive();
    
    // TODO: 添加其他初始化任務（預留）
    // await initializeNotifications();
    // await initializeAnalytics();
    // await requestPermissions();
  }
}
