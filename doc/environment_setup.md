# 書苑閱讀器 - 開發環境配置指南

## 📋 環境檢查結果

### ✅ 已安裝的環境

- **Flutter**: 3.35.6 (stable channel) ✅
- **Dart**: 3.9.2 ✅
- **Android Studio**: 2025.1.2 ✅
- **Android SDK**: 已安裝在 `D:\Program Files\Android\Sdk` ✅
- **VS Code**: 1.105.1 + Flutter 擴展 ✅
- **Chrome**: 用於 Web 開發 ✅

### ⚠️ 需要修復的問題

- **Android cmdline-tools**: 缺少命令行工具

---

## 🔧 修復 Android cmdline-tools

### 方法一：通過 Android Studio（推薦）

1. **打開 Android Studio**
   - 路徑：`D:\Program Files\Android\Android Studio`

2. **打開 SDK Manager**
   ```
   File → Settings (或 Configure → Settings)
   → Appearance & Behavior
   → System Settings
   → Android SDK
   ```

3. **安裝 Android SDK Command-line Tools**
   - 切換到 **SDK Tools** 標籤
   - 勾選 ☑️ **Android SDK Command-line Tools (latest)**
   - 點擊 **Apply** 或 **OK**
   - 等待下載和安裝完成

4. **驗證安裝**
   ```bash
   flutter doctor -v
   ```
   - 應該看到 `[√] Android toolchain` 變成綠色勾選

### 方法二：手動下載（可選）

如果方法一不可行，可以手動下載：

1. **下載 cmdline-tools**
   - 訪問：https://developer.android.com/studio#command-line-tools-only
   - 下載 Windows 版本的 commandlinetools-win-*.zip

2. **解壓到 SDK 目錄**
   ```bash
   # 解壓到以下路徑
   D:\Program Files\Android\Sdk\cmdline-tools\latest\
   ```

3. **設置環境變數**
   ```bash
   # 添加到系統環境變數
   ANDROID_HOME=D:\Program Files\Android\Sdk
   ```

4. **接受許可證**
   ```bash
   flutter doctor --android-licenses
   ```
   - 輸入 `y` 接受所有許可證

---

## 📱 Flutter 專案已建立

### 專案位置
```
D:\SideProject\ShuyuanReader\app\
```

### 專案資訊
- **專案名稱**: shuyuan_reader
- **組織 ID**: com.shuyuan
- **完整包名**: com.shuyuan.shuyuan_reader
- **主程式**: app\lib\main.dart

### 目錄結構
```
app/
├── android/              # Android 原生代碼
├── ios/                  # iOS 原生代碼（未來使用）
├── lib/                  # Dart 代碼（主要開發目錄）
│   └── main.dart        # 應用入口
├── test/                # 測試代碼
├── pubspec.yaml         # 依賴配置
└── README.md           # 專案說明
```

---

## 🚀 運行專案

### 1. 進入專案目錄
```bash
cd app
```

### 2. 檢查可用設備
```bash
flutter devices
```

### 3. 運行專案

#### 在 Chrome 瀏覽器運行（測試用）
```bash
flutter run -d chrome
```

#### 在 Android 模擬器運行
```bash
# 先啟動 Android Studio 的模擬器
# 然後執行
flutter run -d emulator-5554
```

#### 在實體 Android 設備運行
```bash
# 1. 開啟手機的開發者模式和 USB 偵錯
# 2. 連接手機到電腦
# 3. 執行
flutter run
```

---

## 🔨 開發工具配置

### VS Code 配置

#### 必要擴展
- ✅ **Flutter** (已安裝)
- ✅ **Dart** (已安裝)

#### 推薦擴展
```
- Pubspec Assist: 快速添加依賴
- Flutter Widget Snippets: 代碼片段
- Awesome Flutter Snippets: 更多代碼片段
- Error Lens: 即時顯示錯誤
```

