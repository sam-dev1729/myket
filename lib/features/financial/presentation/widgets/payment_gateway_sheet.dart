import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../package_controller.dart';

/// Bottom sheet that lets the user select a payment gateway.
///
/// Pops with either [AppConstants.gatewayZarinpal] or
/// [AppConstants.gatewayAp] as the result, or `null` on cancel.
class PaymentGatewaySheet extends ConsumerWidget {
  /// Creates a [PaymentGatewaySheet] instance.
  const PaymentGatewaySheet({super.key});

  /// Builds the sheet UI.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final gatewayAsync = ref.watch(gatewayStatusProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: gatewayAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppConstants.paddingLarge),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.paymentGatewayErrorTitle}: $e'),
              const SizedBox(height: AppConstants.paddingMedium),
              TextButton(
                onPressed: () => ref.invalidate(gatewayStatusProvider),
                child: Text(l10n.paymentGatewayRetryButton),
              ),
            ],
          ),
          data: (status) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.paymentGatewaySheetTitle,
                style: const TextStyle(
                  fontSize: AppConstants.largeAmountFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              _GatewayTile(
                label: l10n.paymentGatewayZarinpal,
                enabled: status.zarinpal,
                disabledLabel: l10n.paymentGatewayDisabledLabel,
                onTap: () => Navigator.pop(context, AppConstants.gatewayZarinpal),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              _GatewayTile(
                label: l10n.paymentGatewayAp,
                enabled: status.ap,
                disabledLabel: l10n.paymentGatewayDisabledLabel,
                onTap: () => Navigator.pop(context, AppConstants.gatewayAp),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.paymentGatewayCancelButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single tappable tile representing a payment gateway.
class _GatewayTile extends StatelessWidget {
  /// Human-readable label.
  final String label;

  /// Whether this gateway is currently enabled.
  final bool enabled;

  /// Label to show when this gateway is disabled.
  final String disabledLabel;

  /// Called when the tile is tapped and the gateway is enabled.
  final VoidCallback onTap;

  /// Creates a [_GatewayTile] instance.
  const _GatewayTile({
    required this.label,
    required this.enabled,
    required this.disabledLabel,
    required this.onTap,
  });

  /// Builds the tile UI.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(color: context.appDividerColor),
      ),
      title: Text(label),
      trailing: enabled
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : Text(disabledLabel, style: const TextStyle(color: AppTheme.error, fontSize: 12)),
      onTap: enabled ? onTap : null,
    );
  }
}
