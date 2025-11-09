package com.shuyuan.shuyuan_reader

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * MainActivity
 * 
 * 配置 Platform Channel 並連接 ReadiumBridge
 * 這是 Task 4.1.4 的實現
 * 
 * @since 2025-11-09
 */
class MainActivity : FlutterActivity() {
    
    private val TAG = "MainActivity"
    private val CHANNEL = "com.shuyuan.reader/epub"
    
    private lateinit var readiumBridge: ReadiumBridge
    private val coroutineScope = CoroutineScope(Dispatchers.Main)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "Configuring Flutter Engine")
        
        // 初始化 ReadiumBridge
        readiumBridge = ReadiumBridge(this)
        
        // 設置 Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d(TAG, "Method called: ${call.method}")
                
                try {
                    when (call.method) {
                        "openBook" -> {
                            val filePath = call.argument<String>("filePath")
                                ?: throw IllegalArgumentException("filePath is required")
                            val isVertical = call.argument<Boolean>("isVertical") ?: false
                            
                            readiumBridge.openBook(filePath, isVertical)
                            result.success(null)
                        }
                        
                        "closeBook" -> {
                            readiumBridge.closeBook()
                            result.success(null)
                        }
                        
                        "nextPage" -> {
                            readiumBridge.nextPage()
                            result.success(null)
                        }
                        
                        "previousPage" -> {
                            readiumBridge.previousPage()
                            result.success(null)
                        }
                        
                        "getCurrentLocation" -> {
                            val location = readiumBridge.getCurrentLocation()
                            result.success(location)
                        }
                        
                        "setFontSize" -> {
                            val size = call.argument<Double>("size")
                                ?: throw IllegalArgumentException("size is required")
                            readiumBridge.setFontSize(size)
                            result.success(null)
                        }
                        
                        "setReadingDirection" -> {
                            val direction = call.argument<String>("direction")
                                ?: throw IllegalArgumentException("direction is required")
                            readiumBridge.setReadingDirection(direction)
                            result.success(null)
                        }
                        
                        "toggleBookmark" -> {
                            val bookmark = readiumBridge.toggleBookmark()
                            result.success(bookmark)
                        }
                        
                        "setLineHeight" -> {
                            val lineHeight = call.argument<Double>("lineHeight")
                                ?: throw IllegalArgumentException("lineHeight is required")
                            readiumBridge.setLineHeight(lineHeight)
                            result.success(null)
                        }
                        
                        "setTheme" -> {
                            val theme = call.argument<String>("theme")
                                ?: throw IllegalArgumentException("theme is required")
                            readiumBridge.setTheme(theme)
                            result.success(null)
                        }
                        
                        "goToLocation" -> {
                            val locator = call.argument<Map<String, Any>>("locator")
                                ?: throw IllegalArgumentException("locator is required")
                            readiumBridge.goToLocation(locator)
                            result.success(null)
                        }
                        
                        "searchText" -> {
                            val query = call.argument<String>("query")
                                ?: throw IllegalArgumentException("query is required")
                            
                            // 搜索是 suspend 函數，需要在 coroutine 中運行
                            coroutineScope.launch {
                                try {
                                    val results = readiumBridge.searchText(query)
                                    result.success(results)
                                } catch (e: Exception) {
                                    Log.e(TAG, "Search failed", e)
                                    result.error("SEARCH_ERROR", e.message, null)
                                }
                            }
                        }
                        
                        else -> {
                            Log.w(TAG, "Method not implemented: ${call.method}")
                            result.notImplemented()
                        }
                    }
                } catch (e: IllegalArgumentException) {
                    Log.e(TAG, "Invalid argument", e)
                    result.error("INVALID_ARGUMENT", e.message, null)
                } catch (e: Exception) {
                    Log.e(TAG, "Method call failed", e)
                    result.error("ERROR", e.message, null)
                }
            }
        
        Log.d(TAG, "Flutter Engine configured successfully")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // 清理資源
        readiumBridge.closeBook()
    }
}
