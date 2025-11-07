import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../models/book_model.dart';

/// Remote data source for fetching books from GitHub repository
///
/// This class handles all network requests related to books,
/// fetching data from the GitHub raw content URL.
class BookRemoteDataSource {
  /// Base URL for the GitHub repository raw content
  static const String baseUrl =
      'https://raw.githubusercontent.com/kkwenFreemind/ShuyuanReader/main';

  /// Endpoint for books catalog
  static const String booksEndpoint = '/catalog/books.json';

  /// Default connect timeout duration
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Default receive timeout duration
  static const Duration receiveTimeout = Duration(seconds: 15);

  final Dio _dio;

  /// Creates a [BookRemoteDataSource] with the provided [Dio] instance
  ///
  /// The Dio instance will be configured if not already configured.
  BookRemoteDataSource(this._dio) {
    _configureDio();
  }

  /// Configures the Dio instance with base URL, timeout settings, and logging
  void _configureDio() {
    // Only configure if not already configured
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options.baseUrl = baseUrl;
    }
    
    if (_dio.options.connectTimeout == null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    
    if (_dio.options.receiveTimeout == null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }

    // Add logging interceptor in debug mode if not already added
    if (kDebugMode && _dio.interceptors.isEmpty) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[Dio] $obj'),
        ),
      );
    }
  }

  /// Fetches the list of books from the remote repository
  ///
  /// Returns a [Future] that completes with a [List<BookModel>].
  ///
  /// Throws:
  /// - [NetworkException] if there's a network connectivity issue
  /// - [ServerException] if the server returns an error status code
  /// - [ParseException] if the response data cannot be parsed
  Future<List<BookModel>> fetchBooks() async {
    try {
      debugPrint('[BookRemoteDataSource] Fetching books from: $baseUrl$booksEndpoint');

      final response = await _dio.get(booksEndpoint);

      debugPrint('[BookRemoteDataSource] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parseResponse(response.data);
      } else {
        throw ServerException(
          'Server returned status code: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[BookRemoteDataSource] Unexpected error: $e');
      throw ParseException('Unexpected error while fetching books: $e');
    }
  }

  /// Parses the response data into a list of [BookModel]
  ///
  /// The response is expected to have this structure:
  /// ```json
  /// {
  ///   "metadata": { ... },
  ///   "books": [ ... ]
  /// }
  /// ```
  List<BookModel> _parseResponse(dynamic data) {
    try {
      if (data is! Map<String, dynamic>) {
        throw ParseException('Expected a Map but got ${data.runtimeType}');
      }

      final booksJson = data['books'];

      if (booksJson is! List) {
        throw ParseException(
          'Expected books to be a List but got ${booksJson.runtimeType}',
        );
      }

      debugPrint('[BookRemoteDataSource] Parsing ${booksJson.length} books');

      final books = booksJson.map((json) {
        if (json is! Map<String, dynamic>) {
          throw ParseException('Expected a Map for book but got ${json.runtimeType}');
        }
        return BookModel.fromJson(json);
      }).toList();

      debugPrint('[BookRemoteDataSource] Successfully parsed ${books.length} books');

      return books;
    } catch (e) {
      debugPrint('[BookRemoteDataSource] Parse error: $e');
      if (e is ParseException) {
        rethrow;
      }
      throw ParseException('Failed to parse books data: $e');
    }
  }

  /// Handles [DioException] and converts it to appropriate custom exceptions
  Exception _handleDioError(DioException error) {
    debugPrint('[BookRemoteDataSource] DioException type: ${error.type}');
    debugPrint('[BookRemoteDataSource] DioException message: ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout: ${error.message}',
          'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final statusMessage = error.response?.statusMessage;

        if (statusCode == 404) {
          return ServerException(
            'Books catalog not found (404)',
            statusCode,
            'NOT_FOUND',
          );
        }

        return ServerException(
          'Server error: $statusMessage',
          statusCode,
          'BAD_RESPONSE',
        );

      case DioExceptionType.cancel:
        return NetworkException(
          'Request was cancelled',
          'CANCELLED',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network settings.',
          'NO_CONNECTION',
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL certificate validation failed',
          'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        if (error.error != null) {
          return NetworkException(
            'Network error: ${error.error}',
            'UNKNOWN',
          );
        }
        return NetworkException(
          'Unknown network error occurred',
          'UNKNOWN',
        );
    }
  }
}
