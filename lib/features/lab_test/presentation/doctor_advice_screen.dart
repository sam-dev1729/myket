import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/trailing_arrow.dart';
import '../../../l10n/app_localizations.dart';
import 'health_overview_provider.dart';
import 'utils/health_assistant.dart';

/// Dedicated screen listing the doctor-assistant advice for the latest
/// results, with a shortcut into the AI assistant chat.
class DoctorAdviceScreen extends ConsumerWidget {
  const DoctorAdviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overviewAsync = ref.watch(healthOverviewProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.doctorAdviceTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(healthOverviewProvider),
              child: Text(l10n.retry),
            ),
          ),
          data: (overview) {
            final adviceLines = splitAdviceLines(overview.advice);
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: AppConstants.paddingMedium,
              ),
              children: [
                _Banner(l10n: l10n),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  l10n.doctorSuggestionsDescription,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.8,
                    color: context.textSecondaryColor,
                  ),
                ),
                if (adviceLines.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingLarge),
                  ...adviceLines.map((line) => _AdviceBullet(text: line)),
                ],
                const SizedBox(height: AppConstants.paddingXLarge),
                _AskAiCard(
                  l10n: l10n,
                  onTap: () => context.push(AppConstants.aiAssistantRoute),
                ),
                const SizedBox(height: AppConstants.paddingXLarge),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Teal banner with the stethoscope illustration and title.
class _Banner extends StatelessWidget {
  const _Banner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: context.softTealBg,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.doctorSuggestions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.medical_services_outlined, color: AppTheme.success, size: 40),
        ],
      ),
    );
  }
}

/// One advice bullet row.
class _AdviceBullet extends StatelessWidget {
  const _AdviceBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.7, color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue call-to-action card linking to the AI assistant chat.
class _AskAiCard extends StatelessWidget {
  const _AskAiCard({required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.primary,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: context.colorScheme.onPrimary, size: 32),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.askAiTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingTiny),
                    Text(
                      l10n.askAiSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              TrailingArrow(size: 20, color: context.colorScheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
