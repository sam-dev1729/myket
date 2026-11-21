import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/optional.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/presentation/providers/profile_completeness_provider.dart';
import '../data/models/lab_test_models.dart';
import 'lab_test_controller.dart';
import 'lab_test_draft.dart';
import 'utils/lab_date_format.dart';
import 'widgets/add_edit_category_dialog.dart';
import 'widgets/add_edit_header_dialog.dart';
import 'widgets/add_edit_parameter_dialog.dart';
import 'widgets/upload_source_sheet.dart';

/// Screen for picking a lab-test file, uploading it (resumable) and reviewing
/// the AI-extracted data before saving.
///
/// The selected file is kept in [labTestControllerProvider] across failures,
/// so retrying does not require picking the file again. It is cleared when the
/// user leaves the screen or explicitly picks another file.
class UploadLabTestScreen extends ConsumerStatefulWidget {
  const UploadLabTestScreen({super.key});

  @override
  ConsumerState<UploadLabTestScreen> createState() => _UploadLabTestScreenState();
}

class _UploadLabTestScreenState extends ConsumerState<UploadLabTestScreen> {
  bool _restoring = true;

  @override
  void initState() {
    super.initState();
    // Restore a pending upload from disk, or start clean after gating.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final completeness = ref.read(profileCompletenessProvider);
      if (!completeness.isComplete) {
        context.pushReplacement(
          AppConstants.mustFillProfileRoute,
          extra: AppConstants.uploadLabTestRoute,
        );
        return;
      }

      final restored = await ref.read(labTestControllerProvider.notifier).restorePendingUpload();
      if (!mounted) return;
      if (!restored) {
        ref.read(labTestControllerProvider.notifier).reset(clearPending: false);
      }
      setState(() => _restoring = false);
    });
  }

  /// Asks for the source, picks a file and stores it without uploading.
  Future<void> _pickSource() async {
    final source = await UploadSourceSheet.show(context);
    if (source == null || !mounted) return;

    File? file;
    var pickFailed = false;
    try {
      switch (source) {
        case UploadSource.pdf:
          final result = await FilePicker.pickFiles(
            type: FileType.custom,
            allowedExtensions: const ['pdf'],
          );
          final path = result.isNotEmpty ? result.first.path : null;
          if (path != null) file = File(path);
          break;
        case UploadSource.camera:
        case UploadSource.gallery:
          final picked = await ImagePicker().pickImage(
            source: source == UploadSource.camera ? ImageSource.camera : ImageSource.gallery,
            imageQuality: 85,
          );
          if (picked != null) file = File(picked.path);
          break;
      }
    } catch (_) {
      pickFailed = true;
    }

    if (!mounted) return;
    if (file == null) {
      if (pickFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.filePickFailed),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
      return;
    }

    await ref.read(labTestControllerProvider.notifier).selectFile(file);
  }

  void _leave() {
    ref.read(labTestControllerProvider.notifier).reset();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(labTestControllerProvider);
    final completeness = ref.watch(profileCompletenessProvider);

    if (!completeness.isComplete) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ref.listen<LabTestProcessState>(labTestControllerProvider, (previous, next) {
      if (next.status == LabTestProcessStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.extractionSuccess), backgroundColor: AppTheme.success),
        );
      } else if (next.status == LabTestProcessStatus.saveSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.labTestSavedSuccess), backgroundColor: AppTheme.success),
        );
      } else if (next.status == LabTestProcessStatus.error &&
          next.errorMessage != null &&
          (previous?.errorMessage != next.errorMessage ||
              previous?.errorStage != next.errorStage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(labTestControllerProvider.notifier).reset();
      },
      child: Scaffold(
        backgroundColor: context.scaffoldColor,
        appBar: AppBar(
          title: Text(l10n.uploadLabTest),
          centerTitle: true,
          backgroundColor: AppTheme.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: _leave,
          ),
        ),
        body: SafeArea(
          child: _restoring
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: _buildBody(context, state, l10n),
                ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LabTestProcessState state,
    AppLocalizations l10n,
  ) {
    switch (state.status) {
      case LabTestProcessStatus.initial:
        return _SelectFileView(onPick: _pickSource, l10n: l10n);

      case LabTestProcessStatus.fileSelected:
        final file = state.selectedFile;
        if (file == null) return _SelectFileView(onPick: _pickSource, l10n: l10n);
        return _ReadyToUploadView(
          file: file,
          l10n: l10n,
          resuming: state.uploadSession != null && state.uploadProgress > 0,
          progressPercent: (state.uploadProgress * 100).round(),
          onPick: _pickSource,
          onUpload: () => ref.read(labTestControllerProvider.notifier).startUpload(),
        );

      case LabTestProcessStatus.uploading:
        final file = state.selectedFile;
        return Column(
          children: [
            if (file != null) _FileCard(file: file, l10n: l10n),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(l10n.uploadingFile, style: context.textTheme.titleLarge),
            const SizedBox(height: AppConstants.paddingMedium),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.pillRadius),
              child: LinearProgressIndicator(
                value: state.uploadProgress,
                minHeight: 8,
                backgroundColor: context.surfaceVariantColor,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text('${(state.uploadProgress * 100).round()}%'),
            if (state.uploadAttempt > 1) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                l10n.uploadAttempt(state.uploadAttempt, state.maxUploadAttempts),
                style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
              ),
            ],
          ],
        );

      case LabTestProcessStatus.extracting:
        final file = state.selectedFile;
        return Column(
          children: [
            if (file != null) _FileCard(file: file, l10n: l10n),
            const SizedBox(height: AppConstants.paddingXLarge),
            const LinearProgressIndicator(),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              l10n.extractingData,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
          ],
        );

      case LabTestProcessStatus.saving:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: context.colorScheme.primary),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(l10n.savingLabTest, style: context.textTheme.titleLarge),
            ],
          ),
        );

      case LabTestProcessStatus.error:
        return _ErrorStateView(
          state: state,
          l10n: l10n,
          onRetry: () => ref.read(labTestControllerProvider.notifier).retry(),
          onPick: _pickSource,
        );

      case LabTestProcessStatus.success:
      case LabTestProcessStatus.saveSuccess:
        return _buildPreview(context, state, l10n);
    }
  }

  Widget _buildPreview(
    BuildContext context,
    LabTestProcessState state,
    AppLocalizations l10n,
  ) {
    final draft = state.draft ?? LabTestDraft.fromExtracted(state.extractedData);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.previewExtractedData,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: AppConstants.fontSizePreviewHeader,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          _buildHeaderCard(context, draft, l10n),

          const SizedBox(height: AppConstants.paddingMedium),

          if (draft.categories.isEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppConstants.paddingMedium),
              child: Text(
                l10n.noData,
                style: TextStyle(color: context.textSecondaryColor),
              ),
            )
          else
            for (var index = 0; index < draft.categories.length; index++)
              _buildDraftCategory(context, draft, index, l10n),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _addCategory(draft),
              icon: const Icon(Icons.add),
              label: Text(l10n.addCategoryButton),
            ),
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeight,
            child: ElevatedButton(
              onPressed: state.status == LabTestProcessStatus.saveSuccess
                  ? null
                  : () => ref.read(labTestControllerProvider.notifier).saveLabTest(),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.status == LabTestProcessStatus.saveSuccess
                    ? context.appDividerColor
                    : context.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Text(
                state.status == LabTestProcessStatus.saveSuccess
                    ? l10n.save
                    : l10n.saveLabTest,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (state.status == LabTestProcessStatus.saveSuccess) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            SizedBox(
              width: double.infinity,
              height: AppConstants.financialButtonHeight,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(labTestControllerProvider.notifier).reset();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                  ),
                ),
                child: Text(
                  l10n.viewLabTests,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            SizedBox(
              width: double.infinity,
              height: AppConstants.financialButtonHeight,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(labTestControllerProvider.notifier).reset();
                  context.push(AppConstants.healthReportRoute);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                  ),
                ),
                child: Text(
                  l10n.viewHealthReport,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Header card with an edit action that opens [AddEditHeaderDialog].
  Widget _buildHeaderCard(
    BuildContext context,
    LabTestDraft draft,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.editHeaderTitle,
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: l10n.editButton,
                onPressed: () => _editHeader(draft),
                icon: Icon(Icons.edit_outlined, color: context.colorScheme.primary),
              ),
            ],
          ),
          _buildInfoRow(
            l10n.testDate,
            formatLabTestDate(context, draft.testDate, fallback: l10n.noData),
          ),
          _buildInfoRow(l10n.doctorName, draft.doctorName ?? l10n.noData),
          _buildInfoRow(l10n.labName, draft.labName ?? l10n.noData),
          if ((draft.labAddress ?? '').trim().isNotEmpty)
            _buildInfoRow(l10n.labTestDetailLabAddress, draft.labAddress!),
          if ((draft.testNumber ?? '').trim().isNotEmpty)
            _buildInfoRow(l10n.labTestDetailTestNumber, draft.testNumber!),
        ],
      ),
    );
  }

  /// One editable category card with its parameters.
  Widget _buildDraftCategory(
    BuildContext context,
    LabTestDraft draft,
    int categoryIndex,
    AppLocalizations l10n,
  ) {
    final category = draft.categories[categoryIndex];

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AppConstants.paddingMedium),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        children: [
          Container(
            color: context.surfaceVariantColor,
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppConstants.paddingMedium,
              0,
              AppConstants.paddingTiny,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                IconButton(
                  tooltip: l10n.editButton,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _editCategory(draft, categoryIndex),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                  onPressed: () => _deleteCategory(draft, categoryIndex),
                ),
              ],
            ),
          ),
          if (category.parameters.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Text(
                l10n.noData,
                style: TextStyle(color: context.textSecondaryColor),
              ),
            )
          else
            for (var index = 0; index < category.parameters.length; index++)
              _buildDraftParameter(context, draft, categoryIndex, index, l10n),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _addParameter(draft, categoryIndex),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addParameterButton),
            ),
          ),
        ],
      ),
    );
  }

  /// One editable parameter row.
  Widget _buildDraftParameter(
    BuildContext context,
    LabTestDraft draft,
    int categoryIndex,
    int parameterIndex,
    AppLocalizations l10n,
  ) {
    final parameter = draft.categories[categoryIndex].parameters[parameterIndex];
    final range = (parameter.refMin != null || parameter.refMax != null)
        ? '${parameter.refMin ?? '-'} - ${parameter.refMax ?? '-'}'
        : '-';
    final unit = (parameter.unit ?? '').isEmpty ? '' : ' ${parameter.unit}';

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.appDividerColor, width: 0.5)),
      ),
      child: ListTile(
        title: Row(
          children: [
            Expanded(child: Text(parameter.name, style: const TextStyle(fontSize: 13))),
            if ((parameter.flag ?? '').isNotEmpty)
              Text(
                parameter.flag!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: parameter.flag == 'H'
                      ? AppTheme.error
                      : (parameter.flag == 'L' ? AppTheme.info : AppTheme.success),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${parameter.value}$unit · ${l10n.normalRangeLabel}: $range',
          style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.editButton,
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _editParameter(draft, categoryIndex, parameterIndex),
            ),
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
              onPressed: () => _deleteParameter(draft, categoryIndex, parameterIndex),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the header editor and applies the returned optional diffs.
  Future<void> _editHeader(LabTestDraft draft) async {
    final detail = LabTestDetail(
      id: 'draft',
      testDate: draft.testDate,
      doctorName: draft.doctorName,
      labName: draft.labName,
      labAddress: draft.labAddress,
      testNumber: draft.testNumber,
      files: const [],
      categories: const [],
    );

    final data = await AddEditHeaderDialog.show(context, initialDetail: detail);
    if (data == null || !mounted) return;

    final current = ref.read(labTestControllerProvider).draft ?? draft;
    ref.read(labTestControllerProvider.notifier).updateDraft(
      LabTestDraft(
        testDate: _applyOptional(data.testDate, current.testDate),
        doctorName: _applyOptional(data.doctorName, current.doctorName),
        labName: _applyOptional(data.labName, current.labName),
        labAddress: _applyOptional(data.labAddress, current.labAddress),
        testNumber: _applyOptional(data.testNumber, current.testNumber),
        categories: current.categories,
      ),
    );
  }

  /// Adds a category at the end of the draft.
  Future<void> _addCategory(LabTestDraft draft) async {
    final name = await AddEditCategoryDialog.show(context);
    if (name == null || !mounted) return;

    final current = ref.read(labTestControllerProvider).draft ?? draft;
    final categories = _cloneCategories(current)
      ..add(LabTestDraftCategory(name: name));
    _updateCategories(current, categories);
  }

  /// Renames a category.
  Future<void> _editCategory(LabTestDraft draft, int categoryIndex) async {
    final current = ref.read(labTestControllerProvider).draft ?? draft;
    final category = current.categories[categoryIndex];
    final name = await AddEditCategoryDialog.show(context, initialName: category.name);
    if (name == null || !mounted) return;

    final categories = _cloneCategories(current);
    categories[categoryIndex] = LabTestDraftCategory(
      name: name,
      parameters: List.of(category.parameters),
    );
    _updateCategories(current, categories);
  }

  /// Deletes a category (and its parameters) after confirmation.
  Future<void> _deleteCategory(LabTestDraft draft, int categoryIndex) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      l10n.deleteCategoryTitle,
      l10n.deleteCategoryConfirmMessage,
    );
    if (!confirmed || !mounted) return;

    final current = ref.read(labTestControllerProvider).draft ?? draft;
    final categories = _cloneCategories(current)..removeAt(categoryIndex);
    _updateCategories(current, categories);
  }

  /// Opens the parameter editor for an existing parameter.
  Future<void> _editParameter(
    LabTestDraft draft,
    int categoryIndex,
    int parameterIndex,
  ) async {
    final current = ref.read(labTestControllerProvider).draft ?? draft;
    final detailCategories = _toDetailCategories(current);
    final initialParameter = detailCategories[categoryIndex].parameters[parameterIndex];

    final data = await AddEditParameterDialog.show(
      context,
      categories: detailCategories,
      initialCategoryId: detailCategories[categoryIndex].id,
      initialParameter: initialParameter,
    );
    if (data == null || !mounted) return;

    final targetCategory = _categoryIndex(data.categoryId);
    if (targetCategory == null || targetCategory >= current.categories.length) return;

    final oldParameter = current.categories[categoryIndex].parameters[parameterIndex];
    final updatedParameter = LabTestDraftParameter(
      name: data.name,
      value: data.value,
      unit: _applyOptional(data.unit, oldParameter.unit),
      refMin: _applyNum(data.refMin, oldParameter.refMin),
      refMax: _applyNum(data.refMax, oldParameter.refMax),
      flag: _applyOptional(data.flag, oldParameter.flag),
    );

    final categories = _cloneCategories(current);
    if (targetCategory == categoryIndex) {
      categories[categoryIndex].parameters[parameterIndex] = updatedParameter;
    } else {
      categories[categoryIndex].parameters.removeAt(parameterIndex);
      categories[targetCategory].parameters.add(updatedParameter);
    }
    _updateCategories(current, categories);
  }

  /// Adds a parameter to a category.
  Future<void> _addParameter(LabTestDraft draft, int categoryIndex) async {
    final current = ref.read(labTestControllerProvider).draft ?? draft;
    final detailCategories = _toDetailCategories(current);

    final data = await AddEditParameterDialog.show(
      context,
      categories: detailCategories,
      initialCategoryId: detailCategories[categoryIndex].id,
    );
    if (data == null || !mounted) return;

    final targetCategory = _categoryIndex(data.categoryId);
    if (targetCategory == null || targetCategory >= current.categories.length) return;

    final parameter = LabTestDraftParameter(
      name: data.name,
      value: data.value,
      unit: _optionalString(data.unit),
      refMin: _optionalNum(data.refMin),
      refMax: _optionalNum(data.refMax),
      flag: _optionalString(data.flag),
    );

    final categories = _cloneCategories(current);
    categories[targetCategory].parameters.add(parameter);
    _updateCategories(current, categories);
  }

  /// Deletes a parameter after confirmation.
  Future<void> _deleteParameter(
    LabTestDraft draft,
    int categoryIndex,
    int parameterIndex,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      l10n.deleteParameterTitle,
      l10n.deleteParameterConfirmMessage,
    );
    if (!confirmed || !mounted) return;

    final current = ref.read(labTestControllerProvider).draft ?? draft;
    final categories = _cloneCategories(current);
    categories[categoryIndex].parameters.removeAt(parameterIndex);
    _updateCategories(current, categories);
  }

  /// Stores [categories] on the current draft.
  void _updateCategories(LabTestDraft base, List<LabTestDraftCategory> categories) {
    ref.read(labTestControllerProvider.notifier).updateDraft(
      LabTestDraft(
        testDate: base.testDate,
        doctorName: base.doctorName,
        labName: base.labName,
        labAddress: base.labAddress,
        testNumber: base.testNumber,
        categories: categories,
      ),
    );
  }

  /// Deep-ish copy of the categories so lists can be mutated safely.
  List<LabTestDraftCategory> _cloneCategories(LabTestDraft draft) {
    return [
      for (final category in draft.categories)
        LabTestDraftCategory(
          name: category.name,
          parameters: List.of(category.parameters),
        ),
    ];
  }

  /// Builds temporary server models so the existing parameter dialog can be
  /// reused for the in-memory draft.
  List<LabTestDetailCategory> _toDetailCategories(LabTestDraft draft) {
    return [
      for (var categoryIndex = 0; categoryIndex < draft.categories.length; categoryIndex++)
        LabTestDetailCategory(
          id: 'c$categoryIndex',
          name: draft.categories[categoryIndex].name,
          parameters: [
            for (var parameterIndex = 0;
                parameterIndex < draft.categories[categoryIndex].parameters.length;
                parameterIndex++)
              LabTestDetailParameter(
                id: 'p${categoryIndex}_$parameterIndex',
                categoryId: 'c$categoryIndex',
                name: draft.categories[categoryIndex].parameters[parameterIndex].name,
                value: draft.categories[categoryIndex].parameters[parameterIndex].value,
                unit: draft.categories[categoryIndex].parameters[parameterIndex].unit,
                refMin: draft.categories[categoryIndex].parameters[parameterIndex].refMin,
                refMax: draft.categories[categoryIndex].parameters[parameterIndex].refMax,
                flag: draft.categories[categoryIndex].parameters[parameterIndex].flag,
              ),
          ],
        ),
    ];
  }

  int? _categoryIndex(String categoryId) {
    if (!categoryId.startsWith('c')) return null;
    return int.tryParse(categoryId.substring(1));
  }

  T? _applyOptional<T>(Optional<T> option, T? current) {
    return option.isPresent ? option.value : current;
  }

  String? _applyNum(Optional<num> option, String? current) {
    return option.isPresent ? option.value?.toString() : current;
  }

  String? _optionalString(Optional<String> option) {
    return option.isPresent ? option.value : null;
  }

  String? _optionalNum(Optional<num> option) {
    return option.isPresent ? option.value?.toString() : null;
  }

  Future<bool> _confirm(String title, String message) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }


}

