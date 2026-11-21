import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import 'file_repository.dart';

/// Metadata of an upload that can be resumed after the app restarts.
class PendingUploadData {
  const PendingUploadData({
    required this.originalName,
    required this.filePath,
    this.uploadId,
    this.chunkSize,
    this.totalSize,
    this.receivedBytes = 0,
    this.expiresAt,
  });

  /// Original display name of the selected file.
  final String originalName;

  /// Absolute path of the copied file in app storage.
  final String filePath;

  /// Server upload session id (null before the first `init`).
  final String? uploadId;

  /// Server chunk size.
  final int? chunkSize;

  /// Total size in bytes.
  final int? totalSize;

  /// Bytes already accepted by the server.
  final int receivedBytes;

  /// ISO expiry of the upload session.
  final String? expiresAt;

  factory PendingUploadData.fromJson(Map<String, dynamic> json) {
    return PendingUploadData(
      originalName: (json['original_name'] as String?) ?? 'upload',
      filePath: (json['file_path'] as String?) ?? '',
      uploadId: json['upload_id'] as String?,
      chunkSize: (json['chunk_size'] as num?)?.toInt(),
      totalSize: (json['total_size'] as num?)?.toInt(),
      receivedBytes: (json['received_bytes'] as num?)?.toInt() ?? 0,
      expiresAt: json['expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_name': originalName,
      'file_path': filePath,
      'upload_id': uploadId,
      'chunk_size': chunkSize,
      'total_size': totalSize,
      'received_bytes': receivedBytes,
      'expires_at': expiresAt,
    };
  }

  /// Converts this metadata to an upload session when it has one.
  FileUploadSession? toSession() {
    final id = uploadId;
    final size = totalSize;
    final chunk = chunkSize;
    if (id == null || size == null || chunk == null) return null;
    if (receivedBytes >= size) return null;
    return FileUploadSession(
      uploadId: id,
      chunkSize: chunk,
      totalSize: size,
      receivedBytes: receivedBytes,
      expiresAt: expiresAt,
    );
  }
}

/// Stores a copy of the selected file and the upload session metadata so an
/// interrupted upload can continue after the app is restarted.
class PendingUploadStore {
  /// Optional override used by tests.
  PendingUploadStore({Future<Directory> Function()? directoryProvider})
      : _directoryProvider = directoryProvider ?? _defaultDirectory;

  final Future<Directory> Function() _directoryProvider;

  static Future<Directory> _defaultDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}${Platform.pathSeparator}lab_upload');
  }

  Future<File> _metadataFile() async {
    final dir = await _directoryProvider();
    await dir.create(recursive: true);
    return File('${dir.path}${Platform.pathSeparator}pending_upload.json');
  }

  /// Copies [source] into app storage and forgets the previous pending upload.
  Future<PendingUploadData?> stageFile(File source) async {
    try {
      final dir = await _directoryProvider();
      await dir.create(recursive: true);
      await clear();

      final extension = source.path.contains('.')
          ? source.path.substring(source.path.lastIndexOf('.'))
          : '.bin';
      final destination = File(
        '${dir.path}${Platform.pathSeparator}pending_upload$extension',
      );
      final copy = await source.copy(destination.path);

      final data = PendingUploadData(
        originalName: _fileName(source.path),
        filePath: copy.path,
      );
      await _write(data);
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Updates the stored session after init or after a chunk was accepted.
  Future<void> saveSession(FileUploadSession session) async {
    try {
      final current = await load();
      if (current == null) return;
      await _write(
        PendingUploadData(
          originalName: current.originalName,
          filePath: current.filePath,
          uploadId: session.uploadId,
          chunkSize: session.chunkSize,
          totalSize: session.totalSize,
          receivedBytes: session.receivedBytes,
          expiresAt: session.expiresAt,
        ),
      );
    } catch (_) {
      // Persistence is best-effort; the in-memory upload still works.
    }
  }

  /// Loads the pending upload if both metadata and the copied file exist.
  Future<PendingUploadData?> load() async {
    try {
      final metadata = await _metadataFile();
      if (!await metadata.exists()) return null;

      final raw = await metadata.readAsString();
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;

      final data = PendingUploadData.fromJson(map);
      if (data.filePath.isEmpty) return null;
      if (!await File(data.filePath).exists()) {
        await clear();
        return null;
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Deletes the copied file and metadata.
  Future<void> clear() async {
    try {
      final dir = await _directoryProvider();
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        if (entity is File) {
          try {
            await entity.delete();
          } catch (_) {
            // Ignore individual file cleanup errors.
          }
        }
      }
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  Future<void> _write(PendingUploadData data) async {
    final metadata = await _metadataFile();
    await metadata.writeAsString(jsonEncode(data.toJson()), flush: true);
  }

  /// Whether there is a resumable file/session on disk.
  Future<bool> hasPending() async => (await load()) != null;

  /// Default chunk size used when the stored metadata has none.
  static int get fallbackChunkSize => AppConstants.fileChunkSize;

  /// Returns the file name from a Windows or POSIX path.
  static String _fileName(String path) => path.split(RegExp(r'[\\/]')).last;
}

/// Riverpod provider for [PendingUploadStore].
final pendingUploadStoreProvider = Provider<PendingUploadStore>((ref) {
  return PendingUploadStore();
});
