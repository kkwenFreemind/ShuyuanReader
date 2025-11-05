# EPUB 處理器使用說明

## 功能介紹

這個 Python 腳本可以自動化處理 EPUB 電子書檔案，具備以下功能：

1. **自動提取書籍元數據**：標題、作者、語言、描述等
2. **自動提取封面圖片**：從 EPUB 內部提取並保存為獨立圖片檔案
3. **生成統一目錄**：創建包含所有書籍資訊的 `books.json` 檔案

## 檔案結構

```
python/
├── epub_processor.py     # 主要處理邏輯
├── run_processor.py      # 快速執行腳本
├── requirements.txt      # Python 依賴清單
└── README.md            # 本說明檔案
```

## 使用方式

### 方式一：直接執行（推薦）

```bash
cd d:\SideProject\ShuyuanReader\python
python run_processor.py
```

### 方式二：執行主腳本

```bash
cd d:\SideProject\ShuyuanReader\python
python epub_processor.py
```

## 處理流程

1. **掃描 EPUB 檔案**：自動找到 `epub3/` 目錄下的所有 `.epub` 檔案
2. **解析元數據**：
   - 讀取 `META-INF/container.xml` 找到 content.opf 位置
   - 解析 content.opf 中的 metadata 區段
   - 提取標題、作者、語言等資訊
3. **提取封面圖片**：
   - 查找 `<meta name="cover" content="..."/>` 標籤
   - 或查找 `properties="cover-image"` 的項目
   - 從 EPUB 內部提取圖片並保存到 `covers/` 目錄
4. **生成目錄檔案**：創建或更新 `catalog/books.json`

## 輸出結果

### 封面圖片
- 位置：`covers/` 目錄
- 命名：以 EPUB 檔名為基礎，保持原有圖片格式
- 支援格式：JPG, PNG, GIF, WebP

### 書籍目錄 (books.json)
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
      "description": "儒家經典著作...",
      "publisher": "",
      "date": "",
      "epubUrl": "epub3/論語.epub",
      "coverUrl": "covers/論語.jpg"
    }
  ]
}
```

## 技術特點

### EPUB 標準相容性
- 支援 EPUB 2.0 和 EPUB 3.0 格式
- 正確處理 XML 命名空間
- 智能查找封面圖片（多種查找策略）

### 錯誤處理
- 優雅處理損壞的 EPUB 檔案
- 提供詳細的處理進度和錯誤資訊
- 即使部分檔案失敗，也會繼續處理其他檔案

### 路徑處理
- 正確處理 URL 編碼的檔案路徑
- 支援不同的 EPUB 內部結構（OEBPS, EPUB 等）
- 自動偵測圖片格式

## 故障排除

### 常見問題

1. **找不到封面圖片**
   - 可能原因：EPUB 沒有正確標記封面
   - 解決方案：腳本會嘗試多種查找策略

2. **中文檔名問題**
   - 確保系統支援 UTF-8 編碼
   - Windows 使用者可能需要設定代碼頁

3. **權限問題**
   - 確保有讀取 `epub3/` 目錄的權限
   - 確保有寫入 `covers/` 和 `catalog/` 目錄的權限

### 調試模式

腳本會輸出詳細的處理資訊，包括：
- 每個檔案的處理狀態
- 找到的元數據
- 封面提取結果

## 擴展功能

如需增強功能，可以考慮：

1. **更強大的 XML 處理**：安裝 `lxml` 套件
2. **圖片格式轉換**：安裝 `Pillow` 套件
3. **並行處理**：使用 `concurrent.futures` 加速處理大量檔案

## 支援

- Python 版本：3.6+
- 作業系統：Windows, macOS, Linux
- 依賴：僅使用 Python 標準庫，無需額外安裝套件