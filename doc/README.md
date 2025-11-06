# 書苑閱讀器 - 設計文檔導覽

## 📚 項目概述

**書苑閱讀器**是一款專為繁體中文古籍設計的 EPUB 閱讀器 Android APP，採用創新的「GitHub 內容託管 + APP 本地緩存」架構。

### 核心特點

- 📖 **100+ 繁體中文古籍**：三世因果、佛經、道教經典等
- ☁️ **GitHub 託管**：所有內容存放在 GitHub，零服務器成本
- 📱 **按需下載**：只下載用戶需要的書籍，節省空間和流量
- 🔄 **離線閱讀**：已下載的書籍可完全離線使用
- 🎨 **現代 UI**：Material Design + 流暢動畫

---

## 🏗️ 系統架構

```text
┌────────────────────────────────────────────┐
│       GitHub Repository (內容源)            │
│  https://github.com/kkwenFreemind/        │
│  ShuyuanReader                             │
│                                            │
│  📁 catalog/books.json  ← 書籍元數據(50KB)  │
│  📁 covers/*.png        ← 100+ 封面圖片     │
│  📁 epub3/*.epub        ← 100+ 電子書       │
└────────────────────────────────────────────┘
              ↓ HTTPS 下載
              ↓ 按需獲取
┌────────────────────────────────────────────┐
│      Android APP (智能緩存層)               │
│                                            │
│  🗄️  Hive 數據庫    ← 書籍元數據 + 狀態     │
│  📦  files/books/  ← 用戶下載的 EPUB       │
│  🖼️  cache/covers/ ← 自動緩存的封面         │
└────────────────────────────────────────────┘
```

### 為什麼選擇這種架構？

✅ **對開發者**：
- 無需維護服務器（零成本）
- 使用 Git 管理內容（版本控制）
- GitHub CDN 全球加速（高可用）

✅ **對用戶**：
- APP 體積小（不內嵌書籍）
- 按需下載（節省流量）
- 離線可用（已下載內容）

---

## 📖 文檔結構

### 1. [storage_architecture.md](./storage_architecture.md) ⭐ **必讀**

**完整的存儲架構設計**，包括：

- 🌐 遠程資源（GitHub）：URL 結構、資源訪問
- 📱 本地存儲（APP）：目錄結構、路徑管理
- 🔄 數據流程：下載、緩存、更新機制
- 💾 存儲路徑規範：完整的代碼實現

**適合讀者**：所有開發人員、架構師

### 2. [app_design_spec.md](./app_design_spec.md)

**技術設計文檔**（1800+ 行），涵蓋：

1. **系統架構概覽**：核心理念、資源存放
2. **功能擴展與用戶體驗**
   - 書籍管理功能（列表、搜索、過濾）
   - 閱讀器功能（書籤、筆記、高亮）
   - 多語言支持
3. **技術實現與性能**
   - 下載與存儲優化
   - 緩存與離線模式
   - 性能與內存管理
4. **安全性與合規**
   - 數據安全（HTTPS、文件校驗）
   - 隱私保護
   - 版權合規
5. **測試與部署**
6. **技術架構**

**適合讀者**：開發人員、產品經理

### 3. [implementation_checklist.md](./implementation_checklist.md)

**階段性開發檢查清單**，包括：

- 優先級矩陣（P0-P3）
- Phase 1: MVP (4-6 週) - 基本可用
- Phase 2: 功能增強 (4-6 週) - 完善體驗
- Phase 3: 發布準備 (2-4 週) - 上架 Google Play

**每個任務包含**：
- ✅/⬜ 完成狀態
- 📝 詳細實現代碼
- ⏱️ 預估時間
- 🔗 相關依賴

**適合讀者**：開發人員、項目經理

### 4. [architecture_decisions.md](./architecture_decisions.md)

**架構決策記錄（ADR）**，記錄了 8 個關鍵技術決策：

