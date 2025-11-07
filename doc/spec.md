# Spec-kit

- https://github.com/github/spec-kit

## 🎯 Spec-Kit 命令體系（完整版）



## 📋 完整的 Spec-Kit 命令清單

### 1. `/speckit.constitution` - 建立專案憲章

**用途**：定義專案的基本規則、標準和架構原則

**何時使用**：專案開始的第一步

**輸出**：`app/specs/00-constitution.md`

**包含內容**：
- 專案目標和範圍
- 技術棧選擇
- 架構模式（Clean Architecture）
- 編碼規範
- Git 提交規範
- 測試策略
- 文檔標準

---

### 2. `/speckit.plan` - 生成總體開發計劃

**用途**：基於 constitution，生成分階段的開發計劃

**何時使用**：constitution 完成後

**輸出**：`app/specs/development-plan.md`

**包含內容**：
- Phase 1-3 的時間規劃
- 所有 Spec 的列表和概述
- 里程碑定義
- 資源分配
- 風險評估

---

### 3. `/speckit.specify` - 生成詳細的功能規格

**用途**：為單個功能生成詳細的實現規格

**何時使用**：準備開發某個具體功能時

**輸出**：`app/specs/01-splash-screen.md`, `02-book-list.md`, 等

**包含內容**：
- 詳細的 UI 設計
- 完整的代碼實現
- 測試用例
- 驗收標準
- 視覺化驗證清單

---

### 4. `/speckit.tasks` - 將 Spec 分解為可執行任務

**用途**：將一個 Spec 分解為小的、可追蹤的任務

**何時使用**：開始實現 Spec 之前

**輸出**：`app/specs/tasks/spec-01-tasks.md`

**包含內容**：
- 任務清單（TODO list）
- 每個任務的時間估算
- 依賴關係
- 優先級排序

---

### 5. `/speckit.implement` - 生成實現指南

**用途**：為具體任務提供逐步實現指南

**何時使用**：開始編碼時

**輸出**：具體的代碼和步驟指示

**包含內容**：
- 檔案創建命令
- 逐行代碼實現
- 測試命令
- 驗證步驟

