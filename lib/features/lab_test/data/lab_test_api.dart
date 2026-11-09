import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/lab_test_models.dart';

part 'lab_test_api.g.dart';

/// Retrofit API interface for lab test operations.
@RestApi()
abstract class LabTestApi {
  factory LabTestApi(Dio dio, {String? baseUrl}) = _LabTestApi;

  /// Extracts lab test data from the provided file IDs using AI.
  @POST(AppConstants.labTestExtractEndpoint)
  Future<ApiResponse<ExtractedLabTest>> extractLabTest(@Body() ExtractLabTestRequest request);

  /// Creates a new lab test header and links the files.
  @POST(AppConstants.labTestEndpoint)
  Future<ApiResponse<CreatedLabTestResponse>> createLabTest(@Body() CreateLabTestRequest request);

  /// Saves the full category and parameter tree for a specific lab test.
  @PUT('${AppConstants.labTestEndpoint}/{id}/tree')
  Future<ApiResponse<void>> saveLabTestTree(
    @Path('id') String id,
    @Body() List<ExtractedCategory> categories,
  );

  /// Updates the header of a saved lab test (`PATCH /lab-test/{id}`).
  @PATCH('${AppConstants.labTestEndpoint}/{id}')
  Future<ApiResponse<LabTestDetail>> updateLabTestHeader(
    @Path('id') String id,
    @Body() UpdateLabTestHeaderRequest request,
  );

  /// Creates a new empty category on a lab test.
  @POST('${AppConstants.labTestEndpoint}/{id}${AppConstants.labTestCategoryEndpoint}')
  Future<ApiResponse<LabTestDetailCategory>> createCategory(
    @Path('id') String id,
    @Body() CreateLabTestCategoryRequest request,
  );

  /// Renames a category or changes its sort order.
  @PATCH(
      '${AppConstants.labTestEndpoint}/{id}${AppConstants.labTestCategoryEndpoint}/{categoryId}')
  Future<ApiResponse<LabTestDetailCategory>> updateCategory(
    @Path('id') String id,
    @Path('categoryId') String categoryId,
    @Body() UpdateLabTestCategoryRequest request,
  );

  /// Deletes a category and all its parameters (cascade).
  @DELETE(
      '${AppConstants.labTestEndpoint}/{id}${AppConstants.labTestCategoryEndpoint}/{categoryId}')
  Future<ApiResponse<DeleteLabTestCategoryResponse>> deleteCategory(
    @Path('id') String id,
    @Path('categoryId') String categoryId,
  );

  /// Creates a new parameter under a category.
  @POST('${AppConstants.labTestEndpoint}/{id}${AppConstants.labTestParameterEndpoint}')
  Future<ApiResponse<LabTestDetailParameter>> createParameter(
    @Path('id') String id,
    @Body() CreateLabTestParameterRequest request,
  );

  /// Updates a parameter (name, value, unit, range, flag, sort_order, category_id, analyte_id).
  @PATCH(
      '${AppConstants.labTestEndpoint}/{id}${AppConstants.labTestParameterEndpoint}/{parameterId}')
  Future<ApiResponse<LabTestDetailParameter>> updateParameter(
    @Path('id') String id,
    @Path('parameterId') String parameterId,
    @Body() UpdateLabTestParameterRequest request,
  );

  /// Deletes a single parameter.
  @DELETE(
      '${AppConstants.labTestEndpoint}/{id}${AppConstants.labTestParameterEndpoint}/{parameterId}')
  Future<ApiResponse<void>> deleteParameter(
    @Path('id') String id,
    @Path('parameterId') String parameterId,
  );

  /// Fetches the list of saved lab tests for the current user.
  @GET(AppConstants.labTestEndpoint)
  Future<ApiResponse<List<LabTestHeader>>> getLabTests();

  /// Fetches the full detail (header + files + categories + parameters)
  /// for a single lab test.
  @GET('${AppConstants.labTestEndpoint}/{id}')
  Future<ApiResponse<LabTestDetail>> getLabTestDetail(@Path('id') String id);

  /// Deletes a saved lab test and cascades its files, categories, and
  /// parameters on the backend.
  ///
  /// Returns `ApiResponse<void>` because the delete response body carries
  /// no data the client needs — this also avoids the invalid
  /// `Map.fromJson` call that `retrofit_generator` would otherwise emit
  /// for `ApiResponse<Map<String, dynamic>>`. This matches the pattern
  /// used by `deleteAllergy` in `catalog_api.dart`.
  @DELETE('${AppConstants.labTestEndpoint}/{id}')
  Future<ApiResponse<void>> deleteLabTest(@Path('id') String id);

    /// Fetches the AI-driven health overview (overall status + key markers +
  /// disease risk + advice) for the authenticated user.
  @GET(AppConstants.labTestHealthEndpoint)
  Future<ApiResponse<HealthOverview>> getHealthOverview();
  /// Fetches the results overview: overall status + up to 10 latest mapped
  /// parameters + AI advice placeholder.
  @GET(AppConstants.labTestOverviewEndpoint)
  Future<ApiResponse<LabOverview>> getLabOverview();

  /// Fetches the paginated full list of latest mapped parameters.
  @GET(AppConstants.labTestParametersEndpoint)
  Future<ApiResponse<PaginatedLabOverviewParameters>> getLabOverviewParameters({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });
    /// Fetches the paginated list of catalog analytes that appear on the
  /// current user's lab tests. Use the returned `id`s in
  /// [getLabSeriesRequest]/`POST /lab-test/series`.
  @GET(AppConstants.labTestAnalytesEndpoint)
  Future<ApiResponse<PaginatedUserAnalytes>> getUserAnalytes({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  /// Fetches time series for one or more analytes.
  @POST(AppConstants.labTestSeriesEndpoint)
  Future<ApiResponse<LabSeriesResponse>> getLabSeries(@Body() SeriesRequest request);
}