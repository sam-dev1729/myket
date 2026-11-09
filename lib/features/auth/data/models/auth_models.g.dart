// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendOtpRequest _$SendOtpRequestFromJson(Map<String, dynamic> json) =>
    SendOtpRequest(mobile: json['mobile'] as String);

Map<String, dynamic> _$SendOtpRequestToJson(SendOtpRequest instance) =>
    <String, dynamic>{'mobile': instance.mobile};

ValidateOtpRequest _$ValidateOtpRequestFromJson(Map<String, dynamic> json) =>
    ValidateOtpRequest(
      mobile: json['mobile'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$ValidateOtpRequestToJson(ValidateOtpRequest instance) =>
    <String, dynamic>{'mobile': instance.mobile, 'otp': instance.otp};

ValidateOtpResponse _$ValidateOtpResponseFromJson(Map<String, dynamic> json) =>
    ValidateOtpResponse(
      isRegistered: json['is_registered'] as bool,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      registrationToken: json['registration_token'] as String?,
      registrationTokenExpiresAt:
          json['registration_token_expires_at'] as String?,
    );

Map<String, dynamic> _$ValidateOtpResponseToJson(
  ValidateOtpResponse instance,
) => <String, dynamic>{
  'is_registered': instance.isRegistered,
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'user': instance.user,
  'registration_token': instance.registrationToken,
  'registration_token_expires_at': instance.registrationTokenExpiresAt,
};

RegisterPatientRequest _$RegisterPatientRequestFromJson(
  Map<String, dynamic> json,
) => RegisterPatientRequest(
  mobile: json['mobile'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  birthDate: json['birth_date'] as String?,
  isMale: json['is_male'] as bool?,
  registrationToken: json['registration_token'] as String,
  googleOpenId: json['google_open_id'] as String?,
  googleEmail: json['google_email'] as String?,
  googleEmailVerified: json['google_email_verified'] as bool?,
  googleFirstName: json['google_first_name'] as String?,
  googleLastName: json['google_last_name'] as String?,
  googlePicture: json['google_picture'] as String?,
  googleLocale: json['google_locale'] as String?,
  profileUrl: json['profile_url'] as String?,
);

Map<String, dynamic> _$RegisterPatientRequestToJson(
  RegisterPatientRequest instance,
) => <String, dynamic>{
  'mobile': instance.mobile,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'birth_date': ?instance.birthDate,
  'is_male': ?instance.isMale,
  'registration_token': instance.registrationToken,
  'google_open_id': ?instance.googleOpenId,
  'google_email': ?instance.googleEmail,
  'google_email_verified': ?instance.googleEmailVerified,
  'google_first_name': ?instance.googleFirstName,
  'google_last_name': ?instance.googleLastName,
  'google_picture': ?instance.googlePicture,
  'google_locale': ?instance.googleLocale,
  'profile_url': ?instance.profileUrl,
};

GoogleLoginRequest _$GoogleLoginRequestFromJson(Map<String, dynamic> json) =>
    GoogleLoginRequest(
      googleOpenId: json['google_open_id'] as String,
      googleEmail: json['google_email'] as String,
    );

Map<String, dynamic> _$GoogleLoginRequestToJson(GoogleLoginRequest instance) =>
    <String, dynamic>{
      'google_open_id': instance.googleOpenId,
      'google_email': instance.googleEmail,
    };

RefreshTokenResponse _$RefreshTokenResponseFromJson(
  Map<String, dynamic> json,
) => RefreshTokenResponse(accessToken: json['access_token'] as String);

Map<String, dynamic> _$RefreshTokenResponseToJson(
  RefreshTokenResponse instance,
) => <String, dynamic>{'access_token': instance.accessToken};
