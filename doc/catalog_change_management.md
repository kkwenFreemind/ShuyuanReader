# 書籍清單變更管理設計

## 目錄

1. [現狀分析](#現狀分析)
2. [變更檢測機制](#變更檢測機制)
3. [版本控制策略](#版本控制策略)
4. [增量更新方案](#增量更新方案)
5. [用戶通知機制](#用戶通知機制)
6. [數據遷移處理](#數據遷移處理)
7. [實施建議](#實施建議)

---

## 現狀分析

### 當前 books.json 結構

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
      "id": "一夢漫言",
      "title": "一夢漫言",
      "author": "千華寺繼任主持 見月老人自述",
      "language": "tw",
      "epubUrl": "epub3/一夢漫言.epub",
      "coverUrl": "covers/一夢漫言.png"
    }
  ]
}
```

### 問題識別

當前結構缺少以下關鍵信息：

1. ❌ **版本號**：無法判斷目錄是否更新
2. ❌ **變更日誌**：不知道哪些書籍是新增的
3. ❌ **書籍更新時間**：無法識別單本書的更新
4. ❌ **校驗和**：無法驗證數據完整性
5. ❌ **增量更新支持**：每次都要下載完整列表

---

## 變更檢測機制

### 方案 1: 基於版本號（推薦 MVP）

#### 改進的 books.json 結構

```json
{
  "metadata": {
    "title": "書苑閱讀器書目",
    "description": "自動生成的書籍目錄",
    "version": "1.2.0",           // ⭐ 新增：語義化版本號
    "generated_at": "2025-11-05T10:30:00Z",
    "total_books": 100,
    "checksum": "sha256:abc123..."  // ⭐ 新增：整個文件的校驗和
  },
  "books": [
    {
      "id": "一夢漫言",
      "title": "一夢漫言",
      "author": "千華寺繼任主持 見月老人自述",
      "language": "tw",
      "epubUrl": "epub3/一夢漫言.epub",
      "coverUrl": "covers/一夢漫言.png",
      "addedAt": "2025-11-01",    // ⭐ 新增：加入時間
      "updatedAt": "2025-11-05"   // ⭐ 新增：更新時間
    }
  ]
}
```

#### 版本號規則

使用**語義化版本**（Semantic Versioning）：

```
版本格式: MAJOR.MINOR.PATCH

- MAJOR (主版本): 書籍結構變更、不兼容的變化
  例如: 1.0.0 → 2.0.0 (改變 JSON schema)

- MINOR (次版本): 新增書籍
  例如: 1.0.0 → 1.1.0 (新增 10 本書)

- PATCH (修訂版本): 更新現有書籍元數據或修復
  例如: 1.0.0 → 1.0.1 (修正書名錯誤)
```

#### 客戶端檢測邏輯

```dart
class CatalogUpdateChecker {
  // 檢查是否有更新
  Future<UpdateInfo> checkForUpdates() async {
    // 1. 讀取本地緩存的版本號
    final localVersion = await _getLocalVersion();
    
    // 2. 獲取遠程版本號（只下載 metadata，不下載整個文件）
    final remoteMetadata = await _fetchRemoteMetadata();
    final remoteVersion = remoteMetadata['version'];
    
    // 3. 比較版本
    final comparison = _compareVersions(localVersion, remoteVersion);
    
    return UpdateInfo(
      hasUpdate: comparison > 0,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
      updateType: _getUpdateType(localVersion, remoteVersion),
    );
  }
  
  // 比較版本號
  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      if (v2Parts[i] > v1Parts[i]) return 1;  // 遠程版本更新
      if (v2Parts[i] < v1Parts[i]) return -1; // 本地版本更新（異常）
    }
    return 0; // 版本相同
  }
  
  UpdateType _getUpdateType(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();
    
    if (v2Parts[0] > v1Parts[0]) return UpdateType.major;
    if (v2Parts[1] > v1Parts[1]) return UpdateType.minor;
    if (v2Parts[2] > v1Parts[2]) return UpdateType.patch;
    return UpdateType.none;
  }
}

enum UpdateType {
  none,    // 無更新
  patch,   // 小更新（修正）
  minor,   // 中更新（新書）
  major,   // 大更新（結構變更）
}

class UpdateInfo {
  final bool hasUpdate;
  final String localVersion;
  final String remoteVersion;
  final UpdateType updateType;
  
  UpdateInfo({
    required this.hasUpdate,
    required this.localVersion,
    required this.remoteVersion,
    required this.updateType,
  });
  
  String get updateMessage {
    switch (updateType) {
      case UpdateType.major:
        return '發現重要更新 ($remoteVersion)，建議立即更新';
      case UpdateType.minor:
        return '發現新書籍 ($remoteVersion)';
      case UpdateType.patch:
        return '發現書籍資料更新 ($remoteVersion)';
      case UpdateType.none:
        return '已是最新版本';
    }
  }
}
```

#### 快速版本檢查（不下載完整文件）

為了避免每次都下載完整的 books.json，創建一個輕量級的版本信息文件：

**catalog/version.json** (約 1KB)

```json
{
  "version": "1.2.0",
  "generated_at": "2025-11-05T10:30:00Z",
  "total_books": 100,
  "checksum": "sha256:abc123...",
  "changes": {
    "added": 5,      // 新增 5 本書
    "updated": 2,    // 更新 2 本書
    "removed": 0     // 刪除 0 本書
  },
  "download_urls": {
    "full": "https://raw.githubusercontent.com/.../books.json",
    "delta": "https://raw.githubusercontent.com/.../books_delta_1.1.0_to_1.2.0.json"
  }
}
```

```dart
class QuickUpdateChecker {
  Future<bool> hasUpdates() async {
    try {
      // 只下載版本文件（約 1KB）
      final response = await dio.get(
        'https://raw.githubusercontent.com/.../version.json',
      );
      
      final remoteVersion = response.data['version'];
      final localVersion = await _getLocalVersion();
      
      return _compareVersions(localVersion, remoteVersion) > 0;
      
    } catch (e) {
      // 網絡錯誤，返回 false
      return false;
    }
  }
}
```

### 方案 2: 基於 ETag/Last-Modified（備選）

#### 使用 HTTP 頭檢測變更

```dart
class ETagUpdateChecker {
  Future<bool> hasUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedETag = prefs.getString('books_json_etag');
    
    // 使用 HEAD 請求（不下載文件內容）
    final response = await dio.head(
      'https://raw.githubusercontent.com/.../books.json',
    );
    
    final currentETag = response.headers['etag']?.first;
    
    if (currentETag == null) return false;
    
    // 比較 ETag
    final hasUpdate = currentETag != savedETag;
    
    if (hasUpdate) {
      await prefs.setString('books_json_etag', currentETag);
    }
    
    return hasUpdate;
  }
}
```

#### 優缺點比較

| 特性 | 版本號方案 | ETag 方案 |
|------|-----------|-----------|
| **實現難度** | 中等（需修改 JSON） | 簡單（使用 HTTP 頭） |
| **更新類型判斷** | ✅ 可以（major/minor/patch） | ❌ 無法判斷 |
| **增量更新支持** | ✅ 可以 | ❌ 困難 |
| **網絡開銷** | 最小（1KB version.json） | 小（HEAD 請求） |
| **離線兼容** | ✅ 良好 | ⚠️ 需要網絡 |
| **GitHub 支持** | ✅ 完全支持 | ✅ 完全支持 |

**建議：MVP 使用 ETag 方案（簡單），後期升級到版本號方案（功能完整）**

---

## 版本控制策略

### 方案 A: 單文件策略（當前）

```
catalog/
└── books.json  (包含所有書籍)
```

**優點：**
- ✅ 簡單直接
- ✅ 易於維護

**缺點：**
- ❌ 每次更新都要下載完整文件（約 50KB）
- ❌ 不支持增量更新
- ❌ 書籍數量增長後性能下降

### 方案 B: 版本化文件策略（推薦）

```
catalog/
├── version.json                    # 當前版本信息 (1KB)
├── books.json                      # 完整目錄 (50KB)
├── books_v1.0.0.json              # 歷史版本歸檔
├── books_v1.1.0.json
└── deltas/                         # 增量更新文件
    ├── 1.0.0_to_1.1.0.json        # 從 1.0.0 到 1.1.0 的變更
    └── 1.1.0_to_1.2.0.json        # 從 1.1.0 到 1.2.0 的變更
```

#### 增量更新文件格式

**deltas/1.1.0_to_1.2.0.json**

```json
{
  "from_version": "1.1.0",
  "to_version": "1.2.0",
  "generated_at": "2025-11-05T10:30:00Z",
  "changes": {
    "added": [
      {
        "id": "新書1",
        "title": "新書1",
        "author": "作者",
        "epubUrl": "epub3/新書1.epub",
        "coverUrl": "covers/新書1.png",
        "addedAt": "2025-11-05"
      }
    ],
    "updated": [
      {
        "id": "舊書1",
        "changes": {
          "author": "更正後的作者名",
          "updatedAt": "2025-11-05"
        }
      }
    ],
    "removed": [
      "已刪除書籍ID"
    ]
  }
}
```

#### 客戶端增量更新邏輯

```dart
class DeltaUpdateManager {
  Future<void> applyUpdate() async {
    final localVersion = await _getLocalVersion();
    final remoteVersion = await _getRemoteVersion();
    
    // 檢查是否有增量更新文件
    final deltaUrl = _buildDeltaUrl(localVersion, remoteVersion);
    final hasDelta = await _deltaFileExists(deltaUrl);
    
    if (hasDelta) {
      // 下載增量文件（約 5-10KB）
      await _applyDeltaUpdate(deltaUrl);
    } else {
      // 下載完整文件（約 50KB）
      await _downloadFullCatalog();
    }
  }
  
  Future<void> _applyDeltaUpdate(String deltaUrl) async {
    final delta = await dio.get(deltaUrl);
    final changes = delta.data['changes'];
    
    final box = Hive.box<Book>('books');
    
    // 1. 添加新書
    for (var book in changes['added']) {
      await box.add(Book.fromJson(book));
    }
    
    // 2. 更新現有書籍
    for (var update in changes['updated']) {
      final bookId = update['id'];
      final book = box.values.firstWhere((b) => b.id == bookId);
      
      // 應用變更
      final bookUpdates = update['changes'];
      if (bookUpdates['author'] != null) {
        book.author = bookUpdates['author'];
      }
      // ... 其他字段
      
      await book.save();
    }
    
    // 3. 刪除書籍
    for (var bookId in changes['removed']) {
      final index = box.values.toList().indexWhere((b) => b.id == bookId);
      if (index != -1) {
        await box.deleteAt(index);
      }
    }
    
    // 4. 更新本地版本號
    await _saveLocalVersion(delta.data['to_version']);
  }
}
```

### 方案 C: 分頁策略（未來擴展）

當書籍數量超過 500 本時考慮：

```
catalog/
├── version.json
├── books_page_1.json  (前 100 本)
├── books_page_2.json  (101-200 本)
└── books_page_3.json  (201-300 本)
```

---

## 增量更新方案

### 自動生成增量文件

修改現有的 `epub_processor.py`，添加增量文件生成功能：

```python
# python/generate_delta.py

import json
from pathlib import Path
from datetime import datetime

def generate_delta(old_version_file, new_version_file, output_file):
    """生成增量更新文件"""
    
    with open(old_version_file, 'r', encoding='utf-8') as f:
        old_data = json.load(f)
    
    with open(new_version_file, 'r', encoding='utf-8') as f:
        new_data = json.load(f)
    
    old_books = {book['id']: book for book in old_data['books']}
    new_books = {book['id']: book for book in new_data['books']}
    
    # 找出新增的書籍
    added = []
    for book_id, book in new_books.items():
        if book_id not in old_books:
            added.append(book)
    
    # 找出更新的書籍
    updated = []
    for book_id, new_book in new_books.items():
        if book_id in old_books:
            old_book = old_books[book_id]
            changes = {}
            
            # 比較各個字段
            for key in ['title', 'author', 'epubUrl', 'coverUrl']:
                if old_book.get(key) != new_book.get(key):
                    changes[key] = new_book[key]
            
            if changes:
                updated.append({
                    'id': book_id,
                    'changes': changes
                })
    
    # 找出刪除的書籍
    removed = []
    for book_id in old_books:
        if book_id not in new_books:
            removed.append(book_id)
    
    # 生成增量文件
    delta = {
        'from_version': old_data['metadata']['version'],
        'to_version': new_data['metadata']['version'],
        'generated_at': datetime.now().isoformat(),
        'changes': {
            'added': added,
            'updated': updated,
            'removed': removed
        },
        'summary': {
            'added_count': len(added),
            'updated_count': len(updated),
            'removed_count': len(removed)
        }
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(delta, f, ensure_ascii=False, indent=2)
    
    print(f"✅ 增量文件已生成: {output_file}")
    print(f"   新增: {len(added)} 本")
    print(f"   更新: {len(updated)} 本")
    print(f"   刪除: {len(removed)} 本")

if __name__ == '__main__':
    # 使用示例
    generate_delta(
        'catalog/books_v1.1.0.json',
        'catalog/books.json',
        'catalog/deltas/1.1.0_to_1.2.0.json'
    )
```

### 自動化流程

使用 GitHub Actions 自動生成增量文件：

```yaml
# .github/workflows/generate-catalog.yml

name: Generate Catalog Delta

on:
  push:
    paths:
      - 'epub3/**'
      - 'catalog/books.json'

jobs:
  generate-delta:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # 獲取完整歷史
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Generate delta file
        run: |
          # 獲取上一個版本
          git show HEAD~1:catalog/books.json > books_old.json
          
          # 生成增量文件
          python python/generate_delta.py books_old.json catalog/books.json catalog/deltas/delta_latest.json
      
      - name: Commit delta file
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add catalog/deltas/
          git commit -m "Auto-generate delta file" || echo "No changes"
          git push
```

---

## 用戶通知機制

### 通知策略

#### 1. 啟動時檢查（推薦）

```dart
class AppStartupService {
  Future<void> checkUpdatesOnStartup() async {
    // 限制檢查頻率（避免每次啟動都檢查）
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString('last_update_check');
    
    if (lastCheck != null) {
      final lastCheckTime = DateTime.parse(lastCheck);
      final now = DateTime.now();
      
      // 如果距離上次檢查不到 6 小時，跳過
      if (now.difference(lastCheckTime).inHours < 6) {
        return;
      }
    }
    
    // 檢查更新
    final hasUpdate = await updateChecker.hasUpdates();
    
    if (hasUpdate) {
      _showUpdateNotification();
    }
    
    // 記錄檢查時間
    await prefs.setString('last_update_check', DateTime.now().toIso8601String());
  }
  
  void _showUpdateNotification() {
    Get.snackbar(
      '有新書籍',
      '發現新的書籍，下拉刷新查看',
      icon: Icon(Icons.new_releases, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () => _navigateToHome(),
        child: Text('查看', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
```

#### 2. 下拉刷新檢查

```dart
class HomeController extends GetxController {
  Future<void> refreshCatalog() async {
    isRefreshing.value = true;
    
    try {
      final updateInfo = await updateChecker.checkForUpdates();
      
      if (updateInfo.hasUpdate) {
        // 顯示更新提示
        Get.dialog(
          UpdateDialog(updateInfo: updateInfo),
        );
      } else {
        Get.snackbar('已是最新', '當前已是最新書籍目錄');
      }
      
    } finally {
      isRefreshing.value = false;
    }
  }
}
```

#### 3. 更新對話框

```dart
class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  
  const UpdateDialog({required this.updateInfo});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.update, color: Colors.blue),
          SizedBox(width: 8),
          Text('發現更新'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('當前版本: ${updateInfo.localVersion}'),
          Text('最新版本: ${updateInfo.remoteVersion}'),
          SizedBox(height: 16),
          Text(
            updateInfo.updateMessage,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (updateInfo.updateType == UpdateType.minor)
            Text('新增了 ${_getAddedCount()} 本書籍'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('稍後'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _downloadUpdate();
          },
          child: Text('立即更新'),
        ),
      ],
    );
  }
}
```

### 通知時機決策樹

```
App 啟動
  ↓
距離上次檢查 > 6 小時？
  ├─ 否 → 跳過檢查
  └─ 是 → 檢查更新
           ↓
      有更新可用？
           ├─ 否 → 無操作
           └─ 是 → 顯示 SnackBar
                    ↓
               用戶點擊 "查看"？
                    ├─ 否 → 結束
                    └─ 是 → 顯示更新對話框
                             ↓
                        用戶點擊 "立即更新"？
                             ├─ 否 → 結束
                             └─ 是 → 下載並應用更新
```

---

## 數據遷移處理

### 版本兼容性

#### 情況 1: 新增字段（向後兼容）

```json
// v1.0.0
{
  "id": "book1",
  "title": "書名"
}

// v1.1.0 (新增 addedAt 字段)
{
  "id": "book1",
  "title": "書名",
  "addedAt": "2025-11-05"  // ⭐ 新字段
}
```

**處理策略：** 舊客戶端忽略新字段，正常運行

```dart
// 安全解析（如果字段不存在，使用默認值）
Book.fromJson(Map<String, dynamic> json) {
  return Book(
    id: json['id'],
    title: json['title'],
    addedAt: json['addedAt'] ?? '', // 如果沒有，使用空字符串
  );
}
```

#### 情況 2: 字段重命名（破壞性變更）

```json
// v1.0.0
{
  "epubUrl": "epub3/book.epub"
}

// v2.0.0 (字段重命名)
{
  "epubPath": "epub3/book.epub"  // ❌ 破壞性變更
}
```

**處理策略：** 使用遷移腳本

```dart
class BookMigrator {
  Book migrateFromV1ToV2(Map<String, dynamic> json) {
    // 兼容舊字段名
    final epubPath = json['epubPath'] ?? json['epubUrl'];
    
    return Book(
      id: json['id'],
      title: json['title'],
      epubPath: epubPath,
    );
  }
  
  Future<void> migrateDatabaseV1ToV2() async {
    final box = Hive.box<Book>('books');
    
    for (var book in box.values) {
      // 如果是舊格式，進行遷移
      if (book.hasOldFormat()) {
        final migratedBook = migrateFromV1ToV2(book.toJson());
        await box.put(book.key, migratedBook);
      }
    }
  }
}
```

#### 情況 3: 結構變更（主版本升級）

```json
// v1.x.x
{
  "books": [ {...}, {...} ]
}

// v2.0.0 (分類結構)
{
  "categories": {
    "佛教": [ {...}, {...} ],
    "道教": [ {...}, {...} ]
  }
}
```

**處理策略：** 強制更新

```dart
class VersionCompatibilityChecker {
  Future<bool> isCompatible(String remoteVersion) async {
    final localMajorVersion = _getMajorVersion(await _getLocalVersion());
    final remoteMajorVersion = _getMajorVersion(remoteVersion);
    
    // 主版本號不同，不兼容
    if (localMajorVersion != remoteMajorVersion) {
      _showForceUpdateDialog();
      return false;
    }
    
    return true;
  }
  
  void _showForceUpdateDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('需要更新'),
        content: Text('書籍目錄結構已更新，請更新 APP 以繼續使用'),
        actions: [
          ElevatedButton(
            onPressed: () => _openAppStore(),
            child: Text('前往更新'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
```

---

## 實施建議

### Phase 1: MVP（立即實施）

**目標：** 基本的更新檢測

1. **添加 version.json**
   ```json
   {
     "version": "1.0.0",
     "generated_at": "2025-11-06T00:00:00Z",
     "total_books": 100
   }
   ```

2. **客戶端實現 ETag 檢測**
   ```dart
   Future<bool> hasUpdates() async {
     final response = await dio.head('https://.../books.json');
     final currentETag = response.headers['etag']?.first;
     
     final savedETag = prefs.getString('books_etag');
     return currentETag != savedETag;
   }
   ```

3. **啟動時檢查更新**
   - 限制頻率（6 小時一次）
   - 顯示 SnackBar 通知

**預估工時：** 2-3 小時

### Phase 2: 增強版本控制（1-2 週後）

**目標：** 完整的版本管理

1. **升級 books.json 結構**
   - 添加 `version` 字段
   - 添加 `addedAt`、`updatedAt` 字段
   - 添加 `checksum`

2. **實現版本號比較**
   - 語義化版本解析
   - 更新類型判斷（major/minor/patch）

3. **更新 Python 腳本**
   - 自動生成版本號
   - 計算 checksum

**預估工時：** 4-6 小時

### Phase 3: 增量更新（1-2 個月後）

**目標：** 節省流量，提升速度

1. **生成增量文件**
   - 實現 `generate_delta.py`
   - 創建 `deltas/` 目錄

2. **客戶端增量更新**
   - 下載並應用 delta 文件
   - 錯誤處理（回退到完整下載）

3. **GitHub Actions 自動化**
   - 自動生成 delta 文件
   - 自動提交到倉庫

**預估工時：** 8-12 小時

### Phase 4: 高級功能（未來迭代）

1. **分頁加載**（書籍超過 500 本時）
2. **CDN 加速**（使用 jsDelivr）
3. **離線變更檢測**（本地計算 delta）
4. **書籍推薦**（基於更新歷史）

---

## 測試場景

### 測試用例

| 測試場景 | 預期結果 |
|---------|---------|
| **首次安裝** | 下載完整 books.json，保存版本號 |
| **無網絡啟動** | 使用緩存數據，不顯示更新提示 |
| **有網絡，無更新** | 檢查版本號，提示"已是最新" |
| **有網絡，有更新（新增書籍）** | 顯示更新提示，下載更新後合併數據 |
| **有網絡，有更新（修正書籍信息）** | 下載更新，覆蓋本地錯誤數據 |
| **主版本更新（結構變更）** | 顯示強制更新對話框 |
| **下載更新失敗** | 保留舊數據，顯示錯誤提示 |
| **增量更新文件損壞** | 自動回退到完整下載 |
| **用戶主動下拉刷新** | 立即檢查更新，顯示結果 |
| **6 小時內多次啟動** | 跳過自動檢查，節省流量 |

### 測試步驟

```dart
// 單元測試
void main() {
  group('CatalogUpdateChecker', () {
    test('版本號比較 - 有更新', () {
      final checker = CatalogUpdateChecker();
      final result = checker.compareVersions('1.0.0', '1.1.0');
      expect(result, 1);
    });
    
    test('版本號比較 - 無更新', () {
      final checker = CatalogUpdateChecker();
      final result = checker.compareVersions('1.1.0', '1.1.0');
      expect(result, 0);
    });
    
    test('增量更新 - 新增書籍', () async {
      final manager = DeltaUpdateManager();
      await manager.applyDelta(mockDeltaData);
      
      final box = Hive.box<Book>('books');
      expect(box.length, 101); // 原本 100 本，新增 1 本
    });
  });
}
```

---

## 監控與分析

### 關鍵指標

1. **更新檢查頻率**
   - 每日檢查次數
   - 成功/失敗比例

2. **更新下載情況**
   - 完整下載 vs 增量下載
   - 平均下載時間
   - 下載失敗率

3. **用戶行為**
   - 更新通知點擊率
   - 更新接受率（點擊"立即更新"）
   - 用戶刷新頻率

### 日誌記錄

```dart
class UpdateLogger {
  void logUpdateCheck({
    required bool hasUpdate,
    required String localVersion,
    required String remoteVersion,
  }) {
    // 記錄到 Firebase Analytics 或本地日誌
    analytics.logEvent(
      name: 'catalog_update_check',
      parameters: {
        'has_update': hasUpdate,
        'local_version': localVersion,
        'remote_version': remoteVersion,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  void logUpdateDownload({
    required bool success,
    required String version,
    required int downloadTime,
    required bool isDelta,
  }) {
    analytics.logEvent(
      name: 'catalog_update_download',
      parameters: {
        'success': success,
        'version': version,
        'download_time_ms': downloadTime,
        'is_delta': isDelta,
      },
    );
  }
}
```

---

## 總結

### 關鍵要點

1. **MVP 使用 ETag 方案**：簡單快速，立即可用
2. **中期升級到版本號方案**：功能完整，支持增量更新
3. **重視用戶體驗**：
   - 限制檢查頻率（避免騷擾）
   - 清晰的更新提示
   - 可選的更新時機
4. **向後兼容**：新字段使用默認值，避免破壞性變更
5. **自動化流程**：使用 GitHub Actions 自動生成更新文件

### 實施優先級

| 階段 | 功能 | 預估工時 | 優先級 |
|------|------|---------|--------|
| Phase 1 | ETag 更新檢測 | 2-3h | 🔴 高 |
| Phase 1 | 啟動時檢查 + SnackBar | 1-2h | 🔴 高 |
| Phase 2 | 版本號系統 | 4-6h | 🟠 中 |
| Phase 2 | 更新對話框 | 2-3h | 🟠 中 |
| Phase 3 | 增量更新 | 8-12h | 🟡 低 |
| Phase 4 | 分頁加載 | 6-8h | 🟢 未來 |

### 風險與對策

| 風險 | 影響 | 對策 |
|------|------|------|
| GitHub API 限制 | 更新檢查失敗 | 使用 HEAD 請求（無限制） |
| 增量文件損壞 | 更新失敗 | 自動回退到完整下載 |
| 書籍數量暴增 | 性能下降 | 實施分頁加載 |
| 網絡不穩定 | 下載失敗 | 重試機制 + 本地緩存 |

---

## 附錄：完整代碼示例

### 完整的更新管理器

```dart
// lib/core/services/catalog_update_service.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatalogUpdateService extends GetxService {
  final Dio dio;
  final String baseUrl = 'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/catalog';
  
  CatalogUpdateService({required this.dio});
  
  // ========== 快速檢查 ==========
  
  Future<bool> quickCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString('last_update_check');
    
    // 限制頻率：6 小時一次
    if (lastCheck != null) {
      final lastTime = DateTime.parse(lastCheck);
      if (DateTime.now().difference(lastTime).inHours < 6) {
        return false; // 跳過檢查
      }
    }
    
    try {
      final hasUpdate = await _checkETag();
      await prefs.setString('last_update_check', DateTime.now().toIso8601String());
      return hasUpdate;
    } catch (e) {
      print('更新檢查失敗: $e');
      return false;
    }
  }
  
  Future<bool> _checkETag() async {
    final prefs = await SharedPreferences.getInstance();
    final savedETag = prefs.getString('books_etag');
    
    final response = await dio.head('$baseUrl/books.json');
    final currentETag = response.headers['etag']?.first;
    
    if (currentETag == null) return false;
    
    if (currentETag != savedETag) {
      await prefs.setString('books_etag', currentETag);
      return true;
    }
    
    return false;
  }
  
  // ========== 下載更新 ==========
  
  Future<void> downloadUpdate() async {
    try {
      final response = await dio.get('$baseUrl/books.json');
      final data = response.data;
      
      // 保存到本地
      await _saveCatalog(data);
      
      // 更新 Hive 數據庫
      await _updateDatabase(data);
      
      Get.snackbar('更新成功', '書籍目錄已更新');
      
    } catch (e) {
      Get.snackbar('更新失敗', '請檢查網絡連接');
      rethrow;
    }
  }
  
  Future<void> _saveCatalog(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('books_json', jsonEncode(data));
    await prefs.setString('books_json_timestamp', DateTime.now().toIso8601String());
  }
  
  Future<void> _updateDatabase(Map<String, dynamic> data) async {
    final box = Hive.box<Book>('books');
    
    // 清空舊數據
    await box.clear();
    
    // 插入新數據
    final books = (data['books'] as List).map((b) => Book.fromJson(b)).toList();
    await box.addAll(books);
  }
}
```

這份文檔提供了完整的書籍清單變更管理方案，從簡單的 MVP 到完整的增量更新系統。建議從 Phase 1 開始實施！
