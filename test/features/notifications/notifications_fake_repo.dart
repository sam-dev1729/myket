import 'package:dio/dio.dart';
import 'package:myket/features/notifications/data/models/notification_models.dart';
import 'package:myket/features/notifications/data/notifications_api.dart';
import 'package:myket/features/notifications/data/notifications_repository.dart';

/// Hand-rolled fake of [NotificationsRepository].
class FakeNotificationsRepository extends NotificationsRepository {
  FakeNotificationsRepository() : super(NotificationsApi(Dio()));

  PaginatedNotifications? page1;
  PaginatedNotifications? page2;
  Exception? throwOnGetNotifications;

  int? unreadCount;
  Exception? throwOnGetUnreadCount;

  Exception? throwOnMarkAsRead;
  Exception? throwOnMarkAllAsRead;

  @override
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isRead,
    String? tag,
  }) async {
    if (throwOnGetNotifications != null) throw throwOnGetNotifications!;
    if (page == 1 && page1 != null) return page1!;
    if (page == 2 && page2 != null) return page2!;
    throw UnimplementedError('Unexpected page=$page');
  }

  @override
  Future<int> getUnreadCount() async {
    if (throwOnGetUnreadCount != null) throw throwOnGetUnreadCount!;
    return unreadCount ?? 0;
  }

  @override
  Future<void> markAsRead(String id) async {
    if (throwOnMarkAsRead != null) throw throwOnMarkAsRead!;
  }

  @override
  Future<void> markAllAsRead() async {
    if (throwOnMarkAllAsRead != null) throw throwOnMarkAllAsRead!;
  }
}
