import 'package:json_annotation/json_annotation.dart';
import 'geo_models.dart';

part 'user_profile.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfile {
  final String id;
  final String? role;
  final String mobile;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  @JsonKey(name: 'is_male')
  final bool? isMale;
  final int? height;
  final int? weight;
  @JsonKey(name: 'is_pregnant')
  final bool? isPregnant;
  @JsonKey(name: 'blood_type')
  final String? bloodType;
  final CityInfo? city;
  @JsonKey(name: 'underlying_diseases')
  final List<LinkedItem>? underlyingDiseases;
  @JsonKey(name: 'medical_histories')
  final List<LinkedItem>? medicalHistories;
  final List<LinkedItem>? allergies;
  @JsonKey(name: 'local_ethnicity')
  final LocalEthnicity? localEthnicity;
  @JsonKey(name: 'google_accounts')
  final List<GoogleAccount>? googleAccounts;

  const UserProfile({
    required this.id,
    this.role,
    required this.mobile,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.isMale,
    this.height,
    this.weight,
    this.isPregnant,
    this.bloodType,
    this.city,
    this.underlyingDiseases,
    this.medicalHistories,
    this.allergies,
    this.localEthnicity,
    this.googleAccounts,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  @JsonKey(name: 'first_name', includeIfNull: false)
  final String? firstName;
  @JsonKey(name: 'last_name', includeIfNull: false)
  final String? lastName;
  @JsonKey(name: 'birth_date', includeIfNull: false)
  final String? birthDate;
  @JsonKey(name: 'is_male', includeIfNull: false)
  final bool? isMale;
  @JsonKey(includeIfNull: false)
  final int? height;
  @JsonKey(includeIfNull: false)
  final int? weight;
  @JsonKey(name: 'is_pregnant', includeIfNull: false)
  final bool? isPregnant;
  @JsonKey(name: 'blood_type', includeIfNull: false)
  final String? bloodType;
  @JsonKey(name: 'city_id', includeIfNull: false)
  final String? cityId;
  @JsonKey(name: 'local_ethnicity_id', includeIfNull: false)
  final String? localEthnicityId;

  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.birthDate,
    this.isMale,
    this.height,
    this.weight,
    this.isPregnant,
    this.bloodType,
    this.cityId,
    this.localEthnicityId,
  });

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable()
class CityInfo {
  final String id;
  final String? name;
  @JsonKey(name: 'province_id')
  final String? provinceId;
  const CityInfo({required this.id, this.name, this.provinceId});
  factory CityInfo.fromJson(Map<String, dynamic> json) => _$CityInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CityInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LinkedItem {
  final String id;
  final MedicalCatalogItem? allergy;
  @JsonKey(name: 'underlying_disease')
  final MedicalCatalogItem? underlyingDisease;
  @JsonKey(name: 'medical_history')
  final MedicalCatalogItem? medicalHistory;
  const LinkedItem({required this.id, this.allergy, this.underlyingDisease, this.medicalHistory});
  factory LinkedItem.fromJson(Map<String, dynamic> json) => _$LinkedItemFromJson(json);
  Map<String, dynamic> toJson() => _$LinkedItemToJson(this);
}

@JsonSerializable()
class MedicalCatalogItem {
  final String id;
  final String name;
  @JsonKey(name: 'is_system')
  final bool? isSystem;
  const MedicalCatalogItem({required this.id, required this.name, this.isSystem});
  factory MedicalCatalogItem.fromJson(Map<String, dynamic> json) =>
      _$MedicalCatalogItemFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalCatalogItemToJson(this);
}

@JsonSerializable()
class GoogleAccount {
  final String id;
  @JsonKey(name: 'google_email')
  final String? email;
  @JsonKey(name: 'google_first_name')
  final String? firstName;
  @JsonKey(name: 'google_picture')
  final String? picture;
  const GoogleAccount({required this.id, this.email, this.firstName, this.picture});
  factory GoogleAccount.fromJson(Map<String, dynamic> json) => _$GoogleAccountFromJson(json);
  Map<String, dynamic> toJson() => _$GoogleAccountToJson(this);
}
