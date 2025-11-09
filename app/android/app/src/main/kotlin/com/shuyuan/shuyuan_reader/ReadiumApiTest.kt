package com.shuyuan.shuyuan_reader

import android.content.Context
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.readium.r2.shared.publication.Locator
import org.readium.r2.shared.publication.Locations
import org.readium.r2.shared.publication.Publication
import org.readium.r2.shared.publication.ReadingProgression
import org.readium.r2.shared.util.asset.AssetRetriever
import org.readium.r2.streamer.Streamer
import java.io.File

/**
 * Readium API 測試類
 * 
 * 用於驗證對 Readium Kotlin API 的理解
 * 這是 Task 4.1.3 的驗證代碼
 * 
 * @since 2025-11-09
 */
class ReadiumApiTest(private val context: Context) {
    
    private val TAG = "ReadiumApiTest"
    
    // Streamer 實例（用於解析 EPUB）
    private val streamer = Streamer(context)
    
    // AssetRetriever（用於加載文件）
    private val assetRetriever = AssetRetriever(
        context.contentResolver,
        httpClient = null
    )
    
    /**
     * 測試 1: EPUB 解析流程
     * 驗證：Asset → Streamer → Publication
     */
    suspend fun testEpubParsing(filePath: String): Result<Publication> = withContext(Dispatchers.IO) {
        try {
            Log.d(TAG, "開始解析 EPUB: $filePath")
            
            // Step 1: 創建 Asset
            val file = File(filePath)
            if (!file.exists()) {
                return@withContext Result.failure(Exception("文件不存在: $filePath"))
            }
            
            val asset = assetRetriever.retrieve(file)
                .getOrElse { 
                    Log.e(TAG, "無法加載 Asset", it)
                    return@withContext Result.failure(it) 
                }
            
            Log.d(TAG, "Asset 創建成功，類型: ${asset.format}")
            
            // Step 2: 使用 Streamer 打開
            val publication = streamer.open(asset, allowUserInteraction = false)
                .getOrElse { 
                    Log.e(TAG, "無法打開 Publication", it)
                    return@withContext Result.failure(it) 
                }
            
            Log.d(TAG, "Publication 創建成功")
            
            Result.success(publication)
        } catch (e: Exception) {
            Log.e(TAG, "解析失敗", e)
            Result.failure(e)
        }
    }
    
    /**
     * 測試 2: 元數據提取
     * 驗證：Metadata, ReadingProgression
     */
    fun testMetadataExtraction(publication: Publication) {
        val metadata = publication.metadata
        
        // 書名
        val title = metadata.title.string()
        Log.d(TAG, "書名: $title")
        
        // 作者
        val authors = metadata.authors.joinToString { it.name }
        Log.d(TAG, "作者: $authors")
        
        // 語言
        val language = metadata.languages.firstOrNull()
        Log.d(TAG, "語言: $language")
        
        // 閱讀方向
        val readingProgression = metadata.readingProgression
        val isVertical = readingProgression == ReadingProgression.RTL
        Log.d(TAG, "閱讀方向: $readingProgression (直書: $isVertical)")
        
        // 章節數量
        val chapterCount = publication.readingOrder.size
        Log.d(TAG, "章節數量: $chapterCount")
        
        // 目錄
        val tocSize = publication.tableOfContents.size
        Log.d(TAG, "目錄條目: $tocSize")
    }
    
    /**
     * 測試 3: Publication 結構遍歷
     * 驗證：ReadingOrder, Resources
     */
    fun testPublicationStructure(publication: Publication) {
        Log.d(TAG, "=== Publication 結構 ===")
        
        // 閱讀順序（章節列表）
        Log.d(TAG, "ReadingOrder:")
        publication.readingOrder.forEachIndexed { index, link ->
            Log.d(TAG, "  [$index] ${link.href} (${link.type})")
        }
        
        // 資源列表
        Log.d(TAG, "Resources:")
        publication.resources.take(5).forEach { link ->
            Log.d(TAG, "  - ${link.href} (${link.type})")
        }
        if (publication.resources.size > 5) {
            Log.d(TAG, "  ... 還有 ${publication.resources.size - 5} 個資源")
        }
        
        // 鏈接
        Log.d(TAG, "Links:")
        publication.links.forEach { link ->
            Log.d(TAG, "  - ${link.href} [${link.rels.joinToString()}]")
        }
    }
    
