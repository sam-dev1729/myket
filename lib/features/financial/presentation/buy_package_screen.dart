import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'package_controller.dart';
import 'wallet_controller.dart';
import 'widgets/amount_formatter.dart';
import 'widgets/payment_gateway_sheet.dart';

/// Screen that lets the user select a package, choose to use wallet balance,
/// and proceed to payment.
class BuyPackageScreen extends ConsumerStatefulWidget {
  /// The package ID to buy (optional, if passed, it's pre-selected).
  final String? initialPackageId;

  /// Creates a [BuyPackageScreen] instance.
  const BuyPackageScreen({super.key, this.initialPackageId});

  @override
  ConsumerState<BuyPackageScreen> createState() => _BuyPackageScreenState();
}

class _BuyPackageScreenState extends ConsumerState<BuyPackageScreen> {
  String? _selectedPackageId;
  bool _useWallet = false;

  @override
  void initState() {
    super.initState();
    _selectedPackageId = widget.initialPackageId;
  }

  /// Opens the gateway picker and submits the order.
  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedPackageId == null) return;

    final gateway = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const PaymentGatewaySheet(),
    );
    if (gateway == null) return;

    await ref
        .read(buyPackageControllerProvider.notifier)
        .submit(packageId: _selectedPackageId!, useWallet: _useWallet, gateway: gateway);

    if (!mounted) return;
    final st = ref.read(buyPackageControllerProvider);

    if (st.status == BuyStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.buyPackageSuccessMessage), backgroundColor: AppTheme.success),
      );
      ref.invalidate(walletControllerProvider);
      ref.invalidate(activeUserPackagesProvider);
      Navigator.pop(context);
    } else if (st.status == BuyStatus.pending) {
      final url = st.response?.gatewayUrl;
      if (url != null && url.isNotEmpty) {
        final opened = await UrlLauncherHelper.openExternal(url);
        if (opened && mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.buyPackageNoGatewayUrlError)));
      }
    } else if (st.status == BuyStatus.error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(st.errorMessage ?? l10n.buyPackagePurchaseError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final packagesAsync = ref.watch(packagesControllerProvider);
    final walletAsync = ref.watch(walletControllerProvider);
    final buyState = ref.watch(buyPackageControllerProvider);
    final loading = buyState.status == BuyStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.buyPackageTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: packagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l10n.genericErrorPrefix}: $e')),
          data: (packages) {
            if (packages.isEmpty) {
              return Center(child: Text(l10n.packagesEmpty));
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          l10n.buyPackageSelectionTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          l10n.buyPackageSelectionSubtitle,
                          style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),

                        // List of packages
                        ...packages.map((p) {
                          final isSelected = _selectedPackageId == p.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedPackageId = p.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withValues(alpha: 0.05)
                                    : context.surfaceColor,
                                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : context.appDividerColor,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppTheme.primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.primary
                                                : context.textTertiaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: AppTheme.black,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                  if (p.description != null && p.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      p.description!,
                                      style: TextStyle(
                                        color: context.textSecondaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: AppConstants.paddingMedium),
                                  Text(
                                    l10n.currencyTomanWithAmount(
                                      AmountFormatter.toTomanNaked(p.price),
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: AppConstants.paddingMedium),

                        // Wallet Toggle
                        walletAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (w) => Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      l10n.buyPackageUseWalletLabel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      l10n.creditAmountLabel(
                                        AmountFormatter.toTomanNaked(w.balance),
                                        l10n.currencyRial,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Switch(
                                value: _useWallet,
                                onChanged: (v) => setState(() => _useWallet = v),
                                activeColor: AppTheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Pay Button
                Padding(
                  padding: const EdgeInsets.all(AppConstants.screenPadding),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppConstants.financialButtonHeight,
                    child: ElevatedButton(
                      onPressed: loading || _selectedPackageId == null ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedPackageId == null
                            ? context.appDividerColor
                            : AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                        ),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: AppTheme.black)
                          : Text(
                              _selectedPackageId == null
                                  ? l10n.buyPackageSubmitButton
                                  : l10n.buyPackagePayWithRial(
                                      AmountFormatter.toTomanNaked(
                                        packages
                                            .firstWhere((p) => p.id == _selectedPackageId)
                                            .price,
                                      ),
                                    ),
                              style: TextStyle(
                                color: _selectedPackageId == null
                                    ? context.textTertiaryColor
                                    : AppTheme.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
