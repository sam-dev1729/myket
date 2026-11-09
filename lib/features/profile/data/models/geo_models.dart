import 'package:json_annotation/json_annotation.dart';

// Shared pagination metadata (PaginationMeta).
import '../../../financial/data/models/common_models.dart';

part 'geo_models.g.dart';

// ─────────────────────────────────────────────────────────────
// Location (Country → Province → City)
// ─────────────────────────────────────────────────────────────

/// Represents a Country in the Geo API.
@JsonSerializable()
class Country {
  final String id;
  final String name;

  const Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);
}

/// Represents a Province in the Geo API.
@JsonSerializable()
class Province {
  final String id;
  final String name;

  @JsonKey(name: 'country_id')
  final String countryId;

  const Province({required this.id, required this.name, required this.countryId});

  factory Province.fromJson(Map<String, dynamic> json) => _$ProvinceFromJson(json);
  Map<String, dynamic> toJson() => _$ProvinceToJson(this);
}

/// Represents a City in the Geo API.
@JsonSerializable()
class City {
  final String id;
  final String name;

  @JsonKey(name: 'province_id')
  final String provinceId;

  const City({required this.id, required this.name, required this.provinceId});

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}

// ─────────────────────────────────────────────────────────────
// Ethnicity (International → Local)
// ─────────────────────────────────────────────────────────────

/// International (top-level) ethnicity — e.g. "Iranian".
@JsonSerializable()
class InternationalEthnicity {
  final String id;
  final String name;

  const InternationalEthnicity({required this.id, required this.name});

  factory InternationalEthnicity.fromJson(Map<String, dynamic> json) =>
      _$InternationalEthnicityFromJson(json);
  Map<String, dynamic> toJson() => _$InternationalEthnicityToJson(this);
}

/// Local (child) ethnicity — e.g. "Persian", "Kurd", "Azeri".
///
/// Includes `international_ethnicity` when the backend has loaded the
/// parent relation (it usually does for `/geo/local-ethnicity`).
@JsonSerializable(explicitToJson: true)
class LocalEthnicity {
  final String id;
  final String name;

  @JsonKey(name: 'international_ethnicity')
  final InternationalEthnicity? internationalEthnicity;

  const LocalEthnicity({required this.id, this.name = '', this.internationalEthnicity});

  factory LocalEthnicity.fromJson(Map<String, dynamic> json) => _$LocalEthnicityFromJson(json);
  Map<String, dynamic> toJson() => _$LocalEthnicityToJson(this);
}

// ─────────────────────────────────────────────────────────────
// Paginated wrappers
//
// All `/geo/*` list endpoints return `{ meta, data }` — see
// 07_Api_swagger.json. The repository extracts `.data` before
// returning plain `List<...>` to callers.
// ─────────────────────────────────────────────────────────────

@JsonSerializable(explicitToJson: true)
class PaginatedCountries {
  final PaginationMeta meta;
  final List<Country> data;
  const PaginatedCountries({required this.meta, required this.data});
  factory PaginatedCountries.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCountriesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedCountriesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginatedProvinces {
  final PaginationMeta meta;
  final List<Province> data;
  const PaginatedProvinces({required this.meta, required this.data});
  factory PaginatedProvinces.fromJson(Map<String, dynamic> json) =>
      _$PaginatedProvincesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedProvincesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginatedCities {
  final PaginationMeta meta;
  final List<City> data;
  const PaginatedCities({required this.meta, required this.data});
  factory PaginatedCities.fromJson(Map<String, dynamic> json) => _$PaginatedCitiesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedCitiesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginatedInternationalEthnicities {
  final PaginationMeta meta;
  final List<InternationalEthnicity> data;
  const PaginatedInternationalEthnicities({required this.meta, required this.data});
  factory PaginatedInternationalEthnicities.fromJson(Map<String, dynamic> json) =>
      _$PaginatedInternationalEthnicitiesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedInternationalEthnicitiesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginatedLocalEthnicities {
  final PaginationMeta meta;
  final List<LocalEthnicity> data;
  const PaginatedLocalEthnicities({required this.meta, required this.data});
  factory PaginatedLocalEthnicities.fromJson(Map<String, dynamic> json) =>
      _$PaginatedLocalEthnicitiesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedLocalEthnicitiesToJson(this);
}
