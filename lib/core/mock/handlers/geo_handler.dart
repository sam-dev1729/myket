import 'package:dio/dio.dart';

import '../mock_storage.dart';
import 'mock_handler.dart';

/// Mock handler for Geo endpoints (countries, provinces, cities).
///
/// **Sprint 14 fix:** responses are now `{ meta, data }` paginated
/// envelopes — matching the real backend shape. This ensures mock mode
/// and real mode share the same parser contract in `GeoApi`.
class GeoHandler extends MockHandler {
  @override
  bool matches(String method, String path) {
    if (method != 'GET') return false;
    return path == '/geo/country' || path == '/geo/province' || path == '/geo/city';
  }

  @override
  Future<ResponseBody> handle(RequestOptions options) async {
    await Future.delayed(const Duration(milliseconds: 80));

    final storage = MockStorage.instance..ensureSeeded();
    final path = options.path;

    if (path == '/geo/country') {
      final list = storage.countries.map((c) => c.toJson()).toList();
      return mockSuccess(_paginated(list));
    }

    if (path == '/geo/province') {
      final countryId = _qs(options, 'country_id');
      var provinces = storage.provinces;
      if (countryId != null) {
        provinces = provinces.where((p) => p.countryId == countryId).toList();
      }
      return mockSuccess(_paginated(provinces.map((p) => p.toJson()).toList()));
    }

    if (path == '/geo/city') {
      final provinceId = _qs(options, 'province_id');
      var cities = storage.cities;
      if (provinceId != null) {
        cities = cities.where((c) => c.provinceId == provinceId).toList();
      }
      return mockSuccess(_paginated(cities.map((c) => c.toJson()).toList()));
    }

    return mockError(
      statusCode: 404,
      code: 'MOCK_NOT_FOUND',
      message: 'No mock handler for ${options.method} $path',
    );
  }
}

/// Wraps a list in the `{ meta, data }` pagination envelope expected by
/// the real backend's `/geo/*` endpoints.
Map<String, dynamic> _paginated(List<Map<String, dynamic>> data) {
  return {
    'meta': {
      'total': data.length,
      'page': 1,
      'limit': data.length,
      'total_page': 1,
    },
    'data': data,
  };
}

/// Reads a non-empty query parameter as a string.
String? _qs(RequestOptions options, String key) {
  final raw = options.queryParameters[key];
  if (raw == null) return null;
  final s = raw.toString().trim();
  return s.isEmpty ? null : s;
}