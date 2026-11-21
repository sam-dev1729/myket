import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/network/api_exception.dart';
import 'package:myket/core/network/api_response.dart';
import 'package:myket/features/lab_test/data/file_api.dart';
import 'package:myket/features/lab_test/data/file_repository.dart';
import 'package:myket/features/lab_test/data/models/file_models.dart';

void main() {
  late Directory tempDir;
  late File file;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lab_upload_test');
    file = File('${tempDir.path}/report.pdf');
    await file.writeAsBytes(List<int>.generate(10, (index) => index));
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('resumes a partial upload from the server received_bytes', () async {
    final api = _FakeFileApi(totalSize: 10, chunkSize: 4, serverReceived: 4);
    final repository = FileRepository(api);

    final response = await repository.uploadFile(
      file,
      resumeFrom: const FileUploadSession(
        uploadId: 'upload-1',
        chunkSize: 4,
        totalSize: 10,
        receivedBytes: 4,
      ),
    );

    expect(response.id, 'file-1');
    expect(api.initCalls, 0);
    expect(api.chunkOffsets, [4, 8]);
    expect(api.completeCalls, 1);
  });

  test('starts a new session when the previous one is expired', () async {
    final api = _FakeFileApi(totalSize: 10, chunkSize: 4);
    final repository = FileRepository(api);

    await repository.uploadFile(
      file,
      resumeFrom: FileUploadSession(
        uploadId: 'upload-1',
        chunkSize: 4,
        totalSize: 10,
        receivedBytes: 4,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)).toUtc().toIso8601String(),
      ),
    );

    expect(api.initCalls, 1);
    expect(api.chunkOffsets, [0, 4, 8]);
  });

  test('retries a failed chunk and continues from the same offset', () async {
    await file.writeAsBytes(List<int>.generate(8, (index) => index));
    final api = _FakeFileApi(
      totalSize: 8,
      chunkSize: 4,
      failFirstChunk: true,
    );
    final repository = FileRepository(api);
    final attempts = <int>[];

    await repository.uploadFile(
      file,
      onAttempt: (attempt, _) => attempts.add(attempt),
    );

    expect(api.chunkOffsets, [0, 0, 4]);
    expect(attempts, containsAllInOrder([1, 2, 1]));
    expect(api.completeCalls, 1);
  });

  test('reports real progress from received bytes', () async {
    await file.writeAsBytes(List<int>.generate(8, (index) => index));
    final api = _FakeFileApi(totalSize: 8, chunkSize: 4);
    final repository = FileRepository(api);
    final progress = <double>[];

    await repository.uploadFile(file, onProgress: progress.add);

    expect(progress.last, 1);
    expect(progress.any((value) => value > 0 && value < 1), isTrue);
  });
}

/// Fake [FileApi] that tracks calls and can simulate failures.
class _FakeFileApi implements FileApi {
  _FakeFileApi({
    required this.totalSize,
    required this.chunkSize,
    this.serverReceived = 0,
    this.failFirstChunk = false,
  }) : _received = serverReceived;

  final int totalSize;
  final int chunkSize;
  final int serverReceived;
  final bool failFirstChunk;

  int initCalls = 0;
  int completeCalls = 0;
  int _chunkCalls = 0;
  int _received;
  final List<int> chunkOffsets = [];

  @override
  Future<ApiResponse<InitUploadResponse>> initUpload(InitUploadRequest request) async {
    initCalls++;
    _received = 0;
    return ApiResponse(
      success: true,
      body: InitUploadResponse(
        uploadId: 'upload-1',
        chunkSize: chunkSize,
        totalSize: totalSize,
        receivedBytes: 0,
      ),
    );
  }

  @override
  Future<ApiResponse<UploadStatus>> getUploadStatus(String uploadId) async {
    final received = _received;
    return ApiResponse(
      success: true,
      body: UploadStatus(
        uploadId: uploadId,
        name: 'report.pdf',
        source: 'LAB_TEST',
        status: received >= totalSize ? 'COMPLETED' : 'PENDING',
        totalSize: totalSize,
        receivedBytes: received,
        chunkSize: chunkSize,
      ),
    );
  }

  @override
  Future<ApiResponse<UploadChunkResponse>> uploadChunk(
    String uploadId,
    int offset,
    MultipartFile chunk,
  ) async {
    _chunkCalls++;
    chunkOffsets.add(offset);
    if (failFirstChunk && _chunkCalls == 1) {
      _received = serverReceived;
      throw ApiException(message: 'temporary network error', type: ApiErrorType.noInternet);
    }

    _received = offset + chunk.length;
    return ApiResponse(
      success: true,
      body: UploadChunkResponse(
        uploadId: uploadId,
        receivedBytes: _received,
        totalSize: totalSize,
        complete: _received >= totalSize,
      ),
    );
  }

  @override
  Future<ApiResponse<FileResponse>> completeUpload(String uploadId) async {
    completeCalls++;
    return ApiResponse(
      success: true,
      body: const FileResponse(
        id: 'file-1',
        url: 'https://mock.local/file-1.pdf',
        originalName: 'report.pdf',
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
