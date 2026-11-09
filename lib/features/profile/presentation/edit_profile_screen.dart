import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_calendar_widget/persian_calendar_widget.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../data/catalog_repository.dart';
import '../data/geo_repository.dart';
import '../data/models/catalog_models.dart';
import '../data/models/catalog_type.dart';
import '../data/models/geo_models.dart';
import '../data/models/user_profile.dart';
import 'edit_profile_controller.dart';
import 'profile_controller.dart';
import 'widgets/catalog_selection_sheet.dart';
import 'widgets/city_selection_sheet.dart';
import 'widgets/country_selection_sheet.dart';
import 'widgets/international_ethnicity_selection_sheet.dart';
import 'widgets/local_ethnicity_selection_sheet.dart';
import 'widgets/province_selection_sheet.dart';

/// The screen for editing the user's profile, including vitals,
/// personal info, geo (country/province/city), ethnicity, and medical catalogs.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedBloodType;

  String? _selectedCountryId;
  String? _selectedCountryName;
  String? _selectedProvinceId;
  String? _selectedProvinceName;
  String? _selectedCityId;
  String? _selectedCityName;

  String? _selectedInternationalEthnicityId;
  String? _selectedInternationalEthnicityName;
  String? _selectedLocalEthnicityId;
  String? _selectedLocalEthnicityName;

  DateTime? _selectedBirthDate;
  String _displayBirthDate = '';
  bool? _isMale;
  bool _isPregnant = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final profile = ref.read(profileControllerProvider).asData?.value;
    if (profile == null) return; // will retry via `ref.listen` in build
    _initialized = true;
    _prefillFromProfile(profile);
  }

  /// Prefills the form from [profile] and, when a province is set, fetches
  /// its name (and corrects the country) from the backend so the UI does
  /// not show a stale "not selected" state.
  Future<void> _prefillFromProfile(UserProfile profile) async {
    setState(() {
      _heightController.text = profile.height?.toString() ?? '';
      _weightController.text = profile.weight?.toString() ?? '';
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _selectedBloodType = profile.bloodType;
      _isMale = profile.isMale;
      _isPregnant = profile.isPregnant ?? false;

      // Geo prefill — the country defaults to Iran until we can resolve it
      // from the profile's province, below.
      _selectedCountryId ??= '00000000-0000-0000-0000-000000000001';
      _selectedCountryName ??= 'Iran';
      _selectedProvinceId = profile.city?.provinceId;
      _selectedCityId = profile.city?.id;
      _selectedCityName = profile.city?.name;

      // Ethnicity prefill
      final localEth = profile.localEthnicity;
      if (localEth != null && localEth.id.isNotEmpty) {
        _selectedLocalEthnicityId = localEth.id;
        _selectedLocalEthnicityName = localEth.name;

        final intlEth = localEth.internationalEthnicity;
        if (intlEth != null) {
          _selectedInternationalEthnicityId = intlEth.id;
          _selectedInternationalEthnicityName = intlEth.name;
        }
      }
    });

    // Fetch the province name (and its correct country) from the server.
    final provinceId = _selectedProvinceId;
    if (provinceId != null && provinceId.isNotEmpty) {
      try {
        final repo = ref.read(geoRepositoryProvider);
        final provinces = await repo.getProvinces();
        Province? match;
        for (final p in provinces) {
          if (p.id == provinceId) {
            match = p;
            break;
          }
        }
        if (match != null && mounted) {
          setState(() {
            _selectedProvinceName = match!.name;
            _selectedCountryId = match.countryId;
          });

          // Resolve the country name too.
          final countries = await repo.getCountries();
          for (final c in countries) {
            if (c.id == match.countryId) {
              if (mounted) setState(() => _selectedCountryName = c.name);
              break;
            }
          }
        }
      } catch (_) {
        // Silent — UI keeps "not selected" as a safe fallback.
      }
    }

    // Birth date.
    if (profile.birthDate != null && profile.birthDate!.isNotEmpty) {
      try {
        final dt = DateTime.parse(profile.birthDate!);
        _selectedBirthDate = dt;
        final locale = Localizations.localeOf(context);
        if (locale.languageCode == 'fa') {
          final j = Jalali.fromDateTime(dt);
          _displayBirthDate = '${j.day} ${j.formatter.mN} ${j.year}';
        } else {
          _displayBirthDate = profile.birthDate!;
        }
        if (mounted) setState(() {});
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
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
        initialDate: _selectedBirthDate ?? DateTime(1996, 1, 1),
        calendarType: CalendarType.persian,
        i18n: I18n(),
        onSubmit: (selectedDate, formattedDate) {
          setState(() {
            _selectedBirthDate = selectedDate.gregorian.toDateTime();
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

  Future<void> _pickCountry() async {
    final country = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CountrySelectionSheet(),
    );
    if (country != null) {
      setState(() {
        _selectedCountryId = country.id;
        _selectedCountryName = country.name;
        _selectedProvinceId = null; // Reset province
        _selectedProvinceName = null;
        _selectedCityId = null; // Reset city
        _selectedCityName = null;
      });
    }
  }

  Future<void> _pickProvince() async {
    if (_selectedCountryId == null) return;
    final province = await showModalBottomSheet<Province>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProvinceSelectionSheet(countryId: _selectedCountryId!),
    );
    if (province != null) {
      setState(() {
        _selectedProvinceId = province.id;
        _selectedProvinceName = province.name;
        _selectedCityId = null; // Reset city
        _selectedCityName = null;
      });
    }
  }

  Future<void> _pickCity() async {
    if (_selectedProvinceId == null) {
      _showError(AppLocalizations.of(context)!.pleaseSelectProvinceError);
      return;
    }
    final city = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CitySelectionSheet(provinceId: _selectedProvinceId),
    );
    if (city != null) {
      setState(() {
        _selectedCityId = city.id;
        _selectedCityName = city.name;
      });
    }
  }

  Future<void> _pickInternationalEthnicity() async {
    final result = await showModalBottomSheet<InternationalEthnicity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const InternationalEthnicitySelectionSheet(),
    );
    if (result != null) {
      setState(() {
        _selectedInternationalEthnicityId = result.id;
        _selectedInternationalEthnicityName = result.name;
        _selectedLocalEthnicityId = null;
        _selectedLocalEthnicityName = null;
      });
    }
  }

  Future<void> _pickLocalEthnicity() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedInternationalEthnicityId == null) {
      _showError(l10n.pleaseSelectInternationalEthnicityError);
      return;
    }
    final result = await showModalBottomSheet<LocalEthnicity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocalEthnicitySelectionSheet(
        internationalEthnicityId: _selectedInternationalEthnicityId!,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLocalEthnicityId = result.id;
        _selectedLocalEthnicityName = result.name;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      _showError(l10n.pleaseEnterFirstNameError);
      return;
    }
    if (lastName.isEmpty) {
      _showError(l10n.pleaseEnterLastNameError);
      return;
    }
    if (_selectedBirthDate == null) {
      _showError(l10n.pleaseSelectBirthDateError);
      return;
    }
    if (_isMale == null) {
      _showError(l10n.pleaseSelectGenderError);
      return;
    }

    final request = UpdateProfileRequest(
      firstName: firstName,
      lastName: lastName,
      birthDate: _selectedBirthDate!.toIso8601String().split('T').first,
      isMale: _isMale,
      height: int.tryParse(_heightController.text),
      weight: int.tryParse(_weightController.text),
      isPregnant: _isMale == false ? _isPregnant : null,
      bloodType: _selectedBloodType,
      cityId: _selectedCityId,
      localEthnicityId: _selectedLocalEthnicityId,
    );

    await ref.read(editProfileControllerProvider.notifier).updateProfile(request);

    if (!mounted) return;

    final state = ref.read(editProfileControllerProvider);
    if (state.status == EditStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSavedSuccess), backgroundColor: AppTheme.success),
      );
      ref.read(profileControllerProvider.notifier).refreshProfile();
      context.pop();
    } else if (state.status == EditStatus.error) {
      _showError(state.errorMessage ?? l10n.networkError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.error));
  }

  /// Ensures the profile is loaded, fetching it once if the cache is empty.
  Future<UserProfile?> _ensureProfile() async {
    final cached = ref.read(profileControllerProvider).asData?.value;
    if (cached != null) return cached;
    try {
      return await ref.read(profileControllerProvider.future);
    } catch (e) {
      if (mounted) _showError(e.toString());
      return null;
    }
  }

  Future<void> _openCatalogSheet(String type) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(catalogRepositoryProvider);

    final profile = await _ensureProfile();
    if (profile == null) return;

    List<CatalogItem> allItems = [];
    List<String> selectedIds = [];
    String title = '';
    CatalogType catalogType = CatalogType.allergy;

    try {
      if (type == 'allergy') {
        allItems = await repository.getAllergies();
        selectedIds =
            profile.allergies
                ?.map((e) => e.allergy?.id ?? '')
                .where((id) => id.isNotEmpty)
                .toList() ??
            [];
        title = l10n.selectAllergies;
        catalogType = CatalogType.allergy;
      } else if (type == 'disease') {
        allItems = await repository.getDiseases();
        selectedIds =
            profile.underlyingDiseases
                ?.map((e) => e.underlyingDisease?.id ?? '')
                .where((id) => id.isNotEmpty)
                .toList() ??
            [];
        title = l10n.selectDiseases;
        catalogType = CatalogType.disease;
      } else if (type == 'history') {
        allItems = await repository.getHistories();
        selectedIds =
            profile.medicalHistories
                ?.map((e) => e.medicalHistory?.id ?? '')
                .where((id) => id.isNotEmpty)
                .toList() ??
            [];
        title = l10n.selectHistories;
        catalogType = CatalogType.history;
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
      return;
    }

    if (!mounted) return;

    final result = await showModalBottomSheet<CatalogSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CatalogSelectionSheet(
        title: title,
        allItems: allItems,
        selectedItemIds: selectedIds,
        type: catalogType,
      ),
    );

    if (result == null) return;

    // Diff and update
    final newIds = result.selectedItems.map((e) => e.id).toSet();
    final oldIds = selectedIds.toSet();
    final toAdd = newIds.difference(oldIds);
    final toRemove = oldIds.difference(newIds);

    if (toAdd.isEmpty && toRemove.isEmpty) return;

    final controller = ref.read(editProfileControllerProvider.notifier);
    for (final id in toAdd) {
      if (type == 'allergy') {
        await controller.toggleAllergy(id, true);
      } else if (type == 'disease') {
        await controller.toggleDisease(id, true);
      } else if (type == 'history') {
        await controller.toggleHistory(id, true);
      }
    }
    for (final id in toRemove) {
      if (type == 'allergy') {
        await controller.toggleAllergy(id, false);
      } else if (type == 'disease') {
        await controller.toggleDisease(id, false);
      } else if (type == 'history') {
        await controller.toggleHistory(id, false);
      }
    }
    ref.read(profileControllerProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editState = ref.watch(editProfileControllerProvider);
    final isLoading = editState.status == EditStatus.loading;

    // Retry prefill once the profile loads, in case `didChangeDependencies`
    // fired before the profile was ready.
    ref.listen<AsyncValue<UserProfile>>(profileControllerProvider, (prev, next) {
      if (_initialized) return;
      if (!next.hasValue || next.value == null) return;
      _initialized = true;
      _prefillFromProfile(next.value!);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(title: l10n.editProfileBasicInfo),
              const SizedBox(height: AppConstants.paddingMedium),

              // First + Last name
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: l10n.firstNameField,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: l10n.lastNameField,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Birth date
              InkWell(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.birthDateLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _displayBirthDate.isNotEmpty ? _displayBirthDate : l10n.selectBirthDate,
                    style: TextStyle(
                      color: _selectedBirthDate != null
                          ? context.textPrimaryColor
                          : context.textTertiaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Gender
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(l10n.male),
                      value: true,
                      groupValue: _isMale,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setState(() => _isMale = v),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: Text(l10n.female),
                      value: false,
                      groupValue: _isMale,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setState(() => _isMale = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Height + Weight
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.heightLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.weightLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Pregnant checkbox
              if (_isMale == false)
                CheckboxListTile(
                  value: _isPregnant,
                  onChanged: (v) => setState(() => _isPregnant = v ?? false),
                  title: Text(l10n.isPregnantLabel),
                  activeColor: AppTheme.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              if (_isMale == false) const SizedBox(height: AppConstants.paddingMedium),

              // Blood Type
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: InputDecoration(
                  labelText: l10n.bloodTypeLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                items:
                    const [
                      'A_POSITIVE',
                      'A_NEGATIVE',
                      'B_POSITIVE',
                      'B_NEGATIVE',
                      'AB_POSITIVE',
                      'AB_NEGATIVE',
                      'O_POSITIVE',
                      'O_NEGATIVE',
                    ].map((type) {
                      final label = type.replaceAll('_POSITIVE', '+').replaceAll('_NEGATIVE', '-');
                      return DropdownMenuItem(value: type, child: Text(label));
                    }).toList(),
                onChanged: (val) => setState(() => _selectedBloodType = val),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Country
              InkWell(
                onTap: _pickCountry,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.selectCountryTitle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    suffixIcon: const Icon(Icons.public),
                  ),
                  child: Text(
                    _selectedCountryName ?? l10n.noValueSelected,
                    style: TextStyle(
                      color: _selectedCountryName != null
                          ? context.textPrimaryColor
                          : context.textTertiaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Province
              InkWell(
                onTap: _pickProvince,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.selectProvinceTitle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    suffixIcon: const Icon(Icons.map_outlined),
                  ),
                  child: Text(
                    _selectedProvinceName ?? l10n.noValueSelected,
                    style: TextStyle(
                      color: _selectedProvinceName != null
                          ? context.textPrimaryColor
                          : context.textTertiaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // City
              InkWell(
                onTap: _pickCity,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.selectCityLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    suffixIcon: const Icon(Icons.location_city),
                  ),
                  child: Text(
                    _selectedCityName ?? l10n.noValueSelected,
                    style: TextStyle(
                      color: _selectedCityName != null
                          ? context.textPrimaryColor
                          : context.textTertiaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // International Ethnicity
              InkWell(
                onTap: _pickInternationalEthnicity,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.selectInternationalEthnicityTitle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    suffixIcon: const Icon(Icons.people_outline),
                  ),
                  child: Text(
                    _selectedInternationalEthnicityName ?? l10n.noValueSelected,
                    style: TextStyle(
                      color: _selectedInternationalEthnicityName != null
                          ? context.textPrimaryColor
                          : context.textTertiaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Local Ethnicity
              InkWell(
                onTap: _pickLocalEthnicity,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.selectLocalEthnicityTitle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    suffixIcon: const Icon(Icons.group_outlined),
                  ),
                  child: Text(
                    _selectedLocalEthnicityName ?? l10n.noValueSelected,
                    style: TextStyle(
                      color: _selectedLocalEthnicityName != null
                          ? context.textPrimaryColor
                          : context.textTertiaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              // Medical info
              _SectionTitle(title: l10n.editProfileMedicalInfo),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildCatalogButton(l10n.allergiesLabel, () => _openCatalogSheet('allergy')),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildCatalogButton(l10n.underlyingDiseasesLabel, () => _openCatalogSheet('disease')),
              const SizedBox(height: AppConstants.paddingMedium),
              _buildCatalogButton(l10n.medicalHistoryLabel, () => _openCatalogSheet('history')),
              const SizedBox(height: AppConstants.paddingXLarge),

              // Save button
              SizedBox(
                height: AppConstants.financialButtonHeight,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: AppTheme.black)
                      : Text(
                          l10n.saveChanges,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogButton(String title, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: context.appDividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_back_ios_new, size: 16, color: context.textSecondaryColor),
            Text(title, style: TextStyle(fontSize: 16, color: context.textPrimaryColor)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.textPrimaryColor,
        ),
      ),
    );
  }
}
