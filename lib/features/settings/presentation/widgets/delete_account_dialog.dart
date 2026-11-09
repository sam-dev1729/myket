import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Confirmation dialog for deleting the user's account.
///
/// **Security note:** The backend's `DELETE /user/{id}` endpoint requires
/// ops credentials (`TEMP_USER` / `TEMP_PASSWORD`), which cannot be safely
/// embedded in the app. Until a secure `DELETE /user/me` endpoint is added
/// on the backend, this dialog only shows a support-contact message on
/// confirm — it does not issue any HTTP request.
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  /// Shows the dialog. Returns `true` if the user tapped the destructive
  /// action (for caller's snackbar display), or `false`/null otherwise.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.confirmDeleteTitle),
      content: Text(l10n.deleteAccountBackendPendingMessage),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppTheme.error),
          child: Text(l10n.deleteAccountButton),
        ),
      ],
    );
  }
}
