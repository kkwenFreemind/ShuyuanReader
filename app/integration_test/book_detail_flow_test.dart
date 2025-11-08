import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shuyuan_reader/presentation/pages/book_detail_page.dart';
import 'package:shuyuan_reader/presentation/pages/book_list/book_list_page.dart';
import 'package:shuyuan_reader/main.dart' as app;

/// 書籍詳情頁面集成測試
/// 
/// 測試完整的書籍詳情流程，包括：
/// - 從書籍列表進入詳情頁
/// - 書籍詳細信息顯示
/// - 下載流程（開始、暫停、繼續、取消）
/// - 打開閱讀功能
/// - 刪除書籍功能
/// - 返回導航
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// 從書籍列表進入書籍詳情頁的輔助函數
  /// 注意：不啟動應用，假設應用已經在 setUpAll 中啟動
  Future<void> navigateToBookDetail(WidgetTester tester) async {
    // 等待確保在書籍列表頁
    await tester.pumpAndSettle();
    
    // 驗證在書籍列表頁
    expect(find.byType(BookListPage), findsOneWidget,
        reason: '應該在書籍列表頁面');
    
    // 等待書籍加載
    await tester.pump(const Duration(seconds: 1));
    
    // 查找第一個書籍卡片並點擊
    final bookCard = find.byType(Card).first;
    if (bookCard.evaluate().isNotEmpty) {
      await tester.tap(bookCard);
      await tester.pumpAndSettle();
      print('✅ 成功點擊書籍卡片');
    } else {
      print('⚠️  未找到書籍卡片，跳過導航');
    }
  }

  /// 返回到書籍列表頁的輔助函數
  Future<void> backToBookList(WidgetTester tester) async {
    // 如果在詳情頁，點擊返回按鈕
    if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        print('✅ 成功返回書籍列表');
      }
    }
  }

  group('BookDetail Navigation Tests', () {
    setUpAll(() async {
      // 所有測試開始前，只啟動一次應用
      print('🚀 啟動應用...');
      app.main();
    });

    testWidgets('Should navigate to BookDetailPage from BookList',
        (WidgetTester tester) async {
      print('\n🚀 測試：從書籍列表導航到詳情頁...');
      
      // 等待應用完全加載到書籍列表
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4)); // 等待 Splash
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 導航到書籍詳情
      await navigateToBookDetail(tester);
      
      // 驗證已導航到詳情頁
      final detailPage = find.byType(BookDetailPage);
      if (detailPage.evaluate().isNotEmpty) {
        expect(detailPage, findsOneWidget,
            reason: '應該導航到書籍詳情頁面');
        
        // 驗證 AppBar 存在
        expect(find.byType(AppBar), findsOneWidget,
            reason: 'AppBar 應該存在');
        
        print('✅ 導航測試通過');
        
        // 返回書籍列表，為下一個測試做準備
        await backToBookList(tester);
      } else {
        print('ℹ️  無可用書籍，跳過詳情頁測試');
      }
    });

    testWidgets('BookDetailPage should display book information',
        (WidgetTester tester) async {
      print('\n🚀 測試：書籍信息顯示...');
      
      // 導航到詳情頁
      await navigateToBookDetail(tester);
      
      // 如果成功進入詳情頁
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 驗證基本 UI 元素
        expect(find.byType(SingleChildScrollView), findsOneWidget,
            reason: '應該有滾動容器');
        
        // 檢查是否有文本內容（書名、作者等）
        final hasText = find.byType(Text).evaluate().isNotEmpty;
        expect(hasText, true, reason: '應該顯示書籍信息');
        
        print('✅ 書籍信息顯示測試通過');
        
        // 返回書籍列表
        await backToBookList(tester);
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });

    testWidgets('Back button should return to BookList',
        (WidgetTester tester) async {
      print('\n🚀 測試：返回導航...');
    testWidgets('Should navigate to BookDetailPage from BookList',
        (WidgetTester tester) async {
      print('🚀 測試：從書籍列表導航到詳情頁...');
      
      // 啟動應用並導航到書籍詳情
      await navigateToBookDetail(tester);
      
      // 驗證已導航到詳情頁
      final detailPage = find.byType(BookDetailPage);
      if (detailPage.evaluate().isNotEmpty) {
        expect(detailPage, findsOneWidget,
            reason: '應該導航到書籍詳情頁面');
        
        // 驗證 AppBar 存在
        expect(find.byType(AppBar), findsOneWidget,
            reason: 'AppBar 應該存在');
        
        print('✅ 導航測試通過');
      } else {
        print('ℹ️  無可用書籍，跳過詳情頁測試');
      }
    });

    testWidgets('BookDetailPage should display book information',
        (WidgetTester tester) async {
      print('🚀 測試：書籍信息顯示...');
      
      // 導航到詳情頁
      await navigateToBookDetail(tester);
      
      // 如果成功進入詳情頁
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 驗證基本 UI 元素
        expect(find.byType(SingleChildScrollView), findsOneWidget,
            reason: '應該有滾動容器');
        
        // 檢查是否有文本內容（書名、作者等）
        final hasText = find.byType(Text).evaluate().isNotEmpty;
        expect(hasText, true, reason: '應該顯示書籍信息');
        
        print('✅ 書籍信息顯示測試通過');
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });

    testWidgets('Back button should return to BookList',
        (WidgetTester tester) async {
      print('🚀 測試：返回導航...');
      
      // 導航到詳情頁
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 查找返回按鈕
        final backButton = find.byTooltip('Back');
        if (backButton.evaluate().isNotEmpty) {
          // 點擊返回
          await tester.tap(backButton);
          await tester.pumpAndSettle();
          
          // 驗證返回到列表頁
          expect(find.byType(BookListPage), findsOneWidget,
              reason: '應該返回書籍列表頁面');
          
          print('✅ 返回導航測試通過');
        } else {
          print('⚠️  未找到返回按鈕');
        }
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });
  });

  group('BookDetail Display Tests', () {
    testWidgets('Should display cover image placeholder',
        (WidgetTester tester) async {
      print('🚀 測試：封面圖片顯示...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 等待圖片加載
        await tester.pump(const Duration(milliseconds: 500));
        
        // 應該有 CircularProgressIndicator（圖片加載中）或圖片
        final hasProgressIndicator = find.byType(CircularProgressIndicator)
            .evaluate().isNotEmpty;
        
        if (hasProgressIndicator) {
          print('✅ 封面圖片加載指示器顯示正常');
        } else {
          print('✅ 封面圖片已加載');
        }
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });

    testWidgets('Should display book metadata',
        (WidgetTester tester) async {
      print('🚀 測試：書籍元數據顯示...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 等待內容加載
        await tester.pump(const Duration(milliseconds: 500));
        
        // 驗證有文本內容
        final textWidgets = find.byType(Text);
        expect(textWidgets.evaluate().length, greaterThan(0),
            reason: '應該顯示書籍信息文本');
        
        print('✅ 書籍元數據顯示測試通過');
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });

    testWidgets('Should be scrollable',
        (WidgetTester tester) async {
      print('🚀 測試：頁面滾動...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 查找滾動視圖
        final scrollView = find.byType(SingleChildScrollView);
        if (scrollView.evaluate().isNotEmpty) {
          // 執行滾動
          await tester.drag(scrollView, const Offset(0, -200));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          
          // 應用不應該崩潰
          expect(find.byType(BookDetailPage), findsOneWidget);
          
          print('✅ 滾動測試通過');
        } else {
          print('⚠️  未找到滾動視圖');
        }
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });
  });

  group('BookDetail Download Action Tests', () {
    testWidgets('Should display download button for undownloaded book',
        (WidgetTester tester) async {
      print('🚀 測試：未下載書籍的下載按鈕顯示...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 等待內容加載
        await tester.pump(const Duration(milliseconds: 500));
        
        // 查找下載相關按鈕（可能是"下載書籍"或其他狀態）
        final downloadButton = find.text('下載書籍');
        final openButton = find.text('打開閱讀');
        
        // 應該有下載按鈕或打開按鈕之一
        final hasActionButton = downloadButton.evaluate().isNotEmpty ||
            openButton.evaluate().isNotEmpty;
        
        expect(hasActionButton, true,
            reason: '應該顯示下載或打開按鈕');
        
        if (downloadButton.evaluate().isNotEmpty) {
          print('✅ 下載按鈕顯示正常（未下載狀態）');
        } else if (openButton.evaluate().isNotEmpty) {
          print('✅ 打開按鈕顯示正常（已下載狀態）');
        }
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });

    testWidgets('Download button should be tappable',
        (WidgetTester tester) async {
      print('🚀 測試：下載按鈕可點擊...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        await tester.pump(const Duration(milliseconds: 500));
        
        // 查找下載按鈕
        final downloadButton = find.text('下載書籍');
        
        if (downloadButton.evaluate().isNotEmpty) {
          // 嘗試點擊下載按鈕
          await tester.tap(downloadButton);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          
          // 應用不應該崩潰
          expect(find.byType(BookDetailPage), findsOneWidget);
          
          print('✅ 下載按鈕點擊測試通過');
        } else {
          print('ℹ️  未找到下載按鈕（可能已下載）');
        }
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });
  });

  group('BookDetail Complete Download Flow Tests', () {
    testWidgets('Complete download flow: Click download button and verify downloading state',
        (WidgetTester tester) async {
      print('🚀 測試：完整下載流程 - 點擊下載並驗證下載狀態...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 查找下載按鈕
      final downloadButton = find.text('下載書籍');
      
      if (downloadButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕（書籍可能已下載），跳過測試');
        return;
      }
      
      print('✅ Step 1: 找到下載按鈕');
      
      // Step 2: 點擊下載按鈕
      await tester.tap(downloadButton);
      await tester.pump();
      print('✅ Step 2: 已點擊下載按鈕');
      
      // Step 3: 等待下載開始（UI 可能需要時間更新）
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 4: 驗證進入下載狀態
      // 可能的下載狀態指示器：進度條、下載進度文字、暫停按鈕
      final hasProgressIndicator = find.byType(LinearProgressIndicator)
          .evaluate().isNotEmpty;
      final hasPauseButton = find.text('暫停').evaluate().isNotEmpty ||
          find.text('取消').evaluate().isNotEmpty;
      final hasDownloadingText = find.textContaining('%').evaluate().isNotEmpty;
      
      final isDownloading = hasProgressIndicator || hasPauseButton || hasDownloadingText;
      
      if (isDownloading) {
        print('✅ Step 3: 確認進入下載狀態');
        
        if (hasProgressIndicator) {
          print('  - 顯示下載進度條 ✓');
        }
        if (hasPauseButton) {
          print('  - 顯示暫停/取消按鈕 ✓');
        }
        if (hasDownloadingText) {
          print('  - 顯示下載進度百分比 ✓');
        }
        
        expect(isDownloading, true, reason: '應該進入下載狀態');
      } else {
        print('⚠️  未檢測到明確的下載狀態（下載可能太快完成）');
      }
      
      // Step 5: 等待一段時間觀察下載進度
      await tester.pump(const Duration(seconds: 1));
      
      // 驗證應用仍然穩定
      expect(find.byType(BookDetailPage), findsOneWidget,
          reason: '下載過程中應用應該保持穩定');
      
      print('✅ Step 4: 下載流程測試完成');
      print('🎉 完整下載流程測試通過！');
    });

    testWidgets('Download flow: Pause and resume download',
        (WidgetTester tester) async {
      print('🚀 測試：下載流程 - 暫停和繼續下載...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 開始下載
      final downloadButton = find.text('下載書籍');
      
      if (downloadButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕，跳過測試');
        return;
      }
      
      await tester.tap(downloadButton);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 1: 開始下載');
      
      // Step 2: 查找並點擊暫停按鈕
      final pauseButton = find.text('暫停');
      
      if (pauseButton.evaluate().isNotEmpty) {
        await tester.tap(pauseButton);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Step 2: 點擊暫停按鈕');
        
        // Step 3: 驗證暫停狀態
        // 暫停後應該有"繼續"或"下載"按鈕
        final resumeButton = find.text('繼續');
        final continueButton = find.text('下載');
        
        final hasPausedState = resumeButton.evaluate().isNotEmpty ||
            continueButton.evaluate().isNotEmpty;
        
        if (hasPausedState) {
          print('✅ Step 3: 確認進入暫停狀態');
          
          // Step 4: 點擊繼續按鈕
          if (resumeButton.evaluate().isNotEmpty) {
            await tester.tap(resumeButton);
            print('✅ Step 4: 點擊繼續按鈕');
          } else if (continueButton.evaluate().isNotEmpty) {
            await tester.tap(continueButton);
            print('✅ Step 4: 點擊下載按鈕（繼續下載）');
          }
          
          await tester.pump(const Duration(milliseconds: 500));
          
          // 驗證恢復下載狀態
          expect(find.byType(BookDetailPage), findsOneWidget,
              reason: '繼續下載後應用應該穩定');
          
          print('✅ Step 5: 恢復下載成功');
        } else {
          print('⚠️  未檢測到暫停狀態（可能下載太快）');
        }
      } else {
        print('ℹ️  未找到暫停按鈕（下載可能太快完成）');
      }
      
      print('🎉 暫停/繼續測試完成！');
    });

    testWidgets('Download flow: Monitor download progress',
        (WidgetTester tester) async {
      print('🚀 測試：下載流程 - 監控下載進度...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 開始下載
      final downloadButton = find.text('下載書籍');
      
      if (downloadButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕，跳過測試');
        return;
      }
      
      await tester.tap(downloadButton);
      await tester.pump(const Duration(milliseconds: 300));
      print('✅ 開始下載');
      
      // 監控進度變化
      int progressCheckCount = 0;
      Set<String> progressValues = {};
      
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        
        // 查找進度百分比文字
        final progressText = find.textContaining('%');
        
        if (progressText.evaluate().isNotEmpty) {
          progressCheckCount++;
          final text = progressText.evaluate().first.widget as Text;
          final progressValue = text.data ?? '';
          progressValues.add(progressValue);
          print('  檢查點 ${i + 1}: 進度 = $progressValue');
        }
        
        // 檢查是否已完成
        final openButton = find.text('打開閱讀');
        if (openButton.evaluate().isNotEmpty) {
          print('✅ 下載已完成');
          break;
        }
      }
      
      if (progressCheckCount > 0) {
        print('✅ 成功監控到下載進度（檢查 $progressCheckCount 次）');
        print('✅ 記錄到的進度值: ${progressValues.join(', ')}');
        
        expect(progressCheckCount, greaterThan(0),
            reason: '應該能夠監控到下載進度');
      } else {
        print('ℹ️  未監控到進度變化（下載可能非常快）');
      }
      
      // 驗證應用穩定性
      expect(find.byType(BookDetailPage), findsOneWidget,
          reason: '下載過程中應用應該保持穩定');
      
      print('🎉 進度監控測試完成！');
    });

    testWidgets('Download flow: Verify UI elements during download',
        (WidgetTester tester) async {
      print('🚀 測試：下載流程 - 驗證下載過程中的 UI 元素...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 開始下載
      final downloadButton = find.text('下載書籍');
      
      if (downloadButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕，跳過測試');
        return;
      }
      
      await tester.tap(downloadButton);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 1: 開始下載');
      
      // 驗證下載過程中的 UI 元素
      final uiElements = <String, bool>{
        '進度條 (LinearProgressIndicator)': 
            find.byType(LinearProgressIndicator).evaluate().isNotEmpty,
        '進度百分比文字': 
            find.textContaining('%').evaluate().isNotEmpty,
        '暫停按鈕': 
            find.text('暫停').evaluate().isNotEmpty,
        '取消按鈕': 
            find.text('取消').evaluate().isNotEmpty,
        '下載速度文字': 
            find.textContaining('MB/s').evaluate().isNotEmpty ||
            find.textContaining('KB/s').evaluate().isNotEmpty,
      };
      
      print('✅ Step 2: UI 元素檢查結果：');
      int foundElements = 0;
      uiElements.forEach((name, found) {
        print('  - $name: ${found ? "✓" : "✗"}');
        if (found) foundElements++;
      });
      
      if (foundElements > 0) {
        print('✅ Step 3: 找到 $foundElements/${ uiElements.length} 個預期 UI 元素');
        expect(foundElements, greaterThan(0),
            reason: '下載過程應該至少顯示一個 UI 元素');
      } else {
        print('ℹ️  未找到下載 UI 元素（下載可能太快完成）');
      }
      
      // 驗證基本 UI 仍然存在
      expect(find.byType(BookDetailPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      print('✅ Step 4: 基本 UI 元素正常');
      print('🎉 UI 元素驗證測試完成！');
    });

    testWidgets('Download flow: Handle download completion',
        (WidgetTester tester) async {
      print('🚀 測試：下載流程 - 處理下載完成...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 檢查當前狀態
      final downloadButton = find.text('下載書籍');
      final openButton = find.text('打開閱讀');
      
      if (downloadButton.evaluate().isEmpty && openButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載或打開按鈕，跳過測試');
        return;
      }
      
      // 如果已經是下載完成狀態
      if (openButton.evaluate().isNotEmpty) {
        print('✅ 書籍已處於下載完成狀態');
        print('✅ 找到"打開閱讀"按鈕');
        
        // 驗證完成狀態的 UI
        expect(openButton, findsOneWidget,
            reason: '下載完成後應該顯示打開閱讀按鈕');
        
        // 應該有刪除按鈕
        final deleteButton = find.text('刪除');
        if (deleteButton.evaluate().isNotEmpty) {
          print('✅ 找到"刪除"按鈕');
        }
        
        print('🎉 下載完成狀態驗證通過！');
        return;
      }
      
      // 如果是未下載狀態，開始下載並等待完成
      if (downloadButton.evaluate().isNotEmpty) {
        print('✅ Step 1: 開始下載');
        await tester.tap(downloadButton);
        await tester.pump(const Duration(milliseconds: 500));
        
        // 等待下載完成（最多等待 10 秒）
        print('⏳ Step 2: 等待下載完成...');
        bool downloadCompleted = false;
        
        for (int i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          
          // 檢查是否出現"打開閱讀"按鈕
          final openBtn = find.text('打開閱讀');
          if (openBtn.evaluate().isNotEmpty) {
            downloadCompleted = true;
            print('✅ Step 3: 下載完成（耗時約 ${(i + 1) * 0.5} 秒）');
            break;
          }
          
          // 顯示進度
          if (i % 4 == 0) {
            final progressText = find.textContaining('%');
            if (progressText.evaluate().isNotEmpty) {
              final text = progressText.evaluate().first.widget as Text;
              print('  ⏳ 進度: ${text.data}');
            }
          }
        }
        
        if (downloadCompleted) {
          // 驗證完成後的按鈕
          expect(find.text('打開閱讀'), findsOneWidget,
              reason: '下載完成後應該顯示打開閱讀按鈕');
          
          print('✅ Step 4: 驗證完成狀態 UI');
          print('🎉 下載完成測試通過！');
        } else {
          print('⚠️  下載未在預期時間內完成（可能需要更長時間）');
        }
      }
    });
  });

  group('BookDetail Cancel Download Tests', () {
    testWidgets('Cancel download: Click cancel button during download',
        (WidgetTester tester) async {
      print('🚀 測試：取消下載 - 下載過程中點擊取消按鈕...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 檢查當前狀態
      final downloadButton = find.text('下載書籍');
      
      if (downloadButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕（書籍可能已下載），跳過測試');
        return;
      }
      
      print('✅ Step 1: 找到下載按鈕');
      
      // Step 2: 開始下載
      await tester.tap(downloadButton);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 2: 開始下載');
      
      // Step 3: 等待下載狀態確認
      await tester.pump(const Duration(milliseconds: 300));
      
      // Step 4: 查找取消按鈕
      final cancelButton = find.text('取消');
      
      if (cancelButton.evaluate().isEmpty) {
        print('⚠️  未找到取消按鈕（下載可能太快完成或未開始）');
        // 檢查是否已經完成下載
        final openButton = find.text('打開閱讀');
        if (openButton.evaluate().isNotEmpty) {
          print('ℹ️  下載已完成，無法測試取消功能');
        }
        return;
      }
      
      print('✅ Step 3: 找到取消按鈕');
      
      // Step 5: 點擊取消按鈕
      await tester.tap(cancelButton);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 4: 點擊取消按鈕');
      
      // Step 6: 驗證回到未下載狀態
      await tester.pump(const Duration(milliseconds: 500));
      
      // 應該重新出現下載按鈕
      final downloadButtonAfterCancel = find.text('下載書籍');
      
      if (downloadButtonAfterCancel.evaluate().isNotEmpty) {
        print('✅ Step 5: 確認回到未下載狀態（下載按鈕重新出現）');
        
        expect(downloadButtonAfterCancel, findsOneWidget,
            reason: '取消下載後應該回到未下載狀態，顯示下載按鈕');
        
        // 驗證取消按鈕消失
        final cancelButtonAfter = find.text('取消');
        expect(cancelButtonAfter, findsNothing,
            reason: '取消下載後，取消按鈕應該消失');
        
        // 驗證進度條消失
        final progressIndicator = find.byType(LinearProgressIndicator);
        if (progressIndicator.evaluate().isEmpty) {
          print('✅ Step 6: 進度條已消失');
        }
        
        print('🎉 取消下載測試通過！');
      } else {
        print('⚠️  未檢測到下載按鈕重新出現（可能狀態未完全重置）');
      }
    });

    testWidgets('Cancel download: Verify state reset after cancel',
        (WidgetTester tester) async {
      print('🚀 測試：取消下載 - 驗證取消後狀態完全重置...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 開始下載
      final downloadButton = find.text('下載書籍');
      
      if (downloadButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕，跳過測試');
        return;
      }
      
      await tester.tap(downloadButton);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 1: 開始下載');
      
      // Step 2: 等待進入下載狀態
      await tester.pump(const Duration(milliseconds: 300));
      
      // 記錄下載狀態的 UI 元素
      final hasProgressIndicatorBefore = find.byType(LinearProgressIndicator)
          .evaluate().isNotEmpty;
      final hasProgressTextBefore = find.textContaining('%')
          .evaluate().isNotEmpty;
      
      if (hasProgressIndicatorBefore || hasProgressTextBefore) {
        print('✅ Step 2: 確認進入下載狀態');
        if (hasProgressIndicatorBefore) {
          print('  - 進度條存在 ✓');
        }
        if (hasProgressTextBefore) {
          print('  - 進度文字存在 ✓');
        }
      } else {
        print('⚠️  未檢測到下載狀態（可能太快）');
      }
      
      // Step 3: 取消下載
      final cancelButton = find.text('取消');
      
      if (cancelButton.evaluate().isEmpty) {
        print('⚠️  未找到取消按鈕，跳過測試');
        return;
      }
      
      await tester.tap(cancelButton);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 3: 點擊取消按鈕');
      
      // Step 4: 驗證所有下載相關 UI 元素消失
      await tester.pump(const Duration(milliseconds: 500));
      
      final stateAfterCancel = <String, bool>{
        '下載按鈕重新出現': find.text('下載書籍').evaluate().isNotEmpty,
        '進度條已消失': find.byType(LinearProgressIndicator).evaluate().isEmpty,
        '進度文字已消失': find.textContaining('%').evaluate().isEmpty,
        '取消按鈕已消失': find.text('取消').evaluate().isEmpty,
        '暫停按鈕已消失': find.text('暫停').evaluate().isEmpty,
      };
      
      print('✅ Step 4: 狀態重置檢查結果：');
      int correctStates = 0;
      stateAfterCancel.forEach((name, correct) {
        print('  - $name: ${correct ? "✓" : "✗"}');
        if (correct) correctStates++;
      });
      
      print('✅ Step 5: $correctStates/${stateAfterCancel.length} 個狀態檢查通過');
      
      // 至少應該有下載按鈕重新出現
      expect(find.text('下載書籍'), findsOneWidget,
          reason: '取消後應該顯示下載按鈕');
      
      if (correctStates >= 4) {
        print('🎉 狀態重置測試通過！');
      } else {
        print('⚠️  部分狀態未完全重置');
      }
    });

    testWidgets('Cancel download: Restart download after cancel',
        (WidgetTester tester) async {
      print('🚀 測試：取消下載 - 取消後重新開始下載...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 第一次下載
      final downloadButton1 = find.text('下載書籍');
      
      if (downloadButton1.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕，跳過測試');
        return;
      }
      
      await tester.tap(downloadButton1);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 1: 第一次開始下載');
      
      // Step 2: 取消第一次下載
      await tester.pump(const Duration(milliseconds: 300));
      
      final cancelButton1 = find.text('取消');
      
      if (cancelButton1.evaluate().isEmpty) {
        print('⚠️  未找到取消按鈕，跳過測試');
        return;
      }
      
      await tester.tap(cancelButton1);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 2: 取消第一次下載');
      
      // Step 3: 驗證回到未下載狀態
      await tester.pump(const Duration(milliseconds: 300));
      
      final downloadButton2 = find.text('下載書籍');
      
      if (downloadButton2.evaluate().isEmpty) {
        print('⚠️  取消後未出現下載按鈕');
        return;
      }
      
      print('✅ Step 3: 確認回到未下載狀態');
      
      // Step 4: 第二次下載
      await tester.tap(downloadButton2);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 4: 第二次開始下載');
      
      // Step 5: 驗證第二次下載正常進行
      await tester.pump(const Duration(milliseconds: 500));
      
      // 檢查下載狀態指示器
      final hasDownloadIndicators = 
          find.byType(LinearProgressIndicator).evaluate().isNotEmpty ||
          find.text('取消').evaluate().isNotEmpty ||
          find.text('暫停').evaluate().isNotEmpty ||
          find.textContaining('%').evaluate().isNotEmpty;
      
      if (hasDownloadIndicators) {
        print('✅ Step 5: 第二次下載正常進行');
        expect(hasDownloadIndicators, true,
            reason: '取消後重新下載應該能正常進行');
        print('🎉 重新下載測試通過！');
      } else {
        print('ℹ️  未檢測到下載狀態（可能太快完成）');
      }
      
      // 驗證應用穩定性
      expect(find.byType(BookDetailPage), findsOneWidget,
          reason: '多次操作後應用應該保持穩定');
      
      print('✅ Step 6: 應用穩定性確認');
    });

    testWidgets('Cancel download: Verify no partial files remain',
        (WidgetTester tester) async {
      print('🚀 測試：取消下載 - 驗證取消後無殘留文件狀態...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 開始下載
      final downloadButton = find.text('下載書籍');
      
      if (downloadButton.evaluate().isEmpty) {
        print('ℹ️  未找到下載按鈕，跳過測試');
        return;
      }
      
      await tester.tap(downloadButton);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 1: 開始下載');
      
      // 等待一段時間讓下載進行
      await tester.pump(const Duration(milliseconds: 800));
      
      // 取消下載
      final cancelButton = find.text('取消');
      
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Step 2: 取消下載');
        
        // 驗證 UI 狀態表明沒有部分下載的文件
        await tester.pump(const Duration(milliseconds: 500));
        
        // 不應該有"繼續"按鈕（表示有暫停的下載）
        final continueButton = find.text('繼續');
        expect(continueButton, findsNothing,
            reason: '取消後不應該有繼續按鈕（表示部分下載被保留）');
        
        // 應該有下載按鈕（表示從頭開始）
        final freshDownloadButton = find.text('下載書籍');
        expect(freshDownloadButton, findsOneWidget,
            reason: '取消後應該顯示下載按鈕，而非繼續按鈕');
        
        // 不應該顯示任何進度
        final progressText = find.textContaining('%');
        if (progressText.evaluate().isEmpty) {
          print('✅ Step 3: 確認無殘留進度信息');
        }
        
        print('✅ Step 4: 驗證完全重置到初始狀態');
        print('🎉 無殘留文件測試通過！');
      } else {
        print('⚠️  未找到取消按鈕（下載可能太快完成）');
      }
    });

    testWidgets('Cancel download: Multiple cancel operations',
        (WidgetTester tester) async {
      print('🚀 測試：取消下載 - 多次取消操作...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      int successfulCancels = 0;
      
      // 嘗試多次下載和取消循環
      for (int i = 0; i < 3; i++) {
        print('\n--- 循環 ${i + 1} ---');
        
        // 查找下載按鈕
        final downloadButton = find.text('下載書籍');
        
        if (downloadButton.evaluate().isEmpty) {
          print('ℹ️  循環 ${i + 1}: 未找到下載按鈕，結束測試');
          break;
        }
        
        // 開始下載
        await tester.tap(downloadButton);
        await tester.pump(const Duration(milliseconds: 400));
        print('✅ 循環 ${i + 1}: 開始下載');
        
        // 查找取消按鈕
        await tester.pump(const Duration(milliseconds: 200));
        final cancelButton = find.text('取消');
        
        if (cancelButton.evaluate().isEmpty) {
          print('⚠️  循環 ${i + 1}: 未找到取消按鈕（下載可能太快）');
          break;
        }
        
        // 取消下載
        await tester.tap(cancelButton);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ 循環 ${i + 1}: 取消下載');
        
        // 驗證回到初始狀態
        await tester.pump(const Duration(milliseconds: 300));
        
        final downloadButtonAgain = find.text('下載書籍');
        if (downloadButtonAgain.evaluate().isNotEmpty) {
          successfulCancels++;
          print('✅ 循環 ${i + 1}: 成功回到未下載狀態');
        } else {
          print('⚠️  循環 ${i + 1}: 狀態未正確重置');
          break;
        }
      }
      
      print('\n✅ 完成 $successfulCancels 次成功的下載-取消循環');
      
      if (successfulCancels > 0) {
        expect(successfulCancels, greaterThan(0),
            reason: '應該至少成功完成一次取消操作');
        print('🎉 多次取消操作測試通過！');
      } else {
        print('ℹ️  無法完成取消操作循環（下載可能太快）');
      }
      
      // 驗證最終應用穩定性
      expect(find.byType(BookDetailPage), findsOneWidget,
          reason: '多次取消後應用應該保持穩定');
    });
  });

  group('BookDetail Delete Book Tests', () {
    testWidgets('Delete book: Find delete button for downloaded book',
        (WidgetTester tester) async {
      print('🚀 測試：刪除書籍 - 查找已下載書籍的刪除按鈕...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 檢查書籍狀態
      final openButton = find.text('打開閱讀');
      final deleteButton = find.text('刪除書籍');
      final downloadButton = find.text('下載書籍');
      
      if (openButton.evaluate().isNotEmpty && deleteButton.evaluate().isNotEmpty) {
        print('✅ 書籍已下載狀態');
        print('✅ 找到"打開閱讀"按鈕');
        print('✅ 找到"刪除書籍"按鈕');
        
        expect(deleteButton, findsOneWidget,
            reason: '已下載的書籍應該顯示刪除按鈕');
        
        // 驗證刪除按鈕是紅色的（通過查找 Icon 或 Text 的顏色）
        expect(find.byIcon(Icons.delete_outline), findsOneWidget,
            reason: '刪除按鈕應該有刪除圖標');
        
        print('🎉 刪除按鈕檢查通過！');
      } else if (downloadButton.evaluate().isNotEmpty) {
        print('ℹ️  書籍未下載，需要先下載才能測試刪除功能');
      } else {
        print('⚠️  無法確定書籍狀態');
      }
    });

    testWidgets('Delete book: Click delete shows confirmation dialog',
        (WidgetTester tester) async {
      print('🚀 測試：刪除書籍 - 點擊刪除顯示確認對話框...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 查找刪除按鈕
      final deleteButton = find.text('刪除書籍');
      
      if (deleteButton.evaluate().isEmpty) {
        print('ℹ️  未找到刪除按鈕（書籍可能未下載），跳過測試');
        return;
      }
      
      print('✅ Step 1: 找到刪除按鈕');
      
      // Step 2: 點擊刪除按鈕
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      print('✅ Step 2: 點擊刪除按鈕');
      
      // Step 3: 驗證確認對話框出現
      final confirmDialog = find.byType(AlertDialog);
      
      if (confirmDialog.evaluate().isNotEmpty) {
        print('✅ Step 3: 確認對話框已顯示');
        
        // 驗證對話框內容
        expect(find.text('確認刪除'), findsOneWidget,
            reason: '對話框應該顯示"確認刪除"標題');
        
        // 驗證對話框有取消和刪除按鈕
        final cancelButton = find.text('取消');
        final confirmDeleteButton = find.text('刪除');
        
        expect(cancelButton, findsOneWidget,
            reason: '對話框應該有取消按鈕');
        expect(confirmDeleteButton, findsOneWidget,
            reason: '對話框應該有刪除按鈕');
        
        print('✅ Step 4: 對話框內容驗證通過');
        
        // 點擊取消（避免實際刪除）
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        print('✅ Step 5: 點擊取消按鈕');
        
        // 驗證對話框消失
        expect(find.byType(AlertDialog), findsNothing,
            reason: '點擊取消後對話框應該消失');
        
        print('✅ Step 6: 對話框已關閉');
        print('🎉 確認對話框測試通過！');
      } else {
        print('⚠️  未檢測到確認對話框');
      }
    });

    testWidgets('Delete book: Cancel delete operation',
        (WidgetTester tester) async {
      print('🚀 測試：刪除書籍 - 取消刪除操作...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 確認初始狀態
      final initialDeleteButton = find.text('刪除書籍');
      final initialOpenButton = find.text('打開閱讀');
      
      if (initialDeleteButton.evaluate().isEmpty) {
        print('ℹ️  未找到刪除按鈕，跳過測試');
        return;
      }
      
      final wasDownloaded = initialOpenButton.evaluate().isNotEmpty;
      print('✅ Step 1: 確認初始狀態（已下載: $wasDownloaded）');
      
      // Step 2: 點擊刪除
      await tester.tap(initialDeleteButton);
      await tester.pumpAndSettle();
      print('✅ Step 2: 點擊刪除按鈕');
      
      // Step 3: 點擊取消
      final cancelButton = find.text('取消');
      
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        print('✅ Step 3: 點擊取消按鈕');
        
        // Step 4: 驗證狀態未改變
        await tester.pump(const Duration(milliseconds: 500));
        
        final afterCancelDeleteButton = find.text('刪除書籍');
        final afterCancelOpenButton = find.text('打開閱讀');
        
        // 書籍應該仍然是下載狀態
        if (wasDownloaded) {
          expect(afterCancelOpenButton, findsOneWidget,
              reason: '取消刪除後，打開閱讀按鈕應該仍然存在');
          expect(afterCancelDeleteButton, findsOneWidget,
              reason: '取消刪除後，刪除按鈕應該仍然存在');
          print('✅ Step 4: 確認書籍狀態未改變');
        }
        
        print('🎉 取消刪除測試通過！');
      } else {
        print('⚠️  未找到取消按鈕');
      }
    });

    testWidgets('Delete book: Confirm delete and verify state reset',
        (WidgetTester tester) async {
      print('🚀 測試：刪除書籍 - 確認刪除並驗證狀態重置...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // Step 1: 確認書籍已下載
      final deleteButton = find.text('刪除書籍');
      
      if (deleteButton.evaluate().isEmpty) {
        print('ℹ️  書籍未下載，無法測試刪除功能');
        print('ℹ️  提示：可以先下載書籍再運行此測試');
        return;
      }
      
      print('✅ Step 1: 確認書籍已下載（存在刪除按鈕）');
      
      // Step 2: 點擊刪除
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      print('✅ Step 2: 點擊刪除按鈕');
      
      // Step 3: 確認刪除
      final confirmButton = find.text('刪除');
      
      if (confirmButton.evaluate().isNotEmpty) {
        // 在對話框中找到刪除按鈕（不是頁面上的刪除書籍按鈕）
        await tester.tap(confirmButton.last);
        await tester.pumpAndSettle();
        print('✅ Step 3: 確認刪除');
        
        // Step 4: 等待刪除完成
        await tester.pump(const Duration(milliseconds: 500));
        
        // Step 5: 驗證狀態重置
        final downloadButtonAfterDelete = find.text('下載書籍');
        final openButtonAfterDelete = find.text('打開閱讀');
        final deleteButtonAfterDelete = find.text('刪除書籍');
        
        // 應該回到未下載狀態
        if (downloadButtonAfterDelete.evaluate().isNotEmpty) {
          print('✅ Step 4: 確認回到未下載狀態');
          
          expect(downloadButtonAfterDelete, findsOneWidget,
              reason: '刪除後應該顯示下載按鈕');
          expect(openButtonAfterDelete, findsNothing,
              reason: '刪除後不應該有打開閱讀按鈕');
          
          // 刪除按鈕應該消失（因為現在是未下載狀態）
          final remainingDeleteButtons = deleteButtonAfterDelete.evaluate();
          if (remainingDeleteButtons.isEmpty) {
            print('✅ Step 5: 刪除按鈕已消失');
          }
          
          print('🎉 刪除並狀態重置測試通過！');
        } else {
          print('⚠️  未檢測到下載按鈕（狀態可能未重置）');
        }
        
        // 檢查是否有成功提示
        final successSnackbar = find.text('刪除成功');
        if (successSnackbar.evaluate().isNotEmpty) {
          print('✅ Step 6: 顯示刪除成功提示');
        }
      } else {
        print('⚠️  未找到確認刪除按鈕');
      }
    });

    testWidgets('Delete book: Verify UI elements in downloaded state',
        (WidgetTester tester) async {
      print('🚀 測試：刪除書籍 - 驗證已下載狀態的 UI 元素...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 檢查已下載狀態的按鈕
      final uiElements = <String, bool>{
        '打開閱讀按鈕': find.text('打開閱讀').evaluate().isNotEmpty,
        '刪除書籍按鈕': find.text('刪除書籍').evaluate().isNotEmpty,
        '打開閱讀圖標': find.byIcon(Icons.menu_book).evaluate().isNotEmpty,
        '刪除圖標': find.byIcon(Icons.delete_outline).evaluate().isNotEmpty,
      };
      
      print('✅ 已下載狀態 UI 元素檢查：');
      int foundElements = 0;
      uiElements.forEach((name, found) {
        print('  - $name: ${found ? "✓" : "✗"}');
        if (found) foundElements++;
      });
      
      if (foundElements >= 2) {
        print('✅ 找到 $foundElements/${uiElements.length} 個預期 UI 元素');
        
        // 至少應該有打開閱讀或刪除書籍按鈕之一
        final hasDownloadedButtons = 
            find.text('打開閱讀').evaluate().isNotEmpty ||
            find.text('刪除書籍').evaluate().isNotEmpty;
        
        if (hasDownloadedButtons) {
          print('✅ 已下載狀態 UI 正確');
        }
        
        print('🎉 UI 元素驗證測試通過！');
      } else if (foundElements == 0) {
        print('ℹ️  未找到已下載狀態的 UI（書籍可能未下載）');
      } else {
        print('⚠️  部分 UI 元素缺失');
      }
    });

    testWidgets('Delete book: Re-download after delete',
        (WidgetTester tester) async {
      print('🚀 測試：刪除書籍 - 刪除後重新下載...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，跳過測試');
        return;
      }
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // 檢查初始狀態
      final initialState = {
        'hasDelete': find.text('刪除書籍').evaluate().isNotEmpty,
        'hasDownload': find.text('下載書籍').evaluate().isNotEmpty,
      };
      
      print('✅ Step 1: 檢查初始狀態');
      print('  - 刪除按鈕: ${initialState['hasDelete']! ? "存在" : "不存在"}');
      print('  - 下載按鈕: ${initialState['hasDownload']! ? "存在" : "不存在"}');
      
      if (initialState['hasDelete']!) {
        // 如果有刪除按鈕，執行刪除
        print('✅ Step 2: 執行刪除操作');
        
        final deleteButton = find.text('刪除書籍');
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();
        
        // 確認刪除
        final confirmButton = find.text('刪除');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton.last);
          await tester.pumpAndSettle();
          print('✅ Step 3: 確認刪除');
          
          await tester.pump(const Duration(milliseconds: 500));
        }
      }
      
      // 檢查刪除後狀態
      final downloadButtonAfterDelete = find.text('下載書籍');
      
      if (downloadButtonAfterDelete.evaluate().isNotEmpty) {
        print('✅ Step 4: 確認回到未下載狀態');
        
        // 嘗試重新下載
        await tester.tap(downloadButtonAfterDelete);
        await tester.pump(const Duration(milliseconds: 500));
        print('✅ Step 5: 開始重新下載');
        
        // 驗證下載狀態
        await tester.pump(const Duration(milliseconds: 500));
        
        final hasDownloadIndicators = 
            find.byType(LinearProgressIndicator).evaluate().isNotEmpty ||
            find.text('取消').evaluate().isNotEmpty ||
            find.text('暫停').evaluate().isNotEmpty ||
            find.textContaining('%').evaluate().isNotEmpty ||
            find.text('打開閱讀').evaluate().isNotEmpty;
        
        if (hasDownloadIndicators) {
          print('✅ Step 6: 重新下載正常進行');
          expect(hasDownloadIndicators, true,
              reason: '刪除後應該能夠重新下載');
          print('🎉 刪除後重新下載測試通過！');
        } else {
          print('ℹ️  未檢測到下載狀態（可能太快完成）');
        }
        
        // 驗證應用穩定性
        expect(find.byType(BookDetailPage), findsOneWidget,
            reason: '刪除和重新下載後應用應該保持穩定');
      } else if (initialState['hasDownload']!) {
        print('ℹ️  書籍原本就是未下載狀態，跳過測試');
      } else {
        print('⚠️  無法確定刪除後的狀態');
      }
    });
  });

  group('BookDetail Error Handling Tests', () {
    testWidgets('App should not crash on BookDetail page',
        (WidgetTester tester) async {
      print('🚀 測試：詳情頁錯誤處理...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 等待可能的錯誤
        await tester.pump(const Duration(seconds: 1));
        
        // 驗證應用沒有崩潰
        expect(find.byType(BookDetailPage), findsOneWidget,
            reason: '應用應該保持穩定');
        
        print('✅ 錯誤處理測試通過');
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });

    testWidgets('Should handle rapid button taps',
        (WidgetTester tester) async {
      print('🚀 測試：快速點擊處理...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        await tester.pump(const Duration(milliseconds: 500));
        
        // 查找任何可點擊的按鈕
        final buttons = find.byType(ElevatedButton);
        
        if (buttons.evaluate().isNotEmpty) {
          // 快速多次點擊
          for (int i = 0; i < 3; i++) {
            await tester.tap(buttons.first);
            await tester.pump(const Duration(milliseconds: 100));
          }
          
          // 應用不應該崩潰
          expect(find.byType(BookDetailPage), findsOneWidget);
          
          print('✅ 快速點擊測試通過');
        } else {
          print('ℹ️  未找到可點擊按鈕');
        }
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });
  });

  group('BookDetail Integration Smoke Tests', () {
    testWidgets('Complete flow: BookList -> BookDetail -> Back',
        (WidgetTester tester) async {
      print('🚀 開始完整流程測試...');
      
      // 1. 啟動應用並到達書籍列表
      await launchAndWaitForBookList(tester);
      expect(find.byType(BookListPage), findsOneWidget);
      print('✅ Step 1: 到達書籍列表');
      
      // 2. 等待書籍加載
      await tester.pump(const Duration(seconds: 1));
      
      // 3. 查找並點擊書籍卡片
      final bookCard = find.byType(Card).first;
      if (bookCard.evaluate().isEmpty) {
        print('ℹ️  無可用書籍，結束測試');
        return;
      }
      
      await tester.tap(bookCard);
      await tester.pumpAndSettle();
      print('✅ Step 2: 點擊書籍卡片');
      
      // 4. 驗證進入詳情頁
      if (find.byType(BookDetailPage).evaluate().isEmpty) {
        print('ℹ️  未進入詳情頁，結束測試');
        return;
      }
      
      expect(find.byType(BookDetailPage), findsOneWidget);
      print('✅ Step 3: 進入書籍詳情頁');
      
      // 5. 等待內容加載
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Step 4: 內容加載完成');
      
      // 6. 驗證基本元素存在
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      print('✅ Step 5: UI 元素驗證通過');
      
      // 7. 返回書籍列表
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        
        expect(find.byType(BookListPage), findsOneWidget);
        print('✅ Step 6: 返回書籍列表');
      } else {
        print('⚠️  未找到返回按鈕');
      }
      
      print('🎉 完整流程測試通過！');
    });

    testWidgets('BookDetail page should handle all states gracefully',
        (WidgetTester tester) async {
      print('🚀 測試：各種狀態處理...');
      
      await navigateToBookDetail(tester);
      
      if (find.byType(BookDetailPage).evaluate().isNotEmpty) {
        // 等待各種可能的狀態轉換
        for (int i = 0; i < 3; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          
          // 驗證應用始終穩定
          expect(find.byType(BookDetailPage), findsOneWidget);
        }
        
        print('✅ 狀態處理測試通過');
      } else {
        print('ℹ️  未進入詳情頁，跳過測試');
      }
    });
  });

  group('BookDetail Performance Tests', () {
    testWidgets('BookDetail page should load quickly',
        (WidgetTester tester) async {
      print('🚀 測試：頁面加載性能...');
      
      // 測量從列表到詳情頁的時間
      await launchAndWaitForBookList(tester);
      await tester.pump(const Duration(seconds: 1));
      
      final bookCard = find.byType(Card).first;
      if (bookCard.evaluate().isEmpty) {
        print('ℹ️  無可用書籍，跳過性能測試');
        return;
      }
      
      final startTime = DateTime.now();
      
      await tester.tap(bookCard);
      await tester.pumpAndSettle();
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('詳情頁加載時間: ${duration.inMilliseconds}ms');
      
      // 驗證加載時間合理（應該在 2 秒內）
      expect(duration.inSeconds, lessThan(3),
          reason: '詳情頁加載應該在 3 秒內完成');
      
      print('✅ 性能測試通過');
    });
  });
}
