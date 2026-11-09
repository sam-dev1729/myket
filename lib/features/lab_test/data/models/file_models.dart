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

  const InitUploadResponse({
    required this.uploadId,
    required this.chunkSize,
    required this.totalSize,
  });

  factory InitUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$InitUploadResponseFromJson(json);
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
