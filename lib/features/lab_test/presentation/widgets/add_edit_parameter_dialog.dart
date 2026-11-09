import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/optional.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/lab_test_models.dart';

/// Result of [AddEditParameterDialog].
///
/// Required fields ([categoryId], [name], [value]) are plain [String] — they
/// are always sent by the caller. Optional fields are [Optional] so the
/// caller can distinguish "unchanged" from "clear" (see [HeaderFormData]
/// for the diff semantics).
class ParameterFormData {
  final String categoryId;
  final String name;
  final String value;
  final Optional<String> unit;
  final Optional<num> refMin;
  final Optional<num> refMax;
  final Optional<String> flag;

  const ParameterFormData({
    required this.categoryId,
    required this.name,
    required this.value,
    this.unit = const Optional.absent(),
    this.refMin = const Optional.absent(),
    this.refMax = const Optional.absent(),
    this.flag = const Optional.absent(),
  });
}

/// Dialog (bottom sheet) for adding or editing a parameter.
///
/// - In **add** mode ([initialParameter] is null), the category dropdown
///   defaults to [initialCategoryId].
/// - In **edit** mode, all fields are pre-filled from [initialParameter]
///   and the category dropdown allows moving the parameter.
class AddEditParameterDialog extends StatefulWidget {
  /// All available categories (for the dropdown).
  final List<LabTestDetailCategory> categories;

  /// The category to pre-select in add mode.
  final String initialCategoryId;

  /// The parameter being edited (null when adding).
  final LabTestDetailParameter? initialParameter;

  const AddEditParameterDialog({
    super.key,
    required this.categories,
    required this.initialCategoryId,
    this.initialParameter,
  });

  /// Shows the bottom sheet and returns the form data (or null on cancel).
  static Future<ParameterFormData?> show(
    BuildContext context, {
    required List<LabTestDetailCategory> categories,
    required String initialCategoryId,
    LabTestDetailParameter? initialParameter,
  }) {
    return showModalBottomSheet<ParameterFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditParameterDialog(
        categories: categories,
        initialCategoryId: initialCategoryId,
        initialParameter: initialParameter,
      ),
    );
  }

  @override
  State<AddEditParameterDialog> createState() => _AddEditParameterDialogState();
}

class _AddEditParameterDialogState extends State<AddEditParameterDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  late final TextEditingController _unitController;
  late final TextEditingController _refMinController;
  late final TextEditingController _refMaxController;

  late String _selectedCategoryId;
  String _flagValue = ''; // '' = none, 'H' = high, 'L' = low
  bool _submitted = false;

  bool get _isEdit => widget.initialParameter != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialParameter;
    _nameController = TextEditingController(text: p?.name ?? '');
    _valueController = TextEditingController(text: p?.value ?? '');
    _unitController = TextEditingController(text: p?.unit ?? '');
    _refMinController = TextEditingController(text: p?.refMin ?? '');
    _refMaxController = TextEditingController(text: p?.refMax ?? '');
    _selectedCategoryId = p?.categoryId ?? widget.initialCategoryId;
    _flagValue = p?.flag ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _refMinController.dispose();
    _refMaxController.dispose();
    super.dispose();
  }

  num? _parseOptionalNum(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return num.tryParse(trimmed);
  }

  bool _hasInvalidNumber(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return false;
    return num.tryParse(trimmed) == null;
  }

  /// Computes the [Optional] state for a String field by diffing
  /// [current] against [original] (see [HeaderFormData] for semantics).
  Optional<String> _computeOptional(String? current, String? original) {
    final c = current?.trim();
    final o = original?.trim();
    final cEmpty = c == null || c.isEmpty;
    final oEmpty = o == null || o.isEmpty;
    if (cEmpty && oEmpty) return const Optional.absent();
    if (cEmpty && !oEmpty) return const Optional.ofNullable(null);
    if (c == o) return const Optional.absent();
    return Optional.of(c!);
  }


  /// Computes the [Optional] state for a numeric field.
  ///
  /// Both [raw] and [originalRaw] are raw strings (the backend stores
  /// `ref_min`/`ref_max` as strings on [LabTestDetailParameter]); this
  /// helper parses both to `num?` before diffing.
  Optional<num> _computeOptionalNum(String? raw, String? originalRaw) {
    final trimmed = raw?.trim();
    final parsed = (trimmed == null || trimmed.isEmpty) ? null : num.tryParse(trimmed);
    final originalTrimmed = originalRaw?.trim();
    final originalParsed = (originalTrimmed == null || originalTrimmed.isEmpty)
        ? null
        : num.tryParse(originalTrimmed);
    if (parsed == null && originalParsed == null) return const Optional.absent();
    if (parsed == null) return const Optional.ofNullable(null);
    if (parsed == originalParsed) return const Optional.absent();
    return Optional.of(parsed);
  }

  void _submit() {
    setState(() => _submitted = true);

    final name = _nameController.text.trim();
    final value = _valueController.text.trim();
    if (name.isEmpty || value.isEmpty) return;
    if (_hasInvalidNumber(_refMinController.text)) return;
    if (_hasInvalidNumber(_refMaxController.text)) return;

    final original = widget.initialParameter;

    Navigator.of(context).pop(
      ParameterFormData(
        categoryId: _selectedCategoryId,
        name: name,
        value: value,
        unit: _computeOptional(_unitController.text, original?.unit),
        refMin: _computeOptionalNum(_refMinController.text, original?.refMin),
        refMax: _computeOptionalNum(_refMaxController.text, original?.refMax),
        flag: _computeOptional(_flagValue.isEmpty ? null : _flagValue, original?.flag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        height: mediaQuery.size.height * AppConstants.bottomSheetHeightFactor,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.largeCardRadius)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHandleBar(),
              _buildTitle(l10n),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: _buildForm(l10n),
                ),
              ),
              _buildSaveButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppConstants.paddingSmall),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.appDividerColor,
          borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Text(
        _isEdit ? l10n.editParameterTitle : l10n.addParameterButton,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.parameterCategoryLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          items: widget.categories
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedCategoryId = v);
          },
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.parameterNameLabel,
            errorText: _submitted && _nameController.text.trim().isEmpty
                ? l10n.parameterNameRequiredError
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        TextField(
          controller: _valueController,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.parameterValueLabel,
            errorText: _submitted && _valueController.text.trim().isEmpty
                ? l10n.parameterValueRequiredError
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        TextField(
          controller: _unitController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.parameterUnitLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        TextField(
          controller: _refMinController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.parameterRefMinLabel,
            errorText: _submitted && _hasInvalidNumber(_refMinController.text)
                ? l10n.parameterInvalidNumberError
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        TextField(
          controller: _refMaxController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.parameterRefMaxLabel,
            errorText: _submitted && _hasInvalidNumber(_refMaxController.text)
                ? l10n.parameterInvalidNumberError
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        DropdownButtonFormField<String>(
          value: _flagValue,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.parameterFlagLabel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          items: [
            DropdownMenuItem(value: '', child: Text(l10n.labTestFlagNone)),
            DropdownMenuItem(value: 'H', child: Text(l10n.labTestFlagHigh)),
            DropdownMenuItem(value: 'L', child: Text(l10n.labTestFlagLow)),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _flagValue = v);
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: SizedBox(
        width: double.infinity,
        height: AppConstants.buttonHeight,
        child: ElevatedButton(onPressed: _submit, child: Text(l10n.save)),
      ),
    );
  }
}
