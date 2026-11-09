// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) =>
    Country(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Province _$ProvinceFromJson(Map<String, dynamic> json) => Province(
  id: json['id'] as String,
  name: json['name'] as String,
  countryId: json['country_id'] as String,
);

Map<String, dynamic> _$ProvinceToJson(Province instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'country_id': instance.countryId,
};

City _$CityFromJson(Map<String, dynamic> json) => City(
  id: json['id'] as String,
  name: json['name'] as String,
  provinceId: json['province_id'] as String,
);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'province_id': instance.provinceId,
};

InternationalEthnicity _$InternationalEthnicityFromJson(
  Map<String, dynamic> json,
) => InternationalEthnicity(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$InternationalEthnicityToJson(
  InternationalEthnicity instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

LocalEthnicity _$LocalEthnicityFromJson(Map<String, dynamic> json) =>
    LocalEthnicity(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      internationalEthnicity: json['international_ethnicity'] == null
          ? null
          : InternationalEthnicity.fromJson(
              json['international_ethnicity'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LocalEthnicityToJson(LocalEthnicity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'international_ethnicity': instance.internationalEthnicity?.toJson(),
    };

PaginatedCountries _$PaginatedCountriesFromJson(Map<String, dynamic> json) =>
    PaginatedCountries(
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedCountriesToJson(PaginatedCountries instance) =>
    <String, dynamic>{
      'meta': instance.meta.toJson(),
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

PaginatedProvinces _$PaginatedProvincesFromJson(Map<String, dynamic> json) =>
    PaginatedProvinces(
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((e) => Province.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedProvincesToJson(PaginatedProvinces instance) =>
    <String, dynamic>{
      'meta': instance.meta.toJson(),
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

PaginatedCities _$PaginatedCitiesFromJson(Map<String, dynamic> json) =>
    PaginatedCities(
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PaginatedCitiesToJson(PaginatedCities instance) =>
    <String, dynamic>{
      'meta': instance.meta.toJson(),
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

PaginatedInternationalEthnicities _$PaginatedInternationalEthnicitiesFromJson(
  Map<String, dynamic> json,
) => PaginatedInternationalEthnicities(
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>)
      .map((e) => InternationalEthnicity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedInternationalEthnicitiesToJson(
  PaginatedInternationalEthnicities instance,
) => <String, dynamic>{
  'meta': instance.meta.toJson(),
  'data': instance.data.map((e) => e.toJson()).toList(),
};

PaginatedLocalEthnicities _$PaginatedLocalEthnicitiesFromJson(
  Map<String, dynamic> json,
) => PaginatedLocalEthnicities(
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
  data: (json['data'] as List<dynamic>)
      .map((e) => LocalEthnicity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaginatedLocalEthnicitiesToJson(
  PaginatedLocalEthnicities instance,
) => <String, dynamic>{
  'meta': instance.meta.toJson(),
  'data': instance.data.map((e) => e.toJson()).toList(),
};
