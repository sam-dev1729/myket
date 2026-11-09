import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/app_constants.dart';

/// Result of a Google Sign-In attempt containing the user's Google identifiers.
class GoogleAuthResult {
  final String openId;
  final String email;
  final String? firstName;
  final String? lastName;

  const GoogleAuthResult({
    required this.openId,
    required this.email,
    this.firstName,
    this.lastName,
  });
}

/// Custom exception thrown when Google Sign-In fails due to platform issues.
class GoogleAuthException implements Exception {
  final String message;
  const GoogleAuthException(this.message);
}

/// Service responsible for handling Google Authentication on the device.
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: AppConstants.googleWebClientId,
  );

  /// Initiates the Google Sign-In flow.
  /// Throws a [GoogleAuthException] if the platform fails.
  Future<GoogleAuthResult?> signIn() async {
    try {
      // 1. Try to sign out to force the account picker to show up.
      // We wrap this in a separate try-catch because if Google Play Services
      // is missing/broken, signOut() will throw an exception and we don't want
      // to block the sign-in attempt.
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        developer.log(
          'Google Sign-In signOut failed (possibly missing GMS), continuing...',
          name: 'GoogleAuth',
          error: e,
        );
      }

      developer.log('Attempting Google Sign-In...', name: 'GoogleAuth');

      // 2. Attempt the actual sign-in
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        developer.log('Google Sign-In cancelled by user.', name: 'GoogleAuth');
        return null;
      }

      final nameParts = account.displayName?.trim().split(' ') ?? [];
      final firstName = nameParts.isNotEmpty ? nameParts.first : null;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

      return GoogleAuthResult(
        openId: account.id,
        email: account.email,
        firstName: firstName,
        lastName: lastName,
      );
    } on PlatformException catch (e) {
      developer.log(
        'Google Sign-In PlatformException: ${e.code} - ${e.message}',
        name: 'GoogleAuth',
      );

      // Handle missing Google Play Services
      if (e.code == 'sign_in_failed' && e.message?.contains('missing') == true) {
        throw const GoogleAuthException(
          'Google Play Services is missing. Please install it to use Google Sign-In.',
        );
      }

      // Handle Network Error (ApiException: 7)
      if (e.code == 'network_error' || e.message?.contains('ApiException: 7') == true) {
        throw const GoogleAuthException(
          'Network error. Please check your VPN/Internet and try again.',
        );
      }

      // Handle other GMS errors (like SERVICE_INVALID)
      if (e.message?.contains('SERVICE_INVALID') == true) {
        throw const GoogleAuthException(
          'Google Play Services is invalid on this device/emulator. Please use a real device or a proper emulator.',
        );
      }

      // Handle Developer Error (ApiException: 10) - SHA-1 mismatch
      if (e.message?.contains('ApiException: 10') == true) {
        throw const GoogleAuthException(
          'Developer Error: Please check your SHA-1 fingerprint and Client ID.',
        );
      }

      throw GoogleAuthException(e.message ?? 'Google Sign-In failed.');
    } catch (e) {
      developer.log('Google Sign-In error: $e', name: 'GoogleAuth', error: e);
      throw GoogleAuthException(e.toString());
    }
  }

  /// Signs the user out from the Google session.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      developer.log('Error during Google signOut: $e', name: 'GoogleAuth');
    }
  }
}

/// Riverpod provider for [GoogleAuthService].
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});
