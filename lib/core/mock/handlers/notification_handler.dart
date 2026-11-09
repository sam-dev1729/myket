import 'package:dio/dio.dart';

import '../data/mock_notifications.dart';
import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for user notification endpoints.
class NotificationHandler extends MockHandler {
  @override
  bool matches(String method, String path) {
    if (method == 'GET' && path == '/notification') return true;
    if (method == 'GET' && path == '/notification/unread-count') return true;
    if (method == 'PATCH' && path == '/notification/read') return true;
    if (method == 'PATCH' && path == '/notification/read-all') return true;
    return false;
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final storage = MockStorage.instance..ensureSeeded();
    final mobile = _currentMobile(options);
    if (mobile == null) {
      return mockError(statusCode: 401, code: 'UNAUTHORIZED', message: 'Unauthorized');
    }

    // Explicit type annotation forces non-nullable list and prevents
    // inference from drifting into `List<MockNotification?>` in some
    // analyzer configurations.
    final List<MockNotification> list = storage.notifications[mobile] ?? const <MockNotification>[];

    if (options.method == 'GET' && options.path == '/notification') {
      final page = _asInt(options.queryParameters['page']) ?? 1;
      final limit = _asInt(options.queryParameters['limit']) ?? 20;

      // Copy + sort into a fresh, explicitly typed list.
      final sorted = <MockNotification>[...list]
        ..sort((a, b) => b.releaseDate.compareTo(a.releaseDate));

      final total = sorted.length;
      final totalPage = total == 0 ? 0 : ((total + limit - 1) ~/ limit);
      final start = (page - 1) * limit;
      final end = start + limit < total ? start + limit : total;

      // Use sublist — preserves generic type unambiguously.
      final List<MockNotification> pageData = start >= total
          ? const <MockNotification>[]
          : sorted.sublist(start, end);

      // Explicit for-loop: `n` is definitely MockNotification (non-nullable).
      final data = <Map<String, dynamic>>[];
      for (final MockNotification n in pageData) {
        data.add({
          'notification': <String, dynamic>{
            'id': n.id,
            'title': n.title,
            'description': n.description,
            'release_date': n.releaseDate,
            'link': null,
            'logo_url': null,
            'tag': n.tag,
            'source': n.source,
            'automatic_type': n.automaticType,
          },
          'is_read': n.isRead,
        });
      }

      return mockSuccess({
        'meta': {'page': page, 'limit': limit, 'total': total, 'total_page': totalPage},
        'data': data,
      });
    }

    if (options.method == 'GET' && options.path == '/notification/unread-count') {
      final count = list.where((n) => !n.isRead).length;
      return mockSuccess({'unread_count': count});
    }

    if (options.method == 'PATCH' && options.path == '/notification/read') {
      final data = _asMap(options.data);
      final id = _asString(data['notification_id']) ?? _asString(data['id']);
      if (id != null) {
        for (final n in list) {
          if (n.id == id) {
            n.isRead = true;
            break;
          }
        }
      }
      return mockSuccess(null);
    }

    if (options.method == 'PATCH' && options.path == '/notification/read-all') {
      for (final n in list) {
        n.isRead = true;
      }
      return mockSuccess(null);
    }

    return mockError(
      statusCode: 404,
      code: 'MOCK_NOT_FOUND',
      message: 'No mock handler for ${options.method} ${options.path}',
    );
  }
}

/// Extracts current mobile from the mock access token.
String? _currentMobile(RequestOptions options) {
  final raw = options.headers['Authorization'] ?? options.headers['authorization'];
  final auth = raw is String
      ? raw
      : raw is List && raw.isNotEmpty
      ? raw.first.toString()
      : null;
  if (auth == null || !auth.startsWith('Bearer ')) return null;
  final token = auth.substring(7);
  if (!token.startsWith('mock-access-')) return null;
  return token.substring('mock-access-'.length);
}

/// Safely converts an arbitrary request payload to a map.
Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  if (value != null) {
    try {
      final dynamic dynamicValue = value;
      final json = dynamicValue.toJson();
      if (json is Map) {
        return json.map((key, item) => MapEntry(key.toString(), item));
      }
    } catch (_) {}
  }
  return const <String, dynamic>{};
}

/// Converts a value to a non-empty string, or null.
String? _asString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

/// Converts a value to an int, or null.
int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
