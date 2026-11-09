import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/geo_models.dart';

part 'geo_api.g.dart';

/// Retrofit API interface for location and ethnicity data.
///
/// All `/geo/*` list endpoints return `{ meta, data }`; the repository
/// unwraps `.data` before returning `List<...>` to callers.
@RestApi()
abstract class GeoApi {
  factory GeoApi(Dio dio, {String? baseUrl}) = _GeoApi;

  // ── Location ──
  @GET(AppConstants.geoCountryEndpoint)
  Future<ApiResponse<PaginatedCountries>> getCountries(
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
  );

  @GET(AppConstants.geoProvinceEndpoint)
  Future<ApiResponse<PaginatedProvinces>> getProvinces(
    @Query('country_id') String? countryId,
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
  );

  @GET(AppConstants.geoCityEndpoint)
  Future<ApiResponse<PaginatedCities>> getCities({
    @Query('province_id') String? provinceId,
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  // ── Ethnicity ──
  @GET(AppConstants.geoInternationalEthnicityEndpoint)
  Future<ApiResponse<PaginatedInternationalEthnicities>> getInternationalEthnicities(
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
  );

  @GET(AppConstants.geoLocalEthnicityEndpoint)
  Future<ApiResponse<PaginatedLocalEthnicities>> getLocalEthnicities({
    @Query('international_ethnicity_id') String? internationalEthnicityId,
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
  });
}
