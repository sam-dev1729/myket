import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/wallet_models.dart';
import 'wallet_controller.dart';
import 'widgets/amount_formatter.dart';

/// Screen that shows the full paginated history of wallet transactions.
class TransactionsScreen extends ConsumerStatefulWidget {
  /// Creates a [TransactionsScreen] instance.
  const TransactionsScreen({super.key});

  /// Creates the mutable state for this screen.
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

/// Mutable state for [TransactionsScreen].
class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Loads the next page when the user is near the end of the list.
  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - AppConstants.infiniteScrollThreshold) {
      ref.read(transactionsControllerProvider.notifier).loadMore();
    }
  }

  /// Builds the screen UI.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(transactionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionsScreenTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionsControllerProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l10n.transactionsErrorPrefix}: $e')),
          data: (page) {
            if (page.data.isEmpty) {
              return Center(child: Text(l10n.transactionsEmpty));
            }
            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: page.data.length,
              itemBuilder: (_, i) => _TransactionRow(tx: page.data[i], l10n: l10n),
            );
          },
        ),
      ),
    );
  }
}

/// A single transaction row for the history list.
/// A single transaction row for the history list.
class _TransactionRow extends StatelessWidget {
  /// Transaction to display.
  final WalletTransactionModel tx;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Creates a [_TransactionRow] instance.
  const _TransactionRow({required this.tx, required this.l10n});

  /// Builds the row UI.
  @override
  Widget build(BuildContext context) {
    final isDeposit = tx.isDeposit;
    final color = isDeposit ? AppTheme.success : AppTheme.error;
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
          Icon(isDeposit ? Icons.arrow_downward : Icons.arrow_upward, color: color),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  _formatDate(context, tx.createdAt),
                  style: TextStyle(color: context.textSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDeposit ? '+' : '-'} '
                '${AmountFormatter.toTomanNaked(tx.amount)}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                _localizedStatus(context, tx.status), // 👈 وضعیت فارسی شد
                style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Maps the transaction status string to a localized string.
  String _localizedStatus(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
        return l10n.statusSuccess;
      case 'PENDING':
        return l10n.statusPending;
      case 'FAILED':
        return l10n.statusFailed;
      case 'CANCELLED':
        return l10n.statusCancelled;
      default:
        return status;
    }
  }

  /// Formats an ISO date string into a localized date (Jalali if fa).
  String _formatDate(BuildContext context, String iso) {
    if (iso.isEmpty) return iso;
    try {
      final dt = DateTime.parse(iso).toLocal();

      if (Localizations.localeOf(context).languageCode == 'fa') {
        final j = Jalali.fromDateTime(dt);
        final month = j.month.toString().padLeft(2, '0');
        final day = j.day.toString().padLeft(2, '0');
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        return '${j.year}/$month/$day $hour:$minute';
      }

      return DateFormat('yyyy/MM/dd HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }
}
