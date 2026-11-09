import 'package:dio/dio.dart';

/// Interface for a mock handler.
///
/// Each handler declares which path/method patterns it owns, and returns
/// a [ResponseBody] (the mock response) or null to pass to the next handler.
abstract class MockHandler {
  /// Whether this handler owns the given request.
  bool matches(String method, String path);

  /// Produces the mock response.
  Future<ResponseBody> handle(RequestOptions options);
}

/// Helper to build a successful envelope `{ success: true, body: ... }`.
ResponseBody mockSuccess(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    '{"success":true,"body":${_encode(body)}}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Helper to build an error envelope `{ success: false, body: {...} }`.
ResponseBody mockError({required int statusCode, required String code, required String message}) {
  return ResponseBody.fromString(
    '{"success":false,"body":'
    '{"statusCode":$statusCode,"code":"${_escape(code)}",'
    '"message":"${_escape(message)}",'
    '"path":"/","timestamp":"2026-11-07T00:00:00.000Z"}}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Encodes an arbitrary value to JSON using model `toJson()` methods.
String _encode(Object? obj) {
  if (obj == null) return 'null';
  if (obj is String) return '"${_escape(obj)}"';
  if (obj is num || obj is bool) return obj.toString();
  if (obj is List) return '[${obj.map(_encode).join(',')}]';
  if (obj is Map) {
    final entries = obj.entries
        .map((e) => '"${_escape(e.key.toString())}":${_encode(e.value)}')
        .join(',');
    return '{$entries}';
  }

  // Fallback: assume the object has a toJson() method.
  return _encode((obj as dynamic).toJson());
}

/// Escapes special characters for a JSON string literal.
String _escape(String s) => s
    .replaceAll('\\', '\\\\')
    .replaceAll('"', '\\"')
    .replaceAll('\n', '\\n')
    .replaceAll('\r', '\\r')
    .replaceAll('\t', '\\t');
