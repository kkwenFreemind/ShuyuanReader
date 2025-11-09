# Changelog

All notable changes to the ShuyuanReader project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.0] - 2025-11-09

### ✨ Added - EPUB 閱讀器核心功能

#### 📖 閱讀功能
- **EPUB 文件渲染**：完整支援 EPUB 3.0 格式解析和渲染
- **雙閱讀模式**：
  - 直書模式（豎排）：從上到下、從右到左，符合傳統經典閱讀習慣
  - 橫書模式（橫排）：從左到右、從上到下，適合現代閱讀
  - 模式間無縫切換
- **手勢翻頁**：
  - 左右滑動翻頁
  - 點擊左右區域翻頁
  - 點擊中央區域顯示/隱藏工具欄
- **閱讀進度追蹤**：
  - 自動保存當前閱讀位置
  - 記錄閱讀進度百分比
  - 應用重啟後自動恢復到上次閱讀位置

#### 🔖 書籤功能
- **書籤管理**：
  - 點擊書籤按鈕添加/移除當前頁書籤
  - 書籤數據持久化存儲（使用 Hive）
  - 書籤按鈕動畫效果和觸覺反饋
  - 自動恢復已保存的書籤

#### ⚙️ 閱讀設置
- **字體大小調整**：
  - 5 級字體大小（XS/S/M/L/XL）
  - 實時預覽效果
  - 設置自動保存
- **亮度調整**：
  - 滑桿控制螢幕亮度
  - 實時調整效果
- **夜間模式**：
  - 深色背景和淺色文字
  - 減少夜間閱讀眼睛疲勞
- **閱讀設置面板**：
  - 從底部滑出的設置面板
  - 所有設置集中管理
  - 優雅的動畫效果

#### 🎨 UI/UX 改進
- **工具欄自動隱藏**：
  - 閱讀時工具欄自動隱藏以提供沉浸式體驗
  - 點擊螢幕中央區域顯示工具欄
  - 3 秒後自動隱藏
- **閱讀進度條**：
  - 頂部顯示當前閱讀進度
  - 章節和頁碼信息
  - 進度百分比顯示

### 🧪 Testing
- **單元測試**：
  - ReaderController 測試（34 tests）
  - ReadingProgress 實體測試（35 tests）
  - 總計 69 個單元測試，100% 通過
- **Widget 測試**：
  - ReadingSettingsPanel 測試（35 tests）
- **集成測試**：
  - 完整閱讀流程測試（4 testWidgets）
  - 涵蓋導航、閱讀、模式切換、書籤、設置等完整流程
- **性能測試**：
  - 啟動時間測試
  - 翻頁流暢度測試
  - 內存使用測試
  - 動畫性能測試
  - 長時間穩定性測試
  - 完整流程基準測試
  - 總計 6 個性能測試 testWidgets
- **測試總結**：114 個測試，100% 通過率 ✅

### ⚡ Performance
- **RepaintBoundary 優化**：
  - 為 EpubViewerWidget 添加 RepaintBoundary，隔離內容渲染
  - 為 ReadingProgressBar 添加 RepaintBoundary，隔離進度條更新
- **GetX 響應式優化**：
  - 減少 ReaderPage 中的 Obx 嵌套
  - 最小化響應式監聽範圍
  - 預計算值移到外層 Obx
- **性能優化文檔**：完整記錄所有優化措施和驗證方法（`doc/performance_optimizations.md`）

### 📚 Documentation
- **代碼註釋**：所有核心類和方法都有詳細的 Dart Doc 註釋
- **性能優化記錄**：460+ 行詳細優化文檔
- **性能測試報告模板**：包含測試方法、運行指南、結果記錄表格
- **任務追蹤規範**：完整的開發任務清單和驗收標準

### 🏗️ Technical
- **架構**：Clean Architecture（領域層、數據層、展示層分離）
- **狀態管理**：GetX（響應式狀態管理和依賴注入）
- **本地存儲**：Hive（閱讀進度和書籤持久化）
- **EPUB 解析**：epub_view package（v3.0.0）
- **依賴注入**：使用 GetX 的依賴注入系統

### 🔧 Dependencies Added
- `epub_view: ^3.0.0` - EPUB 文件解析和渲染
- `get: ^4.6.6` - 狀態管理和路由
- `hive: ^2.2.3` - 本地數據存儲
- `hive_flutter: ^1.1.0` - Hive Flutter 集成
- `path_provider: ^2.1.4` - 文件路徑訪問
- `flutter_screenutil: ^5.9.3` - 響應式 UI 適配
- `flutter_html: ^3.0.0-beta.2` - HTML 內容渲染

---

## [0.1.0] - 2025-11-06

### ✨ Added - 初始版本

#### 📚 書籍目錄功能
- 從本地 JSON 文件加載書籍目錄
- 書籍列表展示（書名、作者、封面）
- 基本的書籍瀏覽功能

#### 🏗️ 項目結構
- 建立 Clean Architecture 基礎結構
- 配置 Flutter 開發環境
- 設置 Git 版本控制
- 創建基本項目規範文檔

### 🔧 Technical Setup
- Flutter SDK 配置
- 基礎依賴安裝
- Android/iOS 項目配置
- 代碼分析和格式化配置

---

## [Unreleased]

### 計劃中的功能
- **目錄導航**：快速跳轉到特定章節
- **搜索功能**：全文搜索和結果高亮
- **筆記功能**：為重要段落添加個人筆記
- **高亮功能**：標記重要內容
- **字典整合**：長按查詢詞義
- **閱讀統計**：追蹤閱讀時間和習慣
- **雲端同步**：跨設備同步閱讀進度和書籤
- **主題自訂**：更多配色方案和字體選擇

---

## Version History

- **0.2.0** (2025-11-09) - EPUB 閱讀器核心功能完成
- **0.1.0** (2025-11-06) - 初始版本，基礎架構

---

## Notes

### 取消的功能
以下功能在當前版本中被標記為低優先級，暫不實施：
- **API 文檔生成**：代碼中已有詳細 Dart Doc 註釋，可在需要時執行 `dart doc` 生成
- **用戶使用指南**：待正式發布時補充
- **功能截圖和演示視頻**：待推廣時製作

### 延遲的測試
- **ReaderPage Widget 測試**：由於 GetX 生命週期測試的技術挑戰，此測試被延遲實施

---

**維護者**: ShuyuanReader Development Team  
**項目開始日期**: 2025-11-06  
**最後更新**: 2025-11-09
