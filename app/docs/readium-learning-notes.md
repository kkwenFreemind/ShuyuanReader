# Readium Kotlin API 學習筆記

**日期**: 2025-11-09  
**版本**: Readium Kotlin Toolkit 3.1.2  
**目的**: 理解 Readium 架構並為整合做準備

---

## Day 1: Readium 架構概念

### 1.1 Readium 整體架構

Readium Kotlin Toolkit 採用**三層架構**設計：

```
┌─────────────────────────────────────┐
│   Navigator (閱讀器 UI)              │
│   - EpubNavigator                   │
│   - 渲染引擎                         │
│   - 用戶交互                         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Streamer (解析引擎)                │
│   - EPUB 解析                        │
│   - 資源提取                         │
│   - Publication 創建                 │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Shared (核心數據模型)              │
│   - Publication                     │
│   - Locator                         │
│   - Manifest                        │
└─────────────────────────────────────┘
```

#### 各層職責

**Shared Layer (org.readium.r2.shared)**
- 提供核心數據結構和接口
- Publication: 書籍的抽象表示
- Locator: 位置定位系統
- Manifest: 書籍元數據清單
- 跨平台共享（Kotlin Multiplatform）

**Streamer Layer (org.readium.r2.streamer)**
- 解析 EPUB 文件格式
- 提取書籍內容和資源
- 創建 Publication 實例
- 支持 EPUB2 和 EPUB3

**Navigator Layer (org.readium.r2.navigator)**
- 提供閱讀器 UI 組件
- EpubNavigator: EPUB 專用閱讀器
- 處理渲染和用戶交互
- 支持分頁和滾動模式

---

### 1.2 Publication 數據模型

`Publication` 是 Readium 的核心數據結構，表示一本書籍：

```kotlin
class Publication(
    val manifest: Manifest,           // 書籍清單（元數據 + 結構）
    val servicesBuilder: ServicesBuilder = ServicesBuilder()
) {
    val metadata: Metadata            // 標題、作者、語言等
    val readingOrder: List<Link>      // 閱讀順序（章節列表）
    val resources: List<Link>         // 資源列表（圖片、CSS等）
    val links: List<Link>             // 其他鏈接
    
    // 獲取封面
    fun cover(): Bitmap?
    
    // 按路徑獲取資源
    fun get(href: String): Resource?
}
```

#### Publication 結構示例

```
Publication
├── Metadata
│   ├── title: "三世因果目蓮救母經"
│   ├── authors: ["佚名"]
│   ├── languages: ["zh"]
│   └── readingProgression: RTL (直書)
├── ReadingOrder (章節順序)
│   ├── Link("/chapter1.xhtml")
│   ├── Link("/chapter2.xhtml")
│   └── Link("/chapter3.xhtml")
└── Resources (資源)
    ├── Link("/styles.css")
    ├── Link("/cover.jpg")
    └── Link("/fonts/kaiti.ttf")
```

---

### 1.3 Locator 位置系統

`Locator` 用於精確定位書籍中的位置：

```kotlin
data class Locator(
    val href: String,                 // 資源路徑（如 chapter1.xhtml）
    val type: String,                 // 媒體類型
    val title: String? = null,        // 位置標題
    val locations: Locations,         // 位置信息
    val text: Text? = null            // 上下文文本
)

data class Locations(
    val fragments: List<String> = emptyList(),  // HTML fragments
    val progression: Double? = null,            // 章節進度 (0.0-1.0)
    val position: Int? = null,                  // 頁碼
    val totalProgression: Double? = null        // 整本書進度 (0.0-1.0)
)
```

#### Locator 用途
- **書籤**: 保存閱讀位置
- **進度追蹤**: 記錄閱讀進度
- **同步**: 跨設備同步位置
- **目錄跳轉**: 導航到特定章節

