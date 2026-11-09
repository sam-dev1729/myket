import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/file_models.dart';

part 'file_api.g.dart';

/// Retrofit API interface for file upload endpoints.
@RestApi()
abstract class FileApi {
  factory FileApi(Dio dio, {String? baseUrl}) = _FileApi;

  /// Initializes a chunked upload session.
  @POST(AppConstants.fileUploadInitEndpoint)
  Future<ApiResponse<InitUploadResponse>> initUpload(@Body() InitUploadRequest request);

  /// Uploads a specific chunk of the file.
  /// Uses multipart form data, sending both the offset and the file chunk.
  @PUT('${AppConstants.fileUploadBaseEndpoint}/{upload_id}')
  @MultiPart() // 👈 تغییر یافت: M و P بزرگ
  Future<ApiResponse<void>> uploadChunk(
    @Path('upload_id') String uploadId,
    @Part(name: 'offset') int offset,
    @Part(name: 'chunk') MultipartFile chunk,
  );

  /// Completes the upload session and promotes it to a permanent file.
  @POST('${AppConstants.fileUploadBaseEndpoint}/{upload_id}/complete')
  Future<ApiResponse<FileResponse>> completeUpload(@Path('upload_id') String uploadId);
}
