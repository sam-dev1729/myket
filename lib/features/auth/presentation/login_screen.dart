import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/error_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

/// The Login screen of the application.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a [LoginScreen] instance.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;
  bool _termsAccepted = false;
  bool _showTermsError = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    super.dispose();
  }

  /// Validates the phone number input and updates the button state.
  void _validatePhone() {
    final isValid = RegExp(r'^09\d{9}$').hasMatch(_phoneController.text);
    if (isValid != _isPhoneValid) {
      setState(() {
        _isPhoneValid = isValid;
      });
    }
  }

  /// Handles the phone login button tap.
  Future<void> _onLoginClicked() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim();

    // Block the flow when the user hasn't accepted the terms.
    if (!_termsAccepted) {
      setState(() => _showTermsError = true);
      return;
    }

    // Reset the inline error once the user is allowed to continue.
    if (_showTermsError) {
      setState(() => _showTermsError = false);
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterPhone)));
      return;
    }

    await ref.read(authControllerProvider.notifier).sendOtp(phone);

    if (!mounted) return;
    final state = ref.read(authControllerProvider);

    if (state.status == AuthStatus.otpSent) {
      if (state.otpStillValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.otpStillValid),
            backgroundColor: AppTheme.warning,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      context.push(AppConstants.verificationRoute, extra: phone);
    } else if (state.status == AuthStatus.error) {
      final errorMessage =
          state.errorMessage ?? state.error?.getLocalizedMessage(l10n) ?? l10n.networkError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: AppTheme.error));
    }
  }

  /// Handles the Google login button tap.
  Future<void> _onGoogleLoginClicked() async {
    final l10n = AppLocalizations.of(context)!;

    // Google login also requires the terms to be accepted.
    if (!_termsAccepted) {
      setState(() => _showTermsError = true);
      return;
    }

    if (_showTermsError) {
      setState(() => _showTermsError = false);
    }

    await ref.read(authControllerProvider.notifier).loginWithGoogle();

    if (!mounted) return;
    final state = ref.read(authControllerProvider);

    if (state.status == AuthStatus.success) {
      context.go(AppConstants.mainRoute);
    } else if (state.status == AuthStatus.googleNeedsPhone) {
      context.push(AppConstants.googlePhoneRoute);
    } else if (state.status == AuthStatus.error) {
      final errorMessage =
          state.errorMessage ?? state.error?.getLocalizedMessage(l10n) ?? l10n.networkError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: AppTheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
              child: ConstrainedBox(
                // حداقل ارتفاع را برابر ارتفاع صفحه قرار می‌دهیم تا در حالت عادی صفحه پر شود
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  // 👈 به جای Spacer از MainAxisAlignment.center استفاده می‌کنیم
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.biotech, color: context.colorScheme.secondary, size: 80),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: context.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),

                    Text(
                      l10n.enterPhoneNumber,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Phone Input Row (forced LTR)
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Container(
                          height: 55,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                          ),
                          child: Row(
                            children: [
                              const Text("🇮🇷", style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              const Text("+98", style: TextStyle(fontWeight: FontWeight.bold)),
                              const Icon(Icons.keyboard_arrow_down, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: context.surfaceColor,
                              borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              decoration: InputDecoration(
                                hintText: l10n.loginPhonePlaceholder,
                                hintStyle: TextStyle(color: context.textTertiaryColor),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    Text(
                      l10n.or,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: authState.status == AuthStatus.loading
                            ? null
                            : _onGoogleLoginClicked,
                        icon: const Icon(Icons.g_mobiledata, size: 32, color: AppTheme.info),
                        label: Text(
                          l10n.continueWithGoogle,
                          style: TextStyle(fontSize: 16, color: context.textPrimaryColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: context.surfaceColor.withValues(alpha: 0.5),
                          side: BorderSide(color: context.surfaceColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXLarge), // جایگزین Spacer
                    // Terms acceptance checkbox + label
                    Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                              if (_termsAccepted) _showTermsError = false;
                            });
                          },
                          activeColor: context.colorScheme.secondary,
                          checkColor: context.colorScheme.onSecondary,
                          side: BorderSide(color: context.textSecondaryColor, width: 1.5),
                        ),
                        Expanded(
                          child: Text(
                            l10n.termsAcceptanceText,
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                        ),
                      ],
                    ),
                    if (_showTermsError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.termsAcceptanceError,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: (!_isPhoneValid || authState.status == AuthStatus.loading)
                            ? null
                            : _onLoginClicked,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPhoneValid
                              ? context.colorScheme.secondary
                              : context.appDividerColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                          ),
                          elevation: 0,
                        ),
                        child: authState.status == AuthStatus.loading
                            ? CircularProgressIndicator(color: context.colorScheme.onSecondary)
                            : Text(
                                l10n.loginOrSignupButton,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _isPhoneValid ? context.colorScheme.onSecondary : context.textTertiaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
