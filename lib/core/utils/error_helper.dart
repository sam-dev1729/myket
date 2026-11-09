import '../../l10n/app_localizations.dart';
import '../../features/auth/presentation/auth_controller.dart';

/// Extension methods to map specific error enums to localized strings.
extension AuthErrorExtension on AuthError? {
  /// Returns the localized message corresponding to the [AuthError].
  String getLocalizedMessage(AppLocalizations l10n) {
    switch (this) {
      case AuthError.timeout:
        return l10n.timeoutError;
      case AuthError.noInternet:
        return l10n.noInternetError;
      case AuthError.serverError:
        return l10n.serverError;
      case AuthError.invalidOtp:
        return l10n.invalidOtpError;
      case AuthError.sendOtpFailed:
      case AuthError.network:
        return l10n.networkError;
      default:
        return l10n.networkError;
    }
  }
}