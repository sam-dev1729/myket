/// In-memory representation of a mock notification.
///
/// Kept separate from the API model so that [isRead] can be mutated
/// in-place by the read/read-all endpoints.
class MockNotification {
  final String id;
  final String title;
  final String description;
  final String tag; // ADMIN, BIRTHDAY, PACKAGE, LAB_MESSAGE, PUBLIC
  final String source; // MANUAL, AUTOMATIC
  final String? automaticType;
  final String releaseDate; // ISO-8601
  bool isRead;

  MockNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.source,
    this.automaticType,
    required this.releaseDate,
    required this.isRead,
  });
}

/// Returns a fresh list of seeded notifications.
///
/// Called per user so each user gets independent [isRead] state.
List<MockNotification> mockSeedNotifications() => [
  MockNotification(
    id: 'mock-notif-1',
    title: 'به مدیک متاورس خوش آمدید',
    description: 'از اینکه به ما پیوستید خوشحالیم.',
    tag: 'PUBLIC',
    source: 'MANUAL',
    releaseDate: '2026-11-01T10:00:00.000Z',
    isRead: false,
  ),
  MockNotification(
    id: 'mock-notif-2',
    title: 'آزمایش شما تحلیل شد',
    description: 'نتیجهٔ آخرین آزمایش شما آماده است.',
    tag: 'LAB_MESSAGE',
    source: 'MANUAL',
    releaseDate: '2026-10-28T14:30:00.000Z',
    isRead: true,
  ),
  MockNotification(
    id: 'mock-notif-3',
    title: 'تولدت مبارک!',
    description: 'تیم مدیک متاورس تولدت رو تبریک می‌گه.',
    tag: 'BIRTHDAY',
    source: 'AUTOMATIC',
    automaticType: 'BIRTHDAY',
    releaseDate: '2026-10-15T09:00:00.000Z',
    isRead: false,
  ),
];
