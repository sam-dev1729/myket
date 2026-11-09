import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/presentation/profile_controller.dart';
import 'auth_controller.dart';

/// The Splash screen shown on app startup.
///
/// Redirects the user to either the main screen or the login screen
/// depending on their authentication state.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a [SplashScreen] instance.
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// Waits for the configured delay and then decides where to navigate.
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: AppConstants.splashDelaySeconds));

    if (!mounted) return;

    final isLoggedIn = await ref.read(authControllerProvider.notifier).isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      context.go(AppConstants.loginRoute);
      return;
    }

    try {
      await ref
          .refresh(profileControllerProvider.future)
          .timeout(const Duration(seconds: AppConstants.splashTimeoutSeconds));
      if (!mounted) return;
      context.go(AppConstants.mainRoute);
    } on DioException catch (e) {
      if (!mounted) return;
      final apiError = e.error as ApiException?;
      if (apiError?.type == ApiErrorType.timeout ||
          apiError?.type == ApiErrorType.noInternet ||
          apiError?.type == ApiErrorType.unknown) {
        context.go(AppConstants.mainRoute);
      } else {
        context.go(AppConstants.loginRoute);
      }
    } catch (_) {
      if (!mounted) return;
      context.go(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.authBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DNA Icon Placeholder
            const Icon(Icons.biotech, color: AppTheme.logoPurple, size: 100),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              l10n.appName,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: AppTheme.logoPurple,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
