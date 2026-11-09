import 'package:json_annotation/json_annotation.dart';

import '../../../financial/data/models/common_models.dart';

part 'notification_models.g.dart';

/// A single notification item (no per-user state).
@JsonSerializable()
class NotificationItem {
  final String id;
  final String title;
  final String description;

  /// ISO-8601 timestamp of release.
  @JsonKey(name: 'release_date')
  final String releaseDate;

  final String? link;

  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  /// One of: ADMIN, BIRTHDAY, OCCASION, DOCTOR_MESSAGE, LAB_MESSAGE,
  /// PUBLIC, PRIVATE, PACKAGE.
  final String tag;

  /// One of: AUTOMATIC, MANUAL.
  final String source;

  @JsonKey(name: 'automatic_type')
  final String? automaticType;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.releaseDate,
    this.link,
    this.logoUrl,
    required this.tag,
    required this.source,
    this.automaticType,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

/// A notification plus its per-user read flag.
@JsonSerializable(explicitToJson: true)
class NotificationReceipt {
  final NotificationItem notification;

  @JsonKey(name: 'is_read')
  final bool isRead;

  const NotificationReceipt({required this.notification, required this.isRead});

  factory NotificationReceipt.fromJson(Map<String, dynamic> json) =>
      _$NotificationReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationReceiptToJson(this);

  /// Returns a copy with [isRead] replaced.
  NotificationReceipt copyWith({bool? isRead}) =>
      NotificationReceipt(notification: notification, isRead: isRead ?? this.isRead);
}

/// Paginated response for `GET /notification`.
@JsonSerializable(explicitToJson: true)
class PaginatedNotifications {
  final PaginationMeta meta;
  final List<NotificationReceipt> data;

  const PaginatedNotifications({required this.meta, required this.data});

  factory PaginatedNotifications.fromJson(Map<String, dynamic> json) =>
      _$PaginatedNotificationsFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedNotificationsToJson(this);
}

/// Response for `GET /notification/unread-count`.
@JsonSerializable()
class UnreadCountResponse {
  @JsonKey(name: 'unread_count')
  final int unreadCount;

  const UnreadCountResponse({required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}

/// Request body for `PATCH /notification/read`.
@JsonSerializable()
class MarkNotificationReadRequest {
  final String id;

  const MarkNotificationReadRequest({required this.id});

  Map<String, dynamic> toJson() => _$MarkNotificationReadRequestToJson(this);
}
