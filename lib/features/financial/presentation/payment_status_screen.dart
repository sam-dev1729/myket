import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';

/// Screen shown after returning from a payment gateway (via deep link or
/// direct navigation), displaying success / pending / failed state.
class PaymentStatusScreen extends StatelessWidget {
  /// Raw status string from the URL (e.g. `success`, `pending`, `failed`).
  final String status;

  /// Creates a [PaymentStatusScreen] instance.
  const PaymentStatusScreen({super.key, required this.status});

  /// Returns `true` when the payment succeeded.
  bool get _isSuccess => status.toLowerCase() == AppConstants.paymentStatusSuccess;

  /// Returns `true` when the payment is pending.
  bool get _isPending => status.toLowerCase() == AppConstants.paymentStatusPending;

  /// Builds the screen UI.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final color = _isSuccess
        ? AppTheme.success
        : _isPending
        ? AppTheme.warning
        : AppTheme.error;

    final icon = _isSuccess
        ? Icons.check_circle
        : _isPending
        ? Icons.hourglass_bottom
        : Icons.cancel;

    final title = _isSuccess
        ? l10n.paymentStatusSuccessTitle
        : _isPending
        ? l10n.paymentStatusPendingTitle
        : l10n.paymentStatusFailedTitle;

    final message = _isSuccess
        ? l10n.paymentStatusSuccessMessage
        : _isPending
        ? l10n.paymentStatusPendingMessage
        : l10n.paymentStatusFailedMessage;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: AppConstants.paymentStatusIconSize),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondaryColor),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              SizedBox(
                width: double.infinity,
                height: AppConstants.financialButtonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go(AppConstants.mainRoute),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: Text(
                    l10n.paymentStatusBackHomeButton,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
