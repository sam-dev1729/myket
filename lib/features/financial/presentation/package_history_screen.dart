import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/package_models.dart';
import 'user_package_history_controller.dart';
import 'widgets/amount_formatter.dart';

/// Screen that shows the authenticated user's full package-purchase history
/// (`GET /user-package/history`).
///
/// Features:
/// - Pull-to-refresh
/// - Infinite scroll (load-more on scroll-to-end)
/// - Status badge per row (ACTIVE / EXPIRED / CANCELLED)
class PackageHistoryScreen extends ConsumerStatefulWidget {
  const PackageHistoryScreen({super.key});

  @override
  ConsumerState<PackageHistoryScreen> createState() => _PackageHistoryScreenState();
}

class _PackageHistoryScreenState extends ConsumerState<PackageHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.infiniteScrollThreshold) {
      ref.read(userPackageHistoryControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(userPackageHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packageHistory),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text('${l10n.genericErrorPrefix}: $e', textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.paddingSmall),
                  TextButton(
                    onPressed: () =>
                        ref.read(userPackageHistoryControllerProvider.notifier).refresh(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            if (data.items.isEmpty) {
              return Center(child: Text(l10n.packagesEmpty));
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(userPackageHistoryControllerProvider.notifier).refresh(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppConstants.screenPadding),
                itemCount: data.items.length + (data.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: AppConstants.paddingMedium),
                itemBuilder: (context, index) {
                  if (index >= data.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _PackageHistoryCard(item: data.items[index], l10n: l10n);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A single package-purchase row.
class _PackageHistoryCard extends StatelessWidget {
  final UserPackageModel item;
  final AppLocalizations l10n;

  const _PackageHistoryCard({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final title = item.package?.title ?? l10n.noData;
    final type = item.package?.type ?? '-';
    final price = item.package?.price;
    final (statusColor, statusLabel) = _statusStyle(context, item.status, l10n);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (price != null)
                Text(
                  l10n.currencyTomanWithAmount(AmountFormatter.toTomanNaked(price)),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          _InfoRow(
            icon: Icons.play_circle_outline,
            label: _formatDate(item.startsAt),
            valueColor: context.textSecondaryColor,
          ),
          _InfoRow(
            icon: Icons.stop_circle_outlined,
            label: _formatDate(item.expiresAt),
            valueColor: context.textSecondaryColor,
          ),
        ],
      ),
    );
  }

  /// Resolves the status badge (color, localized label).
  (Color, String) _statusStyle(BuildContext context, String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case AppConstants.userPackageStatusActive:
        return (AppTheme.success, l10n.packageStatusActive);
      case AppConstants.userPackageStatusExpired:
        return (context.textTertiaryColor, l10n.packageStatusExpired);
      case AppConstants.userPackageStatusCancelled:
        return (AppTheme.error, l10n.packageStatusCancelled);
      default:
        return (context.textTertiaryColor, status);
    }
  }

  /// Formats an ISO date string as `yyyy/MM/dd`, or returns it unchanged.
  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return '$y/$m/$d';
    } catch (_) {
      return iso;
    }
  }
}

/// A single icon + label row.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color valueColor;

  const _InfoRow({required this.icon, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: valueColor),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(label, style: TextStyle(fontSize: 12, color: valueColor)),
        ],
      ),
    );
  }
}
