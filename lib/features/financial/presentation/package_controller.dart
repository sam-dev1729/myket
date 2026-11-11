import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/financial_repository.dart';
import '../data/models/package_models.dart';
import 'wallet_controller.dart';

/// Async controller for the purchasable packages list.
class PackagesController extends AsyncNotifier<List<PackageModel>> {
  /// Fetches the first page on build.
  @override
  Future<List<PackageModel>> build() async {
    final r = await ref
        .read(financialRepositoryProvider)
        .getPackages(limit: AppConstants.packagesPageSize);
    return r.data;
  }

  /// Re-fetches the packages list from the backend.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final r = await ref
          .read(financialRepositoryProvider)
          .getPackages(limit: AppConstants.packagesPageSize);
      return r.data;
    });
  }
}

/// Riverpod provider for [PackagesController].
final packagesControllerProvider = AsyncNotifierProvider<PackagesController, List<PackageModel>>(
  PackagesController.new,
);

/// FutureProvider that exposes the user's active packages.
///
/// Invalidate this provider after a successful purchase or top-up.
final activeUserPackagesProvider = FutureProvider<List<UserPackageModel>>((ref) async {
  return ref.read(financialRepositoryProvider).getActiveUserPackages();
});

/// FutureProvider that exposes the up/down status of each gateway.
final gatewayStatusProvider = FutureProvider<GatewayStatusModel>((ref) {
  return ref.read(financialRepositoryProvider).getGatewayStatus();
});

/// UI status for the buy-package flow.
enum BuyStatus {
  /// No operation performed yet.
  idle,

  /// The create-order request is in progress.
  loading,

  /// The order was created and a gateway redirect is required.
  pending,

  /// The order was settled immediately (no gateway redirect).
  success,

  /// The create-order request failed.
  error,
}

/// State model for [BuyPackageController].
class BuyPackageState {
  final BuyStatus status;
  final CreateOrderResponse? response; // برای خرید تکی
  final CreateMultiOrderResponse? multiResponse; // برای خرید چندگانه
  final String? errorMessage;

  const BuyPackageState({
    this.status = BuyStatus.idle,
    this.response,
    this.multiResponse,
    this.errorMessage,
  });

  BuyPackageState copyWith({
    BuyStatus? status,
    CreateOrderResponse? response,
    CreateMultiOrderResponse? multiResponse,
    String? errorMessage,
  }) {
    return BuyPackageState(
      status: status ?? this.status,
      response: response ?? this.response,
      multiResponse: multiResponse ?? this.multiResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller that manages the buy-package flow.
class BuyPackageController extends Notifier<BuyPackageState> {
  @override
  BuyPackageState build() => const BuyPackageState();

  /// Submits an order (single or multi).
  Future<void> submit({
    required List<String> packageIds,
    String? discountCode,
    bool useWallet = false,
    String? gateway,
  }) async {
    state = const BuyPackageState(status: BuyStatus.loading);
    try {
      if (packageIds.length == 1) {
        // خرید تکی
        final res = await ref
            .read(financialRepositoryProvider)
            .createOrder(
              packageId: packageIds.first,
              discountCode: discountCode,
              useWallet: useWallet,
              gateway: gateway,
            );
        final needsGateway =
            res.status == AppConstants.statusPending && (res.gatewayUrl?.isNotEmpty ?? false);
        state = state.copyWith(
          status: needsGateway ? BuyStatus.pending : BuyStatus.success,
          response: res,
        );
        if (!needsGateway) {
          await ref.read(walletControllerProvider.notifier).refresh();
          ref.invalidate(activeUserPackagesProvider);
        }
      } else {
        // خرید چندگانه
        final res = await ref
            .read(financialRepositoryProvider)
            .createMultiOrder(
              packageIds: packageIds,
              discountCode: discountCode,
              useWallet: useWallet,
              gateway: gateway,
            );
        final needsGateway =
            res.status == AppConstants.statusPending && (res.gatewayUrl?.isNotEmpty ?? false);
        state = state.copyWith(
          status: needsGateway ? BuyStatus.pending : BuyStatus.success,
          multiResponse: res,
        );
        if (!needsGateway) {
          await ref.read(walletControllerProvider.notifier).refresh();
          ref.invalidate(activeUserPackagesProvider);
        }
      }
    } catch (e) {
      state = state.copyWith(status: BuyStatus.error, errorMessage: e.toString());
    }
  }

  void reset() => state = const BuyPackageState();
}


/// Riverpod provider for [BuyPackageController].
final buyPackageControllerProvider = NotifierProvider<BuyPackageController, BuyPackageState>(
  BuyPackageController.new,
);
