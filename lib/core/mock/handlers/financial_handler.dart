import 'package:dio/dio.dart';

import '../../../features/financial/data/models/package_models.dart';
import '../../../features/financial/data/models/wallet_models.dart';
import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for financial endpoints (wallet, packages, orders, gateway).
///
/// IMPORTANT: Top-up and order placement **immediately succeed** in this
/// mock — the returned `gateway_url` is a placeholder, but the wallet
/// balance is already credited (topup) or the package is already activated
/// (order). This lets the user complete the flow without a real gateway.
class FinancialHandler extends MockHandler {
  @override
  bool matches(String method, String path) {
    if (method == 'GET' && path == '/wallet') return true;
    if (method == 'GET' && path == '/wallet/transactions') return true;
    if (method == 'POST' && path == '/wallet/topup') return true;
    if (method == 'GET' && path == '/wallet/bank') return true;
    if (method == 'GET' && path == '/package') return true;
    if (method == 'GET' && path == '/user-package/active') return true;
    if (method == 'GET' && path == '/user-package/history') return true;
    if (method == 'POST' && path == '/order/create') return true;
    if (method == 'POST' && path == '/order/create-multi') return true;
    if (method == 'GET' && path == '/gateway/status') return true;
    return false;
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 120));

    final storage = MockStorage.instance..ensureSeeded();
    final method = options.method;
    final path = options.path;

    if (method == 'GET' && path == '/gateway/status') {
      return mockSuccess({'AP': true, 'ZARINPAL': true});
    }

    final mobile = _currentMobile(options);
    if (mobile == null) {
      return mockError(statusCode: 401, code: 'UNAUTHORIZED', message: 'Unauthorized');
    }

    final user = storage.users[mobile];
    if (user == null) {
      return mockError(statusCode: 404, code: 'USER_NOT_FOUND', message: 'User not found');
    }

    switch (path) {
      case '/wallet':
        if (method == 'GET') return _handleWallet(storage, mobile, user.id);
        break;
      case '/wallet/transactions':
        if (method == 'GET') return _handleTransactions(storage, mobile, options);
        break;
      case '/wallet/topup':
        if (method == 'POST') return _handleTopup(storage, mobile, options);
        break;
      case '/wallet/bank':
        if (method == 'GET') return mockSuccess(const []);
        break;
      case '/package':
        if (method == 'GET') return _handlePackages(storage, options);
        break;
      case '/user-package/active':
        if (method == 'GET') return _handleActivePackages(storage, mobile);
        break;
      case '/user-package/history':
        if (method == 'GET') return _handlePackageHistory(storage, mobile, options);
        break;
      case '/order/create':
        if (method == 'POST') {
          return _handleCreateOrder(storage, mobile, user.id, options);
        }
        break;
      case '/order/create-multi':
        if (method == 'POST') {
          return _handleCreateMultiOrder(storage, mobile, user.id, options);
        }
        break;
    }

    return mockError(
      statusCode: 404,
      code: 'MOCK_NOT_FOUND',
      message: 'No mock handler for $method $path',
    );
  }

  ResponseBody _handleWallet(MockStorage storage, String mobile, String userId) {
    final balance = storage.walletBalances[mobile] ?? 0;
    return mockSuccess({
      'id': 'mock-wallet-$mobile',
      'user_id': userId,
      'balance': balance,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'created_at': '2026-01-01T00:00:00.000Z',
    });
  }

  ResponseBody _handleTransactions(MockStorage storage, String mobile, RequestOptions options) {
    final page = _asInt(options.queryParameters['page']) ?? 1;
    final limit = _asInt(options.queryParameters['limit']) ?? 20;
    final type = _qs(options, 'type');
    final reason = _qs(options, 'reason');
    final status = _qs(options, 'status');

    var list = List<WalletTransactionModel>.from(storage.transactions[mobile] ?? []);

    if (type != null) list = list.where((t) => t.type == type).toList();
    if (reason != null) list = list.where((t) => t.reason == reason).toList();
    if (status != null) list = list.where((t) => t.status == status).toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final total = list.length;
    final totalPage = total == 0 ? 0 : ((total + limit - 1) ~/ limit);
    final start = (page - 1) * limit;
    final pageData = list.skip(start).take(limit).toList();

    return mockSuccess({
      'meta': {'page': page, 'limit': limit, 'total': total, 'total_page': totalPage},
      'data': pageData.map((t) => t.toJson()).toList(),
    });
  }

  ResponseBody _handleTopup(MockStorage storage, String mobile, RequestOptions options) {
    final data = _asMap(options.data);
    final amount = _asInt(data['amount']) ?? 0;
    if (amount <= 0) {
      return mockError(statusCode: 400, code: 'BAD_REQUEST', message: 'Amount must be positive');
    }

    // Mock: credit the wallet immediately.
    storage.walletBalances[mobile] = (storage.walletBalances[mobile] ?? 0) + amount;

    final now = DateTime.now().toUtc().toIso8601String();
    final txnId = _newId('txn');
    final gateway = _asString(data['payment_gateway']) ?? 'ZARINPAL';

    final txn = WalletTransactionModel(
      id: txnId,
      type: 'DEPOSIT',
      reason: 'WALLET_TOPUP',
      amount: amount,
      paymentMethod: 'GATEWAY',
      gatewayProvider: gateway,
      status: 'SUCCESS',
      description: 'شارژ کیف پول',
      createdAt: now,
      paidAt: now,
    );
    storage.transactions[mobile]?.add(txn);

    return mockSuccess({
      'transaction_id': txnId,
      'amount': amount,
      'status': 'SUCCESS',
      'gateway_url': 'https://mock.local/success',
    });
  }

  ResponseBody _handlePackages(MockStorage storage, RequestOptions options) {
    final page = _asInt(options.queryParameters['page']) ?? 1;
    final limit = _asInt(options.queryParameters['limit']) ?? 20;
    final search = _qs(options, 'search');
    final type = _qs(options, 'type');

    var list = List<PackageModel>.from(storage.packages);
    if (type != null) list = list.where((p) => p.type == type).toList();
    if (search != null) list = list.where((p) => p.title.contains(search)).toList();

    final total = list.length;
    final totalPage = total == 0 ? 0 : ((total + limit - 1) ~/ limit);
    final start = (page - 1) * limit;
    final pageData = list.skip(start).take(limit).toList();

    return mockSuccess({
      'meta': {'page': page, 'limit': limit, 'total': total, 'total_page': totalPage},
      'data': pageData.map((p) => p.toJson()).toList(),
    });
  }

  ResponseBody _handleActivePackages(MockStorage storage, String mobile) {
    final list = (storage.userPackages[mobile] ?? []).where((p) => p.status == 'ACTIVE').toList();
    return mockSuccess(list.map((p) => p.toJson()).toList());
  }

  ResponseBody _handlePackageHistory(MockStorage storage, String mobile, RequestOptions options) {
    final page = _asInt(options.queryParameters['page']) ?? 1;
    final limit = _asInt(options.queryParameters['limit']) ?? 20;

    final list = List<UserPackageModel>.from(storage.userPackages[mobile] ?? [])
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));

    final total = list.length;
    final totalPage = total == 0 ? 0 : ((total + limit - 1) ~/ limit);
    final start = (page - 1) * limit;
    final pageData = list.skip(start).take(limit).toList();

    return mockSuccess({
      'meta': {'page': page, 'limit': limit, 'total': total, 'total_page': totalPage},
      'data': pageData.map((p) => p.toJson()).toList(),
    });
  }

  ResponseBody _handleCreateOrder(
    MockStorage storage,
    String mobile,
    String userId,
    RequestOptions options,
  ) {
    final data = _asMap(options.data);
    final packageId = _asString(data['package_id']);
    if (packageId == null) {
      return mockError(statusCode: 400, code: 'BAD_REQUEST', message: 'package_id required');
    }

    final pkg = _findPackage(storage.packages, packageId);
    if (pkg == null) {
      return mockError(statusCode: 404, code: 'PACKAGE_NOT_FOUND', message: 'Package not found');
    }

    final orderId = _applyOrder(
      storage: storage,
      mobile: mobile,
      userId: userId,
      pkg: pkg,
      data: data,
    );
    return mockSuccess(orderId);
  }

  ResponseBody _handleCreateMultiOrder(
    MockStorage storage,
    String mobile,
    String userId,
    RequestOptions options,
  ) {
    final data = _asMap(options.data);
    final ids =
        (data['package_ids'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];

    if (ids.isEmpty) {
      return mockError(statusCode: 400, code: 'BAD_REQUEST', message: 'package_ids required');
    }

    final responses = <Map<String, dynamic>>[];
    for (final id in ids) {
      final pkg = _findPackage(storage.packages, id);
      if (pkg == null) continue;
      responses.add(
        _applyOrder(storage: storage, mobile: mobile, userId: userId, pkg: pkg, data: data),
      );
    }

    return mockSuccess(responses);
  }

  /// Applies an order: charges wallet (if requested), activates package,
  /// records transaction, and returns the [CreateOrderResponse] map.
  Map<String, dynamic> _applyOrder({
    required MockStorage storage,
    required String mobile,
    required String userId,
    required PackageModel pkg,
    required Map<String, dynamic> data,
  }) {
    final useWallet = _asBool(data['use_wallet']) ?? false;
    final balance = storage.walletBalances[mobile] ?? 0;
    final walletAmount = useWallet ? (balance < pkg.price ? balance : pkg.price) : 0;
    final gatewayAmount = pkg.price - walletAmount;

    if (useWallet && walletAmount > 0) {
      storage.walletBalances[mobile] = balance - walletAmount;
    }

    final paymentMethod = walletAmount > 0 && gatewayAmount > 0
        ? 'MIXED'
        : (walletAmount > 0 ? 'WALLET' : 'GATEWAY');

    final now = DateTime.now().toUtc();

    final userPkg = UserPackageModel(
      id: _newId('user-pkg'),
      userId: userId,
      packageId: pkg.id,
      status: 'ACTIVE',
      startsAt: now.toIso8601String(),
      expiresAt: now.add(Duration(days: pkg.durationDays)).toIso8601String(),
      package: PackageSummaryModel(id: pkg.id, title: pkg.title, type: pkg.type, price: pkg.price),
    );
    storage.userPackages[mobile]?.add(userPkg);

    final txn = WalletTransactionModel(
      id: _newId('txn'),
      type: 'WITHDRAWAL',
      reason: 'PACKAGE_PURCHASE',
      amount: pkg.price,
      paymentMethod: paymentMethod,
      gatewayProvider: 'ZARINPAL',
      status: 'SUCCESS',
      description: 'خرید ${pkg.title}',
      createdAt: now.toIso8601String(),
      paidAt: now.toIso8601String(),
    );
    storage.transactions[mobile]?.add(txn);

    return {
      'order_id': _newId('order'),
      'discount_amount': 0,
      'wallet_amount': walletAmount,
      'gateway_amount': gatewayAmount,
      'status': 'SUCCESS',
      'gateway_url': 'https://mock.local/success',
    };
  }
}

