import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_response.dart';
import 'models/user_profile.dart';

part 'profile_api.g.dart';

/// Retrofit API interface for all profile-related endpoints.
@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String? baseUrl}) = _ProfileApi;

  /// Fetches the authenticated user's profile.
  @GET(AppConstants.profileEndpoint)
  Future<ApiResponse<UserProfile>> getProfile();

  /// Updates the authenticated user's profile.
  @PATCH(AppConstants.profileEndpoint)
  Future<ApiResponse<UserProfile>> updateProfile(@Body() UpdateProfileRequest request);

  // --- Google Account Endpoints ---
  /// Attaches a Google account to the user's profile.
  @POST(AppConstants.profileGoogleAttachEndpoint)
  Future<ApiResponse<void>> attachGoogleAccount(@Body() Map<String, String> body);

  /// Detaches a Google account from the user's profile.
  @POST(AppConstants.profileGoogleDetachEndpoint)
  Future<ApiResponse<void>> detachGoogleAccount(@Body() Map<String, String> body);

  // --- Link Allergies ---
  @POST(AppConstants.profileAllergyAddEndpoint)
  Future<ApiResponse<void>> addAllergy(@Body() Map<String, String> body);

  @POST(AppConstants.profileAllergyRemoveEndpoint)
  Future<ApiResponse<void>> removeAllergy(@Body() Map<String, String> body);

  // --- Link Underlying Diseases ---
  @POST(AppConstants.profileDiseaseAddEndpoint)
  Future<ApiResponse<void>> addDisease(@Body() Map<String, String> body);

  @POST(AppConstants.profileDiseaseRemoveEndpoint)
  Future<ApiResponse<void>> removeDisease(@Body() Map<String, String> body);

  // --- Link Medical Histories ---
  @POST(AppConstants.profileHistoryAddEndpoint)
  Future<ApiResponse<void>> addHistory(@Body() Map<String, String> body);

  @POST(AppConstants.profileHistoryRemoveEndpoint)
  Future<ApiResponse<void>> removeHistory(@Body() Map<String, String> body);
}