/// Initial empty state with the "select file" button.
class _SelectFileView extends StatelessWidget {
  const _SelectFileView({required this.onPick, required this.l10n});

  final VoidCallback onPick;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file,
            size: AppConstants.iconSizeHero,
            color: context.colorScheme.primary,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            l10n.selectFile,
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton(
            onPressed: onPick,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Text(
              l10n.selectFile,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// State after picking a file: show it, allow changing it, and upload manually.
class _ReadyToUploadView extends StatelessWidget {
  const _ReadyToUploadView({
    required this.file,
    required this.l10n,
    required this.resuming,
    required this.progressPercent,
    required this.onPick,
    required this.onUpload,
  });

  final File file;
  final AppLocalizations l10n;
  final bool resuming;
  final int progressPercent;
  final VoidCallback onPick;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FileCard(file: file, l10n: l10n, onChooseAnother: onPick),
        if (resuming) ...[
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            l10n.resumeUploadHint(progressPercent),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
          ),
        ],
        const SizedBox(height: AppConstants.paddingLarge),
        SizedBox(
          width: double.infinity,
          height: AppConstants.buttonHeight,
          child: ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Text(
              resuming ? l10n.resumeUploadButton : l10n.uploadFileButton,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Error state that keeps the selected file and offers resume/retry.
class _ErrorStateView extends StatelessWidget {
  const _ErrorStateView({
    required this.state,
    required this.l10n,
    required this.onRetry,
    required this.onPick,
  });

  final LabTestProcessState state;
  final AppLocalizations l10n;
  final VoidCallback onRetry;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final retryLabel = switch (state.errorStage) {
      LabTestErrorStage.upload => l10n.retryUpload,
      LabTestErrorStage.analysis => l10n.retryAnalysis,
      LabTestErrorStage.save => l10n.retry,
      null => l10n.retry,
    };

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.error),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              state.errorMessage ?? l10n.networkError,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondaryColor),
            ),
            if (state.errorStage == LabTestErrorStage.analysis) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                l10n.analysisRetryHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.textTertiaryColor),
              ),
            ],
            if (state.selectedFile != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              _FileCard(file: state.selectedFile!, l10n: l10n),
            ],
            const SizedBox(height: AppConstants.paddingLarge),
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeight,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: Text(
                  retryLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            SizedBox(
              width: double.infinity,
              height: AppConstants.financialButtonHeight,
              child: OutlinedButton(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: Text(l10n.chooseAnotherFile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing the selected file name/size with an optional "change" action.
class _FileCard extends StatelessWidget {
  const _FileCard({required this.file, required this.l10n, this.onChooseAnother});

  final File file;
  final AppLocalizations l10n;
  final VoidCallback? onChooseAnother;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Icon(Icons.description_outlined, color: context.colorScheme.primary),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path.split(Platform.pathSeparator).last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: AppConstants.paddingTiny),
                Text(
                  l10n.fileSizeMb(_fileSizeMb(file)),
                  style: TextStyle(fontSize: 11, color: context.textSecondaryColor),
                ),
              ],
            ),
          ),
          if (onChooseAnother != null)
            TextButton(
              onPressed: onChooseAnother,
              child: Text(l10n.chooseAnotherFile),
            ),
        ],
      ),
    );
  }

  String _fileSizeMb(File file) {
    try {
      final bytes = file.lengthSync();
      final megabytes = bytes / (1024 * 1024);
      return megabytes < 1 ? megabytes.toStringAsFixed(2) : megabytes.toStringAsFixed(1);
    } catch (_) {
      return '0';
    }
  }
}
