import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

/// Request model for sending an OTP to a mobile number.
@JsonSerializable()
class SendOtpRequest {
  final String mobile;

  SendOtpRequest({required this.mobile});

  Map<String, dynamic> toJson() => _$SendOtpRequestToJson(this);
}

/// Request model for validating an OTP code.
@JsonSerializable()
class ValidateOtpRequest {
  final String mobile;
  final String otp;

  ValidateOtpRequest({required this.mobile, required this.otp});

  Map<String, dynamic> toJson() => _$ValidateOtpRequestToJson(this);
}

/// Response model for OTP validation.
@JsonSerializable()
class ValidateOtpResponse {
  @JsonKey(name: 'is_registered')
  final bool isRegistered;

  @JsonKey(name: 'access_token')
  final String? accessToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  final Map<String, dynamic>? user;

  @JsonKey(name: 'registration_token')
  final String? registrationToken;

  @JsonKey(name: 'registration_token_expires_at')
  final String? registrationTokenExpiresAt;

  ValidateOtpResponse({
    required this.isRegistered,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.registrationToken,
    this.registrationTokenExpiresAt,
  });

  factory ValidateOtpResponse.fromJson(Map<String, dynamic> json) =>
      _$ValidateOtpResponseFromJson(json);
}

/// Request model for registering a new patient.
@JsonSerializable()
class RegisterPatientRequest {
  final String mobile;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  @JsonKey(name: 'birth_date', includeIfNull: false)
  final String? birthDate;

  @JsonKey(name: 'is_male', includeIfNull: false)
  final bool? isMale;

  @JsonKey(name: 'registration_token')
  final String registrationToken;

  @JsonKey(name: 'google_open_id', includeIfNull: false)
  final String? googleOpenId;

  @JsonKey(name: 'google_email', includeIfNull: false)
  final String? googleEmail;

  @JsonKey(name: 'google_email_verified', includeIfNull: false)
  final bool? googleEmailVerified;

  @JsonKey(name: 'google_first_name', includeIfNull: false)
  final String? googleFirstName;

  @JsonKey(name: 'google_last_name', includeIfNull: false)
  final String? googleLastName;

  @JsonKey(name: 'google_picture', includeIfNull: false)
  final String? googlePicture;

  @JsonKey(name: 'google_locale', includeIfNull: false)
  final String? googleLocale;

  @JsonKey(name: 'profile_url', includeIfNull: false)
  final String? profileUrl;

  RegisterPatientRequest({
    required this.mobile,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.isMale,
    required this.registrationToken,
    this.googleOpenId,
    this.googleEmail,
    this.googleEmailVerified,
    this.googleFirstName,
    this.googleLastName,
    this.googlePicture,
    this.googleLocale,
    this.profileUrl,
  });

  Map<String, dynamic> toJson() => _$RegisterPatientRequestToJson(this);
}

/// Request model for Google login.
@JsonSerializable()
class GoogleLoginRequest {
  @JsonKey(name: 'google_open_id')
  final String googleOpenId;

  @JsonKey(name: 'google_email')
  final String googleEmail;

  GoogleLoginRequest({
    required this.googleOpenId,
    required this.googleEmail,
  });

  Map<String, dynamic> toJson() => _$GoogleLoginRequestToJson(this);
}

/// Response model for `POST /auth/refresh-token`.
/// 
/// The backend returns a new short-lived `access_token` when a valid
/// `refresh_token` is provided in the Authorization header.
@JsonSerializable()
class RefreshTokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  RefreshTokenResponse({required this.accessToken});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}