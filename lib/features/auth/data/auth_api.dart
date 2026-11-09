import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/auth_models.dart';

part 'auth_api.g.dart';

/// Retrofit API interface for authentication endpoints.
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// Sends an OTP to the given mobile number.
  @POST(AppConstants.sendOtpEndpoint)
  Future<ApiResponse<dynamic>> sendOtp(@Body() SendOtpRequest request);

  /// Validates the OTP for the given mobile number.
  @POST(AppConstants.validateOtpEndpoint)
  Future<ApiResponse<ValidateOtpResponse>> validateOtp(
      @Body() ValidateOtpRequest request);

  /// Registers a new patient with the backend.
  @POST(AppConstants.registerPatientEndpoint)
  Future<ApiResponse<ValidateOtpResponse>> registerPatient(
      @Body() RegisterPatientRequest request);

  /// Logs in a user via Google Sign-In.
  @POST(AppConstants.loginWithGoogleEndpoint)
  Future<ApiResponse<ValidateOtpResponse>> loginWithGoogle(
      @Body() GoogleLoginRequest request);

  /// Refreshes the access token using the refresh token.
  /// 
  /// **Important**: The refresh token MUST be sent as a Bearer token in the
  /// `Authorization` header, NOT in the request body.
  @POST(AppConstants.refreshTokenEndpoint)
  Future<ApiResponse<RefreshTokenResponse>> refreshToken(
      @Header(AppConstants.headerAuthorization) String bearerToken);
}