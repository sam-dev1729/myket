import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/trailing_arrow.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../financial/data/models/wallet_models.dart';
import '../../../financial/presentation/wallet_controller.dart';
import '../../../financial/presentation/widgets/amount_formatter.dart';
import '../../data/models/user_profile.dart';
import '../profile_controller.dart';

/// The Profile tab showing personal info, account status, wallet info,
/// and settings.
class ProfileTab extends ConsumerWidget {
  /// Creates a [ProfileTab] instance.
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final walletAsync = ref.watch(walletControllerProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopIconBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
                children: [
                  const SizedBox(height: AppConstants.paddingMedium),

                  // ─── Personal Info Preview Card ───
                  profileAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (profile) => _PersonalInfoCard(
                      profile: profile,
                      onViewFullTap: () => context.push(AppConstants.personalInfoRoute),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // ─── Account Status Card ───
                                    // ─── Account Status Card ───
                  _AccountStatusCard(
                    onPackageHistoryTap: () => context.push(AppConstants.packageHistoryRoute),
                    onBuyPackageTap: () => context.push(AppConstants.packagesRoute),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // ─── Wallet Card ───
                  walletAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (wallet) => _WalletCard(
                      wallet: wallet,
                      onTopupTap: () => context.push(AppConstants.topupRoute),
                      onTransactionsTap: () => context.push(AppConstants.transactionsRoute),
                      onCardInfoTap: () => context.push(AppConstants.cardInfoRoute),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // ─── Settings Card ───
                  _SettingsCard(
                    children: [
                      _ArrowLinkTile(
                        title: l10n.settingsTitle,
                        onTap: () => context.push(AppConstants.settingsRoute),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // ─── Version + Logout ───
                  _VersionTile(version: AppConstants.appVersion, isUpToDate: true),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _LogoutTile(
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(AppConstants.loginRoute);
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The top icon bar shared by tab screens.
class _TopIconBar extends StatelessWidget {
  const _TopIconBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
        vertical: AppConstants.paddingMedium,
      ),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.headset_mic_outlined,
            onTap: () => context.push(AppConstants.supportRoute),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          _CircleIconButton(
            icon: Icons.settings_outlined,
            onTap: () => context.push(AppConstants.settingsRoute),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          _CircleIconButton(
            icon: Icons.notifications_none,
            onTap: () => context.push(AppConstants.notificationsRoute),
            showBadge: true,
          ),
        ],
      ),
    );
  }
}

/// A round icon button with an optional notification badge.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _CircleIconButton({required this.icon, required this.onTap, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: context.appDividerColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: context.iconColor, size: 20)),
            if (showBadge)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A compact personal-info preview card (name, birth date, mobile) with a
/// "view full" link that opens [PersonalInfoScreen].
class _PersonalInfoCard extends StatelessWidget {
  /// The user profile to display. Null during initial loading.
  final UserProfile? profile;

  /// Called when the "view full" row is tapped.
  final VoidCallback onViewFullTap;

  const _PersonalInfoCard({required this.profile, required this.onViewFullTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, color: context.textSecondaryColor, size: 22),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  l10n.personalInfoFullTitle,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          _PersonalRow(label: l10n.fullName, value: _fullName(profile, l10n)),
          _PersonalRow(
            label: l10n.birthDateLabel,
            value: _formatBirthDate(profile?.birthDate, context, l10n),
          ),
          _PersonalRow(label: l10n.mobileLabel, value: profile?.mobile ?? l10n.noData),
          const SizedBox(height: AppConstants.paddingMedium),
          _ArrowLinkTile(title: l10n.viewFullLabel, onTap: onViewFullTap),
        ],
      ),
    );
  }

  /// Joins first+last name, falling back to "no data" if both are empty.
  String _fullName(UserProfile? p, AppLocalizations l10n) {
    final first = p?.firstName?.trim() ?? '';
    final last = p?.lastName?.trim() ?? '';
    final joined = '$first $last'.trim();
    return joined.isEmpty ? l10n.noData : joined;
  }

  /// Formats the ISO birth date as a Jalali long date in Persian
  /// (e.g. `11 دی 1374`), or falls back to ISO in other locales.
  String _formatBirthDate(String? iso, BuildContext context, AppLocalizations l10n) {
    if (iso == null || iso.isEmpty) return l10n.noData;
    try {
      final dt = DateTime.parse(iso);
      final locale = Localizations.localeOf(context);
      if (locale.languageCode == 'fa') {
        final j = Jalali.fromDateTime(dt);
        return '${j.day} ${j.formatter.mN} ${j.year}';
      }
      return iso;
    } catch (_) {
      return iso;
    }
  }
}

/// A label:value row where the label sits on the start side and the value
/// on the end side (both follow Directionality, so RTL renders naturally).
class _PersonalRow extends StatelessWidget {
  final String label;
  final String value;

  const _PersonalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Account status card showing user level and package shortcuts.
class _AccountStatusCard extends StatelessWidget {
  final VoidCallback onPackageHistoryTap;
  final VoidCallback onBuyPackageTap;

  const _AccountStatusCard({required this.onPackageHistoryTap, required this.onBuyPackageTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined, color: context.textSecondaryColor, size: 22),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  l10n.accountStatus,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            l10n.userLevelBronze,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
          ),
          const SizedBox(height: AppConstants.paddingTiny),
          Text(
            l10n.activePackages,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _ArrowLinkTile(title: l10n.packageHistory, onTap: onPackageHistoryTap),
          _ArrowLinkTile(title: l10n.buyPackageTitle, onTap: onBuyPackageTap),
        ],
      ),
    );
  }
}

/// Wallet card showing balance and shortcuts.
class _WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback onTopupTap;
  final VoidCallback onTransactionsTap;
  final VoidCallback onCardInfoTap;

