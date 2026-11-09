import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Dialog that displays the app's Terms & Conditions content.
class TermsDialogWidget extends StatelessWidget {
  const TermsDialogWidget({super.key});

  /// Shows the Terms dialog.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const TermsDialogWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.termsAndConditions),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Text(
            l10n.termsBody,
            style: const TextStyle(fontSize: 13, height: 1.7),
          ),
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