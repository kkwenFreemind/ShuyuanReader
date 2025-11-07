@echo off
echo ========================================
echo 書苑閱讀器 - 環境驗證腳本
echo ========================================
echo.

echo [1/5] 檢查 Flutter 版本...
flutter --version
echo.

echo [2/5] 檢查 Android SDK 路徑...
echo ANDROID_HOME = %ANDROID_HOME%
echo ANDROID_SDK_ROOT = %ANDROID_SDK_ROOT%
echo.

echo [3/5] 檢查符號連結...
if exist D:\AndroidSDK (
    echo ✓ D:\AndroidSDK 存在
) else (
    echo ✗ D:\AndroidSDK 不存在
)
echo.

echo [4/5] 檢查 ADB...
adb version
echo.

echo [5/5] 執行 Flutter Doctor...
flutter doctor -v
echo.

echo ========================================
echo 驗證完成！
echo ========================================
pause
