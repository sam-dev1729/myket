import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/features/financial/data/financial_api.dart';
import 'package:myket/features/financial/data/financial_repository.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  group('FinancialRepository.getWallet', () {
    test('returns wallet on success envelope', () async {
      final repo = _repoWith({
        '/wallet': (_) => _jsonResponse(200, {
          'success': true,
          'body': {'id': 'w1', 'user_id': 'u1', 'balance': 2500000},
        }),
      });

      final wallet = await repo.getWallet();
      expect(wallet.id, 'w1');
      expect(wallet.balance, 2500000);
    });

    test('throws ApiException on error envelope', () async {
      final repo = _repoWith({
        '/wallet': (_) => _jsonResponse(401, {
          'success': false,
          'body': {'statusCode': 401, 'code': 'UNAUTHORIZED', 'message': 'Unauthorized'},
        }),
      });

      await expectLater(repo.getWallet(), throwsA(isA<ApiException>()));
    });
  });

  group('FinancialRepository.getPackages', () {
    test('returns packages on success', () async {
      final repo = _repoWith({
        '/package': (_) => _jsonResponse(200, {
          'success': true,
          'body': {
            'meta': {'total': 2, 'page': 1, 'limit': 20, 'total_page': 1},
            'data': [
              {'id': 'p1', 'title': 'Basic', 'price': 500000, 'duration_days': 30, 'type': 'BLOOD'},
              {'id': 'p2', 'title': 'Pro', 'price': 1500000, 'duration_days': 90, 'type': 'BLOOD'},
            ],
          },
        }),
      });

      final result = await repo.getPackages();
      expect(result.data, hasLength(2));
      expect(result.data.first.title, 'Basic');
      expect(result.meta.total, 2);
    });

    test('returns empty list on empty data', () async {
      final repo = _repoWith({
        '/package': (_) => _jsonResponse(200, {
          'success': true,
          'body': {
            'meta': {'total': 0, 'page': 1, 'limit': 20, 'total_page': 0},
            'data': <dynamic>[],
          },
        }),
      });

      final result = await repo.getPackages();
      expect(result.data, isEmpty);
      expect(result.meta.total, 0);
    });

    test('throws ApiException on error envelope', () async {
      final repo = _repoWith({
        '/package': (_) => _jsonResponse(500, {
          'success': false,
          'body': {'statusCode': 500, 'code': 'SERVER_ERROR', 'message': 'boom'},
        }),
      });

      await expectLater(repo.getPackages(), throwsA(isA<ApiException>()));
    });
  });

  group('FinancialRepository.createOrder', () {
    test('returns response on success', () async {
      final repo = _repoWith({
        '/order/create': (_) => _jsonResponse(200, {
          'success': true,
          'body': {
            'order_id': 'o1',
            'discount_amount': 0,
            'wallet_amount': 500000,
            'gateway_amount': 0,
            'status': 'SUCCESS',
          },
        }),
      });

      final res = await repo.createOrder(packageId: 'p1', useWallet: true);
      expect(res.orderId, 'o1');
      expect(res.status, 'SUCCESS');
      expect(res.gatewayUrl, isNull);
      expect(res.walletAmount, 500000);
    });

    test('returns response with gatewayUrl on pending', () async {
      final repo = _repoWith({
        '/order/create': (_) => _jsonResponse(200, {
          'success': true,
          'body': {
            'order_id': 'o2',
            'discount_amount': 0,
            'wallet_amount': 0,
            'gateway_amount': 500000,
            'status': 'PENDING',
            'gateway_url': 'https://gateway.test/pay/o2',
          },
        }),
      });

      final res = await repo.createOrder(packageId: 'p1');
      expect(res.status, 'PENDING');
      expect(res.gatewayUrl, 'https://gateway.test/pay/o2');
    });

    test('throws ApiException on error envelope', () async {
      final repo = _repoWith({
        '/order/create': (_) => _jsonResponse(404, {
          'success': false,
          'body': {'statusCode': 404, 'code': 'PACKAGE_NOT_FOUND', 'message': 'Package not found'},
        }),
      });

      await expectLater(repo.createOrder(packageId: 'unknown'), throwsA(isA<ApiException>()));
    });
  });

  group('FinancialRepository.topup', () {
    test('returns TopupResponse on success', () async {
      final repo = _repoWith({
        '/wallet/topup': (_) => _jsonResponse(200, {
          'success': true,
          'body': {
            'transaction_id': 't1',
            'amount': 100000,
            'status': 'PENDING',
            'gateway_url': 'https://gateway.test/topup/t1',
          },
        }),
      });

      final res = await repo.topup(100000, gateway: 'ZARINPAL');
      expect(res.transactionId, 't1');
      expect(res.amount, 100000);
      expect(res.gatewayUrl, 'https://gateway.test/topup/t1');
    });

    test('throws ApiException on error envelope', () async {
      final repo = _repoWith({
        '/wallet/topup': (_) => _jsonResponse(400, {
          'success': false,
          'body': {'statusCode': 400, 'code': 'BAD_REQUEST', 'message': 'Amount required'},
        }),
      });

      await expectLater(repo.topup(0), throwsA(isA<ApiException>()));
    });
  });
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

FinancialRepository _repoWith(Map<String, ResponseBody Function(RequestOptions)> routes) {
  // `validateStatus: (_) => true` is critical here:
  // By default Dio throws DioException for any 4xx/5xx response *before*
  // Retrofit can parse the response envelope into ApiResponse. The
  // production ApiClient relies on a Dio interceptor to map such
  // DioExceptions into ApiException inside `e.error`, but the test uses
  // a raw Dio (with a canned adapter and no interceptor) — so we bypass
  // Dio's status-code guard and let `ApiResponse.fromJson` handle the
  // error envelope, matching the intended repository contract.
  final dio = Dio(BaseOptions(baseUrl: 'http://fake.invalid', validateStatus: (_) => true));
  dio.httpClientAdapter = _CannedAdapter(routes);
  return FinancialRepository(FinancialApi(dio));
}

ResponseBody _jsonResponse(int status, Map<String, dynamic> json) {
  return ResponseBody.fromString(
    jsonEncode(json),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// A minimal [HttpClientAdapter] that returns canned responses per path.
class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter(this._routes);

  final Map<String, ResponseBody Function(RequestOptions)> _routes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final handler = _routes[options.path];
    if (handler == null) {
      return ResponseBody.fromString(
        '{"success":false,"body":{"code":"NOT_MOCKED","message":"No route for ${options.path}"}}',
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