#### Locator 示例
```kotlin
val bookmark = Locator(
    href = "/chapter2.xhtml",
    type = "application/xhtml+xml",
    title = "第二章",
    locations = Locations(
        progression = 0.35,        // 章節 35% 位置
        totalProgression = 0.12,   // 整本書 12% 位置
        position = 5               // 第 5 頁
    )
)
```

---

### 1.4 核心概念詳解

#### Manifest（書籍清單）

```kotlin
data class Manifest(
    val metadata: Metadata,           // 元數據
    val links: List<Link> = emptyList(),
    val readingOrder: List<Link>,     // 必需：閱讀順序
    val resources: List<Link> = emptyList(),
    val toc: List<Link> = emptyList() // 目錄
)
```

**Manifest 包含**:
- 書籍基本信息（標題、作者、出版商）
- 閱讀順序（章節列表）
- 資源清單（圖片、樣式表、字體）
- 目錄結構（Table of Contents）

#### ReadingOrder（閱讀順序）

定義章節的順序和結構：

```kotlin
val readingOrder = listOf(
    Link(href = "/cover.xhtml", type = "application/xhtml+xml"),
    Link(href = "/chapter1.xhtml", type = "application/xhtml+xml"),
    Link(href = "/chapter2.xhtml", type = "application/xhtml+xml")
)
```

**特點**:
- 順序排列（從前到後）
- 包含所有可閱讀內容
- 支持嵌套結構（子章節）

#### Resources（資源管理）

管理非內容資源：

```kotlin
val resources = listOf(
    Link(href = "/styles.css", type = "text/css"),
    Link(href = "/cover.jpg", type = "image/jpeg"),
    Link(href = "/fonts/noto.ttf", type = "font/ttf")
)
```

**資源類型**:
- 樣式表 (CSS)
- 圖片 (JPEG, PNG, SVG)
- 字體 (TTF, OTF)
- 腳本 (JavaScript)

---

### 1.5 Metadata（元數據）

```kotlin
data class Metadata(
    val identifier: String? = null,           // ISBN 或唯一 ID
    val title: LocalizedString,               // 書名
    val subtitle: LocalizedString? = null,    // 副標題
    val authors: List<Contributor> = emptyList(),
    val languages: List<String> = emptyList(),
    val readingProgression: ReadingProgression = ReadingProgression.AUTO,
    val description: String? = null,
    val modified: Date? = null,
    val published: Date? = null,
    val subjects: List<Subject> = emptyList()
)

enum class ReadingProgression {
    LTR,    // 橫書：左到右（英文、簡體中文）
    RTL,    // 直書：右到左（繁體中文、日文）
    TTB,    // 上到下
    BTT,    // 下到上
    AUTO    // 自動檢測
}
```

#### 直書橫書判斷

```kotlin
// 檢查書籍是否為直書
val isVertical = publication.metadata.readingProgression == ReadingProgression.RTL

// 根據語言自動判斷
when (publication.metadata.languages.firstOrNull()) {
    "zh-TW", "ja" -> ReadingProgression.RTL  // 繁體中文、日文 → 直書
    "zh-CN", "en" -> ReadingProgression.LTR  // 簡體中文、英文 → 橫書
    else -> ReadingProgression.AUTO
}
```

---

## Day 2: EPUB 解析流程

### 2.1 Asset 加載機制

Readium 使用 `Asset` 抽象來表示書籍來源：

```kotlin
// 1. FileAsset - 本地文件
val fileAsset = FileAsset(File("/storage/emulated/0/books/book.epub"))

// 2. ResourceAsset - 已解壓資源
val resourceAsset = ResourceAsset(
    mediaType = MediaType.EPUB,
    resource = FileResource(File("/path/to/book"))
)
```

#### Asset 類型比較

| Asset 類型 | 用途 | 性能 | 適用場景 |
|-----------|------|------|---------|
| FileAsset | 本地 EPUB 文件 | ⭐⭐⭐ | 本地閱讀 |
| ResourceAsset | 已解壓目錄 | ⭐⭐⭐⭐⭐ | 開發測試 |
| HttpAsset | 遠端下載 | ⭐ | 在線閱讀 |

