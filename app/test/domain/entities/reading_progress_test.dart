/// ReadingProgress 實體單元測試
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shuyuan_reader/domain/entities/reader/reading_progress.dart';

void main() {
  group('ReadingProgress Entity Tests', () {
    late DateTime testTime;
    late ReadingProgress testProgress;

    setUp(() {
      testTime = DateTime(2025, 11, 8, 10, 30);
      testProgress = ReadingProgress(
        bookId: 'test_book_001',
        currentPage: 10,
        bookmarkedPages: const [5, 15, 25],
        lastReadTime: testTime,
        epubCfi: 'epubcfi(/6/4[chap01ref]!/4/2/1:0)',
        totalPages: 100,
      );
    });

    group('構造函數測試', () {
      test('應該創建具有所有必需字段的實例', () {
        expect(testProgress.bookId, 'test_book_001');
        expect(testProgress.currentPage, 10);
        expect(testProgress.bookmarkedPages, [5, 15, 25]);
        expect(testProgress.lastReadTime, testTime);
        expect(testProgress.epubCfi, 'epubcfi(/6/4[chap01ref]!/4/2/1:0)');
        expect(testProgress.totalPages, 100);
      });

      test('應該使用默認值創建實例', () {
        final progress = ReadingProgress(
          bookId: 'book_002',
          lastReadTime: testTime,
        );

        expect(progress.currentPage, 1);
        expect(progress.bookmarkedPages, isEmpty);
        expect(progress.epubCfi, isNull);
        expect(progress.totalPages, isNull);
      });
    });

    group('書籤功能測試', () {
      test('isBookmarked 應該正確檢查書籤是否存在', () {
        expect(testProgress.isBookmarked(5), isTrue);
        expect(testProgress.isBookmarked(15), isTrue);
        expect(testProgress.isBookmarked(25), isTrue);
        expect(testProgress.isBookmarked(10), isFalse);
        expect(testProgress.isBookmarked(100), isFalse);
      });

      test('toggleBookmark 應該添加新書籤', () {
        final updated = testProgress.toggleBookmark(30);

        expect(updated.bookmarkedPages, contains(30));
        expect(updated.bookmarkedPages.length, 4);
        expect(updated.bookmarkedPages, [5, 15, 25, 30]);
      });

      test('toggleBookmark 應該移除現有書籤', () {
        final updated = testProgress.toggleBookmark(15);

        expect(updated.bookmarkedPages, isNot(contains(15)));
        expect(updated.bookmarkedPages.length, 2);
        expect(updated.bookmarkedPages, [5, 25]);
      });

      test('toggleBookmark 應該保持書籤列表有序', () {
        final updated = testProgress.toggleBookmark(3);

        expect(updated.bookmarkedPages, [3, 5, 15, 25]);
      });

      test('addBookmark 應該添加新書籤', () {
        final updated = testProgress.addBookmark(20);

        expect(updated.bookmarkedPages, contains(20));
        expect(updated.bookmarkedPages, [5, 15, 20, 25]);
      });

      test('addBookmark 不應該重複添加已存在的書籤', () {
        final updated = testProgress.addBookmark(15);

        expect(updated.bookmarkedPages, [5, 15, 25]);
        expect(updated, testProgress); // 應該返回相同實例
      });

      test('removeBookmark 應該移除書籤', () {
        final updated = testProgress.removeBookmark(15);

        expect(updated.bookmarkedPages, isNot(contains(15)));
        expect(updated.bookmarkedPages, [5, 25]);
      });

      test('removeBookmark 不應該改變不存在的書籤', () {
        final updated = testProgress.removeBookmark(99);

        expect(updated.bookmarkedPages, [5, 15, 25]);
        expect(updated, testProgress);
      });

      test('bookmarkCount 應該返回正確的書籤數量', () {
        expect(testProgress.bookmarkCount, 3);

        final withMoreBookmarks = testProgress.addBookmark(30);
        expect(withMoreBookmarks.bookmarkCount, 4);
      });
    });

    group('進度更新測試', () {
      test('updatePosition 應該更新頁碼', () {
        final updated = testProgress.updatePosition(page: 50);

        expect(updated.currentPage, 50);
        expect(updated.bookId, testProgress.bookId);
        expect(updated.bookmarkedPages, testProgress.bookmarkedPages);
      });

      test('updatePosition 應該更新 CFI', () {
        final newCfi = 'epubcfi(/6/8[chap02ref]!/4/2/1:0)';
        final updated = testProgress.updatePosition(
          page: 20,
          cfi: newCfi,
        );

        expect(updated.currentPage, 20);
        expect(updated.epubCfi, newCfi);
      });

      test('updatePosition 應該更新最後閱讀時間', () {
        final updated = testProgress.updatePosition(page: 15);

        expect(updated.lastReadTime.isAfter(testTime), isTrue);
      });
    });

    group('進度計算測試', () {
      test('progressPercentage 應該返回正確的百分比（0.0-1.0）', () {
        expect(testProgress.progressPercentage, 0.1);

        final halfway = testProgress.updatePosition(page: 50);
        expect(halfway.progressPercentage, 0.5);

        final almostDone = testProgress.updatePosition(page: 95);
        expect(almostDone.progressPercentage, 0.95);
      });

      test('progressPercent 應該返回正確的百分數（0-100）', () {
        expect(testProgress.progressPercent, 10.0);

        final halfway = testProgress.updatePosition(page: 50);
        expect(halfway.progressPercent, 50.0);
      });

      test('progressPercentage 應該在沒有總頁數時返回 0.0', () {
        final noTotal = ReadingProgress(
          bookId: 'book_003',
          currentPage: 50,
          lastReadTime: testTime,
        );

        expect(noTotal.progressPercentage, 0.0);
      });

      test('progressPercentage 應該限制在 0.0 到 1.0 之間', () {
        final overLimit = testProgress.updatePosition(page: 150);
        expect(overLimit.progressPercentage, 1.0);

        final underLimit = testProgress.updatePosition(page: -5);
        expect(underLimit.progressPercentage, 0.0);
      });
    });

    group('狀態檢查測試', () {
      test('isCompleted 應該在完成時返回 true', () {
        final completed = testProgress.updatePosition(page: 100);
        expect(completed.isCompleted, isTrue);

        final overCompleted = testProgress.updatePosition(page: 105);
        expect(overCompleted.isCompleted, isTrue);
      });

      test('isCompleted 應該在未完成時返回 false', () {
        expect(testProgress.isCompleted, isFalse);

        final halfway = testProgress.updatePosition(page: 50);
        expect(halfway.isCompleted, isFalse);
      });

      test('isCompleted 應該在沒有總頁數時返回 false', () {
        final noTotal = ReadingProgress(
          bookId: 'book_004',
          currentPage: 100,
          lastReadTime: testTime,
        );

        expect(noTotal.isCompleted, isFalse);
      });

      test('isJustStarted 應該正確判斷', () {
        final justStarted = ReadingProgress(
          bookId: 'book_005',
          currentPage: 1,
          lastReadTime: testTime,
        );

        expect(justStarted.isJustStarted, isTrue);
        expect(testProgress.isJustStarted, isFalse);
      });
    });

    group('copyWith 測試', () {
      test('copyWith 應該創建新實例並更新指定字段', () {
        final updated = testProgress.copyWith(
          currentPage: 50,
          totalPages: 200,
        );

        expect(updated.currentPage, 50);
        expect(updated.totalPages, 200);
        expect(updated.bookId, testProgress.bookId);
        expect(updated.bookmarkedPages, testProgress.bookmarkedPages);
      });

      test('copyWith 應該在不提供參數時保持原值', () {
        final copy = testProgress.copyWith();

        expect(copy.bookId, testProgress.bookId);
        expect(copy.currentPage, testProgress.currentPage);
        expect(copy.totalPages, testProgress.totalPages);
      });
    });

    group('Equatable 測試', () {
      test('相同內容的實例應該相等', () {
        final other = ReadingProgress(
          bookId: 'test_book_001',
          currentPage: 10,
          bookmarkedPages: const [5, 15, 25],
          lastReadTime: testTime,
          epubCfi: 'epubcfi(/6/4[chap01ref]!/4/2/1:0)',
          totalPages: 100,
        );

        expect(testProgress, equals(other));
        expect(testProgress.hashCode, equals(other.hashCode));
      });

      test('不同內容的實例應該不相等', () {
        final different = testProgress.copyWith(currentPage: 20);

        expect(testProgress, isNot(equals(different)));
      });
    });

    group('toString 測試', () {
      test('toString 應該包含關鍵信息', () {
        final str = testProgress.toString();

        expect(str, contains('test_book_001'));
        expect(str, contains('currentPage: 10'));
        expect(str, contains('totalPages: 100'));
        expect(str, contains('bookmarks: 3'));
        expect(str, contains('progress: 10.0%'));
      });
    });
  });
}
