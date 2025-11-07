import 'package:flutter_test/flutter_test.dart';
import 'package:shuyuan_reader/data/models/book_model.dart';

void main() {
  group('BookModel', () {
    late BookModel testBook;

    setUp(() {
      testBook = BookModel(
        id: 'test-book-id',
        title: '測試書籍',
        author: '測試作者',
        coverUrl: 'https://example.com/cover.png',
        epubUrl: 'https://example.com/book.epub',
        description: '這是一本測試書籍的描述',
        language: 'zh-TW',
        fileSize: 2621440, // 2.5 MB
      );
    });

    group('fromJson', () {
      test('should correctly parse complete JSON', () {
        final json = {
          'id': 'yi-meng-man-yan',
          'title': '一夢漫言',
          'author': '千華寺繼任主持 見月老人自述',
          'cover_url':
              'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/covers/一夢漫言.png',
          'epub_url':
              'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main/epub3/一夢漫言.epub',
          'description': '千華寺繼任主持見月老人的自傳，記錄了見月老人的修行歷程與佛法心得。',
          'language': 'zh-TW',
          'file_size': 2621440,
        };

        final book = BookModel.fromJson(json);

        expect(book.id, 'yi-meng-man-yan');
        expect(book.title, '一夢漫言');
        expect(book.author, '千華寺繼任主持 見月老人自述');
        expect(book.coverUrl, contains('一夢漫言.png'));
        expect(book.epubUrl, contains('一夢漫言.epub'));
        expect(book.description, contains('見月老人的自傳'));
        expect(book.language, 'zh-TW');
        expect(book.fileSize, 2621440);
        expect(book.downloadedAt, isNull);
        expect(book.localPath, isNull);
      });

      test('should parse JSON with optional fields', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Book',
          'author': 'Test Author',
          'cover_url': 'https://example.com/cover.png',
          'epub_url': 'https://example.com/book.epub',
          'description': 'Test description',
          'language': 'en-US',
          'file_size': 1024000,
          'downloaded_at': '2025-11-07T10:00:00.000Z',
          'local_path': '/storage/books/test.epub',
        };

        final book = BookModel.fromJson(json);

        expect(book.id, 'test-id');
        expect(book.downloadedAt, isNotNull);
        expect(book.downloadedAt!.year, 2025);
        expect(book.downloadedAt!.month, 11);
        expect(book.downloadedAt!.day, 7);
        expect(book.localPath, '/storage/books/test.epub');
      });

      test('should handle missing description gracefully', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Book',
          'author': 'Test Author',
          'cover_url': 'https://example.com/cover.png',
          'epub_url': 'https://example.com/book.epub',
          'language': 'en-US',
          'file_size': 1024000,
        };

        final book = BookModel.fromJson(json);

        expect(book.description, '');
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON', () {
        final json = testBook.toJson();

        expect(json['id'], 'test-book-id');
        expect(json['title'], '測試書籍');
        expect(json['author'], '測試作者');
        expect(json['cover_url'], 'https://example.com/cover.png');
        expect(json['epub_url'], 'https://example.com/book.epub');
        expect(json['description'], '這是一本測試書籍的描述');
        expect(json['language'], 'zh-TW');
        expect(json['file_size'], 2621440);
        expect(json['downloaded_at'], isNull);
        expect(json['local_path'], isNull);
      });

      test('should serialize optional fields when present', () {
        final downloadedBook = testBook.copyWith(
          downloadedAt: DateTime(2025, 11, 7, 10, 0, 0),
          localPath: '/storage/books/test.epub',
        );

        final json = downloadedBook.toJson();

        expect(json['downloaded_at'], isNotNull);
        expect(json['downloaded_at'], contains('2025-11-07'));
        expect(json['local_path'], '/storage/books/test.epub');
      });
    });

    group('isDownloaded getter', () {
      test('should return false when localPath is null', () {
        expect(testBook.isDownloaded, false);
      });

      test('should return false when localPath is empty', () {
        final bookWithEmptyPath = testBook.copyWith(localPath: '');
        expect(bookWithEmptyPath.isDownloaded, false);
      });

      test('should return true when localPath has value', () {
        final downloadedBook =
            testBook.copyWith(localPath: '/storage/books/test.epub');
        expect(downloadedBook.isDownloaded, true);
      });
    });

    group('fileSizeFormatted getter', () {
      test('should format size in KB when less than 1MB', () {
        final smallBook = testBook.copyWith(fileSize: 512000); // 500 KB
        expect(smallBook.fileSizeFormatted, '500.0 KB');
      });

      test('should format size in MB when greater than or equal to 1MB', () {
        final largeBook = testBook.copyWith(fileSize: 2621440); // 2.5 MB
        expect(largeBook.fileSizeFormatted, '2.5 MB');
      });

      test('should format very large files correctly', () {
        final hugeBook = testBook.copyWith(fileSize: 10485760); // 10 MB
        expect(hugeBook.fileSizeFormatted, '10.0 MB');
      });

      test('should format small files correctly', () {
        final tinyBook = testBook.copyWith(fileSize: 10240); // 10 KB
        expect(tinyBook.fileSizeFormatted, '10.0 KB');
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final updatedBook = testBook.copyWith(
          title: '更新的標題',
          fileSize: 5242880, // 5 MB
        );

        expect(updatedBook.id, testBook.id);
        expect(updatedBook.title, '更新的標題');
        expect(updatedBook.author, testBook.author);
        expect(updatedBook.fileSize, 5242880);
      });

      test('should keep original values when not specified', () {
        final copiedBook = testBook.copyWith();

        expect(copiedBook.id, testBook.id);
        expect(copiedBook.title, testBook.title);
        expect(copiedBook.author, testBook.author);
        expect(copiedBook.fileSize, testBook.fileSize);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final book1 = BookModel(
          id: 'same-id',
          title: 'Same Title',
          author: 'Same Author',
          coverUrl: 'https://example.com/cover.png',
          epubUrl: 'https://example.com/book.epub',
          description: 'Same description',
          language: 'zh-TW',
          fileSize: 1024000,
        );

        final book2 = BookModel(
          id: 'same-id',
          title: 'Same Title',
          author: 'Same Author',
          coverUrl: 'https://example.com/cover.png',
          epubUrl: 'https://example.com/book.epub',
          description: 'Same description',
          language: 'zh-TW',
          fileSize: 1024000,
        );

        expect(book1, equals(book2));
        expect(book1.hashCode, equals(book2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final book1 = testBook;
        final book2 = testBook.copyWith(title: 'Different Title');

        expect(book1, isNot(equals(book2)));
        expect(book1.hashCode, isNot(equals(book2.hashCode)));
      });

      test('should be equal to itself', () {
        expect(testBook, equals(testBook));
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        final str = testBook.toString();

        expect(str, contains('BookModel'));
        expect(str, contains('test-book-id'));
        expect(str, contains('測試書籍'));
        expect(str, contains('測試作者'));
        expect(str, contains('zh-TW'));
        expect(str, contains('2.5 MB'));
        expect(str, contains('isDownloaded: false'));
      });

      test('should show downloaded status correctly', () {
        final downloadedBook =
            testBook.copyWith(localPath: '/storage/books/test.epub');
        final str = downloadedBook.toString();

        expect(str, contains('isDownloaded: true'));
      });
    });

    group('JSON roundtrip', () {
      test('should maintain data integrity through JSON conversion', () {
        final originalBook = BookModel(
          id: 'roundtrip-test',
          title: 'Round Trip Book',
          author: 'Test Author',
          coverUrl: 'https://example.com/cover.png',
          epubUrl: 'https://example.com/book.epub',
          description: 'Testing JSON roundtrip',
          language: 'zh-TW',
          fileSize: 3145728,
          downloadedAt: DateTime(2025, 11, 7, 12, 30, 0),
          localPath: '/storage/books/test.epub',
        );

        final json = originalBook.toJson();
        final reconstructedBook = BookModel.fromJson(json);

        expect(reconstructedBook.id, originalBook.id);
        expect(reconstructedBook.title, originalBook.title);
        expect(reconstructedBook.author, originalBook.author);
        expect(reconstructedBook.coverUrl, originalBook.coverUrl);
        expect(reconstructedBook.epubUrl, originalBook.epubUrl);
        expect(reconstructedBook.description, originalBook.description);
        expect(reconstructedBook.language, originalBook.language);
        expect(reconstructedBook.fileSize, originalBook.fileSize);
        expect(reconstructedBook.downloadedAt, originalBook.downloadedAt);
        expect(reconstructedBook.localPath, originalBook.localPath);
      });
    });
  });
}
