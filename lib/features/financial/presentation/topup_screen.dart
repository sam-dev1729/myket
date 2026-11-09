import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'wallet_controller.dart';
import 'widgets/amount_formatter.dart';
import 'widgets/payment_gateway_sheet.dart';

/// Screen that lets the user charge their wallet by choosing an amount
/// and opening a payment gateway.
class TopupScreen extends ConsumerStatefulWidget {
  /// Creates a [TopupScreen] instance.
  const TopupScreen({super.key});

  @override
  ConsumerState<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends ConsumerState<TopupScreen> {
  /// Preset top-up amounts in IRR.
  static const List<int> _presets = [
    AppConstants.topupPreset100kToman,
    AppConstants.topupPreset200kToman,
    AppConstants.topupPreset500kToman,
  ];

  int? _selectedPreset;
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  /// Returns the effective amount in IRR, or null if invalid.
  int? get _amount {
    if (_selectedPreset != null) return _selectedPreset;
    final raw = _customController.text.replaceAll(',', '').trim();
    final toman = int.tryParse(raw);
    if (toman == null || toman <= 0) return null;
    return toman * AppConstants.rialToTomanDivisor;
  }

  /// Starts the top-up flow.
  Future<void> _startTopup() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = _amount;
    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.topupAmountRequiredError)));
      return;
    }

    final gateway = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const PaymentGatewaySheet(),
    );
    if (gateway == null) return;

    await ref.read(topupControllerProvider.notifier).submit(amount, gateway: gateway);

    if (!mounted) return;
    final state = ref.read(topupControllerProvider);

    if (state.status == TopupStatus.success) {
      final url = state.response?.gatewayUrl;
      if (url == null || url.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.topupCannotOpenGatewayError)));
        }
        return;
      }
      final opened = await UrlLauncherHelper.openExternal(url);
      if (!mounted) return;
      if (opened) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.topupCannotOpenGatewayError)));
      }
    } else if (state.status == TopupStatus.error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage ?? l10n.topupUnknownError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(topupControllerProvider);
    final loading = state.status == TopupStatus.loading;
    final walletAsync = ref.watch(walletControllerProvider);
    final amount = _amount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.increaseCreditTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                child: Column(
                  children: [
                    const SizedBox(height: AppConstants.paddingLarge),

                    // ─── Current balance ───
                    Text(
                      l10n.topupCurrentBalanceLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSecondaryColor, fontSize: 14),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    walletAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => Text(
                        l10n.noData,
                        style: TextStyle(fontSize: 24, color: context.textTertiaryColor),
                      ),
                      data: (w) => Text(
                        l10n.currencyTomanWithAmount(AmountFormatter.toTomanNaked(w.balance)),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingXLarge),

                    // ─── Amount selection title ───
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.topupSelectAmountLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // ─── Preset options ───
                    ..._presets.map(
                      (p) => _RadioOptionRow(
                        label: l10n.currencyTomanWithAmount(AmountFormatter.toTomanNaked(p)),
                        isSelected: _selectedPreset == p,
                        onTap: () {
                          setState(() {
                            _selectedPreset = _selectedPreset == p ? null : p;
                            if (_selectedPreset != null) {
                              _customController.clear();
                            }
                          });
                        },
                      ),
                    ),

                    // ─── Custom amount option ───
                    _RadioOptionRow(
                      label: l10n.customAmount,
                      isSelected: _selectedPreset == null && _customController.text.isNotEmpty,
                      onTap: () {
                        setState(() {
                          _selectedPreset = null;
                        });
                      },
                    ),

                    if (_selectedPreset == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextField(
                          controller: _customController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandSeparatorFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: l10n.topupCustomAmountLabel,
                            suffixText: l10n.currencyToman,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ─── Pay button ───
            Padding(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: SizedBox(
                width: double.infinity,
                height: AppConstants.financialButtonHeight,
                child: ElevatedButton(
                  onPressed: loading || amount == null ? null : _startTopup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amount == null ? context.appDividerColor : AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: AppTheme.black)
                      : Text(
                          amount == null
                              ? l10n.payButton
                              : l10n.currencyTomanWithAmount(AmountFormatter.toTomanNaked(amount)),
                          style: TextStyle(
                            color: amount == null ? context.textTertiaryColor : AppTheme.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single radio row used in the amount-selection list.
///
/// Uses the default [Row] direction (respects RTL in Persian apps), placing
/// the radio on the leading edge and the label on the trailing side.
/// This gives a natural Persian layout — radio on the right in RTL, label
/// on the left (right-aligned toward the radio).
class _RadioOptionRow extends StatelessWidget {
  /// Text shown next to the radio.
  final String label;

  /// Whether this row is currently selected.
  final bool isSelected;

  /// Called when the row is tapped.
  final VoidCallback onTap;

  const _RadioOptionRow({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          children: [
            // Radio on the leading edge (right in RTL, left in LTR).
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : context.textTertiaryColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            // Label on the trailing side, aligned to the row's start
            // (which is the right side of the expanded area in RTL).
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [TextInputFormatter] that inserts thousands separators (`,`) as the user
/// types digits — e.g. `100000` becomes `100,000`.
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
