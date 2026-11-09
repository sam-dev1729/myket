import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

/// Simple text dialog used to enter a custom catalog item name
/// (e.g. a disease not in the preset list).
///
/// Returns the trimmed name on submit, or null on cancel.
class CustomCatalogItemDialog extends StatefulWidget {
  /// The dialog title (e.g. "افزودن آلرژی جدید").
  final String title;

  const CustomCatalogItemDialog({super.key, required this.title});

  static Future<String?> show(BuildContext context, {required String title}) {
    return showDialog<String>(
      context: context,
      builder: (_) => CustomCatalogItemDialog(title: title),
    );
  }

  @override
  State<CustomCatalogItemDialog> createState() => _CustomCatalogItemDialogState();
}

class _CustomCatalogItemDialogState extends State<CustomCatalogItemDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    Navigator.pop(context, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.addNewItemLabel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
