import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:shuyuan_reader/core/errors/exceptions.dart';
import 'package:shuyuan_reader/data/datasources/book_remote_datasource.dart';
import 'package:shuyuan_reader/data/models/book_model.dart';

// Generate mock using build_runner:
// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateNiceMocks([MockSpec<Dio>()])
import 'book_remote_datasource_test.mocks.dart';

void main() {
  late BookRemoteDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = BookRemoteDataSource(mockDio);
  });

  group('BookRemoteDataSource', () {
    const testJsonResponse = {
      'metadata': {
        'title': '書苑閱讀器書目',
        'total_books': 2,
      },
      'books': [
        {
          'id': 'test_book_1',
          'title': 'Test Book 1',
          'author': 'Author 1',
          'coverUrl': 'covers/test1.png',
          'epubUrl': 'epub3/test1.epub',
          'description': 'Test description 1',
          'language': 'tw',
          'fileSize': 2621440,
        },
        {
          'id': 'test_book_2',
          'title': 'Test Book 2',
          'author': 'Author 2',
          'coverUrl': 'covers/test2.png',
          'epubUrl': 'epub3/test2.epub',
          'description': 'Test description 2',
          'language': 'en',
          'fileSize': 3145728,
        },
      ],
    };

    group('fetchBooks', () {
      test('returns list of BookModel on successful response', () async {
        // Arrange
        when(mockDio.get(any)).thenAnswer(
          (_) async => Response(
            data: testJsonResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act
        final result = await dataSource.fetchBooks();

        // Assert
        expect(result, isA<List<BookModel>>());
        expect(result.length, 2);
        expect(result[0].id, 'test_book_1');
        expect(result[0].title, 'Test Book 1');
        expect(result[0].author, 'Author 1');
        expect(result[1].id, 'test_book_2');
        expect(result[1].title, 'Test Book 2');

        verify(mockDio.get('/catalog/books.json')).called(1);
      });

      test('parses empty books list correctly', () async {
        // Arrange
        final emptyResponse = {
          'metadata': {'total_books': 0},
          'books': [],
        };

        when(mockDio.get(any)).thenAnswer(
          (_) async => Response(
            data: emptyResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act
        final result = await dataSource.fetchBooks();

        // Assert
        expect(result, isEmpty);
      });

      test('throws ServerException on non-200 status code', () async {
        // Arrange
        when(mockDio.get(any)).thenAnswer(
          (_) async => Response(
            data: {'error': 'Internal server error'},
            statusCode: 500,
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(isA<ServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          )),
        );
      });

      test('throws ServerException with 404 code when resource not found',
          () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              statusMessage: 'Not Found',
              requestOptions: RequestOptions(path: '/catalog/books.json'),
            ),
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<ServerException>()
                .having((e) => e.statusCode, 'statusCode', 404)
                .having((e) => e.code, 'code', 'NOT_FOUND'),
          ),
        );
      });

      test('throws NetworkException on connection timeout', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout',
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<NetworkException>().having((e) => e.code, 'code', 'TIMEOUT'),
          ),
        );
      });

      test('throws NetworkException on send timeout', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.sendTimeout,
            message: 'Send timeout',
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<NetworkException>().having((e) => e.code, 'code', 'TIMEOUT'),
          ),
        );
      });

      test('throws NetworkException on receive timeout', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.receiveTimeout,
            message: 'Receive timeout',
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<NetworkException>().having((e) => e.code, 'code', 'TIMEOUT'),
          ),
        );
      });

      test('throws NetworkException on connection error', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            message: 'No internet connection',
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<NetworkException>()
                .having((e) => e.code, 'code', 'NO_CONNECTION')
                .having(
                  (e) => e.message,
                  'message',
                  contains('internet connection'),
                ),
          ),
        );
      });

      test('throws NetworkException on request cancelled', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.cancel,
            message: 'Request cancelled',
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<NetworkException>().having((e) => e.code, 'code', 'CANCELLED'),
          ),
        );
      });

      test('throws NetworkException on bad certificate', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.badCertificate,
            message: 'Certificate verification failed',
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<NetworkException>()
                .having((e) => e.code, 'code', 'BAD_CERTIFICATE'),
          ),
        );
      });

      test('throws NetworkException on unknown DioException', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            type: DioExceptionType.unknown,
            message: 'Unknown error',
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(
            isA<NetworkException>().having((e) => e.code, 'code', 'UNKNOWN'),
          ),
        );
      });

      test('throws ParseException when response data is not a Map', () async {
        // Arrange
        when(mockDio.get(any)).thenAnswer(
          (_) async => Response(
            data: 'invalid json string',
            statusCode: 200,
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(isA<ParseException>().having(
            (e) => e.message,
            'message',
            contains('Expected a Map'),
          )),
        );
      });

      test('throws ParseException when books field is not a List', () async {
        // Arrange
        final invalidResponse = {
          'metadata': {},
          'books': 'not a list',
        };

        when(mockDio.get(any)).thenAnswer(
          (_) async => Response(
            data: invalidResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(isA<ParseException>().having(
            (e) => e.message,
            'message',
            contains('Expected books to be a List'),
          )),
        );
      });

      test('throws ParseException when book item is not a Map', () async {
        // Arrange
        final invalidResponse = {
          'metadata': {},
          'books': ['invalid', 'book', 'data'],
        };

        when(mockDio.get(any)).thenAnswer(
          (_) async => Response(
            data: invalidResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(isA<ParseException>().having(
            (e) => e.message,
            'message',
            contains('Expected a Map for book'),
          )),
        );
      });

      test('throws ParseException when book JSON is missing required fields',
          () async {
        // Arrange
        final invalidResponse = {
          'metadata': {},
          'books': [
            {
              'id': 'test',
              // Missing required fields like title, author, etc.
            },
          ],
        };

        when(mockDio.get(any)).thenAnswer(
          (_) async => Response(
            data: invalidResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/catalog/books.json'),
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(isA<ParseException>()),
        );
      });

      test('throws ParseException on unexpected non-Dio exception', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          Exception('Unexpected error'),
        );

        // Act & Assert
        expect(
          () => dataSource.fetchBooks(),
          throwsA(isA<ParseException>().having(
            (e) => e.message,
            'message',
            contains('Unexpected error while fetching books'),
          )),
        );
      });
    });
  });
}
