import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/google_auth_service.dart';
import 'auth_api.dart';
import 'models/auth_models.dart';

/// Repository for managing authentication data from the backend.
class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  /// Sends an OTP to the given [mobile] number.
  Future<void> sendOtp(String mobile) async {
    final response = await api.sendOtp(SendOtpRequest(mobile: mobile));
    if (!response.success) throw response.error!;
  }

  /// Validates the [otp] for the given [mobile] number.
  Future<ValidateOtpResponse> validateOtp(String mobile, String otp) async {
    final response = await api.validateOtp(ValidateOtpRequest(mobile: mobile, otp: otp));
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Registers a new patient, optionally linking a Google account.
  Future<ValidateOtpResponse> registerPatient(
    String token,
    String mobile,
    String firstName,
    String lastName, {
    String? birthDate,
    bool? isMale,
    GoogleAuthResult? googleAuthResult,
  }) async {
    final response = await api.registerPatient(
      RegisterPatientRequest(
        registrationToken: token,
        mobile: mobile,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        isMale: isMale,
        googleOpenId: googleAuthResult?.openId,
        googleEmail: googleAuthResult?.email,
        googleFirstName: googleAuthResult?.firstName,
        googleLastName: googleAuthResult?.lastName,
      ),
    );
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Logs in via Google.
  Future<ValidateOtpResponse> loginWithGoogle(String googleOpenId, String googleEmail) async {
    final response = await api.loginWithGoogle(
      GoogleLoginRequest(googleOpenId: googleOpenId, googleEmail: googleEmail),
    );
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Refreshes the access token.
  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await api.refreshToken('${AppConstants.bearerPrefix}$refreshToken');
    if (!response.success) throw response.error!;
    return response.body!.accessToken;
  }
}

/// Riverpod provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = AuthApi(apiClient.dio);
  return AuthRepository(api);
});
