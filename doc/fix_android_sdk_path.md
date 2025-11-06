# Android SDK 路徑空格問題解決方案

## 問題說明

當前 Android SDK 安裝在：`D:\Program Files\Android\Sdk`

由於路徑中包含空格（`Program Files`），這會導致 Android NDK 工具出現問題。

Flutter Doctor 警告：
```
X Android SDK location currently contains spaces, which is not
  supported by the Android SDK as it causes problems with NDK 
  tools.
```

---

## 🎯 推薦解決方案（3選1）

### ✅ 方案一：創建符號連結（推薦）

**優點**：
- 不需要移動文件
- 不影響現有配置
- 最快速的解決方案

**步驟**：

1. **以管理員身分運行 PowerShell 或 CMD**
   - 按 `Win + X`
   - 選擇「Windows PowerShell (系統管理員)」或「命令提示字元 (系統管理員)」

2. **創建符號連結**
   ```cmd
   mklink /D D:\AndroidSDK "D:\Program Files\Android\Sdk"
   ```
   
   執行成功後會顯示：
   ```
   為 D:\AndroidSDK <<===>> D:\Program Files\Android\Sdk 建立的符號連結
   ```

3. **設置環境變數**
   
   **方法 A - 使用 PowerShell**：
   ```powershell
   # 設置用戶環境變數
   [System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'D:\AndroidSDK', 'User')
   [System.Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', 'D:\AndroidSDK', 'User')
   
   # 添加到 PATH
   $oldPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
   $newPath = $oldPath + ';D:\AndroidSDK\platform-tools;D:\AndroidSDK\cmdline-tools\latest\bin'
   [System.Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
   ```

   **方法 B - 使用 GUI**：
   - 右鍵點擊「本機」→「內容」
   - 點擊「進階系統設定」
   - 點擊「環境變數」
   - 在「使用者變數」中：
     - 新增/編輯 `ANDROID_HOME` = `D:\AndroidSDK`
     - 新增/編輯 `ANDROID_SDK_ROOT` = `D:\AndroidSDK`
     - 編輯 `Path`，添加：
       - `D:\AndroidSDK\platform-tools`
       - `D:\AndroidSDK\cmdline-tools\latest\bin`

4. **重啟 VS Code/終端**
   - 關閉所有終端和 VS Code
   - 重新打開

5. **驗證**
   ```bash
   flutter doctor -v
   ```

---

### ⚠️ 方案二：移動 Android SDK（不推薦，耗時）

**缺點**：
- 需要移動大量文件（數 GB）
- 需要重新配置 Android Studio
- 可能需要重新下載某些組件

**步驟**：

1. **複製整個 SDK 目錄**
   ```powershell
   # 這會花費 10-20 分鐘
   Copy-Item -Path "D:\Program Files\Android\Sdk" -Destination "D:\AndroidSDK" -Recurse
   ```

2. **在 Android Studio 中更改 SDK 位置**
   - 打開 Android Studio
   - File → Settings
   - Appearance & Behavior → System Settings → Android SDK
   - 點擊 "Edit" (Android SDK Location 旁邊)
   - 選擇新位置：`D:\AndroidSDK`
   - 點擊 Next → Finish

3. **更新環境變數**（同方案一的步驟 3）

4. **刪除舊 SDK**（確認一切正常後）
   ```powershell
   Remove-Item -Path "D:\Program Files\Android\Sdk" -Recurse -Force
   ```

---

### 🔧 方案三：僅設置環境變數（臨時解決）

**說明**：某些情況下，即使有空格，通過正確設置環境變數也能工作。

**步驟**：

1. **設置環境變數**
   ```cmd
   setx ANDROID_HOME "D:\Program Files\Android\Sdk"
   setx ANDROID_SDK_ROOT "D:\Program Files\Android\Sdk"
   ```

2. **重啟終端並測試**
   ```bash
   flutter doctor -v
   ```

3. **如果仍有警告**
   - 對於基本開發通常不影響
   - 只有在使用 NDK（Native Development Kit）時才會有問題
   - 如果您不需要使用 C/C++ 原生代碼，可以忽略此警告

---

## 🚀 推薦執行流程

### 快速解決（5分鐘）

```powershell
# 1. 以管理員身分運行 PowerShell

# 2. 創建符號連結
mklink /D D:\AndroidSDK "D:\Program Files\Android\Sdk"

# 3. 設置環境變數
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'D:\AndroidSDK', 'User')
[System.Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', 'D:\AndroidSDK', 'User')

# 4. 重啟 VS Code

# 5. 驗證
flutter doctor -v
```

---

## ✅ 驗證步驟

完成後，執行以下命令驗證：

```bash
# 1. 檢查環境變數
echo %ANDROID_HOME%
echo %ANDROID_SDK_ROOT%

# 2. 檢查 Flutter
flutter doctor -v

# 3. 檢查 ADB
adb version
```

**預期結果**：
```
[√] Android toolchain - develop for Android devices (Android SDK version 36.1.0)
    • Android SDK at D:\AndroidSDK
    • Platform android-36, build-tools 36.1.0
    • ANDROID_HOME = D:\AndroidSDK
    • ANDROID_SDK_ROOT = D:\AndroidSDK
    • Java version OpenJDK Runtime Environment (build 21.0.6+...)
```

---

## 🎯 對書苑閱讀器開發的影響

### 目前狀態
- ✅ Flutter 可以正常使用
- ✅ 可以開發 Flutter 代碼
- ✅ 可以在 Chrome 中運行測試
- ⚠️ Android 編譯可能會有問題（如果使用 NDK）

### 是否需要立即修復？

**如果您只是開始開發**：
- 可以先忽略此警告
- 在 Chrome 或 Web 上測試
- 等到需要在 Android 設備上測試時再修復

**如果您需要 Android 測試**：
- 建議使用方案一（符號連結）
- 5 分鐘即可完成
- 不影響現有配置

---

## 📋 故障排除

### 問題 1：符號連結創建失敗（權限不足）

**解決方法**：
1. 確保以管理員身分運行 CMD/PowerShell
2. 按 `Win + X` → 選擇「Windows Terminal (系統管理員)」
3. 重新執行 mklink 命令

### 問題 2：環境變數設置後沒有生效

**解決方法**：
1. 完全關閉所有終端和 VS Code
2. 重新啟動 VS Code
3. 打開新的終端
4. 執行 `flutter doctor -v` 驗證

### 問題 3：Flutter 仍然顯示警告

**解決方法**：
1. 檢查環境變數是否正確設置：
   ```bash
   echo %ANDROID_HOME%
   echo %ANDROID_SDK_ROOT%
   ```
2. 確保沒有拼寫錯誤
3. 重啟電腦（確保所有進程都載入新的環境變數）

---

## 💡 建議

對於書苑閱讀器專案：

1. **現在可以開始開發**
   - 這個警告不影響基本開發
   - 可以先在 Web/Chrome 上測試

2. **需要 Android 測試時**
   - 花 5 分鐘執行方案一（符號連結）
   - 這樣更安全且不影響現有配置

3. **不要花太多時間在環境問題上**
   - 書苑閱讀器不需要 NDK
   - 這個警告對您的專案影響很小

---

## 🎉 總結

**最佳方案**：符號連結（方案一）
- ✅ 快速（5分鐘）
- ✅ 安全（不移動文件）
- ✅ 有效（完全解決問題）

**現在就開始開發**：
```bash
cd app
flutter run -d chrome
```

開發過程中有任何問題隨時問我！
