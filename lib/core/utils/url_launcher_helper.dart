import 'dart:developer' as developer;

import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Utility helper for safely opening URLs in the platform's external browser.
///
/// Centralizes the logic for:
/// - Trimming and validating URLs.
/// - Normalizing URLs that are missing a scheme (prepends `https://`).
/// - Attempting to launch and logging failures without throwing.
///
/// Using this helper avoids the well-known Android 11+ package-visibility
/// issues with `canLaunchUrl` by attempting [launchUrl] directly and
/// falling back gracefully.
class UrlLauncherHelper {
  const UrlLauncherHelper._();

  /// Safely launches [rawUrl] in the platform's default browser.
  ///
  /// Performs the following steps:
  /// 1. Trims and validates the URL.
  /// 2. Prepends `https://` if the scheme is missing.
  /// 3. Attempts to launch the URL using [LaunchMode.externalApplication].
  ///
  /// Returns `true` when the URL was successfully opened, `false` otherwise.
  static Future<bool> openExternal(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      developer.log('Attempted to open an empty URL.', name: AppConstants.logTagUrlLauncher);
      return false;
    }

    Uri uri;
    try {
      uri = Uri.parse(trimmed);
      if (!uri.hasScheme) {
        uri = Uri.parse('${AppConstants.urlSchemeHttpsPrefix}$trimmed');
      }
    } catch (e) {
      developer.log(
        'Failed to parse URL: $trimmed',
        name: AppConstants.logTagUrlLauncher,
        error: e,
      );
      return false;
    }

    try {
      final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!didLaunch) {
        developer.log('launchUrl returned false for: $uri', name: AppConstants.logTagUrlLauncher);
      }
      return didLaunch;
    } catch (e, st) {
      developer.log(
        'Exception while launching URL: $uri',
        name: AppConstants.logTagUrlLauncher,
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}
