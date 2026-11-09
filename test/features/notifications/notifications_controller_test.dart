import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/financial/data/models/common_models.dart';
import 'package:myket/features/notifications/data/models/notification_models.dart';
import 'package:myket/features/notifications/data/notifications_repository.dart';
import 'package:myket/features/notifications/presentation/notifications_controller.dart';

import '../../helpers/test_channel_mocks.dart';
import 'notifications_fake_repo.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  group('notificationsControllerProvider', () {
    test('loads first page', () async {
      final fake = FakeNotificationsRepository()..page1 = _page(1, 25, 10);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(notificationsControllerProvider.future);
      final state = container.read(notificationsControllerProvider).value!;
      expect(state.items, hasLength(10));
      expect(state.total, 25);
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
    });

    test('loadMore appends page 2', () async {
      final fake = FakeNotificationsRepository()
        ..page1 = _page(1, 15, 10)
        ..page2 = _page(2, 15, 5);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(notificationsControllerProvider.future);
      await container.read(notificationsControllerProvider.notifier).loadMore();

      final state = container.read(notificationsControllerProvider).value!;
      expect(state.items, hasLength(15));
      expect(state.hasMore, isFalse);
    });

    test('markAsRead updates local state optimistically', () async {
      final fake = FakeNotificationsRepository()..page1 = _page(1, 3, 3, allUnread: true);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(notificationsControllerProvider.future);
      final targetId = container
          .read(notificationsControllerProvider)
          .value!
          .items
          .first
          .notification
          .id;

      final ok = await container
          .read(notificationsControllerProvider.notifier)
          .markAsRead(targetId);
      expect(ok, isTrue);

      final state = container.read(notificationsControllerProvider).value!;
      expect(state.items.first.isRead, isTrue);
      expect(state.localUnreadCount, 2);
    });

    test('markAllAsRead sets every item read', () async {
      final fake = FakeNotificationsRepository()..page1 = _page(1, 3, 3, allUnread: true);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(notificationsControllerProvider.future);
      final ok = await container.read(notificationsControllerProvider.notifier).markAllAsRead();
      expect(ok, isTrue);

      final state = container.read(notificationsControllerProvider).value!;
      expect(state.items.every((i) => i.isRead), isTrue);
      expect(state.localUnreadCount, 0);
    });

    test('error from repository → AsyncError', () async {
      final fake = FakeNotificationsRepository()
        ..throwOnGetNotifications = Exception('network down');
      final container = _container(fake);
      addTearDown(container.dispose);

      await expectLater(
        container.read(notificationsControllerProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(notificationsControllerProvider), isA<AsyncError>());
    });
  });
}

ProviderContainer _container(FakeNotificationsRepository fake) => ProviderContainer(
  overrides: [notificationsRepositoryProvider.overrideWithValue(fake)],
  retry: TestChannelMocks.disabledRetry,
);

PaginatedNotifications _page(int page, int total, int count, {bool allUnread = false}) {
  return PaginatedNotifications(
    meta: PaginationMeta(total: total, page: page, limit: 10, totalPage: (total / 10).ceil()),
    data: List.generate(
      count,
      (i) => NotificationReceipt(
        notification: NotificationItem(
          id: 'n${page}_$i',
          title: 'Title ${page}_$i',
          description: 'Desc ${page}_$i',
          releaseDate: '2026-11-01T10:00:00.000Z',
          tag: 'PUBLIC',
          source: 'MANUAL',
        ),
        isRead: !allUnread,
      ),
    ),
  );
}