---

### 2.2 Publication 創建流程

使用 `Streamer` 解析 EPUB 並創建 `Publication`：

```kotlin
import org.readium.r2.shared.util.asset.AssetRetriever
import org.readium.r2.streamer.Streamer
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class EpubParser(private val context: Context) {
    
    // 1. 創建 Streamer
    private val streamer = Streamer(
        context = context,
        // 可選：自定義解析器配置
    )
    
    // 2. 創建 AssetRetriever
    private val assetRetriever = AssetRetriever(
        context.contentResolver,
        httpClient = null  // 不支持遠端下載
    )
    
    // 3. 打開 EPUB
    suspend fun openEpub(filePath: String): Result<Publication> = withContext(Dispatchers.IO) {
        try {
            // 3.1 創建 Asset
            val file = File(filePath)
            val asset = assetRetriever.retrieve(file)
                .getOrElse { return@withContext Result.failure(it) }
            
            // 3.2 使用 Streamer 打開
            val publication = streamer.open(asset, allowUserInteraction = false)
                .getOrElse { return@withContext Result.failure(it) }
            
            Result.success(publication)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

#### 解析流程圖

```
File Path
    ↓
AssetRetriever.retrieve()
    ↓
Asset (FileAsset)
    ↓
Streamer.open()
    ↓
Publication
    ├─ Manifest
    ├─ Metadata
    ├─ ReadingOrder
    └─ Resources
```

---

### 2.3 錯誤處理

Readium 使用 Kotlin Result 類型處理錯誤：

```kotlin
// Result<T> 模式
when (val result = openEpub(filePath)) {
    is Result.Success -> {
        val publication = result.value
        // 處理成功
    }
    is Result.Failure -> {
        when (val error = result.cause) {
            is FileNotFoundException -> 
                showError("文件不存在")
            is OpeningException.UnsupportedFormat -> 
                showError("不支持的文件格式")
            is OpeningException.NotFound ->
                showError("無法打開文件")
            else -> 
                showError("未知錯誤: ${error.message}")
        }
    }
}
```

#### 常見錯誤類型

```kotlin
sealed class OpeningException {
    class NotFound : OpeningException()            // 文件不存在
    class UnsupportedFormat : OpeningException()   // 格式不支持
    class Forbidden : OpeningException()           // 無權限
    class Unavailable : OpeningException()         // 資源不可用
}
```

---

### 2.4 元數據提取

```kotlin
// 提取書籍元數據
fun extractMetadata(publication: Publication) {
    val metadata = publication.metadata
    
    // 基本信息
    val title = metadata.title.string()              // "三世因果目蓮救母經"
    val authors = metadata.authors.joinToString { it.name }
    val language = metadata.languages.firstOrNull()  // "zh"
    
    // 封面圖片
    val cover: Bitmap? = publication.cover()
    
    // 閱讀方向
    val isVertical = metadata.readingProgression == ReadingProgression.RTL
    
    // 章節數量
    val chapterCount = publication.readingOrder.size
    
    // 目錄
    val toc = publication.tableOfContents
}
```

#### Cover 提取示例

```kotlin
suspend fun getCover(publication: Publication): Bitmap? {
    return withContext(Dispatchers.IO) {
        try {
            publication.cover()
        } catch (e: Exception) {
            Log.e("Cover", "Failed to extract cover", e)
            null
        }
    }
}
```

---

## Day 3: 閱讀器配置與事件

### 3.1 EpubNavigator 配置

`EpubNavigator` 是 Readium 提供的 EPUB 閱讀器組件：

```kotlin
import org.readium.r2.navigator.epub.EpubNavigatorFactory
import org.readium.r2.navigator.Navigator
import org.readium.r2.navigator.NavigatorDelegate
import androidx.fragment.app.Fragment

