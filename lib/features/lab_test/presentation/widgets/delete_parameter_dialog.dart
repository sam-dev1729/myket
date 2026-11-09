import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Shows a confirmation dialog for deleting a parameter.
///
/// Returns `true` if the user confirms, `false`/null otherwise.
class DeleteParameterDialog extends StatelessWidget {
  /// The name of the parameter (shown for clarity; caller may opt to embed
  /// it into the message in future iterations).
  final String parameterName;

  const DeleteParameterDialog({super.key, required this.parameterName});

  /// Shows the dialog and returns true when the user confirms.
  static Future<bool> show(BuildContext context, {required String parameterName}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteParameterDialog(parameterName: parameterName),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.deleteParameterTitle),
      content: Text(l10n.deleteParameterConfirmMessage),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppTheme.error),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
