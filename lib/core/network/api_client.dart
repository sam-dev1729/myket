import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/session_expired_provider.dart';
import '../constants/app_constants.dart';
import '../mock/mock_api_adapter.dart';
import '../mock/mock_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// The main HTTP client for the application, configured with Dio.
class ApiClient {
  final Dio dio;
  final Ref ref;
  late final TokenStorage _tokenStorage;

  ApiClient({required this.ref})
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
          receiveTimeout: const Duration(seconds: AppConstants.apiTimeoutSeconds),
          headers: {
            AppConstants.headerContentType: AppConstants.contentTypeJson,
            AppConstants.headerAccept: AppConstants.contentTypeJson,
          },
        ),
      ) {
    _tokenStorage = ref.read(tokenStorageProvider);

    if (MockConfig.useMocks) {
      dio.httpClientAdapter = MockApiAdapter();
    } else {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains(AppConstants.sendOtpEndpoint) &&
              !options.path.contains(AppConstants.validateOtpEndpoint) &&
              !options.path.contains(AppConstants.registerPatientEndpoint) &&
              !options.path.contains(AppConstants.refreshTokenEndpoint)) {
            final token = await _tokenStorage.getAccessToken();
            if (token != null) {
              options.headers[AppConstants.headerAuthorization] =
                  '${AppConstants.bearerPrefix}$token';
            }
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          final statusCode = e.response?.statusCode;

          // 1. Handle 401 Unauthorized with automatic token refresh.
          if (statusCode == AppConstants.statusUnauthorized &&
              !e.requestOptions.path.contains(AppConstants.refreshTokenEndpoint)) {
            if (e.requestOptions.extra[AppConstants.extraKeyRetryAttempted] == true) {
              await _handleSessionExpiredSafely();
              return handler.reject(_mapToApiException(e));
            }

            try {
              final refreshToken = await _tokenStorage.getRefreshToken();
              if (refreshToken == null) {
                await _handleSessionExpiredSafely();
                return handler.reject(_mapToApiException(e));
              }

              final refreshResponse = await dio.post(
                AppConstants.refreshTokenEndpoint,
                options: Options(
                  headers: {
                    AppConstants.headerAuthorization: '${AppConstants.bearerPrefix}$refreshToken',
                  },
                ),
              );

              final refreshData = refreshResponse.data;
              if (refreshData is Map<String, dynamic> && refreshData['success'] == true) {
                final newAccessToken = refreshData['body']?['access_token'] as String?;

                if (newAccessToken != null) {
                  await _tokenStorage.saveTokens(newAccessToken, refreshToken);

                  final retryOptions = e.requestOptions;
                  retryOptions.extra[AppConstants.extraKeyRetryAttempted] = true;
                  retryOptions.headers[AppConstants.headerAuthorization] =
                      '${AppConstants.bearerPrefix}$newAccessToken';

                  try {
                    final retryResponse = await dio.fetch(retryOptions);
                    return handler.resolve(retryResponse);
                  } catch (retryError) {
                    return handler.next(_mapToApiException(retryError as DioException));
                  }
                }
              }
              await _handleSessionExpiredSafely();
              return handler.reject(_mapToApiException(e));
            } catch (_) {
              await _handleSessionExpiredSafely();
              return handler.reject(_mapToApiException(e));
            }
          }

          // 2. Handle Server Errors (5xx) with Auto-Retry
          if (statusCode != null && statusCode >= AppConstants.statusServerErrorMin) {
            final retryCount = e.requestOptions.extra[AppConstants.extraKeyRetryCount] as int? ?? 0;
            if (retryCount < AppConstants.maxRetryAttempts) {
              e.requestOptions.extra[AppConstants.extraKeyRetryCount] = retryCount + 1;
              await Future.delayed(
                Duration(milliseconds: AppConstants.retryDelayBaseMs * (retryCount + 1)),
              );
              try {
                final retryResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (retryError) {
                return handler.next(_mapToApiException(retryError as DioException));
              }
            }
          }

          // 3. Map any remaining errors (including parsing TypeErrors) to ApiException
          return handler.reject(_mapToApiException(e));
        },
      ),
    );
  }

  /// Maps a [DioException] to a new [DioException] containing an [ApiException].
  DioException _mapToApiException(DioException e) {
    // If it's already an ApiException, return as is.
    if (e.error is ApiException) return e;

    // Check if the backend returned a JSON error envelope.
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['success'] == false) {
      final body = data['body'];
      if (body is Map<String, dynamic>) {
        return DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          error: ApiException.fromJson(body),
          type: e.type,
        );
      }
    }

    // Otherwise, map network errors or unknown errors (like parsing errors).
    return DioException(
      requestOptions: e.requestOptions,
      response: e.response,
      error: ApiException.fromDio(e),
      type: e.type,
    );
  }

  /// Clears tokens and notifies the app that the session has expired.
  Future<void> _handleSessionExpiredSafely() async {
    try {
      await _tokenStorage.clearTokens();
    } catch (_) {
      // Ignore storage errors
    } finally {
      ref.read(sessionExpiredProvider.notifier).state = true;
    }
  }
}

/// Riverpod provider for [ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref: ref);
});
