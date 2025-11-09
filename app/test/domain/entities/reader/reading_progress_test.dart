import 'package:flutter_test/flutter_test.dart';
import 'package:shuyuan_reader/domain/entities/reader/reading_progress.dart';

void main() {
  group('ReadingProgress Entity', () {
    late DateTime testTime;

    setUp(() {
      testTime = DateTime(2024, 1, 1, 12, 0, 0);
    });

    group('Initialization', () {
      test('should create with required fields', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          lastReadTime: testTime,
        );

        expect(progress.bookId, 'book1');
        expect(progress.currentPage, 1);
        expect(progress.bookmarkedPages, isEmpty);
        expect(progress.lastReadTime, testTime);
        expect(progress.epubCfi, isNull);
        expect(progress.totalPages, isNull);
      });

      test('should create with all fields', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 50,
          bookmarkedPages: const [10, 20, 30],
          lastReadTime: testTime,
          epubCfi: 'epubcfi(/6/4[chap01ref]!/4/2/1:3)',
          totalPages: 100,
        );

        expect(progress.bookId, 'book1');
        expect(progress.currentPage, 50);
        expect(progress.bookmarkedPages, [10, 20, 30]);
        expect(progress.lastReadTime, testTime);
        expect(progress.epubCfi, 'epubcfi(/6/4[chap01ref]!/4/2/1:3)');
        expect(progress.totalPages, 100);
      });
    });

    group('Bookmark Management - isBookmarked', () {
      test('should return true when page is bookmarked', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 10, 15],
          lastReadTime: testTime,
        );

        expect(progress.isBookmarked(10), isTrue);
      });

      test('should return false when page is not bookmarked', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 10, 15],
          lastReadTime: testTime,
        );

        expect(progress.isBookmarked(7), isFalse);
      });

      test('should return false for empty bookmarks list', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          lastReadTime: testTime,
        );

        expect(progress.isBookmarked(5), isFalse);
      });
    });

    group('Bookmark Management - toggleBookmark', () {
      test('should add bookmark when page is not bookmarked', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 15],
          lastReadTime: testTime,
        );

        final newProgress = progress.toggleBookmark(10);

        expect(newProgress.bookmarkedPages, [5, 10, 15]);
        expect(newProgress.isBookmarked(10), isTrue);
        expect(newProgress.lastReadTime.isAfter(testTime), isTrue);
      });

      test('should remove bookmark when page is already bookmarked', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 10, 15],
          lastReadTime: testTime,
        );

        final newProgress = progress.toggleBookmark(10);

        expect(newProgress.bookmarkedPages, [5, 15]);
        expect(newProgress.isBookmarked(10), isFalse);
        expect(newProgress.lastReadTime.isAfter(testTime), isTrue);
      });

      test('should keep bookmarks sorted when adding', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 15],
          lastReadTime: testTime,
        );

        final newProgress = progress.toggleBookmark(10);

        expect(newProgress.bookmarkedPages, [5, 10, 15]);
      });

      test('should not modify original progress object', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 10],
          lastReadTime: testTime,
        );

        progress.toggleBookmark(15);

        expect(progress.bookmarkedPages, [5, 10]);
      });
    });

    group('Bookmark Management - addBookmark', () {
      test('should add bookmark to page', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5],
          lastReadTime: testTime,
        );

        final newProgress = progress.addBookmark(10);

        expect(newProgress.bookmarkedPages, [5, 10]);
        expect(newProgress.lastReadTime.isAfter(testTime), isTrue);
      });

      test('should return same instance if bookmark already exists', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 10],
          lastReadTime: testTime,
        );

        final newProgress = progress.addBookmark(10);

        expect(newProgress, progress);
      });

      test('should keep bookmarks sorted', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 15],
          lastReadTime: testTime,
        );

        final newProgress = progress.addBookmark(10);

        expect(newProgress.bookmarkedPages, [5, 10, 15]);
      });
    });

    group('Bookmark Management - removeBookmark', () {
      test('should remove bookmark from page', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 10, 15],
          lastReadTime: testTime,
        );

        final newProgress = progress.removeBookmark(10);

        expect(newProgress.bookmarkedPages, [5, 15]);
        expect(newProgress.lastReadTime.isAfter(testTime), isTrue);
      });

      test('should return same instance if bookmark does not exist', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 15],
          lastReadTime: testTime,
        );

        final newProgress = progress.removeBookmark(10);

        expect(newProgress, progress);
      });
    });

    group('Position Update', () {
      test('should update current page', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 10,
          lastReadTime: testTime,
        );

        final newProgress = progress.updatePosition(page: 25);

        expect(newProgress.currentPage, 25);
        expect(newProgress.lastReadTime.isAfter(testTime), isTrue);
      });

      test('should update current page and EPUB CFI', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 10,
          lastReadTime: testTime,
        );

        final newProgress = progress.updatePosition(
          page: 25,
          cfi: 'epubcfi(/6/4[chap02ref]!/4/2/1:5)',
        );

        expect(newProgress.currentPage, 25);
        expect(newProgress.epubCfi, 'epubcfi(/6/4[chap02ref]!/4/2/1:5)');
        expect(newProgress.lastReadTime.isAfter(testTime), isTrue);
      });
    });

    group('Progress Calculation', () {
      test('should calculate progress percentage correctly', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 50,
          totalPages: 100,
          lastReadTime: testTime,
        );

        expect(progress.progressPercentage, 0.5);
        expect(progress.progressPercent, 50.0);
      });

      test('should return 0.0 when total pages is null', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 50,
          lastReadTime: testTime,
        );

        expect(progress.progressPercentage, 0.0);
        expect(progress.progressPercent, 0.0);
      });

      test('should return 0.0 when total pages is 0', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 50,
          totalPages: 0,
          lastReadTime: testTime,
        );

        expect(progress.progressPercentage, 0.0);
      });

      test('should clamp progress to 1.0 when current page exceeds total', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 150,
          totalPages: 100,
          lastReadTime: testTime,
        );

        expect(progress.progressPercentage, 1.0);
        expect(progress.progressPercent, 100.0);
      });

      test('should calculate 0% at start', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 1,
          totalPages: 100,
          lastReadTime: testTime,
        );

        expect(progress.progressPercentage, 0.01);
        expect(progress.progressPercent, 1.0);
      });

      test('should calculate 100% at end', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 100,
          totalPages: 100,
          lastReadTime: testTime,
        );

        expect(progress.progressPercentage, 1.0);
        expect(progress.progressPercent, 100.0);
      });
    });

    group('Status Checks', () {
      test('isCompleted should return true when at last page', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 100,
          totalPages: 100,
          lastReadTime: testTime,
        );

        expect(progress.isCompleted, isTrue);
      });

      test('isCompleted should return true when current page exceeds total', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 101,
          totalPages: 100,
          lastReadTime: testTime,
        );

        expect(progress.isCompleted, isTrue);
      });

      test('isCompleted should return false when not at last page', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 50,
          totalPages: 100,
          lastReadTime: testTime,
        );

        expect(progress.isCompleted, isFalse);
      });

      test('isCompleted should return false when total pages is null', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 100,
          lastReadTime: testTime,
        );

        expect(progress.isCompleted, isFalse);
      });

      test('isJustStarted should return true when on first page', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 1,
          lastReadTime: testTime,
        );

        expect(progress.isJustStarted, isTrue);
      });

      test('isJustStarted should return false when beyond first page', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 2,
          lastReadTime: testTime,
        );

        expect(progress.isJustStarted, isFalse);
      });

      test('bookmarkCount should return correct count', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          bookmarkedPages: const [5, 10, 15, 20],
          lastReadTime: testTime,
        );

        expect(progress.bookmarkCount, 4);
      });

      test('bookmarkCount should return 0 for empty list', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          lastReadTime: testTime,
        );

        expect(progress.bookmarkCount, 0);
      });
    });

    group('copyWith', () {
      test('should copy with updated fields', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 10,
          bookmarkedPages: const [5],
          lastReadTime: testTime,
          epubCfi: 'old_cfi',
          totalPages: 100,
        );

        final newTime = DateTime(2024, 1, 2, 12, 0, 0);
        final newProgress = progress.copyWith(
          currentPage: 20,
          bookmarkedPages: const [5, 10],
          lastReadTime: newTime,
          epubCfi: 'new_cfi',
        );

        expect(newProgress.bookId, 'book1');
        expect(newProgress.currentPage, 20);
        expect(newProgress.bookmarkedPages, [5, 10]);
        expect(newProgress.lastReadTime, newTime);
        expect(newProgress.epubCfi, 'new_cfi');
        expect(newProgress.totalPages, 100);
      });

      test('should keep original values when not specified', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 10,
          bookmarkedPages: const [5],
          lastReadTime: testTime,
          epubCfi: 'cfi',
          totalPages: 100,
        );

        final newProgress = progress.copyWith(currentPage: 20);

        expect(newProgress.bookId, 'book1');
        expect(newProgress.currentPage, 20);
        expect(newProgress.bookmarkedPages, [5]);
        expect(newProgress.lastReadTime, testTime);
        expect(newProgress.epubCfi, 'cfi');
        expect(newProgress.totalPages, 100);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        final progress1 = ReadingProgress(
          bookId: 'book1',
          currentPage: 10,
          bookmarkedPages: const [5, 10],
          lastReadTime: testTime,
          epubCfi: 'cfi',
          totalPages: 100,
        );

        final progress2 = ReadingProgress(
          bookId: 'book1',
          currentPage: 10,
          bookmarkedPages: const [5, 10],
          lastReadTime: testTime,
          epubCfi: 'cfi',
          totalPages: 100,
        );

        expect(progress1, equals(progress2));
      });

      test('should not be equal when properties differ', () {
        final progress1 = ReadingProgress(
          bookId: 'book1',
          currentPage: 10,
          lastReadTime: testTime,
        );

        final progress2 = ReadingProgress(
          bookId: 'book1',
          currentPage: 20,
          lastReadTime: testTime,
        );

        expect(progress1, isNot(equals(progress2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final progress = ReadingProgress(
          bookId: 'book1',
          currentPage: 50,
          bookmarkedPages: const [10, 20, 30],
          lastReadTime: testTime,
          totalPages: 100,
        );

        final result = progress.toString();

        expect(result, contains('book1'));
        expect(result, contains('currentPage: 50'));
        expect(result, contains('totalPages: 100'));
        expect(result, contains('bookmarks: 3'));
        expect(result, contains('progress: 50.0%'));
        expect(result, contains('lastRead: $testTime'));
      });
    });
  });
}
