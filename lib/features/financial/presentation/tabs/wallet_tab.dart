import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/wallet_models.dart';
import '../wallet_controller.dart';
import '../widgets/amount_formatter.dart';

/// Wallet tab showing the current balance, recent transactions, and
/// shortcuts to top-up / buy-package screens.
class WalletTab extends ConsumerWidget {
  /// Creates a [WalletTab] instance.
  const WalletTab({super.key});

  /// Builds the wallet tab UI.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final walletAsync = ref.watch(walletControllerProvider);
    final txAsync = ref.watch(transactionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walletTabTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(walletControllerProvider.notifier).refresh();
          await ref.read(transactionsControllerProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              walletAsync.when(
                loading: () =>
                    const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _ErrorCard(
                  onRetry: () => ref.read(walletControllerProvider.notifier).refresh(),
                ),
                data: (w) => _BalanceCard(wallet: w),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.walletRecentTransactionsTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppConstants.transactionsRoute),
                    child: Text(l10n.walletSeeAllButton),
                  ),
                ],
              ),
              txAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppConstants.paddingLarge),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _ErrorCard(
                  onRetry: () => ref.read(transactionsControllerProvider.notifier).refresh(),
                ),
                data: (page) {
                  final items = page.data.take(AppConstants.walletRecentTransactionCount).toList();
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingLarge),
                      child: Center(child: Text(l10n.walletNoTransactions)),
                    );
                  }
                  return Column(
                    children: items.map((tx) => _TransactionTile(tx: tx, l10n: l10n)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Balance card showing the wallet amount and top-up / buy-package shortcuts.
class _BalanceCard extends StatelessWidget {
  /// Wallet to display.
  final WalletModel wallet;

  /// Creates a [_BalanceCard] instance.
  const _BalanceCard({required this.wallet});

  /// Builds the balance card UI.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppConstants.financialCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.walletBalanceLabel,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            l10n.currencyTomanWithAmount(AmountFormatter.toTomanNaked(wallet.balance)),
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.walletBalanceFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppConstants.topupRoute),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(l10n.walletTopupButton, style: const TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppConstants.packagesRoute),
                  icon: const Icon(Icons.shopping_bag, color: Colors.white),
                  label: Text(
                    l10n.walletBuyPackageButton,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single transaction row.
class _TransactionTile extends StatelessWidget {
  /// Transaction to display.
  final WalletTransactionModel tx;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Creates a [_TransactionTile] instance.
  const _TransactionTile({required this.tx, required this.l10n});

  /// Builds the transaction row UI.
  @override
  Widget build(BuildContext context) {
    final isDeposit = tx.isDeposit;
    final color = isDeposit ? AppTheme.success : AppTheme.error;
    final sign = isDeposit ? '+' : '-';
    final title = tx.isWalletTopup
        ? l10n.transactionReasonWalletTopup
        : l10n.transactionReasonPackagePurchase;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx.createdAt),
                  style: TextStyle(color: context.textSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '$sign ${AmountFormatter.toTomanNaked(tx.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Formats an ISO date string into a localized date.
  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return DateFormat('yyyy/MM/dd HH:mm').format(d);
    } catch (_) {
      return iso;
    }
  }
}

/// Small reusable error card with a retry button.
class _ErrorCard extends StatelessWidget {
  /// Callback invoked when the user taps "retry".
  final VoidCallback onRetry;

  /// Creates an [_ErrorCard] instance.
  const _ErrorCard({required this.onRetry});

  /// Builds the error card UI.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: context.softRedBg,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error),
          const SizedBox(height: AppConstants.paddingSmall),
          TextButton(onPressed: onRetry, child: Text(l10n.genericRetryButton)),
        ],
      ),
    );
  }
}
