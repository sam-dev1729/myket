import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'file_api.dart';
import 'models/file_models.dart';

/// Immutable snapshot of a chunked upload session.
///
/// The controller keeps this between attempts so an interrupted upload can
/// continue from [receivedBytes] instead of starting over.
@immutable
class FileUploadSession {
  const FileUploadSession({
    required this.uploadId,
    required this.chunkSize,
    required this.totalSize,
    required this.receivedBytes,
    this.expiresAt,
  });

  /// Server-side upload id.
  final String uploadId;

  /// Server-recommended chunk size in bytes.
  final int chunkSize;

  /// Total file size in bytes.
  final int totalSize;

  /// Bytes already accepted by the server.
  final int receivedBytes;

  /// ISO timestamp after which the session cannot be resumed.
  final String? expiresAt;

  /// Upload progress in the 0..1 range.
  double get progress =>
      totalSize <= 0 ? 0 : (receivedBytes / totalSize).clamp(0, 1).toDouble();

  /// Whether the server session has expired.
  bool get isExpired {
    final raw = expiresAt;
    if (raw == null) return false;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return false;
    return DateTime.now().toUtc().isAfter(parsed.toUtc());
  }

  /// Returns a copy with an updated [receivedBytes].
  FileUploadSession copyWith({int? receivedBytes}) {
    return FileUploadSession(
      uploadId: uploadId,
      chunkSize: chunkSize,
      totalSize: totalSize,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      expiresAt: expiresAt,
    );
  }
}

/// Repository responsible for reading a file from the device,
/// splitting it into chunks, and uploading it to the server.
///
/// The upload is resumable: if a previous [FileUploadSession] is supplied,
/// the server status is queried and the transfer continues from the bytes the
/// server already has.
class FileRepository {
  final FileApi api;

  FileRepository(this.api);

