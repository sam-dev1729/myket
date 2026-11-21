import 'package:json_annotation/json_annotation.dart';

part 'file_models.g.dart';

/// Request body to initialize a chunked file upload.
@JsonSerializable()
class InitUploadRequest {
  /// The original name of the file (e.g., lab.pdf).
  final String name;

  /// The source of the file (e.g., LAB_TEST).
  final String source;

  /// The total size of the file in bytes.
  @JsonKey(name: 'total_size')
  final int totalSize;

  /// Optional SHA-256 hash of the file content for integrity.
  @JsonKey(name: 'content_hash')
  final String? contentHash;

  const InitUploadRequest({
    required this.name,
    required this.source,
    required this.totalSize,
    this.contentHash,
  });

  Map<String, dynamic> toJson() => _$InitUploadRequestToJson(this);
}

/// Response received after initializing an upload session.
@JsonSerializable()
class InitUploadResponse {
  /// The unique identifier for this upload session.
  @JsonKey(name: 'upload_id')
  final String uploadId;

  /// The recommended chunk size in bytes.
  @JsonKey(name: 'chunk_size')
  final int chunkSize;

  /// The total size of the file.
  @JsonKey(name: 'total_size')
  final int totalSize;

  /// Bytes already received for this session (0 for a new upload).
  @JsonKey(name: 'received_bytes', defaultValue: 0)
  final int receivedBytes;

  /// ISO timestamp after which the session can no longer be resumed.
  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  const InitUploadResponse({
    required this.uploadId,
    required this.chunkSize,
    required this.totalSize,
    this.receivedBytes = 0,
    this.expiresAt,
  });

  factory InitUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$InitUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InitUploadResponseToJson(this);
}

/// Current state of an in-progress upload session
/// (`GET /file/upload/{upload_id}`).
@JsonSerializable()
class UploadStatus {
  /// Upload session id.
  @JsonKey(name: 'upload_id')
  final String uploadId;

  /// Original file name.
  final String name;

  /// File source (e.g. `LAB_TEST`).
  final String source;

  /// Backend status (e.g. `PENDING`, `COMPLETED`).
  final String status;

  /// Total file size in bytes.
  @JsonKey(name: 'total_size')
  final int totalSize;

  /// Bytes already received by the server.
  @JsonKey(name: 'received_bytes')
  final int receivedBytes;

  /// Server-recommended chunk size.
  @JsonKey(name: 'chunk_size')
  final int chunkSize;

  /// ISO timestamp after which the session cannot be resumed.
  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  const UploadStatus({
    required this.uploadId,
    required this.name,
    required this.source,
    required this.status,
    required this.totalSize,
    required this.receivedBytes,
    required this.chunkSize,
    this.expiresAt,
  });

  factory UploadStatus.fromJson(Map<String, dynamic> json) => _$UploadStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UploadStatusToJson(this);
}

/// Response body of `PUT /file/upload/{upload_id}` after appending a chunk.
@JsonSerializable()
class UploadChunkResponse {
  /// Upload session id.
  @JsonKey(name: 'upload_id')
  final String uploadId;

  /// Total bytes received so far.
  @JsonKey(name: 'received_bytes')
  final int receivedBytes;

  /// Total file size.
  @JsonKey(name: 'total_size')
  final int totalSize;

  /// Whether all bytes have been received.
  final bool complete;

  const UploadChunkResponse({
    required this.uploadId,
    required this.receivedBytes,
    required this.totalSize,
    required this.complete,
  });

  factory UploadChunkResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadChunkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadChunkResponseToJson(this);
}

/// Response received after completing an upload.
@JsonSerializable()
class FileResponse {
  /// The unique identifier of the uploaded file.
  final String id;

  /// The URL to access or download the file.
  final String url;

  /// The original name of the file.
  @JsonKey(name: 'originalName')
  final String originalName;

  const FileResponse({required this.id, required this.url, required this.originalName});

  factory FileResponse.fromJson(Map<String, dynamic> json) => _$FileResponseFromJson(json);
}
