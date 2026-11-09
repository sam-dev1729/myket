import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Shows a confirmation dialog for deleting a category.
///
/// Returns `true` if the user confirms, `false`/null otherwise.
class DeleteCategoryDialog extends StatelessWidget {
  /// The name of the category (shown for clarity; caller may opt to embed
  /// it into the message in future iterations).
  final String categoryName;

  const DeleteCategoryDialog({super.key, required this.categoryName});

  /// Shows the dialog and returns true when the user confirms.
  static Future<bool> show(BuildContext context, {required String categoryName}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteCategoryDialog(categoryName: categoryName),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.deleteCategoryTitle),
      content: Text(l10n.deleteCategoryConfirmMessage),
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
