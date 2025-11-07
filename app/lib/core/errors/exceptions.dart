/// Custom exceptions for the application
///
/// This file defines all custom exceptions used throughout the app.

/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when there's a network-related error
class NetworkException extends AppException {
  const NetworkException(String message, [String? code]) : super(message, code);

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when the server returns an error
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(String message, [this.statusCode, String? code])
      : super(message, code);

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (status: $statusCode)' : ''}${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when data parsing fails
class ParseException extends AppException {
  const ParseException(String message, [String? code]) : super(message, code);

  @override
  String toString() => 'ParseException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when data is not found in cache
class CacheException extends AppException {
  const CacheException(String message, [String? code]) : super(message, code);

  @override
  String toString() => 'CacheException: $message${code != null ? ' (code: $code)' : ''}';
}
