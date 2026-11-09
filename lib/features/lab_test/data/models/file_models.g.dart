// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitUploadRequest _$InitUploadRequestFromJson(Map<String, dynamic> json) =>
    InitUploadRequest(
      name: json['name'] as String,
      source: json['source'] as String,
      totalSize: (json['total_size'] as num).toInt(),
      contentHash: json['content_hash'] as String?,
    );

Map<String, dynamic> _$InitUploadRequestToJson(InitUploadRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'source': instance.source,
      'total_size': instance.totalSize,
      'content_hash': instance.contentHash,
    };

InitUploadResponse _$InitUploadResponseFromJson(Map<String, dynamic> json) =>
    InitUploadResponse(
      uploadId: json['upload_id'] as String,
      chunkSize: (json['chunk_size'] as num).toInt(),
      totalSize: (json['total_size'] as num).toInt(),
    );

Map<String, dynamic> _$InitUploadResponseToJson(InitUploadResponse instance) =>
    <String, dynamic>{
      'upload_id': instance.uploadId,
      'chunk_size': instance.chunkSize,
      'total_size': instance.totalSize,
    };

FileResponse _$FileResponseFromJson(Map<String, dynamic> json) => FileResponse(
  id: json['id'] as String,
  url: json['url'] as String,
  originalName: json['originalName'] as String,
);

Map<String, dynamic> _$FileResponseToJson(FileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'originalName': instance.originalName,
    };
