import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/financial_repository.dart';
import '../data/models/wallet_models.dart';

/// Async controller that fetches and caches the current wallet.
class WalletController extends AsyncNotifier<WalletModel> {
  /// Fetches the wallet on build.
  @override
  Future<WalletModel> build() => ref.read(financialRepositoryProvider).getWallet();

  /// Re-fetches the wallet from the backend.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(financialRepositoryProvider).getWallet());
  }
}

/// Riverpod provider for [WalletController].
final walletControllerProvider = AsyncNotifierProvider<WalletController, WalletModel>(
  WalletController.new,
);

/// Async controller for paginated wallet transactions.
class TransactionsController extends AsyncNotifier<PaginatedWalletTransactions> {
  int _page = 1;

  /// Fetches the first page on build.
  @override
  Future<PaginatedWalletTransactions> build() {
    _page = 1;
    return ref
        .read(financialRepositoryProvider)
        .getTransactions(page: 1, limit: AppConstants.transactionsPageSize);
  }

  /// Loads the next page and appends it to the current state.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null) return;
    if (current.data.length >= current.meta.total) return;

    _page++;
    final next = await ref
        .read(financialRepositoryProvider)
        .getTransactions(page: _page, limit: AppConstants.transactionsPageSize);
    state = AsyncData(
      PaginatedWalletTransactions(meta: next.meta, data: [...current.data, ...next.data]),
    );
  }

  /// Resets pagination and re-fetches the first page.
  Future<void> refresh() async {
    _page = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(financialRepositoryProvider)
          .getTransactions(page: 1, limit: AppConstants.transactionsPageSize),
    );
  }
}

/// Riverpod provider for [TransactionsController].
final transactionsControllerProvider =
    AsyncNotifierProvider<TransactionsController, PaginatedWalletTransactions>(
      TransactionsController.new,
    );

/// UI status for the top-up flow.
enum TopupStatus {
  /// No operation performed yet.
  idle,

  /// The top-up request is in progress.
  loading,

  /// The top-up request succeeded and returned a gateway URL.
  success,

  /// The top-up request failed.
  error,
}

/// State model for [TopupController].
class TopupState {
  /// Current status of the top-up flow.
  final TopupStatus status;

  /// Response body when [status] is [TopupStatus.success].
  final TopupResponse? response;

  /// Error message when [status] is [TopupStatus.error].
  final String? errorMessage;

  /// Creates a [TopupState] instance.
  const TopupState({this.status = TopupStatus.idle, this.response, this.errorMessage});

  /// Returns a copy of this state with selected fields replaced.
  TopupState copyWith({TopupStatus? status, TopupResponse? response, String? errorMessage}) {
    return TopupState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller that manages the wallet top-up flow.
class TopupController extends Notifier<TopupState> {
  /// Initial state.
  @override
  TopupState build() => const TopupState();

  /// Submits a top-up request.
  Future<void> submit(int amount, {String? gateway}) async {
    state = state.copyWith(status: TopupStatus.loading);
    try {
      final res = await ref.read(financialRepositoryProvider).topup(amount, gateway: gateway);
      state = state.copyWith(status: TopupStatus.success, response: res);
    } catch (e) {
      state = state.copyWith(status: TopupStatus.error, errorMessage: e.toString());
    }
  }

  /// Resets the top-up state to idle.
  void reset() => state = const TopupState();
}

/// Riverpod provider for [TopupController].
final topupControllerProvider = NotifierProvider<TopupController, TopupState>(TopupController.new);
