import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/financial_repository.dart';
import '../data/models/common_models.dart';
import '../data/models/package_models.dart';

/// Aggregated state for the paginated user-package-history list.
class UserPackageHistoryState {
  /// Loaded entitlements (across all loaded pages).
  final List<UserPackageModel> items;

  /// Pagination metadata from the most recent response.
  final PaginationMeta meta;

  /// Whether a "load more" request is currently in flight.
  final bool isLoadingMore;

  const UserPackageHistoryState({
    this.items = const [],
    required this.meta,
    this.isLoadingMore = false,
  });

  /// Whether more pages exist.
  bool get hasMore => meta.page < meta.totalPage;

  UserPackageHistoryState copyWith({
    List<UserPackageModel>? items,
    PaginationMeta? meta,
    bool? isLoadingMore,
  }) => UserPackageHistoryState(
    items: items ?? this.items,
    meta: meta ?? this.meta,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Paginated controller for `GET /user-package/history`.
///
/// Same pattern as the wallet-transactions and notifications controllers —
/// initial load on build, `loadMore` appends the next page, `refresh` resets.
class UserPackageHistoryController extends AsyncNotifier<UserPackageHistoryState> {
  @override
  Future<UserPackageHistoryState> build() => _loadFirstPage();

  Future<UserPackageHistoryState> _loadFirstPage() async {
    final repo = ref.read(financialRepositoryProvider);
    final result = await repo.getUserPackageHistory(page: 1, limit: AppConstants.packagesPageSize);
    return UserPackageHistoryState(items: result.data, meta: result.meta);
  }

  /// Resets to page 1 and re-fetches.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadFirstPage);
  }

  /// Loads the next page and appends it to the current list.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(financialRepositoryProvider);
      final next = await repo.getUserPackageHistory(
        page: current.meta.page + 1,
        limit: AppConstants.packagesPageSize,
      );
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...next.data],
          meta: next.meta,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, st);
    }
  }
}

/// Riverpod provider for [UserPackageHistoryController].
final userPackageHistoryControllerProvider =
    AsyncNotifierProvider<UserPackageHistoryController, UserPackageHistoryState>(
      UserPackageHistoryController.new,
    );
