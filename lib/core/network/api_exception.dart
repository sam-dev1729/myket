import 'package:dio/dio.dart';

/// Defines the types of errors that can occur during an API request.
enum ApiErrorType { server, timeout, noInternet, cancelled, unknown }

/// Represents a custom exception thrown by the API client.
/// It encapsulates both backend errors and network-level errors.
class ApiException implements Exception {
  /// The HTTP status code (e.g., 400, 401, 500).
  final int? statusCode;

  /// The specific error code returned by the backend (e.g., 'OTP_INVALID').
  final String? code;

  /// The error message (usually returned by the backend).
  final String? message;

  /// The API path where the error occurred.
  final String? path;

  /// The categorized type of the error.
  final ApiErrorType type;

  /// Constructs an [ApiException].
  ApiException({
    this.statusCode,
    this.code,
    this.message,
    this.path,
    this.type = ApiErrorType.server,
  });

  /// Factory constructor to create an [ApiException] from a backend JSON response.
  /// Uses safe type casting to prevent crashes if the backend returns unexpected types.
  factory ApiException.fromJson(Map<String, dynamic> json) {
    // Safely parse statusCode whether it's an int or a String.
    int? parsedStatusCode;
    final rawStatusCode = json['statusCode'];
    if (rawStatusCode is int) {
      parsedStatusCode = rawStatusCode;
    } else if (rawStatusCode is String) {
      parsedStatusCode = int.tryParse(rawStatusCode);
    }

    return ApiException(
      statusCode: parsedStatusCode,
      code: json['code']?.toString(),
      message: json['message']?.toString(),
      path: json['path']?.toString(),
      type: ApiErrorType.server,
    );
  }

  /// Factory constructor to map a [DioException] to an [ApiException].
  factory ApiException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(type: ApiErrorType.timeout);
    } else if (e.type == DioExceptionType.connectionError) {
      return ApiException(type: ApiErrorType.noInternet);
    } else if (e.type == DioExceptionType.cancel) {
      return ApiException(type: ApiErrorType.cancelled);
    } else {
      return ApiException(type: ApiErrorType.unknown);
    }
  }

  @override
  String toString() => 'ApiException(type: $type, code: $code, message: $message)';
}
