import 'package:flutter/material.dart';
import 'package:persian_calendar_widget/persian_calendar_widget.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/optional.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/lab_test_models.dart';

/// Plain data holder returned by [AddEditHeaderDialog].
///
/// All fields are [Optional] so the caller can distinguish:
/// - `Optional.absent()` → leave unchanged
/// - `Optional.of(value)` → set to value
/// - `Optional.ofNullable(null)` → explicitly clear on the backend
class HeaderFormData {
  final Optional<String> testDate;
  final Optional<String> doctorName;
  final Optional<String> labName;
  final Optional<String> labAddress;
  final Optional<String> testNumber;

  const HeaderFormData({
    this.testDate = const Optional.absent(),
    this.doctorName = const Optional.absent(),
    this.labName = const Optional.absent(),
    this.labAddress = const Optional.absent(),
    this.testNumber = const Optional.absent(),
  });
}

/// Bottom sheet dialog for editing a lab test's header fields.
///
/// Fields (all optional):
/// - `test_date`     — Persian calendar date picker (ISO string stored)
/// - `doctor_name`   — text
/// - `lab_name`      — text
/// - `lab_address`   — multi-line text
/// - `test_number`   — text
///
/// Returns [HeaderFormData] on save, or null on cancel/dismiss.
class AddEditHeaderDialog extends StatefulWidget {
  /// The current lab test detail used to prefill the form.
  final LabTestDetail initialDetail;

  const AddEditHeaderDialog({super.key, required this.initialDetail});

  /// Shows the bottom sheet and returns the form data (or null on cancel).
  static Future<HeaderFormData?> show(
    BuildContext context, {
    required LabTestDetail initialDetail,
  }) {
    return showModalBottomSheet<HeaderFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditHeaderDialog(initialDetail: initialDetail),
    );
  }

  @override
  State<AddEditHeaderDialog> createState() => _AddEditHeaderDialogState();
}

class _AddEditHeaderDialogState extends State<AddEditHeaderDialog> {
  late final TextEditingController _doctorNameController;
  late final TextEditingController _labNameController;
  late final TextEditingController _labAddressController;
  late final TextEditingController _testNumberController;

  /// ISO date string (YYYY-MM-DD) or null when unset.
  String? _testDate;

  /// Locale-formatted display string for the date field.
  String _displayDate = '';

  /// Guards the one-shot locale-dependent formatting in `didChangeDependencies`.
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetail;
    _doctorNameController = TextEditingController(text: d.doctorName ?? '');
    _labNameController = TextEditingController(text: d.labName ?? '');
    _labAddressController = TextEditingController(text: d.labAddress ?? '');
    _testNumberController = TextEditingController(text: d.testNumber ?? '');
    _testDate = d.testDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localeInitialized) return;
    _localeInitialized = true;
    _displayDate = _formatDisplayDate(_testDate);
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _labNameController.dispose();
    _labAddressController.dispose();
    _testNumberController.dispose();
    super.dispose();
  }

  /// Formats an ISO date string for display, using the Persian calendar
  /// when the app locale is `fa`.
  String _formatDisplayDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final locale = Localizations.localeOf(context);
      if (locale.languageCode == 'fa') {
        final j = Jalali.fromDateTime(dt);
        return '${j.day} ${j.formatter.mN} ${j.year}';
      }
      return isoDate;
    } catch (_) {
      return isoDate;
    }
  }

  /// Opens the Persian (or Gregorian fallback) date picker for the test date.
  Future<void> _pickTestDate() async {
    final locale = Localizations.localeOf(context);
    final isPersian = locale.languageCode == 'fa';

    if (isPersian) {
      final now = Jalali.now();
      MinimalPersianCalendar.pickFullDate(
        context: context,
        minYear: AppConstants.minBirthYearFa,
        maxYear: now.year,
        initialDate: _testDate != null ? DateTime.parse(_testDate!) : DateTime.now(),
        calendarType: CalendarType.persian,
        i18n: I18n(),
        onSubmit: (selectedDate, formattedDate) {
          setState(() {
            final dt = selectedDate.gregorian.toDateTime();
            _testDate = dt.toIso8601String().split('T').first;
            final j = Jalali.fromDateTime(dt);
            _displayDate = '${j.day} ${j.formatter.mN} ${j.year}';
          });
        },
      );
    } else {
      await _showGregorianDatePicker();
    }
  }

  /// Gregorian fallback picker used when the app locale is not Persian.
  Future<void> _showGregorianDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _testDate != null ? DateTime.parse(_testDate!) : now,
      firstDate: DateTime(AppConstants.minBirthYearEn),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _testDate = picked.toIso8601String().split('T').first;
        _displayDate = _testDate!;
      });
    }
  }

  /// Trims and returns null for empty strings.
  String? _nullIfEmpty(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Computes the [Optional] state by diffing [current] against [original].
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

  void _submit() {
    final original = widget.initialDetail;
    Navigator.of(context).pop(
      HeaderFormData(
        testDate: _computeOptional(_testDate, original.testDate),
        doctorName: _computeOptional(_nullIfEmpty(_doctorNameController.text), original.doctorName),
        labName: _computeOptional(_nullIfEmpty(_labNameController.text), original.labName),
        labAddress: _computeOptional(_nullIfEmpty(_labAddressController.text), original.labAddress),
        testNumber: _computeOptional(_nullIfEmpty(_testNumberController.text), original.testNumber),
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
        l10n.editHeaderTitle,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Test date (Persian calendar picker)
        InkWell(
          onTap: _pickTestDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.testDate,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              _displayDate.isNotEmpty ? _displayDate : l10n.noData,
              style: TextStyle(
                color: _displayDate.isNotEmpty
                    ? context.textPrimaryColor
                    : context.textTertiaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // Doctor name
        TextField(
          controller: _doctorNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.doctorName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // Lab name
        TextField(
          controller: _labNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.labName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // Lab address (multi-line)
        TextField(
          controller: _labAddressController,
          maxLines: 2,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.labTestDetailLabAddress,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),

        // Test number
        TextField(
          controller: _testNumberController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: l10n.labTestDetailTestNumber,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
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
