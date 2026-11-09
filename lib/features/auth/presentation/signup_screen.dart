import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_calendar_widget/persian_calendar_widget.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/error_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

/// The Sign-Up screen for new users.
class SignUpScreen extends ConsumerStatefulWidget {
  final String registrationToken;
  final String? phoneNumber;

  const SignUpScreen({super.key, required this.registrationToken, this.phoneNumber});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  DateTime? _selectedBirthDate;
  String _displayBirthDate = '';
  bool? _isMale;

  @override
  void initState() {
    super.initState();
    // Pre-fill names if coming from Google Login
    final googleData = ref.read(authControllerProvider).googleAuthResult;
    if (googleData != null) {
      _firstNameController.text = googleData.firstName ?? '';
      _lastNameController.text = googleData.lastName ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _pickBirthDate() {
    final locale = Localizations.localeOf(context);
    final isPersian = locale.languageCode == 'fa';

    if (isPersian) {
      final now = Jalali.now();
      MinimalPersianCalendar.pickFullDate(
        context: context,
        minYear: AppConstants.minBirthYearFa,
        maxYear: now.year,
        initialDate: DateTime(1996, 1, 1),
        calendarType: CalendarType.persian,
        i18n: I18n(),
        onSubmit: (selectedDate, formattedDate) {
          setState(() {
            _selectedBirthDate = selectedDate.gregorian.toDateTime();
            // FIX: Proper Jalali formatting
            final j = Jalali.fromDateTime(_selectedBirthDate!);
            _displayBirthDate = '${j.day} ${j.formatter.mN} ${j.year}';
          });
        },
      );
    } else {
      _showGregorianDatePicker();
    }
  }

  Future<void> _showGregorianDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(AppConstants.minBirthYearEn),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _displayBirthDate = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        context.go(AppConstants.mainRoute);
      } else if (next.status == AuthStatus.error) {
        final errorMessage =
            next.errorMessage ?? next.error?.getLocalizedMessage(l10n) ?? l10n.networkError;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    void onRegisterClicked() {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = widget.phoneNumber?.trim() ?? '';

      if (firstName.isEmpty || lastName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterName)));
        return;
      }

      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.phoneMissingError)));
        return;
      }

      if (_selectedBirthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.selectBirthDate)));
        return;
      }

      if (_isMale == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.genderLabel)));
        return;
      }

      final birthDateStr = _selectedBirthDate?.toIso8601String().split('T').first;

      ref
          .read(authControllerProvider.notifier)
          .registerPatient(phone, firstName, lastName, birthDate: birthDateStr, isMale: _isMale);
    }

    final subtitleText = widget.phoneNumber != null
        ? l10n.signUpSubtitle(widget.phoneNumber!)
        : l10n.pleaseEnterDetails;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.signUpTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitleText,
                  style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: l10n.firstName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: l10n.lastName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.birthDate,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _displayBirthDate.isNotEmpty ? _displayBirthDate : l10n.selectBirthDate,
                      style: TextStyle(
                        color: _selectedBirthDate != null
                            ? context.textPrimaryColor
                            : context.textSecondaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text(l10n.male),
                        value: true,
                        groupValue: _isMale,
                        onChanged: (v) => setState(() => _isMale = v),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text(l10n.female),
                        value: false,
                        groupValue: _isMale,
                        onChanged: (v) => setState(() => _isMale = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading ? null : onRegisterClicked,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: authState.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.registerAndLogin,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
