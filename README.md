# 書苑閱讀器 (ShuyuanReader)

一個自動化處理 EPUB 電子書的工具，專門用於管理中文古籍電子書收藏。

## 功能特點

- 🔄 **自動批次處理**：一次處理大量 EPUB 檔案
- 📖 **元數據提取**：自動提取書名、作者、語言、描述等資訊
- 🖼️ **封面提取**：自動從 EPUB 內部提取封面圖片
- 📚 **統一目錄**：生成包含所有書籍資訊的 JSON 目錄檔案
- 🔍 **問題診斷**：檢查缺少封面或有問題的 EPUB 檔案

## 項目結構

```
ShuyuanReader/
├── catalog/              # 書籍目錄
│   └── books.json       # 自動生成的書籍目錄檔案
├── covers/              # 封面圖片 (自動提取)
├── epub3/               # EPUB 電子書檔案
├── python/              # Python 處理工具
│   ├── epub_processor.py      # 主要處理邏輯
│   ├── run_processor.py       # 快速執行腳本
│   ├── check_missing_covers.py # 檢查缺少封面的書籍
│   ├── inspect_problematic.py # 診斷有問題的檔案
│   ├── requirements.txt       # 依賴說明
│   └── README.md             # 工具使用說明
└── app/                 # 應用程式目錄 (未來擴展)
```

## 使用方式

### 1. 處理所有 EPUB 檔案

```bash
cd python
python run_processor.py
```

這會自動：
- 掃描 `epub3/` 目錄下的所有 `.epub` 檔案
- 提取書籍元數據和封面圖片
- 將封面保存到 `covers/` 目錄
- 生成或更新 `catalog/books.json` 目錄檔案

### 2. 檢查缺少封面的書籍

```bash
cd python
python check_missing_covers.py
```

### 3. 診斷有問題的 EPUB 檔案

```bash
cd python
python inspect_problematic.py
```

## 技術特點

### EPUB 標準支援
- 支援 EPUB 2.0 和 EPUB 3.0 格式
- 正確處理 XML 命名空間
- 多種封面查找策略：
  - `<meta name="cover" content="..."/>` 標籤
  - `properties="cover-image"` 屬性
  - 常見檔名模式識別

### 錯誤處理
- 優雅處理損壞的 EPUB 檔案
- 詳細的處理進度和錯誤資訊
- 即使部分檔案失敗也會繼續處理

### 檔案格式支援
- 圖片格式：JPG, PNG, GIF, WebP
- 自動偵測圖片格式
- 保持原有圖片品質

## 處理結果示例

```json
{
  "metadata": {
    "title": "書苑閱讀器書目",
    "description": "自動生成的書籍目錄",
    "generated_at": "2025-11-05",
    "total_books": 100
  },
  "books": [
    {
      "id": "論語",
      "title": "論語",
      "author": "孔子",
      "language": "zh-Hant",
      "description": "儒家經典著作",
      "epubUrl": "epub3/論語.epub",
      "coverUrl": "covers/論語.jpg"
    }
  ]
}
```

## 依賴需求

- Python 3.6+
- 標準庫依賴：
  - `zipfile` - EPUB 檔案解壓
  - `xml.etree.ElementTree` - XML 解析
  - `json` - JSON 處理
  - `pathlib` - 路徑處理

## 統計資訊

目前處理結果：
- 總 EPUB 檔案：101 個
- 成功處理：100 個
- 成功提取封面：94 個
- 封面提取成功率：94%

## 貢獻

歡迎提交 Issues 和 Pull Requests 來改進這個工具。

## 授權

MIT License