/// Finds a package by id, or returns null.
PackageModel? _findPackage(List<PackageModel> packages, String id) {
  for (final p in packages) {
    if (p.id == id) return p;
  }
  return null;
}

/// Extracts current mobile from the mock access token.
String? _currentMobile(RequestOptions options) {
  final raw = options.headers['Authorization'] ?? options.headers['authorization'];
  final auth = raw is String
      ? raw
      : raw is List && raw.isNotEmpty
      ? raw.first.toString()
      : null;
  if (auth == null || !auth.startsWith('Bearer ')) return null;
  final token = auth.substring(7);
  if (!token.startsWith('mock-access-')) return null;
  return token.substring('mock-access-'.length);
}

/// Reads a non-empty query parameter as a string.
String? _qs(RequestOptions options, String key) {
  final raw = options.queryParameters[key];
  if (raw == null) return null;
  final s = raw.toString().trim();
  return s.isEmpty ? null : s;
}

/// Generates a unique mock id with the given prefix.
String _newId(String prefix) => 'mock-$prefix-${DateTime.now().microsecondsSinceEpoch}';

/// Safely converts an arbitrary request payload to a map.
Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  if (value != null) {
    try {
      final dynamic dynamicValue = value;
      final json = dynamicValue.toJson();
      if (json is Map) {
        return json.map((key, item) => MapEntry(key.toString(), item));
      }
    } catch (_) {}
  }
  return const <String, dynamic>{};
}

/// Converts a value to a non-empty string, or null.
String? _asString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

/// Converts a value to an int, or null.
int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

/// Converts a value to a bool, or null.
bool? _asBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}