  /// Uploads [file], resuming from [resumeFrom] when possible.
  ///
  /// [onProgress] reports real progress (received bytes / total bytes).
  /// [onAttempt] reports the automatic retry counter for the current chunk.
  /// [onSession] exposes the current session so the caller can persist it.
  Future<FileResponse> uploadFile(
    File file, {
    FileUploadSession? resumeFrom,
    void Function(double progress)? onProgress,
    void Function(int attempt, int maxAttempts)? onAttempt,
    void Function(FileUploadSession session)? onSession,
  }) async {
    try {
      final totalSize = await file.length();
      if (totalSize <= 0) {
        throw ApiException(
          message: 'File is empty',
          type: ApiErrorType.unknown,
        );
      }

      final resumedSession = await _resumeSession(totalSize, resumeFrom);
      var session = resumedSession ?? await _initSession(file, totalSize);

      onSession?.call(session);
      onProgress?.call(session.progress);

      final raf = await file.open();
      try {
        var offset = session.receivedBytes.clamp(0, totalSize);

        while (offset < totalSize) {
          final end = math.min(offset + session.chunkSize, totalSize);
          final length = end - offset;

          await raf.setPosition(offset);
          final chunk = await raf.read(length);
          if (chunk.length != length) {
            throw ApiException(
              message: 'Read error: expected $length bytes, got ${chunk.length}',
              type: ApiErrorType.unknown,
            );
          }

          final newOffset = await _sendChunk(
            session: session,
            offset: offset,
            bytes: chunk,
            onAttempt: onAttempt,
          );

          if (newOffset <= offset) {
            throw ApiException(
              message: 'Upload did not advance from offset $offset',
              type: ApiErrorType.unknown,
            );
          }

          session = session.copyWith(receivedBytes: math.min(newOffset, totalSize));
          offset = session.receivedBytes;
          onSession?.call(session);
          onProgress?.call(session.progress);
        }
      } finally {
        await raf.close();
      }

      return await _completeUpload(session, onAttempt);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDio(e);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Tries to resume [previous] by asking the server how many bytes it has.
  Future<FileUploadSession?> _resumeSession(
    int totalSize,
    FileUploadSession? previous,
  ) async {
    if (previous == null) return null;
    if (previous.totalSize != totalSize || previous.isExpired) return null;

    final status = await _statusOrNull(previous.uploadId);
    if (status == null) return null;
    if (status.status != AppConstants.uploadStatusPending) return null;
    if (status.totalSize != totalSize) return null;
    if (status.receivedBytes >= totalSize) return null;

    return FileUploadSession(
      uploadId: status.uploadId,
      chunkSize: status.chunkSize > 0 ? status.chunkSize : previous.chunkSize,
      totalSize: status.totalSize,
      receivedBytes: status.receivedBytes,
      expiresAt: status.expiresAt ?? previous.expiresAt,
    );
  }

  /// Creates a new upload session for [file].
  Future<FileUploadSession> _initSession(File file, int totalSize) async {
    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes).toString();

    final response = await api.initUpload(
      InitUploadRequest(
        name: file.uri.pathSegments.last,
        source: AppConstants.fileSourceLabTest,
        totalSize: totalSize,
        contentHash: hash,
      ),
    );

    if (!response.success) throw response.error!;
    final body = response.body;
    if (body == null) {
      throw ApiException(
        message: 'Upload session was not created',
        type: ApiErrorType.unknown,
      );
    }

    return FileUploadSession(
      uploadId: body.uploadId,
      chunkSize: body.chunkSize > 0 ? body.chunkSize : AppConstants.fileChunkSize,
      totalSize: body.totalSize > 0 ? body.totalSize : totalSize,
      receivedBytes: body.receivedBytes,
      expiresAt: body.expiresAt,
    );
  }

  /// Sends one chunk and retries up to [AppConstants.maxUploadChunkRetries].
  ///
  /// After a failed attempt the server status is queried; if the server has
  /// already accepted part of the chunk, the new offset is returned so the
  /// caller can continue from there.
  Future<int> _sendChunk({
    required FileUploadSession session,
    required int offset,
    required List<int> bytes,
    void Function(int attempt, int maxAttempts)? onAttempt,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= AppConstants.maxUploadChunkRetries; attempt++) {
      onAttempt?.call(attempt, AppConstants.maxUploadChunkRetries);
      try {
        final response = await api.uploadChunk(
          session.uploadId,
          offset,
          MultipartFile.fromBytes(bytes, filename: 'chunk'),
        );
        if (!response.success) throw response.error!;
        return response.body?.receivedBytes ?? (offset + bytes.length);
      } catch (e) {
        lastError = e;
        if (attempt >= AppConstants.maxUploadChunkRetries) break;

        await Future<void>.delayed(
          Duration(milliseconds: AppConstants.uploadRetryBackoffMs * attempt),
        );

        final status = await _statusOrNull(session.uploadId);
        if (status != null && status.receivedBytes != offset) {
          return status.receivedBytes;
        }
      }
    }

    if (lastError is ApiException) throw lastError;
    throw ApiException(
      message: lastError?.toString() ?? 'Upload chunk failed',
      type: ApiErrorType.unknown,
    );
  }

  /// Completes the session, retrying a few times on transient failures.
  Future<FileResponse> _completeUpload(
    FileUploadSession session,
    void Function(int attempt, int maxAttempts)? onAttempt,
  ) async {
    Object? lastError;

    for (var attempt = 1; attempt <= AppConstants.maxUploadChunkRetries; attempt++) {
      onAttempt?.call(attempt, AppConstants.maxUploadChunkRetries);
      try {
        final response = await api.completeUpload(session.uploadId);
        if (!response.success) throw response.error!;
        final body = response.body;
        if (body == null) {
          throw ApiException(
            message: 'Upload completed without a file',
            type: ApiErrorType.unknown,
          );
        }
        return body;
      } catch (e) {
        lastError = e;
        if (attempt >= AppConstants.maxUploadChunkRetries) break;
        await Future<void>.delayed(
          Duration(milliseconds: AppConstants.uploadRetryBackoffMs * attempt),
        );
      }
    }

    if (lastError is ApiException) throw lastError;
    throw ApiException(
      message: lastError?.toString() ?? 'Failed to complete upload',
      type: ApiErrorType.unknown,
    );
  }

  /// Reads the server status or returns null when the session is gone.
  Future<UploadStatus?> _statusOrNull(String uploadId) async {
    try {
      final response = await api.getUploadStatus(uploadId);
      if (!response.success) return null;
      return response.body;
    } catch (_) {
      return null;
    }
  }
}

/// Riverpod provider for [FileRepository].
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = FileApi(apiClient.dio);
  return FileRepository(api);
});
