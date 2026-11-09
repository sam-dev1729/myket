import 'package:dio/dio.dart';
import 'package:myket/features/financial/data/financial_api.dart';
import 'package:myket/features/financial/data/financial_repository.dart';
import 'package:myket/features/financial/data/models/common_models.dart';
import 'package:myket/features/financial/data/models/package_models.dart';
import 'package:myket/features/financial/data/models/wallet_models.dart';

/// Hand-rolled fake of [FinancialRepository] used by controller tests.
///
/// Configurable via public fields so each test can tailor the responses
/// and error behavior. Never touches Dio or any platform channel.
class FakeFinancialRepository extends FinancialRepository {
  FakeFinancialRepository() : super(FinancialApi(Dio()));

  // ── Configurable responses ──
  WalletModel? wallet;
  List<PackageModel>? packages;
  PaginatedWalletTransactions? transactionsPage1;
  PaginatedWalletTransactions? transactionsPage2;
  CreateOrderResponse? createOrderResponse;
  TopupResponse? topupResponse;

  // ── Configurable errors ──
  Exception? throwOnGetWallet;
  Exception? throwOnGetPackages;
  Exception? throwOnGetTransactions;
  Exception? throwOnCreateOrder;
  Exception? throwOnTopup;

  @override
  Future<WalletModel> getWallet() async {
    if (throwOnGetWallet != null) throw throwOnGetWallet!;
    return wallet!;
  }

  @override
  Future<PaginatedPackages> getPackages({int page = 1, int limit = 20}) async {
    if (throwOnGetPackages != null) throw throwOnGetPackages!;
    final list = packages ?? const <PackageModel>[];
    return PaginatedPackages(
      meta: PaginationMeta(total: list.length, page: page, limit: limit, totalPage: 1),
      data: list,
    );
  }

  @override
  Future<PaginatedWalletTransactions> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? reason,
    String? status,
  }) async {
    if (throwOnGetTransactions != null) throw throwOnGetTransactions!;
    if (page == 1 && transactionsPage1 != null) return transactionsPage1!;
    if (page == 2 && transactionsPage2 != null) return transactionsPage2!;
    throw UnimplementedError('Unexpected page=$page in fake repo');
  }

  @override
  Future<CreateOrderResponse> createOrder({
    required String packageId,
    String? discountCode,
    bool useWallet = false,
    String? gateway,
  }) async {
    if (throwOnCreateOrder != null) throw throwOnCreateOrder!;
    return createOrderResponse!;
  }

  @override
  Future<TopupResponse> topup(int amount, {String? gateway}) async {
    if (throwOnTopup != null) throw throwOnTopup!;
    return topupResponse!;
  }

  @override
  Future<List<UserPackageModel>> getActiveUserPackages() async => const [];

  @override
  Future<PaginatedUserPackages> getUserPackageHistory({int page = 1, int limit = 20}) async =>
      PaginatedUserPackages(
        meta: PaginationMeta(total: 0, page: page, limit: limit, totalPage: 0),
        data: const [],
      );

  @override
  Future<GatewayStatusModel> getGatewayStatus() async =>
      const GatewayStatusModel(ap: true, zarinpal: true);
}
