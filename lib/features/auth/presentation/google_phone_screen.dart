import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/error_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

/// A screen to collect the user's phone number after they sign in with Google,
/// but their Google account is not yet linked to a registered mobile number.
class GooglePhoneScreen extends ConsumerStatefulWidget {
  const GooglePhoneScreen({super.key});

  @override
  ConsumerState<GooglePhoneScreen> createState() => _GooglePhoneScreenState();
}

class _GooglePhoneScreenState extends ConsumerState<GooglePhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitClicked() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim();

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
            duration: AppConstants.snackbarDuration,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.phoneNumber, style: context.textTheme.headlineLarge),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                l10n.enterPhoneNumber,
                style: context.textTheme.bodyLarge?.copyWith(color: context.textSecondaryColor),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  hintText: l10n.phoneHint,
                  prefixIcon: const Icon(Icons.phone, color: AppTheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: AppConstants.borderWidthFocused,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),

              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading ? null : _onSubmitClicked,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: AppTheme.white)
                      : Text(
                          l10n.sendOtp,
                          style: context.textTheme.titleLarge?.copyWith(color: AppTheme.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
