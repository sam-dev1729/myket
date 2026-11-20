import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Dialog that displays the app's "About Us" content.
class AboutDialogWidget extends StatelessWidget {
  const AboutDialogWidget({super.key});

  /// Shows the About dialog.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const AboutDialogWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.aboutUs),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.biotech, color: context.colorScheme.secondary, size: 40),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    l10n.appName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              l10n.aboutDescription,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              l10n.versionLabel(AppConstants.appVersion),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}