class ReaderFragment : Fragment(), NavigatorDelegate {
    
    private lateinit var navigator: Navigator
    
    fun setupNavigator(publication: Publication) {
        // 1. 創建 Navigator 配置
        val config = EpubNavigatorFactory.Configuration(
            // 閱讀方向
            readingProgression = publication.metadata.readingProgression,
            
            // 滾動模式（分頁 vs 連續滾動）
            scroll = false,  // false = 分頁模式
            
            // 用戶設置
            preferences = EpubPreferences(
                fontSize = 1.2,              // 字體大小（相對於默認）
                fontFamily = "serif",        // 字體系列
                textAlign = TextAlign.START, // 文字對齊
                lineHeight = 1.5,            // 行高
                
                // 主題
                backgroundColor = Color.WHITE,
                textColor = Color.BLACK
            )
        )
        
        // 2. 創建 Navigator
        navigator = EpubNavigatorFactory(publication)
            .createFragmentNavigator(
                activity = requireActivity(),
                configuration = config,
                initialLocation = null,  // 起始位置（null = 從頭開始）
                listener = this          // 事件監聽
            )
        
        // 3. 嵌入到 Fragment
        childFragmentManager.beginTransaction()
            .replace(R.id.navigator_container, navigator.fragment)
            .commit()
    }
}
```

---

### 3.2 ReadingProgression（閱讀方向）

```kotlin
// 直書配置（RTL - Right to Left）
val verticalConfig = EpubNavigatorFactory.Configuration(
    readingProgression = ReadingProgression.RTL,
    scroll = false
)
// 結果：
// - 翻頁方向：右 → 左
// - 文字排版：垂直（需要 CSS 支持）
// - 適用於：繁體中文、日文

// 橫書配置（LTR - Left to Right）
val horizontalConfig = EpubNavigatorFactory.Configuration(
    readingProgression = ReadingProgression.LTR,
    scroll = false
)
// 結果：
// - 翻頁方向：左 → 右
// - 文字排版：水平
// - 適用於：簡體中文、英文
```

---

### 3.3 字體、字號、行距配置

```kotlin
data class EpubPreferences(
    // 字體大小（1.0 = 默認，0.5 = 50%，2.0 = 200%）
    val fontSize: Double = 1.0,
    
    // 字體系列
    val fontFamily: String? = null,  // "serif", "sans-serif", "monospace"
    
    // 行高（1.0 = 默認，1.5 = 1.5倍行距）
    val lineHeight: Double = 1.5,
    
    // 字間距
    val letterSpacing: Double = 0.0,
    
    // 詞間距
    val wordSpacing: Double = 0.0,
    
    // 文字對齊
    val textAlign: TextAlign = TextAlign.START,  // START, END, CENTER, JUSTIFY
    
    // 段落間距
    val paragraphSpacing: Double = 0.0
)
```

#### 動態更新設置

```kotlin
// 更新字體大小
fun increaseFontSize() {
    val currentSize = navigator.preferences.fontSize
    navigator.submitPreferences(
        navigator.preferences.copy(fontSize = currentSize + 0.1)
    )
}

// 切換字體
fun setFont(fontFamily: String) {
    navigator.submitPreferences(
        navigator.preferences.copy(fontFamily = fontFamily)
    )
}

// 調整行高
fun setLineHeight(lineHeight: Double) {
    navigator.submitPreferences(
        navigator.preferences.copy(lineHeight = lineHeight)
    )
}
```

---

### 3.4 主題配置

```kotlin
// 主題設置
data class Theme(
    val backgroundColor: Color,
    val textColor: Color
)

// 預設主題
object Themes {
    val Light = Theme(
        backgroundColor = Color.WHITE,
        textColor = Color.BLACK
    )
    
    val Dark = Theme(
        backgroundColor = Color(0xFF1E1E1E),
        textColor = Color(0xFFE0E0E0)
    )
    
