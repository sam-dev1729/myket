import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/constants/app_constants.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/core/network/api_client.dart';
import 'package:myket/core/storage/token_storage.dart';
import 'package:mocktail/mocktail.dart';

/// Mock of [TokenStorage] so the interceptor can be exercised without
/// hitting `flutter_secure_storage`.
class MockTokenStorage extends Mock implements TokenStorage {}

/// A fake [HttpClientAdapter] that lets tests intercept requests.
class MockHttpAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) handler;
  RequestOptions? lastRequest;

  MockHttpAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    lastRequest = options;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockTokenStorage mockTokenStorage;

  setUp(() {
    mockTokenStorage = MockTokenStorage();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(overrides: [tokenStorageProvider.overrideWithValue(mockTokenStorage)]);
  }

  ResponseBody jsonSuccess() {
    return ResponseBody.fromString(
      '{"success": true, "body": {}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  group('ApiClient - Token Attachment', () {
    test('should attach Bearer token to protected endpoints', () async {
      when(() => mockTokenStorage.getAccessToken()).thenAnswer((_) async => 'test-token-123');

      final container = createContainer();
      final client = container.read(apiClientProvider);

      final adapter = MockHttpAdapter((_) async => jsonSuccess());
      client.dio.httpClientAdapter = adapter;

      await client.dio.get(AppConstants.profileEndpoint);

      expect(
        adapter.lastRequest?.headers[AppConstants.headerAuthorization],
        'Bearer test-token-123',
      );
      container.dispose();
    });

    test('should NOT attach token to /user/send-otp', () async {
      final container = createContainer();
      final client = container.read(apiClientProvider);

      final adapter = MockHttpAdapter((_) async => jsonSuccess());
      client.dio.httpClientAdapter = adapter;

      await client.dio.post(AppConstants.sendOtpEndpoint, data: {});

      expect(adapter.lastRequest?.headers[AppConstants.headerAuthorization], isNull);
      verifyNever(() => mockTokenStorage.getAccessToken());
      container.dispose();
    });

    test('should NOT attach token to /user/validate-otp', () async {
      final container = createContainer();
      final client = container.read(apiClientProvider);

      final adapter = MockHttpAdapter((_) async => jsonSuccess());
      client.dio.httpClientAdapter = adapter;

      await client.dio.post(AppConstants.validateOtpEndpoint, data: {});

      expect(adapter.lastRequest?.headers[AppConstants.headerAuthorization], isNull);
      container.dispose();
    });

    test('should NOT attach token when no token exists', () async {
      when(() => mockTokenStorage.getAccessToken()).thenAnswer((_) async => null);

      final container = createContainer();
      final client = container.read(apiClientProvider);

      final adapter = MockHttpAdapter((_) async => jsonSuccess());
      client.dio.httpClientAdapter = adapter;

      await client.dio.get(AppConstants.profileEndpoint);

      expect(adapter.lastRequest?.headers[AppConstants.headerAuthorization], isNull);
      container.dispose();
    });
  });

  group('ApiClient - Error Mapping', () {
    test('should convert error response to ApiException', () async {
      when(() => mockTokenStorage.getAccessToken()).thenAnswer((_) async => 'token');

      final container = createContainer();
      final client = container.read(apiClientProvider);

      final adapter = MockHttpAdapter((_) async {
        return ResponseBody.fromString(
          '{"success": false, "body": {"statusCode": 400, "code": "OTP_INVALID", "message": "Invalid OTP"}}',
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      client.dio.httpClientAdapter = adapter;

      try {
        await client.dio.post(AppConstants.validateOtpEndpoint);
        fail('Expected DioException');
      } on DioException catch (e) {
        expect(e.error, isA<ApiException>());
        final error = e.error as ApiException;
        expect(error.code, AppConstants.errorCodeOtpInvalid);
        expect(error.statusCode, 400);
      }
      container.dispose();
    });

    test('should preserve connection timeout type', () async {
      when(() => mockTokenStorage.getAccessToken()).thenAnswer((_) async => 'token');

      final container = createContainer();
      final client = container.read(apiClientProvider);

      final adapter = MockHttpAdapter((_) async {
        throw DioException(
          requestOptions: RequestOptions(path: AppConstants.profileEndpoint),
          type: DioExceptionType.connectionTimeout,
        );
      });
      client.dio.httpClientAdapter = adapter;

      try {
        await client.dio.get(AppConstants.profileEndpoint);
        fail('Expected DioException');
      } on DioException catch (e) {
        expect(e.type, DioExceptionType.connectionTimeout);
      }
      container.dispose();
    });
  });
}
