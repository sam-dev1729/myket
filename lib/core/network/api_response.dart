import 'api_exception.dart';

/// A generic wrapper for all API responses to handle the backend's envelope format.
class ApiResponse<T> {
  final bool success;
  final T? body;
  final ApiException? error;

  ApiResponse({required this.success, this.body, this.error});

  /// Parses the JSON envelope into a typed response or an [ApiException].
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    if (json['success'] == true) {
      return ApiResponse(
        success: true,
        body: json['body'] != null ? fromJsonT(json['body']) : null,
      );
    } else {
      // Safely parse the error body. If it's not a Map (e.g., HTML from a gateway), handle it gracefully.
      final errorBody = json['body'];
      if (errorBody is Map<String, dynamic>) {
        return ApiResponse(success: false, error: ApiException.fromJson(errorBody));
      } else {
        return ApiResponse(
          success: false,
          error: ApiException(message: errorBody?.toString(), type: ApiErrorType.unknown),
        );
      }
    }
  }
}
