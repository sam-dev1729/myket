import 'package:dio/dio.dart';

import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for chunked file upload endpoints.
///
/// Flow:
///   `POST /file/upload/init`            → start session, returns upload_id
///   `PUT  /file/upload/{id}`            → receive a chunk (multipart)
///   `POST /file/upload/{id}/complete`   → promote to permanent file
///   `DELETE /file/upload/{id}`          → abort session
class FileHandler extends MockHandler {
  static final _initPattern = RegExp(r'^/file/upload/init$');
  static final _uploadPattern = RegExp(r'^/file/upload/([^/]+)$');
  static final _completePattern = RegExp(r'^/file/upload/([^/]+)/complete$');

  @override
  bool matches(String method, String path) {
    return path.startsWith('/file/upload');
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    final method = options.method;
    final path = options.path;

    if (method == 'POST' && _initPattern.hasMatch(path)) {
      return _handleInit(options);
    }

    if (method == 'POST') {
      final m = _completePattern.firstMatch(path);
      if (m != null) return _handleComplete(m.group(1)!);
    }

    if (method == 'PUT') {
      final m = _uploadPattern.firstMatch(path);
      if (m != null) return _handleChunk(m.group(1)!, options);
    }

    if (method == 'DELETE') {
      final m = _uploadPattern.firstMatch(path);
      if (m != null) return _handleAbort(m.group(1)!);
    }

    return mockError(
      statusCode: 404,
      code: 'MOCK_NOT_FOUND',
      message: 'No mock handler for $method $path',
    );
  }

  // ──────────────────────────────────────────────────────────
  // Init
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleInit(RequestOptions options) {
    final storage = MockStorage.instance..ensureSeeded();
    final data = _asMap(options.data);
    final name = _asString(data['name']) ?? 'upload.pdf';
    final totalSize = _asInt(data['total_size']) ?? 0;

    final uploadId = _newId('upload');
    storage.uploadSessions[uploadId] = MockUploadSession(
      uploadId: uploadId,
      name: name,
      totalSize: totalSize,
    );

    return mockSuccess({
      'upload_id': uploadId,
      'chunk_size': 8388608, // 8 MB — matches backend default
      'total_size': totalSize,
      'received_bytes': 0,
      'expires_at': DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String(),
    });
  }

  // ──────────────────────────────────────────────────────────
  // Chunk
  // ──────────────────────────────────────────────────────────

  Future<ResponseBody> _handleChunk(String uploadId, RequestOptions options) async {
    final storage = MockStorage.instance..ensureSeeded();
    final session = storage.uploadSessions[uploadId];
    if (session == null) {
      return mockError(
        statusCode: 404,
        code: 'UPLOAD_SESSION_NOT_FOUND',
        message: 'Upload session not found',
      );
    }

    // Small delay so the UI progress bar is visible.
    await Future.delayed(const Duration(milliseconds: 150));

    // The `offset` may be sent as a query parameter or as a multipart
    // form field. Prefer query when present.
    final offsetFromQuery = _asInt(options.queryParameters['offset']);
    final offsetFromData = _extractOffsetFromFormData(options.data);
    final offset = offsetFromQuery ?? offsetFromData ?? session.receivedBytes;

    // Estimate chunk size from the multipart payload. Falls back to the
    // backend's chunk size (8 MB) when the payload can't be inspected.
    final chunkSize = _estimateChunkSize(options.data);

    var received = offset + chunkSize;
    if (received > session.totalSize && session.totalSize > 0) {
      received = session.totalSize;
    }
    session.receivedBytes = received;
    if (session.totalSize > 0 && received >= session.totalSize) {
      session.completed = true;
    }

    return mockSuccess({
      'upload_id': uploadId,
      'received_bytes': session.receivedBytes,
      'total_size': session.totalSize,
      'complete': session.completed,
    });
  }

  // ──────────────────────────────────────────────────────────
  // Complete
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleComplete(String uploadId) {
    final storage = MockStorage.instance..ensureSeeded();
    final session = storage.uploadSessions[uploadId];
    if (session == null) {
      return mockError(
        statusCode: 404,
        code: 'UPLOAD_SESSION_NOT_FOUND',
        message: 'Upload session not found',
      );
    }

    final fileId = _newId('file');
    final file = MockUploadedFile(
      id: fileId,
      originalName: session.name,
      mimeType: 'application/pdf',
      size: session.totalSize,
      source: 'LAB_TEST',
    );
    storage.uploadedFiles[fileId] = file;
    storage.uploadSessions.remove(uploadId);

    // Include both snake_case and camelCase variants so the response
    // parses regardless of how FileResponse declares its field keys.
    return mockSuccess({
      'id': fileId,
      'url': 'https://mock.local/files/$fileId.pdf',
      'hash': 'mockhash-$fileId',
      'path': '/mock/$fileId.pdf',
      'size': file.size,
      'source': file.source,
      'mimeType': file.mimeType,
      'mime_type': file.mimeType,
      'originalName': file.originalName,
      'original_name': file.originalName,
    });
  }

  // ──────────────────────────────────────────────────────────
  // Abort
  // ──────────────────────────────────────────────────────────

  ResponseBody _handleAbort(String uploadId) {
    final storage = MockStorage.instance..ensureSeeded();
    storage.uploadSessions.remove(uploadId);
    return mockSuccess({'message': 'upload session aborted.'});
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// Reads the `offset` field from a multipart [FormData] payload, or null.
int? _extractOffsetFromFormData(Object? data) {
  try {
    final dynamic d = data;
    if (d is FormData) {
      for (final entry in d.fields) {
        if (entry.key == 'offset') {
          return int.tryParse(entry.value);
        }
      }
    }
  } catch (_) {
    // Ignore — fall back to query parameter or accumulated bytes.
  }
  return null;
}

/// Estimates the current chunk size from a multipart payload.
///
/// Sums the `length` of every [MultipartFile] in the form. If the payload
/// isn't a [FormData] (e.g. already serialized), falls back to the backend
/// default chunk size of 8 MB.
int _estimateChunkSize(Object? data) {
  try {
    final dynamic d = data;
    if (d is FormData) {
      var total = 0;
      for (final entry in d.files) {
        total += entry.value.length;
      }
      if (total > 0) return total;
    }
  } catch (_) {
    // Ignore — fall back to default.
  }
  return 8388608; // 8 MB
}

/// Generates a unique mock id with the given prefix.
String _newId(String prefix) => 'mock-$prefix-${DateTime.now().microsecondsSinceEpoch}';

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
