import 'package:flutter_riverpod/flutter_riverpod.dart';

// Shared pagination metadata (PaginationMeta).
import '../../financial/data/models/common_models.dart';
import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';

/// Riverpod [FutureProvider] that loads the compact results overview
/// (`GET /lab-test/overview` — overall status + up to 10 latest parameters).
///
/// Consumed by the CTA on the Health Record tab. For the full paginated list
/// use [labOverviewParametersControllerProvider].
final labOverviewProvider = FutureProvider<LabOverview>((ref) async {
  return ref.read(labTestRepositoryProvider).getLabOverview();
});

/// Aggregated state for the paginated overview-parameters controller.
class LabOverviewParametersState {
  /// Loaded parameter rows (across all loaded pages).
  final List<LabOverviewParameter> items;

  /// Pagination metadata from the most recent response.
  final PaginationMeta meta;

  /// Whether a "load more" request is currently in flight.
  final bool isLoadingMore;

  /// The current search query (null when no filter is applied).
  final String? searchQuery;

  /// Overall status computed over the full set (from the backend).
  final String? overallStatus;

  const LabOverviewParametersState({
    this.items = const [],
    required this.meta,
    this.isLoadingMore = false,
    this.searchQuery,
    this.overallStatus,
  });

  LabOverviewParametersState copyWith({
    List<LabOverviewParameter>? items,
    PaginationMeta? meta,
    bool? isLoadingMore,
    String? searchQuery,
    String? overallStatus,
  }) => LabOverviewParametersState(
    items: items ?? this.items,
    meta: meta ?? this.meta,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    searchQuery: searchQuery ?? this.searchQuery,
    overallStatus: overallStatus ?? this.overallStatus,
  );

  /// Whether more pages exist.
  bool get hasMore => meta.page < meta.totalPage;
}

/// Controller for the paginated latest-parameters list.
///
/// Pattern matches `notificationsControllerProvider` (listener + AsyncNotifier)
/// so pagination and search behave consistently across the app.
class LabOverviewParametersController extends AsyncNotifier<LabOverviewParametersState> {
  @override
  Future<LabOverviewParametersState> build() async {
    return _loadFirstPage();
  }

  Future<LabOverviewParametersState> _loadFirstPage({String? search}) async {
    final repo = ref.read(labTestRepositoryProvider);
    final result = await repo.getLabOverviewParameters(page: 1, search: search);
    return LabOverviewParametersState(
      items: result.data,
      meta: result.meta,
      searchQuery: search,
      overallStatus: result.overallStatus,
    );
  }

  /// Resets to page 1 and re-fetches.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    // Riverpod 3: `value` returns null during loading/error instead of throwing.
    state = await AsyncValue.guard(() => _loadFirstPage(search: state.value?.searchQuery));
  }

  /// Applies [query] as a search filter (null/empty clears the filter).
  Future<void> search(String query) async {
    final trimmed = query.trim();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFirstPage(search: trimmed.isEmpty ? null : trimmed));
  }

  /// Loads the next page and appends it to the current list.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(labTestRepositoryProvider);
      final next = await repo.getLabOverviewParameters(
        page: current.meta.page + 1,
        search: current.searchQuery,
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

/// Riverpod provider for [LabOverviewParametersController].
final labOverviewParametersControllerProvider =
    AsyncNotifierProvider<LabOverviewParametersController, LabOverviewParametersState>(
      LabOverviewParametersController.new,
    );
