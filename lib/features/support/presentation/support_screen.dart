import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';

/// The Support screen for live chat with the support team.
class SupportScreen extends StatelessWidget {
  /// Creates a [SupportScreen] instance.
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supportTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.supportGreetingTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingTiny),
                        Text(
                          l10n.supportSubtitle,
                          style: const TextStyle(fontSize: 12, color: AppTheme.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  const CircleAvatar(
                    radius: AppConstants.avatarRadius,
                    backgroundColor: AppTheme.white,
                    child: Icon(Icons.support_agent, color: AppTheme.primary, size: 32),
                  ),
                ],
              ),
            ),
            Expanded(child: Container(color: context.surfaceVariantColor)),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
              color: context.surfaceColor,
              child: Row(
                children: [
                  Icon(Icons.mic_none, color: context.textSecondaryColor),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.supportInputHint,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Icon(Icons.sentiment_satisfied_alt, color: context.textSecondaryColor),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Icon(Icons.attach_file, color: context.textSecondaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
