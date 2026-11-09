import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_expired_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/presentation/tabs/profile_tab.dart';
import 'tabs/features_tab.dart';
import 'tabs/health_record_tab.dart';
import 'tabs/home_tab.dart';

/// The main application screen hosting a bottom-navigation bar with four
/// tabs: Home, Features, Health Record, and Profile.
class MainScreen extends ConsumerStatefulWidget {
  /// Creates a [MainScreen] instance.
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

/// Mutable state for [MainScreen].
class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [HomeTab(), FeaturesTab(), HealthRecordTab(), ProfileTab()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<bool>(sessionExpiredProvider, (previous, next) {
      if (next == true) {
        ref.read(sessionExpiredProvider.notifier).reset();
        context.go(AppConstants.loginRoute);
      }
    });

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: AppConstants.bottomNavHeight,
        decoration: const BoxDecoration(color: AppTheme.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, l10n.homeTab),
            _buildNavItem(1, Icons.category_outlined, l10n.featuresTab),
            _buildNavItem(2, Icons.monitor_heart_outlined, l10n.healthRecordTab),
            _buildNavItem(3, Icons.person_outline, l10n.profileTab),
          ],
        ),
      ),
    );
  }

  /// Builds a single bottom-navigation item with an icon and a label.
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.black : AppTheme.black.withValues(alpha: 0.55);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: AppConstants.paddingTiny),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
