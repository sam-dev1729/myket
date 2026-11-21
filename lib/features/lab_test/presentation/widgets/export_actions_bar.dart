import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/report_exporter.dart';

/// Sticky bottom bar with "download" and "share" actions for a text report.
class ExportActionsBar extends StatelessWidget {
  const ExportActionsBar({
    super.key,
    required this.text,
    required this.fileName,
    required this.shareSubject,
    required this.l10n,
  });

  /// Report body exported/shared by the actions.
  final String text;

  /// Suggested file name when downloading.
  final String fileName;

  /// Subject passed to the platform share sheet.
  final String shareSubject;

  /// Localized strings.
  final AppLocalizations l10n;

  Future<void> _download(BuildContext context) async {
    final ok = await ReportExporter.saveText(text, fileName: fileName);
    if (!context.mounted) return;
    _showMessage(
      context,
      ok ? l10n.reportSavedSuccess : l10n.reportDownloadFailed,
      ok ? AppTheme.success : AppTheme.error,
    );
  }

  Future<void> _share(BuildContext context) async {
    final ok = await ReportExporter.shareText(text, subject: shareSubject);
    if (!context.mounted || ok) return;
    _showMessage(context, l10n.reportShareFailed, AppTheme.error);
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.appDividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _download(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, AppConstants.financialButtonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
              ),
              child: Text(
                l10n.downloadReportButton,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _share(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppConstants.financialButtonHeight),
                side: BorderSide(color: context.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
              ),
              child: Text(
                l10n.shareButton,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
