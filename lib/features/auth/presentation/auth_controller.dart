import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';

/// Represents the different states of the authentication flow.
enum AuthStatus { initial, loading, otpSent, success, googleNeedsPhone, newUser, error }

/// Specific error types for the UI to display localized messages.
enum AuthError { invalidOtp, network, timeout, noInternet, serverError, unknown, sendOtpFailed }

/// The state model for [AuthController].
class AuthState {
  final AuthStatus status;
  final AuthError? error;
  final String? errorMessage;
  final String? registrationToken;
  final bool otpStillValid;
  final GoogleAuthResult? googleAuthResult;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.errorMessage,
    this.registrationToken,
    this.otpStillValid = false,
    this.googleAuthResult,
  });
}

/// Controller responsible for managing the entire authentication flow.
class AuthController extends Notifier<AuthState> {
  late final TokenStorage _tokenStorage;
  late final GoogleAuthService _googleAuthService;

  @override
  AuthState build() {
    _tokenStorage = ref.read(tokenStorageProvider);
    _googleAuthService = ref.read(googleAuthServiceProvider);
    return const AuthState();
  }

  /// Checks whether the user is currently logged in.
  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Extracts an [ApiException] from a [DioException].
  ///
  /// If the [DioException] carries no typed error (e.g. a raw timeout), we
  /// fall back to [ApiException.fromDio] which maps the
  /// [DioExceptionType] to an [ApiErrorType] — so callers see `timeout` or
  /// `noInternet` instead of the generic `unknown`.
  ApiException _extractApiError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException.fromDio(e);
  }

  /// Initiates the Google Sign-In flow.
  Future<void> loginWithGoogle() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final googleResult = await _googleAuthService.signIn();
      if (googleResult == null) {
        state = const AuthState(status: AuthStatus.initial);
        return;
      }

      final repository = ref.read(authRepositoryProvider);
      final response = await repository.loginWithGoogle(googleResult.openId, googleResult.email);

      if (response.isRegistered && response.accessToken != null && response.refreshToken != null) {
        await _tokenStorage.saveTokens(response.accessToken!, response.refreshToken!);
        state = AuthState(status: AuthStatus.success, googleAuthResult: googleResult);
      } else {
        // Per API: `is_registered: false` means the Google account is not yet
        // linked. The user must complete OTP for a mobile number first.
        state = AuthState(status: AuthStatus.googleNeedsPhone, googleAuthResult: googleResult);
      }
    } on GoogleAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: AuthError.unknown,
        errorMessage: e.message,
      );
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.error, error: _mapApiError(e), errorMessage: e.message);
    } on DioException catch (e) {
      final apiError = _extractApiError(e);
      state = AuthState(
        status: AuthStatus.error,
        error: _mapApiError(apiError),
        errorMessage: apiError.message,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.error, error: AuthError.unknown);
    }
  }

  /// Sends an OTP to the provided [mobile] number.
  Future<void> sendOtp(String mobile) async {
    final currentGoogleData = state.googleAuthResult;
    state = AuthState(status: AuthStatus.loading, googleAuthResult: currentGoogleData);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.sendOtp(mobile);
      state = AuthState(status: AuthStatus.otpSent, googleAuthResult: currentGoogleData);
    } on ApiException catch (e) {
      if (e.code == AppConstants.errorCodeOtpNotExpired) {
        state = AuthState(
          status: AuthStatus.otpSent,
          otpStillValid: true,
          googleAuthResult: currentGoogleData,
        );
        return;
      }
      state = AuthState(
        status: AuthStatus.error,
        error: _mapApiError(e),
        errorMessage: e.message,
        googleAuthResult: currentGoogleData,
      );
    } on DioException catch (e) {
      final apiError = _extractApiError(e);
      if (apiError.code == AppConstants.errorCodeOtpNotExpired) {
        state = AuthState(
          status: AuthStatus.otpSent,
          otpStillValid: true,
          googleAuthResult: currentGoogleData,
        );
        return;
      }
      state = AuthState(
        status: AuthStatus.error,
        error: _mapApiError(apiError),
        errorMessage: apiError.message,
        googleAuthResult: currentGoogleData,
      );
    } catch (_) {
      state = AuthState(
        status: AuthStatus.error,
        error: AuthError.unknown,
        googleAuthResult: currentGoogleData,
      );
    }
  }

  /// Verifies the OTP and handles the response.
  Future<void> verifyOtp(String mobile, String otp) async {
    final currentGoogleData = state.googleAuthResult;
    state = AuthState(status: AuthStatus.loading, googleAuthResult: currentGoogleData);

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.validateOtp(mobile, otp);

      if (response.isRegistered && response.accessToken != null && response.refreshToken != null) {
        await _tokenStorage.saveTokens(response.accessToken!, response.refreshToken!);
        state = AuthState(status: AuthStatus.success, googleAuthResult: currentGoogleData);
      } else {
        state = AuthState(
          status: AuthStatus.newUser,
          registrationToken: response.registrationToken,
          googleAuthResult: currentGoogleData,
        );
      }
    } on ApiException catch (e) {
      if (e.code == AppConstants.errorCodeOtpInvalid) {
        state = AuthState(
          status: AuthStatus.error,
          error: AuthError.invalidOtp,
          errorMessage: e.message,
          googleAuthResult: currentGoogleData,
        );
      } else {
        state = AuthState(
          status: AuthStatus.error,
          error: _mapApiError(e),
          errorMessage: e.message,
          googleAuthResult: currentGoogleData,
        );
      }
    } on DioException catch (e) {
      final apiError = _extractApiError(e);
      if (apiError.code == AppConstants.errorCodeOtpInvalid) {
        state = AuthState(
          status: AuthStatus.error,
          error: AuthError.invalidOtp,
          errorMessage: apiError.message,
          googleAuthResult: currentGoogleData,
        );
      } else {
        state = AuthState(
          status: AuthStatus.error,
          error: _mapApiError(apiError),
          errorMessage: apiError.message,
          googleAuthResult: currentGoogleData,
        );
      }
    } catch (_) {
      state = AuthState(
        status: AuthStatus.error,
        error: AuthError.unknown,
        googleAuthResult: currentGoogleData,
      );
    }
  }

  /// Registers a new patient.
  Future<void> registerPatient(
    String mobile,
    String firstName,
    String lastName, {
    String? birthDate,
    bool? isMale,
  }) async {
    final token = state.registrationToken;
    if (token == null) return;

    final currentGoogleData = state.googleAuthResult;
    state = AuthState(status: AuthStatus.loading, googleAuthResult: currentGoogleData);

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.registerPatient(
        token,
        mobile,
        firstName,
        lastName,
        birthDate: birthDate,
        isMale: isMale,
        googleAuthResult: currentGoogleData,
      );

      if (response.accessToken != null && response.refreshToken != null) {
        await _tokenStorage.saveTokens(response.accessToken!, response.refreshToken!);
      }
      state = AuthState(status: AuthStatus.success, googleAuthResult: currentGoogleData);
    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        error: _mapApiError(e),
        errorMessage: e.message,
        googleAuthResult: currentGoogleData,
      );
    } on DioException catch (e) {
      final apiError = _extractApiError(e);
      state = AuthState(
        status: AuthStatus.error,
        error: _mapApiError(apiError),
        errorMessage: apiError.message,
        googleAuthResult: currentGoogleData,
      );
    } catch (_) {
      state = AuthState(
        status: AuthStatus.error,
        error: AuthError.unknown,
        googleAuthResult: currentGoogleData,
      );
    }
  }

  /// Logs out the user by clearing tokens.
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    await _googleAuthService.signOut();
    state = const AuthState(status: AuthStatus.initial);
  }

  /// Maps an [ApiException] to the corresponding [AuthError].
  AuthError _mapApiError(ApiException e) {
    switch (e.type) {
      case ApiErrorType.timeout:
        return AuthError.timeout;
      case ApiErrorType.noInternet:
        return AuthError.noInternet;
      case ApiErrorType.server:
        return AuthError.serverError;
      default:
        return AuthError.network;
    }
  }
}

/// Riverpod provider for [AuthController].
final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
