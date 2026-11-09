import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/error_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

/// Implementation of [SmsRetriever] using the [SmartAuth] package.
class SmsRetrieverImpl implements SmsRetriever {
  /// Creates an [SmsRetrieverImpl] instance.
  const SmsRetrieverImpl(this.smartAuth);

  /// The underlying [SmartAuth] instance.
  final SmartAuth smartAuth;

  @override
  Future<void> dispose() => smartAuth.removeSmsRetrieverApiListener();

  @override
  Future<String?> getSmsCode() async {
    final res = await smartAuth.getSmsWithRetrieverApi();
    if (res.hasData && res.requireData.code != null) {
      return res.requireData.code;
    }
    return null;
  }

  @override
  bool get listenForMultipleSms => false;
}

/// The OTP Verification screen.
class VerificationScreen extends ConsumerStatefulWidget {
  /// The phone number that received the OTP.
  final String phoneNumber;

  /// Creates a [VerificationScreen] instance.
  const VerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  Timer? _timer;
  int _start = AppConstants.otpTimerSeconds;
  bool _isResending = false;
  late final SmsRetrieverImpl _smsRetriever;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _smsRetriever = SmsRetrieverImpl(SmartAuth.instance);
  }

  /// Starts the OTP-resend countdown timer.
  void _startTimer() {
    _timer?.cancel();
    setState(() => _start = AppConstants.otpTimerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    _smsRetriever.dispose();
    super.dispose();
  }

  /// Handles the "verify" button tap.
  Future<void> _onVerifyClicked() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pinController.text.length < AppConstants.otpLength) return;

    await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(widget.phoneNumber, _pinController.text);

    if (!mounted) return;
    final state = ref.read(authControllerProvider);

    if (state.status == AuthStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verificationSuccess)));
      context.go(AppConstants.mainRoute);
    } else if (state.status == AuthStatus.newUser) {
      final token = state.registrationToken;
      if (token == null || token.isEmpty) {
        // Defensive: backend returned `newUser` without a token. This can
        // happen if the account was partially deleted, or the backend
        // forgot to include the token. Show an error instead of freezing.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.networkError), backgroundColor: AppTheme.error));
        _pinController.clear();
        return;
      }
      context.push(
        AppConstants.signUpRoute,
        extra: {AppConstants.extraKeyToken: token, AppConstants.extraKeyPhone: widget.phoneNumber},
      );
    } else if (state.status == AuthStatus.error) {
      final errorMessage =
          state.errorMessage ?? state.error?.getLocalizedMessage(l10n) ?? l10n.networkError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: AppTheme.error));
      _pinController.clear();
    }
  }

  /// Handles the "resend" button tap.
  Future<void> _onResendClicked() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isResending = true);

    await ref.read(authControllerProvider.notifier).sendOtp(widget.phoneNumber);

    if (!mounted) return;
    setState(() => _isResending = false);

    final state = ref.read(authControllerProvider);

    if (state.status == AuthStatus.otpSent) {
      if (state.otpStillValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.otpStillValid), backgroundColor: AppTheme.warning),
        );
      } else {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.otpSentAgain), backgroundColor: AppTheme.success),
        );
      }
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

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: context.textPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: context.appDividerColor),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              Text(
                l10n.otpTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                l10n.otpSubtitle(widget.phoneNumber),
                style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),
              Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    controller: _pinController,
                    length: AppConstants.otpLength,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyDecorationWith(
                      border: Border.all(color: AppTheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    smsRetriever: _smsRetriever,
                    onCompleted: (_) => _onVerifyClicked(),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading ? null : _onVerifyClicked,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                    ),
                  ),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: AppTheme.black)
                      : Text(
                          l10n.verifyButton,
                          style: TextStyle(
                            fontSize: 18,
                            color: context.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const Spacer(),
              Center(child: _buildResendWidget(l10n, authState)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the resend-code widget (timer or button).
  Widget _buildResendWidget(AppLocalizations l10n, AuthState authState) {
    if (_isResending) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_start > 0) {
      return Text(
        l10n.resendIn(_start.toString()),
        style: TextStyle(color: context.textSecondaryColor),
      );
    }
    return TextButton(
      onPressed: authState.status == AuthStatus.loading ? null : _onResendClicked,
      child: Text(
        l10n.resendCode,
        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
