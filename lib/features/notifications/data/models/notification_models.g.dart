// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      releaseDate: json['release_date'] as String,
      link: json['link'] as String?,
      logoUrl: json['logo_url'] as String?,
      tag: json['tag'] as String,
      source: json['source'] as String,
      automaticType: json['automatic_type'] as String?,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'release_date': instance.releaseDate,
      'link': instance.link,
      'logo_url': instance.logoUrl,
      'tag': instance.tag,
      'source': instance.source,
      'automatic_type': instance.automaticType,
    };

NotificationReceipt _$NotificationReceiptFromJson(Map<String, dynamic> json) =>
    NotificationReceipt(
      notification: NotificationItem.fromJson(
        json['notification'] as Map<String, dynamic>,
      ),
      isRead: json['is_read'] as bool,
    );

Map<String, dynamic> _$NotificationReceiptToJson(
  NotificationReceipt instance,
) => <String, dynamic>{
  'notification': instance.notification.toJson(),
  'is_read': instance.isRead,
};

PaginatedNotifications _$PaginatedNotificationsFromJson(
  Map<String, dynamic> json,
) => PaginatedNotifications(
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>)
      .map((e) => NotificationReceipt.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedNotificationsToJson(
  PaginatedNotifications instance,
) => <String, dynamic>{
  'meta': instance.meta.toJson(),
  'data': instance.data.map((e) => e.toJson()).toList(),
};

UnreadCountResponse _$UnreadCountResponseFromJson(Map<String, dynamic> json) =>
    UnreadCountResponse(unreadCount: (json['unread_count'] as num).toInt());

Map<String, dynamic> _$UnreadCountResponseToJson(
  UnreadCountResponse instance,
) => <String, dynamic>{'unread_count': instance.unreadCount};

MarkNotificationReadRequest _$MarkNotificationReadRequestFromJson(
  Map<String, dynamic> json,
) => MarkNotificationReadRequest(id: json['id'] as String);

Map<String, dynamic> _$MarkNotificationReadRequestToJson(
  MarkNotificationReadRequest instance,
) => <String, dynamic>{'id': instance.id};
