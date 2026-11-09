import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/package_models.dart';
import 'package_controller.dart';
import 'widgets/amount_formatter.dart';

/// Screen that lists all purchasable packages and lets the user start
/// a purchase flow.
class PackagesScreen extends ConsumerWidget {
  /// Creates a [PackagesScreen] instance.
  const PackagesScreen({super.key});

  /// Builds the screen UI.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(packagesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packagesScreenTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(packagesControllerProvider.notifier).refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                const SizedBox(height: AppConstants.paddingMedium),
                Text('${l10n.packagesErrorTitle}: $e', textAlign: TextAlign.center),
                const SizedBox(height: AppConstants.paddingMedium),
                ElevatedButton(
                  onPressed: () => ref.read(packagesControllerProvider.notifier).refresh(),
                  child: Text(l10n.packagesRetryButton),
                ),
              ],
            ),
          ),
          data: (packages) {
            if (packages.isEmpty) {
              return Center(child: Text(l10n.packagesEmpty));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: packages.length,
              itemBuilder: (_, i) => _PackageCard(package: packages[i], l10n: l10n),
            );
          },
        ),
      ),
    );
  }
}

/// A single package card.
class _PackageCard extends StatelessWidget {
  /// Package to display.
  final PackageModel package;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Creates a [_PackageCard] instance.
  const _PackageCard({required this.package, required this.l10n});

  /// Builds the package card UI.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.financialCardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  package.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  package.type,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (package.description != null && package.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(package.description!, style: TextStyle(color: context.textSecondaryColor)),
          ],
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: context.textTertiaryColor),
              const SizedBox(width: 4),
              Text(
                l10n.packagesDurationDays(package.durationDays),
                style: TextStyle(color: context.textSecondaryColor, fontSize: 12),
              ),
              const Spacer(),
              Text(
                l10n.currencyTomanWithAmount(AmountFormatter.toTomanNaked(package.price)),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          SizedBox(
            width: double.infinity,
            height: AppConstants.financialButtonHeightSmall,
            child: ElevatedButton(
              onPressed: () => context.push(AppConstants.buyPackageRoute, extra: package.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.packagesBuyButton, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