    /**
     * 測試 4: Locator 創建和使用
     * 驗證：Locator, Locations
     */
    fun testLocatorCreation(publication: Publication): Locator? {
        // 獲取第一章
        val firstChapter = publication.readingOrder.firstOrNull() ?: return null
        
        // 創建 Locator（假設在章節 25% 位置）
        val locator = Locator(
            href = firstChapter.href,
            type = firstChapter.type ?: "application/xhtml+xml",
            title = "第一章",
            locations = Locations(
                progression = 0.25,        // 章節內 25% 位置
                totalProgression = 0.05,   // 整本書 5% 位置
                position = 3               // 第 3 頁
            )
        )
        
        Log.d(TAG, """
            Locator 創建成功:
              位置: ${locator.href}
              標題: ${locator.title}
              章節進度: ${locator.locations.progression}
              總進度: ${locator.locations.totalProgression}
              頁碼: ${locator.locations.position}
        """.trimIndent())
        
        return locator
    }
    
    /**
     * 測試 5: 封面提取
     * 驗證：Publication.cover()
     */
    suspend fun testCoverExtraction(publication: Publication) = withContext(Dispatchers.IO) {
        try {
            val cover = publication.cover()
            if (cover != null) {
                Log.d(TAG, "封面提取成功: ${cover.width}x${cover.height}")
            } else {
                Log.d(TAG, "此書無封面")
            }
        } catch (e: Exception) {
            Log.e(TAG, "封面提取失敗", e)
        }
    }
    
    /**
     * 測試 6: 資源訪問
     * 驗證：Publication.get()
     */
    suspend fun testResourceAccess(publication: Publication) = withContext(Dispatchers.IO) {
        // 獲取第一章資源
        val firstChapterHref = publication.readingOrder.firstOrNull()?.href ?: return@withContext
        
        try {
            val resource = publication.get(firstChapterHref)
            if (resource != null) {
                val length = resource.length().getOrNull()
                Log.d(TAG, "資源訪問成功: $firstChapterHref (大小: $length bytes)")
            } else {
                Log.d(TAG, "資源不存在: $firstChapterHref")
            }
        } catch (e: Exception) {
            Log.e(TAG, "資源訪問失敗", e)
        }
    }
    
    /**
     * 運行所有測試
     */
    suspend fun runAllTests(epubPath: String) {
        Log.d(TAG, "====================================")
        Log.d(TAG, "開始 Readium API 測試")
        Log.d(TAG, "====================================")
        
        // Test 1: 解析 EPUB
        val result = testEpubParsing(epubPath)
        if (result.isFailure) {
            Log.e(TAG, "測試失敗: 無法解析 EPUB")
            return
        }
        
        val publication = result.getOrThrow()
        Log.d(TAG, "✅ Test 1: EPUB 解析成功")
        
        // Test 2: 元數據提取
        testMetadataExtraction(publication)
        Log.d(TAG, "✅ Test 2: 元數據提取成功")
        
        // Test 3: 結構遍歷
        testPublicationStructure(publication)
        Log.d(TAG, "✅ Test 3: 結構遍歷成功")
        
        // Test 4: Locator 創建
        val locator = testLocatorCreation(publication)
        if (locator != null) {
            Log.d(TAG, "✅ Test 4: Locator 創建成功")
        }
        
        // Test 5: 封面提取
        testCoverExtraction(publication)
        Log.d(TAG, "✅ Test 5: 封面提取測試完成")
        
        // Test 6: 資源訪問
        testResourceAccess(publication)
        Log.d(TAG, "✅ Test 6: 資源訪問測試完成")
        
        Log.d(TAG, "====================================")
        Log.d(TAG, "所有測試完成！")
        Log.d(TAG, "====================================")
    }
    
    /**
     * 測試直書橫書判斷邏輯
     */
    fun testReadingDirection(publication: Publication) {
        val metadata = publication.metadata
        val progression = metadata.readingProgression
        
        val direction = when (progression) {
            ReadingProgression.RTL -> "直書（右到左）"
            ReadingProgression.LTR -> "橫書（左到右）"
            ReadingProgression.TTB -> "上到下"
            ReadingProgression.BTT -> "下到上"
            ReadingProgression.AUTO -> "自動檢測"
        }
        
        Log.d(TAG, """
            閱讀方向分析:
              原始值: $progression
              解釋: $direction
              適用場景: ${getScenario(progression)}
        """.trimIndent())
    }
    
    private fun getScenario(progression: ReadingProgression): String {
        return when (progression) {
            ReadingProgression.RTL -> "繁體中文、日文古籍"
            ReadingProgression.LTR -> "簡體中文、英文書籍"
            ReadingProgression.TTB -> "蒙古文"
            ReadingProgression.BTT -> "特殊排版"
            ReadingProgression.AUTO -> "根據語言自動判斷"
        }
    }
}

/**
 * 使用示例
 * 
 * ```kotlin
 * val tester = ReadiumApiTest(context)
 * 
 * lifecycleScope.launch {
 *     tester.runAllTests("/storage/emulated/0/books/三世因果目蓮救母經.epub")
 * }
 * ```
 */
