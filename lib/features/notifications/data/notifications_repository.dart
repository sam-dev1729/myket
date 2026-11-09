import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'models/notification_models.dart';
import 'notifications_api.dart';

/// Repository for `/notification/*` endpoints.
class NotificationsRepository {
  final NotificationsApi api;

  NotificationsRepository(this.api);

  /// Returns the paginated inbox for the authenticated user.
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isRead,
    String? tag,
  }) async {
    final r = await api.getNotifications(
      page: page,
      limit: limit,
      search: search,
      isRead: isRead,
      tag: tag,
    );
    if (!r.success) throw r.error!;
    return r.body!;
  }

  /// Returns the number of unread notifications.
  Future<int> getUnreadCount() async {
    final r = await api.getUnreadCount();
    if (!r.success) throw r.error!;
    return r.body!.unreadCount;
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String id) async {
    final r = await api.markAsRead(MarkNotificationReadRequest(id: id));
    if (!r.success) throw r.error!;
  }

  /// Marks every unread notification as read.
  Future<void> markAllAsRead() async {
    final r = await api.markAllAsRead();
    if (!r.success) throw r.error!;
  }
}

/// Riverpod provider for [NotificationsRepository].
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = NotificationsApi(apiClient.dio);
  return NotificationsRepository(api);
});
