import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Source selected in [UploadSourceSheet].
enum UploadSource { pdf, camera, gallery }

/// Bottom sheet that asks the user where the lab-test file comes from.
class UploadSourceSheet extends StatelessWidget {
  const UploadSourceSheet({super.key});

  /// Opens the sheet and returns the selected source (or null).
  static Future<UploadSource?> show(BuildContext context) {
    return showModalBottomSheet<UploadSource>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const UploadSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppConstants.screenPadding,
              0,
              AppConstants.screenPadding,
              AppConstants.paddingSmall,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.uploadSheetTitle,
                    style: context.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.close,
                  icon: Icon(Icons.close, color: context.textSecondaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          _SourceTile(
            icon: Icons.description_outlined,
            label: l10n.uploadPdfSource,
            onTap: () => Navigator.of(context).pop(UploadSource.pdf),
          ),
          Divider(height: 1, color: context.appDividerColor),
          _SourceTile(
            icon: Icons.photo_camera_outlined,
            label: l10n.uploadCameraSource,
            onTap: () => Navigator.of(context).pop(UploadSource.camera),
          ),
          Divider(height: 1, color: context.appDividerColor),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: l10n.uploadGallerySource,
            onTap: () => Navigator.of(context).pop(UploadSource.gallery),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
        ],
      ),
    );
  }
}

/// A single upload-source row.
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      leading: Icon(icon, color: context.colorScheme.primary),
      title: Text(label, style: context.textTheme.titleMedium),
      onTap: onTap,
    );
  }
}