- ADR-001: GetX 狀態管理
- ADR-002: epub_view 閱讀器
- ADR-003: Hive 本地數據庫
- ADR-004: Dio 網絡庫
- ADR-005: 離線優先策略
- ADR-006: **GitHub 內容託管** ⭐
- ADR-007: Material Design
- ADR-008: Android 優先

**適合讀者**：架構師、技術負責人

### 5. [catalog_change_management.md](./catalog_change_management.md)

**書籍目錄變更管理策略**，包括：

- 變更檢測機制（ETag、Last-Modified）
- 增量更新策略
- 版本控制方案
- 數據遷移處理

**適合讀者**：後端開發人員、DevOps

---

## 🚀 快速開始

### 前置需求

- Flutter SDK 3.13+
- Android Studio / VS Code
- Android SDK (API 21+)
- Git

### 開發流程

1. **閱讀架構文檔**
   ```bash
   # 必讀：了解存儲架構
   cat doc/storage_architecture.md
   ```

2. **按照檢查清單開發**
   ```bash
   # 從 Phase 1 開始
   cat doc/implementation_checklist.md
   ```

3. **參考技術設計**
   ```bash
   # 查找具體實現代碼
   cat doc/app_design_spec.md
   ```

---

## 📊 項目統計

| 項目 | 數據 |
|------|------|
| **書籍數量** | 100+ 本 |
| **書籍格式** | EPUB 3.0 |
| **封面格式** | PNG |
| **總文件大小** | ~200-500 MB (100本) |
| **books.json** | ~50 KB |
| **單本 EPUB** | 1-5 MB |
| **單張封面** | 50-200 KB |

---

## 🛠️ 技術棧

### 前端 (Flutter)

```yaml
dependencies:
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
```

### 後端 (GitHub)

- **內容託管**：GitHub Repository
- **CDN**：GitHub Raw Content
- **版本控制**：Git
- **成本**：免費

---

## 📈 開發路線圖

### Phase 1: MVP (4-6 週)

- ✅ 基礎架構搭建
- ✅ 書籍列表顯示
- ✅ 下載管理
- ✅ EPUB 閱讀器
- ✅ 離線模式

### Phase 2: 增強功能 (4-6 週)

- ⬜ 搜索和過濾
- ⬜ 書籤和筆記
- ⬜ 閱讀設置
- ⬜ 性能優化

### Phase 3: 發布準備 (2-4 週)

- ⬜ 多語言支持
- ⬜ 隱私政策
- ⬜ Google Play 上架

---

## 🤝 貢獻指南

### 如何添加新書籍？

1. **準備 EPUB 文件**
   ```bash
   # 確保文件名使用 UTF-8 編碼
   # 例如：金剛經.epub
   ```

2. **添加封面圖片**
   ```bash
   # PNG 格式，建議尺寸 400x600
   # 文件名與 EPUB 相同
   # 例如：金剛經.png
   ```

3. **更新 books.json**
   ```json
   {
     "id": "金剛經",
     "title": "金剛經",
     "author": "鳩摩羅什譯",
     "epubUrl": "epub3/金剛經.epub",
     "coverUrl": "covers/金剛經.png"
   }
   ```

4. **提交到 GitHub**
   ```bash
   git add catalog/books.json covers/金剛經.png epub3/金剛經.epub
   git commit -m "feat: 添加《金剛經》"
   git push origin main
   ```

5. **APP 自動檢測更新** ✅

---

## 📝 變更日誌

### 2025-11-06

- ✅ 創建完整的設計文檔體系
- ✅ 定義 GitHub 託管架構
- ✅ 完成存儲路徑規範
- ✅ 制定開發檢查清單

---

## 📧 聯繫方式

- **GitHub**: [kkwenFreemind/ShuyuanReader](https://github.com/kkwenFreemind/ShuyuanReader)
- **Issues**: [提交問題](https://github.com/kkwenFreemind/ShuyuanReader/issues)

---

## 📄 授權

本項目採用 MIT 授權。

書籍內容版權歸原作者所有，僅供學習和研究使用。

---

**🎉 開始閱讀文檔，開始開發吧！**
