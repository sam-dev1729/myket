import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'file_api.dart';
import 'models/file_models.dart';

/// Repository responsible for reading a file from the device,
/// splitting it into chunks, and uploading it to the server.
class FileRepository {
  final FileApi api;

  FileRepository(this.api);

  /// Uploads a file using the chunked upload protocol.
  ///
  /// Returns the [FileResponse] containing the `file_id` upon success.
  /// The [onProgress] callback can be used to update the UI.
  Future<FileResponse> uploadFile(File file, {void Function(double)? onProgress}) async {
    try {
      // 1. Read file and calculate total size and hash.
      final int totalSize = await file.length();
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes).toString();

      // 2. Initialize the upload session.
      final initResponse = await api.initUpload(
        InitUploadRequest(
          name: file.uri.pathSegments.last,
          source: AppConstants.fileSourceLabTest,
          totalSize: totalSize,
          contentHash: hash,
        ),
      );

      if (!initResponse.success) throw initResponse.error!;

      final uploadId = initResponse.body!.uploadId;
      final chunkSize = initResponse.body!.chunkSize;

      print("UPLOAD_START: Total Size = $totalSize, Chunk Size = $chunkSize");

      // 3. Upload chunks sequentially.
      final raf = await file.open();
      int offset = 0;

      try {
        while (offset < totalSize) {
          final int end = (offset + chunkSize < totalSize) ? offset + chunkSize : totalSize;
          final int length = end - offset;

          await raf.setPosition(offset);
          final chunkBytes = await raf.read(length);

          if (chunkBytes.length != length) {
            throw Exception("Read error: Expected $length bytes, but read ${chunkBytes.length}");
          }

          print("UPLOAD_CHUNK: Sending offset=$offset, length=$length, end=$end");

          final multipartFile = MultipartFile.fromBytes(chunkBytes, filename: 'chunk');

          // Upload the chunk.
          // 👈 اکنون offset به عنوان یک فیلد درون بدنه (Part) ارسال می‌شود.
          final chunkResponse = await api.uploadChunk(uploadId, offset, multipartFile);

          if (!chunkResponse.success) {
            print("UPLOAD_ERROR: Server rejected chunk at offset $offset");
            throw chunkResponse.error!;
          }

          offset += length;

          if (onProgress != null) {
            onProgress(offset / totalSize);
          }
        }
      } finally {
        await raf.close();
      }

      print("UPLOAD_COMPLETE: All chunks uploaded successfully.");

      // 4. Complete the upload.
      final completeResponse = await api.completeUpload(uploadId);
      if (!completeResponse.success) throw completeResponse.error!;

      return completeResponse.body!;
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
}

/// Riverpod provider for [FileRepository].
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = FileApi(apiClient.dio);
  return FileRepository(api);
});