    val Sepia = Theme(
        backgroundColor = Color(0xFFFBF0D9),
        textColor = Color(0xFF5F4B32)
    )
}

// 應用主題
fun applyTheme(theme: Theme) {
    navigator.submitPreferences(
        navigator.preferences.copy(
            backgroundColor = theme.backgroundColor,
            textColor = theme.textColor
        )
    )
}
```

---

### 3.5 事件處理

實現 `NavigatorDelegate` 接口處理事件：

```kotlin
interface NavigatorDelegate {
    
    // 位置變化事件
    fun onLocationChanged(locator: Locator?) {
        locator?.let {
            // 保存當前位置
            saveReadingProgress(it)
            
            // 更新 UI（進度條、頁碼等）
            updateProgressBar(it.locations.totalProgression ?: 0.0)
            
            Log.d("Navigator", """
                位置: ${it.href}
                章節進度: ${it.locations.progression}
                總進度: ${it.locations.totalProgression}
            """.trimIndent())
        }
    }
    
    // 翻頁事件
    override fun onPageChanged(pageIndex: Int, totalPages: Int) {
        updatePageIndicator("$pageIndex / $totalPages")
    }
    
    // 用戶點擊事件
    override fun onTap(point: ScreenPoint): Boolean {
        // 返回 true 表示消費事件，false 表示傳遞給下層
        return showReaderMenu()  // 顯示閱讀器菜單
    }
    
    // 長按事件
    override fun onLongPress(point: ScreenPoint): Boolean {
        // 選擇文字、添加批注等
        return handleTextSelection(point)
    }
    
    // 資源加載失敗
    override fun onResourceLoadFailed(href: String, error: Error) {
        Log.e("Navigator", "Failed to load: $href", error)
        showError("無法加載資源: $href")
    }
}
```

---

### 3.6 導航控制

```kotlin
class NavigatorController(private val navigator: Navigator) {
    
    // 下一頁
    fun nextPage() {
        navigator.go(forward = true)
    }
    
    // 上一頁
    fun previousPage() {
        navigator.go(forward = false)
    }
    
    // 跳轉到指定位置
    fun goToLocation(locator: Locator) {
        navigator.go(locator, animated = true)
    }
    
    // 跳轉到章節
    fun goToChapter(index: Int, publication: Publication) {
        val link = publication.readingOrder.getOrNull(index) ?: return
        val locator = Locator(
            href = link.href,
            type = link.type ?: "application/xhtml+xml"
        )
        navigator.go(locator, animated = true)
    }
    
    // 獲取當前位置
    fun getCurrentLocation(): Locator? {
        return navigator.currentLocator
    }
    
    // 搜索文字
    suspend fun search(query: String): List<Locator> {
        return navigator.search(query)
            .getOrNull() ?: emptyList()
    }
}
```

---

## 實踐範例：完整流程

### 示例：打開並顯示 EPUB

```kotlin
class EpubReaderActivity : AppCompatActivity(), NavigatorDelegate {
    
