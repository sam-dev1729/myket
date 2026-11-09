import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/catalog_models.dart';

part 'catalog_api.g.dart';

/// Retrofit API interface for medical catalogs (Allergy, Disease, History).
///
/// **Sprint 14 fix:** `/allergy`, `/underlying-disease`, and
/// `/medical-history` **do not accept** `page`/`limit` query params
/// (confirmed via `07_Api_swagger.json`). Sending them results in a
/// `BAD_REQUEST` from the backend's `forbidNonWhitelisted` validator.
@RestApi()
abstract class CatalogApi {
  factory CatalogApi(Dio dio, {String? baseUrl}) = _CatalogApi;

  // --- Allergy Endpoints ---
  @GET(AppConstants.allergyCatalogEndpoint)
  Future<ApiResponse<List<CatalogItem>>> getAllergies(@Query('search') String? search);

  @POST(AppConstants.allergyCatalogEndpoint)
  Future<ApiResponse<CatalogItem>> createAllergy(@Body() CreateCatalogItemRequest request);

  @PATCH('${AppConstants.allergyCatalogEndpoint}/{id}')
  Future<ApiResponse<CatalogItem>> updateAllergy(
    @Path('id') String id,
    @Body() UpdateCatalogItemRequest request,
  );

  @DELETE('${AppConstants.allergyCatalogEndpoint}/{id}')
  Future<ApiResponse<void>> deleteAllergy(@Path('id') String id);

  // --- Underlying Disease Endpoints ---
  @GET(AppConstants.underlyingDiseaseCatalogEndpoint)
  Future<ApiResponse<List<CatalogItem>>> getDiseases(@Query('search') String? search);

  @POST(AppConstants.underlyingDiseaseCatalogEndpoint)
  Future<ApiResponse<CatalogItem>> createDisease(@Body() CreateCatalogItemRequest request);

  // --- Medical History Endpoints ---
  @GET(AppConstants.medicalHistoryCatalogEndpoint)
  Future<ApiResponse<List<CatalogItem>>> getHistories(@Query('search') String? search);

  @POST(AppConstants.medicalHistoryCatalogEndpoint)
  Future<ApiResponse<CatalogItem>> createHistory(@Body() CreateCatalogItemRequest request);
}
