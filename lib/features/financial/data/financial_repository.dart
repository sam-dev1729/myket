import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'financial_api.dart';
import 'models/package_models.dart';
import 'models/wallet_models.dart';

/// Repository that wraps [FinancialApi] and provides domain-friendly
/// methods for the financial feature.
class FinancialRepository {
  /// Underlying API instance.
  final FinancialApi api;

  /// Creates a [FinancialRepository] instance.
  FinancialRepository(this.api);

  /// Returns the authenticated user's wallet.
  Future<WalletModel> getWallet() async {
    final r = await api.getWallet();
    if (!r.success) throw r.error!;
    return r.body!;
  }

  /// Returns paginated wallet transactions.
  Future<PaginatedWalletTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? reason,
    String? status,
  }) async {
    final r = await api.getTransactions(
      page: page,
      limit: limit,
      type: type,
      reason: reason,
      status: status,
    );
    if (!r.success) throw r.error!;
    return r.body!;
  }

  /// Starts a wallet top-up and returns the gateway response.
  Future<TopupResponse> topup(int amount, {String? gateway}) async {
    final r = await api.topup(TopupRequest(amount: amount, paymentGateway: gateway));
    if (!r.success) throw r.error!;
    return r.body!;
  }

  /// Returns paginated purchasable packages.
  Future<PaginatedPackages> getPackages({int page = 1, int limit = 20}) async {
    final r = await api.getPackages(page: page, limit: limit);
    if (!r.success) throw r.error!;
    return r.body!;
  }

  /// Returns the user's currently active package entitlements.
  Future<List<UserPackageModel>> getActiveUserPackages() async {
    final r = await api.getActiveUserPackages();
    if (!r.success) throw r.error!;
    return r.body ?? <UserPackageModel>[];
  }

  /// Returns the user's package history (all statuses).
  Future<PaginatedUserPackages> getUserPackageHistory({int page = 1, int limit = 20}) async {
    final r = await api.getUserPackageHistory(page: page, limit: limit);
    if (!r.success) throw r.error!;
    return r.body!;
  }

  /// Creates a single-package order.
  Future<CreateOrderResponse> createOrder({
    required String packageId,
    String? discountCode,
    bool useWallet = false,
    String? gateway,
  }) async {
    final r = await api.createOrder(
      CreateOrderRequest(
        packageId: packageId,
        discountCode: discountCode,
        useWallet: useWallet,
        paymentGateway: gateway,
      ),
    );
    if (!r.success) throw r.error!;
    return r.body!;
  }

  /// Returns the up/down status of each payment gateway.
  Future<GatewayStatusModel> getGatewayStatus() async {
    final r = await api.getGatewayStatus();
    if (!r.success) throw r.error!;
    return r.body!;
  }
}

/// Riverpod provider for [FinancialRepository].
final financialRepositoryProvider = Provider<FinancialRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = FinancialApi(apiClient.dio);
  return FinancialRepository(api);
});