  const _WalletCard({
    required this.wallet,
    required this.onTopupTap,
    required this.onTransactionsTap,
    required this.onCardInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: context.textSecondaryColor,
                size: 22,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  l10n.walletTitle,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            l10n.creditAmountLabel(
              AmountFormatter.toTomanNaked(wallet.balance),
              l10n.currencyToman,
            ),
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _ArrowLinkTile(title: l10n.increaseCreditTitle, onTap: onTopupTap),
          _ArrowLinkTile(title: l10n.transactionHistory, onTap: onTransactionsTap),
          _ArrowLinkTile(title: l10n.cardAndAccountInfo, onTap: onCardInfoTap),
        ],
      ),
    );
  }
}

/// A link row using the shared [TrailingArrow] widget so the arrow always
/// points left in RTL and right in LTR.
class _ArrowLinkTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ArrowLinkTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(title, textAlign: TextAlign.start, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: AppConstants.paddingSmall),
            TrailingArrow(color: context.textSecondaryColor),
          ],
        ),
      ),
    );
  }
}

/// A wrapper card that groups multiple rows with dividers.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        children: children
            .asMap()
            .map(
              (i, widget) => MapEntry(
                i,
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                      child: widget,
                    ),
                    if (i < children.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: AppConstants.paddingMedium,
                        endIndent: AppConstants.paddingMedium,
                        color: context.appDividerColor,
                      ),
                  ],
                ),
              ),
            )
            .values
            .toList(),
      ),
    );
  }
}

/// A tile showing the app version and an up-to-date status.
class _VersionTile extends StatelessWidget {
  final String version;
  final bool isUpToDate;

  const _VersionTile({required this.version, required this.isUpToDate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Row(
        children: [
          Text(
            l10n.versionLabel(version),
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          if (isUpToDate) const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.success),
          const SizedBox(width: AppConstants.paddingTiny),
          Expanded(
            child: Text(
              isUpToDate ? l10n.appUpToDate : '',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// A logout tile that mirrors [_ArrowLinkTile]'s layout exactly:
/// - In **RTL**: text on the right, icon on the left.
/// - In **LTR**: text on the left, icon on the right.
///
/// Achieved by placing [Expanded] first (which grabs the start-aligned
/// space) and the icon last. No manual `isRtl` branch needed.
class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(color: context.appDividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.logoutLabel,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              const Icon(Icons.logout, color: AppTheme.error, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
