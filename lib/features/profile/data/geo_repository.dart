import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import 'geo_api.dart';
import 'models/geo_models.dart';

/// Repository for managing geographic + ethnicity data.
class GeoRepository {
  final GeoApi api;

  GeoRepository(this.api);

  // ── Location ──
  Future<List<Country>> getCountries({String? search}) async {
    final response = await api.getCountries(search, 1, AppConstants.maxPageSize);
    if (!response.success) throw response.error!;
    return response.body?.data ?? const <Country>[];
  }

  Future<List<Province>> getProvinces({String? countryId, String? search}) async {
    final response = await api.getProvinces(countryId, search, 1, AppConstants.maxPageSize);
    if (!response.success) throw response.error!;
    return response.body?.data ?? const <Province>[];
  }

  Future<List<City>> getCities({String? provinceId, String? search}) async {
    final response = await api.getCities(
      provinceId: provinceId,
      search: search,
      page: 1,
      limit: AppConstants.maxPageSize,
    );
    if (!response.success) throw response.error!;
    return response.body?.data ?? const <City>[];
  }

  // ── Ethnicity ──
  Future<List<InternationalEthnicity>> getInternationalEthnicities({String? search}) async {
    final response = await api.getInternationalEthnicities(search, 1, AppConstants.maxPageSize);
    if (!response.success) throw response.error!;
    return response.body?.data ?? const <InternationalEthnicity>[];
  }

  Future<List<LocalEthnicity>> getLocalEthnicities({
    String? internationalEthnicityId,
    String? search,
  }) async {
    final response = await api.getLocalEthnicities(
      internationalEthnicityId: internationalEthnicityId,
      search: search,
      page: 1,
      limit: AppConstants.maxPageSize,
    );
    if (!response.success) throw response.error!;
    return response.body?.data ?? const <LocalEthnicity>[];
  }
}

final geoRepositoryProvider = Provider<GeoRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = GeoApi(apiClient.dio);
  return GeoRepository(api);
});
