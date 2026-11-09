import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/models/notification_models.dart';
import '../data/notifications_repository.dart';

/// State for the paginated notifications inbox.
class NotificationsState {
  /// Loaded receipts (across all loaded pages).
  final List<NotificationReceipt> items;

  /// Total number of notifications on the server.
  final int total;

  /// Current page number (1-indexed).
  final int page;

  /// Total number of pages available.
  final int totalPage;

  /// Whether a "load more" request is currently in flight.
  final bool isLoadingMore;

  /// Current search query (null when no filter is applied).
  final String? searchQuery;

  const NotificationsState({
    this.items = const [],
    required this.total,
    required this.page,
    required this.totalPage,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  /// Whether more pages exist.
  bool get hasMore => page < totalPage;

  /// Local unread count over loaded items (best-effort).
  int get localUnreadCount => items.where((i) => !i.isRead).length;

  NotificationsState copyWith({
    List<NotificationReceipt>? items,
    int? total,
    int? page,
    int? totalPage,
    bool? isLoadingMore,
    String? searchQuery,
  }) => NotificationsState(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    totalPage: totalPage ?? this.totalPage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    searchQuery: searchQuery ?? this.searchQuery,
  );
}

/// Paginated controller for `GET /notification`.
class NotificationsController extends AsyncNotifier<NotificationsState> {
  @override
  Future<NotificationsState> build() async => _loadFirstPage();

  Future<NotificationsState> _loadFirstPage({String? search}) async {
    final repo = ref.read(notificationsRepositoryProvider);
    final result = await repo.getNotifications(
      page: 1,
      limit: AppConstants.defaultPageSize,
      search: search,
    );
    return NotificationsState(
      items: result.data,
      total: result.meta.total,
      page: result.meta.page,
      totalPage: result.meta.totalPage,
      searchQuery: search,
    );
  }

  /// Reloads page 1 (respects the current search query).
  Future<void> refresh() async {
    final currentSearch = state.value?.searchQuery;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFirstPage(search: currentSearch));
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
      final repo = ref.read(notificationsRepositoryProvider);
      final next = await repo.getNotifications(
        page: current.page + 1,
        limit: AppConstants.defaultPageSize,
        search: current.searchQuery,
      );
      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...next.data],
          page: next.meta.page,
          totalPage: next.meta.totalPage,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, st);
    }
  }

  /// Marks a single notification as read (optimistic local update).
  ///
  /// Returns `true` on success (or when already read), `false` on failure.
  Future<bool> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return false;

    final idx = current.items.indexWhere((i) => i.notification.id == id);
    if (idx < 0) return false;
    if (current.items[idx].isRead) return true; // already read

    try {
      await ref.read(notificationsRepositoryProvider).markAsRead(id);
      final updated = [...current.items];
      updated[idx] = updated[idx].copyWith(isRead: true);
      state = AsyncValue.data(current.copyWith(items: updated));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Marks every notification as read (optimistic local update).
  Future<bool> markAllAsRead() async {
    final current = state.value;
    if (current == null) return false;

    try {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
      final updated = current.items.map((i) => i.copyWith(isRead: true)).toList();
      state = AsyncValue.data(current.copyWith(items: updated));
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Riverpod provider for [NotificationsController].
final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, NotificationsState>(NotificationsController.new);

/// Server-side unread count — kept separate so a badge can refresh without
/// touching the paginated list.
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  return ref.read(notificationsRepositoryProvider).getUnreadCount();
});
