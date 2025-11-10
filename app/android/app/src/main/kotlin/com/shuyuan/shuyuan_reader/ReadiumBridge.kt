package com.shuyuan.shuyuan_reader

import android.content.Context
import android.util.Log
import androidx.fragment.app.FragmentActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.readium.r2.shared.publication.Publication
import org.readium.r2.shared.util.asset.AssetRetriever
import org.readium.r2.streamer.Streamer
import java.io.File

/**
 * Readium Bridge
 * 
 * Flutter 和 Readium Kotlin 之間的橋樑
 * 封裝所有 Readium 相關的功能
 * 
 * Task 4.1.4: 骨架實現
 * Task 4.2.1: 基礎功能實現（openBook, closeBook）
 * 
 * @since 2025-11-09
 * @updated 2025-11-10
 */
class ReadiumBridge(private val context: Context) {
    
    private val TAG = "ReadiumBridge"
    
    // Readium 核心組件
    private val streamer: Streamer by lazy {
        Streamer(context)
    }
    
    private val assetRetriever: AssetRetriever by lazy {
        AssetRetriever(context.contentResolver)
    }
    
    // 當前打開的書籍
    private var currentPublication: Publication? = null
    private var currentFilePath: String? = null
    
    // Coroutine scope for async operations
    private val scope = CoroutineScope(Dispatchers.Main)
    
    /**
     * 打開書籍
     * 
     * Task 4.2.1: 完整實現
     * 
     * @param filePath EPUB 文件路徑
     * @param isVertical 是否為直書模式（目前僅記錄，Task 4.2.3 會使用）
     */
    fun openBook(filePath: String, isVertical: Boolean) {
        Log.d(TAG, "openBook called: filePath=$filePath, isVertical=$isVertical")
        
        // 在後台線程執行 EPUB 解析
        scope.launch {
            try {
                // 1. 檢查文件是否存在
                val file = File(filePath)
                if (!file.exists()) {
                    Log.e(TAG, "File not found: $filePath")
                    throw Exception("File not found: $filePath")
                }
                
                Log.d(TAG, "File exists, size: ${file.length()} bytes")
                
                // 2. 關閉當前書籍（如果有）
                closeBookInternal()
                
                // 3. 使用 AssetRetriever 加載文件
                Log.d(TAG, "Retrieving asset...")
                val asset = withContext(Dispatchers.IO) {
                    assetRetriever.retrieve(file)
                        .getOrElse { error ->
                            Log.e(TAG, "Failed to retrieve asset: ${error.message}")
                            throw error
                        }
                }
                
                Log.d(TAG, "Asset retrieved successfully")
                
                // 4. 使用 Streamer 打開 Publication
                Log.d(TAG, "Opening publication...")
                val publication = withContext(Dispatchers.IO) {
                    streamer.open(asset, allowUserInteraction = false)
                        .getOrElse { error ->
                            Log.e(TAG, "Failed to open publication: ${error.message}")
                            throw error
                        }
                }
                
                Log.d(TAG, "Publication opened successfully")
                
                // 5. 保存當前 Publication
                currentPublication = publication
                currentFilePath = filePath
                
                // 6. 輸出書籍基本信息
                logPublicationInfo(publication)
                
                // TODO: Task 4.2.3 - 創建並顯示 EpubNavigator
                Log.d(TAG, "Book opened successfully (Navigator will be created in Task 4.2.3)")
                
            } catch (e: Exception) {
                Log.e(TAG, "Failed to open book", e)
                currentPublication = null
                currentFilePath = null
                throw e
            }
        }
    }
    
    /**
     * 關閉當前書籍
     * 
     * Task 4.2.1: 完整實現
     */
    fun closeBook() {
        Log.d(TAG, "closeBook called")
        closeBookInternal()
    }
    
    /**
     * 內部方法：關閉書籍並釋放資源
     */
    private fun closeBookInternal() {
        currentPublication?.let { publication ->
            Log.d(TAG, "Closing publication: ${publication.metadata.title}")
            
            // TODO: Task 4.2.3 - 銷毀 Navigator
            // navigator?.destroy()
            
            // 關閉 Publication
            try {
                publication.close()
                Log.d(TAG, "Publication closed successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Error closing publication", e)
            }
        }
        
        currentPublication = null
        currentFilePath = null
        Log.d(TAG, "Book closed and resources released")
    }
    
    /**
     * 輸出 Publication 信息（用於調試）
     */
    private fun logPublicationInfo(publication: Publication) {
        val metadata = publication.metadata
        Log.d(TAG, "=== Publication Info ===")
        Log.d(TAG, "Title: ${metadata.title}")
        Log.d(TAG, "Authors: ${metadata.authors.joinToString { it.name }}")
        Log.d(TAG, "Language: ${metadata.languages.firstOrNull() ?: "Unknown"}")
        Log.d(TAG, "Reading Progression: ${metadata.readingProgression}")
        Log.d(TAG, "Chapters: ${publication.readingOrder.size}")
        Log.d(TAG, "Resources: ${publication.resources.size}")
        Log.d(TAG, "========================")
    }
    
    /**
     * 下一頁
     * 
     * TODO: Task 4.2.3 實現
     * - 調用 Navigator.go(forward = true)
     */
    fun nextPage() {
        Log.d(TAG, "nextPage called")
        // TODO: 在 Task 4.2.3 實現
        // navigator.go(forward = true)
    }
    
