import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/presentation/providers/profile_completeness_provider.dart';
import '../data/models/lab_test_models.dart';
import 'lab_test_controller.dart';

/// A screen to select a lab test file, upload it, and display the AI
/// extraction preview.
///
/// Gated on [profileCompletenessProvider]: if mandatory profile fields are
/// missing, the user is redirected to the must-fill screen and can return
/// here automatically once the profile is complete.
class UploadLabTestScreen extends ConsumerStatefulWidget {
  const UploadLabTestScreen({super.key});

  @override
  ConsumerState<UploadLabTestScreen> createState() => _UploadLabTestScreenState();
}

class _UploadLabTestScreenState extends ConsumerState<UploadLabTestScreen> {
  @override
  void initState() {
    super.initState();
    // Gate check must run after the first frame, because we may call
    // `context.pushReplacement` — which is not allowed during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final completeness = ref.read(profileCompletenessProvider);
      if (!completeness.isComplete) {
        context.pushReplacement(
          AppConstants.mustFillProfileRoute,
          extra: AppConstants.uploadLabTestRoute,
        );
      }
    });
  }

  Future<void> _pickFile() async {
    final List<PlatformFile>? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.isNotEmpty) {
      final String? path = result.first.path;
      if (path != null) {
        final file = File(path);
        await ref.read(labTestControllerProvider.notifier).processFile(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(labTestControllerProvider);
    final completeness = ref.watch(profileCompletenessProvider);

    // While redirecting, show a neutral spinner instead of the upload UI.
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
      } else if (next.status == LabTestProcessStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? l10n.networkError),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.uploadLabTest),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            ref.read(labTestControllerProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: _buildBody(context, state, l10n),
        ),
      ),
    );
  }

  /// Builds the UI based on the current state.
  Widget _buildBody(BuildContext context, LabTestProcessState state, AppLocalizations l10n) {
    switch (state.status) {
      case LabTestProcessStatus.initial:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.upload_file,
                size: AppConstants.iconSizeHero,
                color: AppTheme.primary,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(
                l10n.selectFile,
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: Text(
                  l10n.selectFile,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

      case LabTestProcessStatus.uploading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.uploadingFile, style: context.textTheme.titleLarge),
              const SizedBox(height: AppConstants.paddingMedium),
              LinearProgressIndicator(value: state.uploadProgress, color: AppTheme.primary),
              const SizedBox(height: AppConstants.paddingSmall),
              Text('${(state.uploadProgress * 100).toStringAsFixed(1)}%'),
            ],
          ),
        );

      case LabTestProcessStatus.extracting:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(l10n.extractingData, style: context.textTheme.titleLarge),
            ],
          ),
        );

      case LabTestProcessStatus.saving:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: AppConstants.paddingLarge),
              Text(l10n.savingLabTest, style: context.textTheme.titleLarge),
            ],
          ),
        );

      case LabTestProcessStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: AppConstants.iconSizeHero,
                color: AppTheme.error,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(state.errorMessage ?? l10n.networkError, textAlign: TextAlign.center),
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton(
                onPressed: () {
                  ref.read(labTestControllerProvider.notifier).reset();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        );

      case LabTestProcessStatus.success:
      case LabTestProcessStatus.saveSuccess:
        final data = state.extractedData;
        if (data == null) return const SizedBox.shrink();

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

              _buildInfoRow(l10n.testDate, data.testDate ?? l10n.noData),
              _buildInfoRow(l10n.doctorName, data.doctorName ?? l10n.noData),
              _buildInfoRow(l10n.labName, data.labName ?? l10n.noData),

              const SizedBox(height: AppConstants.paddingLarge),

              ...data.categories?.map((category) => _buildCategorySection(category, l10n)) ?? [],

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
                        : AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                  ),
                  child: Text(
                    state.status == LabTestProcessStatus.saveSuccess ? l10n.save : l10n.saveLabTest,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: context.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ExtractedCategory category, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: AppConstants.paddingMedium),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
      child: ExpansionTile(
        title: Text(
          category.name,
          style: context.textTheme.titleMedium?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        children:
            category.parameters?.map((param) {
              return ListTile(
                title: Text(param.name),
                subtitle: Text('${param.value ?? '-'} ${param.unit ?? ''}'),
                trailing: Text(
                  param.flag ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: param.flag == 'H'
                        ? AppTheme.error
                        : (param.flag == 'L' ? AppTheme.info : AppTheme.success),
                  ),
                ),
              );
            }).toList() ??
            [],
      ),
    );
  }
}
