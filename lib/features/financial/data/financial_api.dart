import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/package_models.dart';
import 'models/wallet_models.dart';

part 'financial_api.g.dart';

/// Retrofit interface for all financial endpoints (wallet, packages,
/// orders, and gateway status).
@RestApi()
abstract class FinancialApi {
  /// Creates a [FinancialApi] instance.
  factory FinancialApi(Dio dio, {String? baseUrl}) = _FinancialApi;

  /// Returns the authenticated user's wallet.
  @GET(AppConstants.walletEndpoint)
  Future<ApiResponse<WalletModel>> getWallet();

  /// Returns paginated wallet transactions.
  @GET(AppConstants.walletTransactionsEndpoint)
  Future<ApiResponse<PaginatedWalletTransactions>> getTransactions({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('type') String? type,
    @Query('reason') String? reason,
    @Query('status') String? status,
    @Query('search') String? search,
  });

  /// Starts a wallet top-up and returns the gateway URL to open.
  @POST(AppConstants.walletTopupEndpoint)
  Future<ApiResponse<TopupResponse>> topup(@Body() TopupRequest request);

  /// Returns paginated purchasable packages.
  @GET(AppConstants.packageEndpoint)
  Future<ApiResponse<PaginatedPackages>> getPackages({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  /// Returns the user's currently active package entitlements.
  @GET(AppConstants.userPackageActiveEndpoint)
  Future<ApiResponse<List<UserPackageModel>>> getActiveUserPackages();

  /// Returns the user's package history (all statuses).
  @GET(AppConstants.userPackageHistoryEndpoint)
  Future<ApiResponse<PaginatedUserPackages>> getUserPackageHistory({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  /// Creates a single-package order (checkout).
  @POST(AppConstants.orderCreateEndpoint)
  Future<ApiResponse<CreateOrderResponse>> createOrder(@Body() CreateOrderRequest request);

  /// Returns the up/down status of each payment gateway.
  @GET(AppConstants.gatewayStatusEndpoint)
  Future<ApiResponse<GatewayStatusModel>> getGatewayStatus();
}
