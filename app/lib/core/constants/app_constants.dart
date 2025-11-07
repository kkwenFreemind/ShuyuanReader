/// 應用常量定義
/// 
/// 集中管理應用中使用的所有常量值，包括：
/// - 啟動畫面相關常量
/// - 顏色定義
/// - 字體大小
/// - 動畫時長
/// 
/// 使用常量而非魔術數字可以提高代碼可維護性和可讀性
class AppConstants {
  // ==================== 啟動畫面常量 ====================
  
  /// 啟動畫面顯示時長（秒）
  /// 
  /// 用於控制啟動畫面展示的時間
  /// 在初始化完成後，應用會在此畫面停留指定秒數
  static const int splashDurationSeconds = 3;
  
  /// Logo 尺寸（寬度和高度）
  /// 
  /// Logo 是正方形，寬高相等
  static const double logoSize = 120.0;
  
  /// Logo 淡入動畫時長（毫秒）
  /// 
  /// 控制 Logo 從完全透明到完全不透明的過渡時間
  static const int fadeInDurationMs = 500;
  
  /// Logo 圓角半徑
  /// 
  /// 控制 Logo 容器的圓角大小
  static const double logoRadius = 24.0;
  
  /// 加載指示器大小
  /// 
  /// CircularProgressIndicator 的寬度和高度
  static const double loadingIndicatorSize = 32.0;
  
  /// 加載指示器線寬
  /// 
  /// CircularProgressIndicator 的筆畫寬度
  static const double loadingStrokeWidth = 3.0;
  
  // ==================== 顏色常量 ====================
  
  /// 主色調
  /// 
  /// 應用的主要品牌色，用於按鈕、進度條等
  static const int primaryColor = 0xFF2196F3;
  
  /// 次要色調
  /// 
  /// 用於輔助元素和強調內容
  static const int secondaryColor = 0xFF1976D2;
  
  /// 背景色
  /// 
  /// 啟動畫面的背景色
  static const int backgroundColor = 0xFFFFFFFF;
  
  /// Logo 背景色
  /// 
  /// Logo 容器的背景色（淺藍色）
  static const int logoBackgroundColor = 0xFFE3F2FD;
  
  /// 主要文字顏色
  /// 
  /// 用於標題等重要文字
  static const int textColor = 0xFF000000;
  
  /// 次要文字顏色
  /// 
  /// 用於副標題等次要文字
  static const int secondaryTextColor = 0xFF424242;
  
  /// 提示文字顏色
  /// 
  /// 用於版本號、Loading 文字等提示性內容
  static const int hintTextColor = 0xFF9E9E9E;
  
  // ==================== 字體大小常量 ====================
  
  /// Logo 表情符號大小
  /// 
  /// 用於顯示 📚 表情符號
  static const double logoEmojiFontSize = 64.0;
  
  /// 標題字體大小
  /// 
  /// 用於應用名稱："書苑閱讀器"
  static const double titleFontSize = 24.0;
  
  /// 副標題字體大小
  /// 
  /// 用於英文名稱："ShuyuanReader"
  static const double subtitleFontSize = 16.0;
  
  /// Loading 文字字體大小
  /// 
  /// 用於 "Loading..." 文字
  static const double loadingTextFontSize = 14.0;
  
  /// 版本號字體大小
  /// 
  /// 用於底部版本號顯示："v1.0.0"
  static const double versionFontSize = 12.0;
  
  // ==================== 間距常量 ====================
  
  /// 超大間距
  /// 
  /// 用於主要元素之間的大間距
  static const double spacingXLarge = 48.0;
  
  /// 大間距
  /// 
  /// 用於元素之間的標準大間距
  static const double spacingLarge = 24.0;
  
  /// 中等間距
  /// 
  /// 用於相關元素之間的間距
  static const double spacingMedium = 16.0;
  
  /// 小間距
  /// 
  /// 用於緊密相關元素之間的間距
  static const double spacingSmall = 8.0;
  
  // ==================== 其他常量 ====================
  
  /// 應用名稱（中文）
  static const String appNameZh = '書苑閱讀器';
  
  /// 應用名稱（英文）
  static const String appNameEn = 'ShuyuanReader';
  
  /// Loading 文字
  static const String loadingText = 'Loading...';
  
  /// 私有構造函數，防止實例化
  /// 
  /// 此類僅包含靜態常量，不應被實例化
  AppConstants._();
}