#### VS Code 設置
在 `.vscode/settings.json` 中添加：
```json
{
  "dart.flutterSdkPath": "D:\\flutter\\flutter",
  "editor.formatOnSave": true,
  "editor.rulers": [80, 120],
  "dart.lineLength": 80
}
```

### Android Studio 配置

#### 安裝 Flutter 插件
1. 打開 Android Studio
2. File → Settings → Plugins
3. 搜索 "Flutter"
4. 點擊 Install
5. 重啟 Android Studio

---

## 📦 添加專案依賴

### 編輯 pubspec.yaml

```bash
cd app
code pubspec.yaml
```

### 添加必要的依賴

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 狀態管理
  get: ^4.6.5
  
  # 網絡
  dio: ^5.3.3
  connectivity_plus: ^5.0.1
  
  # 本地存儲
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # EPUB 閱讀
  epub_view: ^3.1.0
  
  # 圖片緩存
  cached_network_image: ^3.3.0
  
  # UI
  flutter_screenutil: ^5.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
  flutter_lints: ^3.0.0
```

### 安裝依賴
```bash
flutter pub get
```

---

## 🎯 下一步

### 1. 修復 Android cmdline-tools
按照上面的「方法一」步驟操作

### 2. 驗證環境
```bash
flutter doctor -v
```
- 確保所有項目都是綠色 ✅

### 3. 運行測試專案
```bash
cd app
flutter run -d chrome
```

### 4. 開始開發
- 參考 `doc/implementation_checklist.md`
- 從 Phase 1: MVP 開始

---

## ⚡ 快速命令參考

### Flutter 命令
```bash
# 檢查環境
flutter doctor

# 創建專案
flutter create <project_name>

# 運行專案
flutter run

# 構建 APK
flutter build apk

# 構建 Release APK
flutter build apk --release

# 清理專案
flutter clean

# 獲取依賴
flutter pub get

# 升級依賴
flutter pub upgrade

# 查看可用設備
flutter devices
```

### Android 命令
```bash
# 列出 Android 模擬器
emulator -list-avds

# 啟動模擬器
emulator -avd <avd_name>

# ADB 命令
adb devices                 # 列出連接的設備
adb install app.apk        # 安裝 APK
adb logcat                 # 查看日誌
```

---

## 🐛 常見問題

### 問題 1: cmdline-tools 缺失
**解決方法**：參考上面的「修復 Android cmdline-tools」

### 問題 2: Gradle 下載慢
**解決方法**：
1. 編輯 `app/android/build.gradle`
2. 添加國內鏡像源：
```gradle
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        google()
        mavenCentral()
    }
}
```

### 問題 3: Flutter SDK 版本過舊
**解決方法**：
```bash
flutter upgrade
```

### 問題 4: Android 許可證未接受
**解決方法**：
```bash
flutter doctor --android-licenses
# 輸入 y 接受所有許可證
```

---

## 📚 參考資源

### 官方文檔
- [Flutter 官方文檔](https://flutter.dev/docs)
- [Dart 語言指南](https://dart.dev/guides)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)

### 社區資源
- [Flutter 中文網](https://flutter.cn/)
- [Pub.dev (Dart 包倉庫)](https://pub.dev/)
- [Flutter Awesome (精選資源)](https://flutterawesome.com/)

### 視頻教程
- [Flutter YouTube 頻道](https://www.youtube.com/c/flutterdev)
- [Flutter Widget of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG)

---

## ✅ 檢查清單

安裝環境配置完成後，請確認以下項目：

- [ ] Flutter SDK 已安裝並可以運行
- [ ] Android Studio 已安裝
- [ ] Android SDK cmdline-tools 已安裝
- [ ] `flutter doctor` 沒有錯誤（全綠勾選）
- [ ] VS Code + Flutter 擴展已配置
- [ ] Flutter 專案已建立在 `app/` 目錄
- [ ] 可以運行 `flutter run -d chrome`
- [ ] Android 模擬器或實體設備可以連接

完成以上步驟後，您就可以開始開發書苑閱讀器了！🎉