    /**
     * 上一頁
     * 
     * TODO: Task 4.2.3 實現
     * - 調用 Navigator.go(forward = false)
     */
    fun previousPage() {
        Log.d(TAG, "previousPage called")
        // TODO: 在 Task 4.2.3 實現
        // navigator.go(forward = false)
    }
    
    /**
     * 獲取當前位置
     * 
     * @return 位置信息 Map
     * 
     * TODO: Task 4.2.3 實現
     * - 從 Navigator 獲取 currentLocator
     * - 轉換為 Map 返回
     */
    fun getCurrentLocation(): Map<String, Any> {
        Log.d(TAG, "getCurrentLocation called")
        // TODO: 在 Task 4.2.3 實現
        // val locator = navigator.currentLocator
        // return mapOf(
        //     "href" to locator.href,
        //     "progression" to locator.locations.progression,
        //     "totalProgression" to locator.locations.totalProgression
        // )
        return emptyMap()
    }
    
    /**
     * 設置字體大小
     * 
     * @param size 字體大小倍數 (1.0 = 默認)
     * 
     * TODO: Task 4.4.2 實現
     * - 更新 Navigator preferences
     */
    fun setFontSize(size: Double) {
        Log.d(TAG, "setFontSize called: size=$size")
        // TODO: 在 Task 4.4.2 實現
        // val prefs = navigator.preferences.copy(fontSize = size)
        // navigator.submitPreferences(prefs)
    }
    
    /**
     * 設置閱讀方向
     * 
     * @param direction "rtl" 或 "ltr"
     * 
     * TODO: Task 4.2.3 實現
     * - 根據 direction 更新 ReadingProgression
     * - 重新配置 Navigator
     */
    fun setReadingDirection(direction: String) {
        Log.d(TAG, "setReadingDirection called: direction=$direction")
        // TODO: 在 Task 4.2.3 實現
        // val progression = when (direction) {
        //     "rtl" -> ReadingProgression.RTL
        //     "ltr" -> ReadingProgression.LTR
        //     else -> ReadingProgression.AUTO
        // }
        // 重新配置 Navigator
    }
    
    /**
     * 切換書籤
     * 
     * @return 書籤信息 Map
     * 
     * TODO: Task 4.4.1 實現
     * - 獲取當前位置
     * - 添加或移除書籤
     * - 保存到數據庫
     */
    fun toggleBookmark(): Map<String, Any> {
        Log.d(TAG, "toggleBookmark called")
        // TODO: 在 Task 4.4.1 實現
        // val locator = navigator.currentLocator
        // val isBookmarked = bookmarkRepository.toggle(locator)
        // return mapOf(
        //     "isBookmarked" to isBookmarked,
        //     "locator" to locatorToMap(locator)
        // )
        return mapOf("isBookmarked" to false)
    }
    
    /**
     * 設置行高
     * 
     * @param lineHeight 行高倍數 (1.0 = 默認)
     * 
     * TODO: Task 4.4.2 實現
     */
    fun setLineHeight(lineHeight: Double) {
        Log.d(TAG, "setLineHeight called: lineHeight=$lineHeight")
        // TODO: 在 Task 4.4.2 實現
        // val prefs = navigator.preferences.copy(lineHeight = lineHeight)
        // navigator.submitPreferences(prefs)
    }
    
    /**
     * 設置主題
     * 
     * @param theme "light", "dark", 或 "sepia"
     * 
     * TODO: Task 4.4.2 實現
     */
    fun setTheme(theme: String) {
        Log.d(TAG, "setTheme called: theme=$theme")
        // TODO: 在 Task 4.4.2 實現
        // val (bgColor, textColor) = when (theme) {
        //     "dark" -> Pair(Color.BLACK, Color.WHITE)
        //     "sepia" -> Pair(Color(0xFFFBF0D9), Color(0xFF5F4B32))
        //     else -> Pair(Color.WHITE, Color.BLACK)
        // }
        // val prefs = navigator.preferences.copy(
        //     backgroundColor = bgColor,
        //     textColor = textColor
        // )
        // navigator.submitPreferences(prefs)
    }
    
    /**
     * 跳轉到指定位置
     * 
     * @param locatorMap 位置信息 Map
     * 
     * TODO: Task 4.2.3 實現
     */
    fun goToLocation(locatorMap: Map<String, Any>) {
        Log.d(TAG, "goToLocation called: $locatorMap")
        // TODO: 在 Task 4.2.3 實現
        // val locator = mapToLocator(locatorMap)
        // navigator.go(locator, animated = true)
    }
    
    /**
     * 搜索文字
     * 
     * @param query 搜索關鍵字
     * @return 匹配位置列表
     * 
     * TODO: Task 4.4.3 實現
     */
    suspend fun searchText(query: String): List<Map<String, Any>> {
        Log.d(TAG, "searchText called: query=$query")
        // TODO: 在 Task 4.4.3 實現
        // val results = navigator.search(query).getOrNull() ?: emptyList()
        // return results.map { locatorToMap(it) }
        return emptyList()
    }
    
    // ========== 輔助方法（待實現）==========
    
    /**
     * 將 Locator 轉換為 Map
     * TODO: Task 4.2.3 實現
     */
    private fun locatorToMap(locator: Any): Map<String, Any> {
        // TODO: 實現轉換邏輯
        return emptyMap()
    }
    
    /**
     * 將 Map 轉換為 Locator
     * TODO: Task 4.2.3 實現
     */
    private fun mapToLocator(map: Map<String, Any>): Any {
        // TODO: 實現轉換邏輯
        throw NotImplementedError("mapToLocator not implemented yet")
    }
}