    private lateinit var publication: Publication
    private lateinit var navigator: Navigator
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_reader)
        
        lifecycleScope.launch {
            openAndDisplayEpub("/storage/emulated/0/三世因果目蓮救母經.epub")
        }
    }
    
    private suspend fun openAndDisplayEpub(filePath: String) {
        // 1. 解析 EPUB
        val result = parseEpub(filePath)
        if (result.isFailure) {
            showError("無法打開書籍: ${result.exceptionOrNull()?.message}")
            return
        }
        
        publication = result.getOrThrow()
        
        // 2. 提取元數據
        val title = publication.metadata.title.string()
        val isVertical = publication.metadata.readingProgression == ReadingProgression.RTL
        
        supportActionBar?.title = title
        
        // 3. 配置 Navigator
        val config = EpubNavigatorFactory.Configuration(
            readingProgression = if (isVertical) ReadingProgression.RTL else ReadingProgression.LTR,
            scroll = false,
            preferences = EpubPreferences(
                fontSize = 1.2,
                lineHeight = 1.5
            )
        )
        
        // 4. 創建並顯示 Navigator
        navigator = EpubNavigatorFactory(publication)
            .createFragmentNavigator(
                activity = this,
                configuration = config,
                initialLocation = loadLastLocation(),  // 從上次位置開始
                listener = this
            )
        
        supportFragmentManager.beginTransaction()
            .replace(R.id.reader_container, navigator.fragment)
            .commit()
    }
    
    private suspend fun parseEpub(filePath: String): Result<Publication> {
        return withContext(Dispatchers.IO) {
            try {
                val streamer = Streamer(applicationContext)
                val assetRetriever = AssetRetriever(contentResolver)
                
                val asset = assetRetriever.retrieve(File(filePath))
                    .getOrThrow()
                
                val pub = streamer.open(asset, allowUserInteraction = false)
                    .getOrThrow()
                
                Result.success(pub)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
    
    // NavigatorDelegate 實現
    override fun onLocationChanged(locator: Locator?) {
        locator?.let { saveLastLocation(it) }
    }
    
    override fun onTap(point: ScreenPoint): Boolean {
        toggleReaderMenu()
        return true
    }
    
    private fun loadLastLocation(): Locator? {
        // 從 SharedPreferences 或數據庫加載
        return null
    }
    
    private fun saveLastLocation(locator: Locator) {
        // 保存到 SharedPreferences 或數據庫
    }
}
```

---

## 核心 API 速查表

### Streamer API

```kotlin
// 創建 Streamer
val streamer = Streamer(context)

// 打開 Publication
streamer.open(asset, allowUserInteraction = false)
    .onSuccess { publication -> }
    .onFailure { error -> }
```

### Publication API

```kotlin
val publication: Publication

// 元數據
publication.metadata.title
publication.metadata.authors
publication.metadata.readingProgression

// 結構
publication.readingOrder       // 章節列表
publication.resources          // 資源列表
publication.tableOfContents    // 目錄

// 資源訪問
publication.get(href)          // 獲取資源
publication.cover()            // 獲取封面
```

### Navigator API

```kotlin
val navigator: Navigator

// 導航
navigator.go(forward = true)           // 下一頁
navigator.go(locator, animated = true) // 跳轉

// 位置
navigator.currentLocator               // 當前位置

// 設置
navigator.submitPreferences(prefs)     // 更新設置

// 搜索
navigator.search(query)                // 搜索文字
```

### Locator API

```kotlin
val locator = Locator(
    href = "/chapter1.xhtml",
    type = "application/xhtml+xml",
    locations = Locations(
        progression = 0.5,
        totalProgression = 0.1
    )
)
```

---

## 關鍵要點總結

### ✅ Day 1: 架構理解
- Readium 三層架構：Shared → Streamer → Navigator
- Publication 是核心數據模型
- Locator 用於位置定位和書籤

### ✅ Day 2: EPUB 解析
- 使用 AssetRetriever + Streamer 打開 EPUB
- Result 類型處理錯誤
- 元數據提取和封面獲取

### ✅ Day 3: 閱讀器配置
- EpubNavigator 提供完整閱讀器 UI
- ReadingProgression 控制直書/橫書
- NavigatorDelegate 處理事件
- 動態更新字體、主題等設置

---

## 下一步行動

1. **Task 4.1.4**: 搭建 Platform Channel
   - 創建 Flutter ↔ Kotlin 通訊橋樑
   - 設計方法調用接口

2. **Task 4.2.1**: 實現 ReadiumBridge
   - 整合 Streamer 和 Navigator
   - 封裝核心功能

3. **Task 4.2.3**: 實現直書橫書切換
   - 基於 ReadingProgression 配置
   - 動態切換模式

---

**學習完成日期**: 2025-11-09  
**準備就緒**: ✅ 可以開始 Task 4.1.4
