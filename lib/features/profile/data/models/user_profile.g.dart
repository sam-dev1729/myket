// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String,
  role: json['role'] as String?,
  mobile: json['mobile'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  birthDate: json['birth_date'] as String?,
  isMale: json['is_male'] as bool?,
  height: (json['height'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toInt(),
  isPregnant: json['is_pregnant'] as bool?,
  bloodType: json['blood_type'] as String?,
  city: json['city'] == null
      ? null
      : CityInfo.fromJson(json['city'] as Map<String, dynamic>),
  underlyingDiseases: (json['underlying_diseases'] as List<dynamic>?)
      ?.map((e) => LinkedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  medicalHistories: (json['medical_histories'] as List<dynamic>?)
      ?.map((e) => LinkedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  allergies: (json['allergies'] as List<dynamic>?)
      ?.map((e) => LinkedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  localEthnicity: json['local_ethnicity'] == null
      ? null
      : LocalEthnicity.fromJson(
          json['local_ethnicity'] as Map<String, dynamic>,
        ),
  googleAccounts: (json['google_accounts'] as List<dynamic>?)
      ?.map((e) => GoogleAccount.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserProfileToJson(
  UserProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'role': instance.role,
  'mobile': instance.mobile,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'birth_date': instance.birthDate,
  'is_male': instance.isMale,
  'height': instance.height,
  'weight': instance.weight,
  'is_pregnant': instance.isPregnant,
  'blood_type': instance.bloodType,
  'city': instance.city?.toJson(),
  'underlying_diseases': instance.underlyingDiseases
      ?.map((e) => e.toJson())
      .toList(),
  'medical_histories': instance.medicalHistories
      ?.map((e) => e.toJson())
      .toList(),
  'allergies': instance.allergies?.map((e) => e.toJson()).toList(),
  'local_ethnicity': instance.localEthnicity?.toJson(),
  'google_accounts': instance.googleAccounts?.map((e) => e.toJson()).toList(),
};

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  birthDate: json['birth_date'] as String?,
  isMale: json['is_male'] as bool?,
  height: (json['height'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toInt(),
  isPregnant: json['is_pregnant'] as bool?,
  bloodType: json['blood_type'] as String?,
  cityId: json['city_id'] as String?,
  localEthnicityId: json['local_ethnicity_id'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'first_name': ?instance.firstName,
  'last_name': ?instance.lastName,
  'birth_date': ?instance.birthDate,
  'is_male': ?instance.isMale,
  'height': ?instance.height,
  'weight': ?instance.weight,
  'is_pregnant': ?instance.isPregnant,
  'blood_type': ?instance.bloodType,
  'city_id': ?instance.cityId,
  'local_ethnicity_id': ?instance.localEthnicityId,
};

CityInfo _$CityInfoFromJson(Map<String, dynamic> json) => CityInfo(
  id: json['id'] as String,
  name: json['name'] as String?,
  provinceId: json['province_id'] as String?,
);

Map<String, dynamic> _$CityInfoToJson(CityInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'province_id': instance.provinceId,
};

LinkedItem _$LinkedItemFromJson(Map<String, dynamic> json) => LinkedItem(
  id: json['id'] as String,
  allergy: json['allergy'] == null
      ? null
      : MedicalCatalogItem.fromJson(json['allergy'] as Map<String, dynamic>),
  underlyingDisease: json['underlying_disease'] == null
      ? null
      : MedicalCatalogItem.fromJson(
          json['underlying_disease'] as Map<String, dynamic>,
        ),
  medicalHistory: json['medical_history'] == null
      ? null
      : MedicalCatalogItem.fromJson(
          json['medical_history'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$LinkedItemToJson(LinkedItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'allergy': instance.allergy?.toJson(),
      'underlying_disease': instance.underlyingDisease?.toJson(),
      'medical_history': instance.medicalHistory?.toJson(),
    };

MedicalCatalogItem _$MedicalCatalogItemFromJson(Map<String, dynamic> json) =>
    MedicalCatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      isSystem: json['is_system'] as bool?,
    );

Map<String, dynamic> _$MedicalCatalogItemToJson(MedicalCatalogItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_system': instance.isSystem,
    };

GoogleAccount _$GoogleAccountFromJson(Map<String, dynamic> json) =>
    GoogleAccount(
      id: json['id'] as String,
      email: json['google_email'] as String?,
      firstName: json['google_first_name'] as String?,
      picture: json['google_picture'] as String?,
    );

Map<String, dynamic> _$GoogleAccountToJson(GoogleAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'google_email': instance.email,
      'google_first_name': instance.firstName,
      'google_picture': instance.picture,
    };
