import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

/// Shows a dialog to add or edit a category.
///
/// If [initialName] is provided, the dialog is in "edit" mode.
/// Returns the entered name on submit, or null on cancel.
class AddEditCategoryDialog extends StatefulWidget {
  /// The initial category name (null when adding).
  final String? initialName;

  const AddEditCategoryDialog({super.key, this.initialName});

  /// Shows the dialog and returns the entered (trimmed) name, or null on
  /// cancel.
  static Future<String?> show(BuildContext context, {String? initialName}) {
    return showDialog<String>(
      context: context,
      builder: (_) => AddEditCategoryDialog(initialName: initialName),
    );
  }

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  late final TextEditingController _controller;
  bool _showError = false;

  bool get _isEdit => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  void _onChanged(String _) {
    setState(() {
      // Clear the error as soon as the field has content again.
      if (_showError && _canSubmit) _showError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(_isEdit ? l10n.editCategoryTitle : l10n.addCategoryButton),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onChanged: _onChanged,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.categoryNameLabel,
          errorText: _showError ? l10n.categoryNameRequiredError : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        ElevatedButton(onPressed: _canSubmit ? _submit : null, child: Text(l10n.save)),
      ],
    );
  }
}
