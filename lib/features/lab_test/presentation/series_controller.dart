import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../financial/data/models/common_models.dart';
import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';

// ─────────────────────────────────────────────────────────────
// Analyte Picker State
// ─────────────────────────────────────────────────────────────

/// Aggregated state for the paginated analyte picker.
class UserAnalytesState {
  final List<UserAnalyte> items;
  final PaginationMeta meta;
  final bool isLoadingMore;
  final String? searchQuery;

  const UserAnalytesState({
    this.items = const [],
    required this.meta,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  UserAnalytesState copyWith({
    List<UserAnalyte>? items,
    PaginationMeta? meta,
    bool? isLoadingMore,
    String? searchQuery,
  }) =>
      UserAnalytesState(
        items: items ?? this.items,
        meta: meta ?? this.meta,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  bool get hasMore => meta.page < meta.totalPage;
}

/// Paginated controller for `GET /lab-test/analytes`.
class UserAnalytesController extends AsyncNotifier<UserAnalytesState> {
  @override
  Future<UserAnalytesState> build() async => _loadFirstPage();

  Future<UserAnalytesState> _loadFirstPage({String? search}) async {
    final repo = ref.read(labTestRepositoryProvider);
    final result = await repo.getUserAnalytes(page: 1, search: search);
    return UserAnalytesState(
      items: result.data,
      meta: result.meta,
      searchQuery: search,
    );
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _loadFirstPage(search: trimmed.isEmpty ? null : trimmed),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(labTestRepositoryProvider);
      final next = await repo.getUserAnalytes(
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

/// Riverpod provider for [UserAnalytesController].
final userAnalytesControllerProvider =
    AsyncNotifierProvider<UserAnalytesController, UserAnalytesState>(
  UserAnalytesController.new,
);

// ─────────────────────────────────────────────────────────────
// Lab Series (keyed by analyte-ids list)
// ─────────────────────────────────────────────────────────────

/// Riverpod [FutureProvider] family that loads time series for a set of
/// analyte ids.
///
/// Keyed by a `List<String>` — since Dart lists are by-reference, callers
/// must pass a stable, sorted copy (e.g. via `seriesKey` helper) to avoid
/// re-fetch loops.
final labSeriesProvider = FutureProvider.family<LabSeriesResponse, List<String>>(
  (ref, ids) async {
    if (ids.isEmpty) return const LabSeriesResponse();
    return ref.read(labTestRepositoryProvider).getLabSeries(ids);
  },
);

/// Returns a stable, sorted, comma-joined key for [ids] so provider family
/// instances aren't recreated for the same logical set.
String seriesKey(List<String> ids) {
  final copy = [...ids]..sort();
  return copy.join(',');
}