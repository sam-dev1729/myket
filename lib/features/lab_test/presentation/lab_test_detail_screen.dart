import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/utils/url_launcher_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/lab_test_models.dart';
import 'lab_test_detail_controller.dart';
import 'utils/report_exporter.dart';
import 'widgets/export_actions_bar.dart';

/// Screen that displays the full detail (header + files + categories) of a
/// saved lab test, plus edit and delete actions.
class LabTestDetailScreen extends ConsumerWidget {
  final String id;

  const LabTestDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncDetail = ref.watch(labTestDetailProvider(id));

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.labTestDetailTitle),
        centerTitle: true,
        backgroundColor: AppTheme.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: context.iconColor),
            onSelected: (value) async {
              if (value == 'edit') {
                await context.push(
                  AppConstants.editLabTestRouteTemplate.replaceFirst(':id', id),
                );
                if (context.mounted) ref.invalidate(labTestDetailProvider(id));
              } else if (value == 'delete') {
                _confirmDelete(context, ref, l10n);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.editButton),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.delete, style: const TextStyle(color: AppTheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: asyncDetail.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                const SizedBox(height: AppConstants.paddingSmall),
                Text('${l10n.genericErrorPrefix}: $e', textAlign: TextAlign.center),
                const SizedBox(height: AppConstants.paddingSmall),
                TextButton(
                  onPressed: () => ref.invalidate(labTestDetailProvider(id)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (detail) => _DetailBody(detail: detail, l10n: l10n),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labTestDeleteConfirmTitle),
        content: Text(l10n.labTestDeleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await deleteLabTestById(ref, id);

    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labTestDeleted), backgroundColor: AppTheme.success),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.labTestDeleteFailed), backgroundColor: AppTheme.error),
      );
    }
  }
}

/// The main scrollable body of the detail screen.
class _DetailBody extends StatelessWidget {
  final LabTestDetail detail;
  final AppLocalizations l10n;

  const _DetailBody({required this.detail, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final reportText = ReportExporter.buildLabTestDetailText(
      l10n: l10n,
      detail: detail,
      formattedDate: _formatDate(context, detail.testDate),
    );

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // برای رفرش، می‌توانید از متد مربوطه استفاده کنید
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
              children: [
                const SizedBox(height: AppConstants.paddingMedium),

                // ─── 1. کارت اطلاعات هدر ───
                _HeaderCard(detail: detail, l10n: l10n),
                const SizedBox(height: AppConstants.paddingLarge),

                // ─── 2. بخش پارامترهای استخراج شده ───
                Text(
                  l10n.extractedParametersLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'با کلیک روی هر سطر راهنمای مربوط به پارامتر را ببینید.',
                  style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                ),
                const SizedBox(height: AppConstants.paddingMedium),

                // نمایش جدول برای هر دسته‌بندی
                ...detail.categories.map((category) => _CategoryTable(
                      category: category,
                      l10n: l10n,
                    )),

                const SizedBox(height: AppConstants.paddingLarge),

                // ─── 3. توصیه‌های دستیار پزشک ───
                _DoctorSuggestionsSection(l10n: l10n),
                
                const SizedBox(height: AppConstants.paddingLarge),
                
                // ─── 4. بیشتر بخوانید ───
                Text(
                  l10n.readMore,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'مقالات زیر کمک می‌کنند اطلاعات بیشتری در مورد سلامت خود داشته باشید.',
                  style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                _ReadMoreLink(text: l10n.healthAdvice1),
                const SizedBox(height: AppConstants.paddingSmall),
                _ReadMoreLink(text: l10n.healthAdvice2),
                const SizedBox(height: AppConstants.paddingSmall),
                _ReadMoreLink(text: l10n.healthAdvice3),
                
                const SizedBox(height: AppConstants.paddingXLarge),
              ],
            ),
          ),
        ),
        
        ExportActionsBar(
          text: reportText,
          fileName: 'lab-test-${detail.id}.txt',
          shareSubject: l10n.labTestDetailTitle,
          l10n: l10n,
        ),
      ],
    );
  }

  /// Formats [iso] for display (Jalali for Persian).
  String _formatDate(BuildContext context, String? iso) {
    if (iso == null || iso.isEmpty) return l10n.noData;
    try {
      final date = DateTime.parse(iso);
      if (Localizations.localeOf(context).languageCode == 'fa') {
        final jalali = Jalali.fromDateTime(date);
        return '${jalali.day} ${jalali.formatter.mN} ${jalali.year}';
      }
      return iso;
    } catch (_) {
      return iso;
    }
  }
}

/// کارت بالای صفحه که شامل اطلاعات هدر و فایل PDF است.
class _HeaderCard extends StatelessWidget {
  final LabTestDetail detail;
  final AppLocalizations l10n;

  const _HeaderCard({required this.detail, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: l10n.testTypeLabel, value: l10n.bloodTestTitle),
          _InfoRow(label: l10n.testDate, value: _formatDate(detail.testDate, context)),
          _InfoRow(label: l10n.doctorName, value: detail.doctorName ?? l10n.noData),
          _InfoRow(label: l10n.labName, value: detail.labName ?? l10n.noData),
          if (detail.labAddress != null && detail.labAddress!.isNotEmpty)
            _InfoRow(label: l10n.labTestDetailLabAddress, value: detail.labAddress!),
          if (detail.testNumber != null && detail.testNumber!.isNotEmpty)
            _InfoRow(label: l10n.labTestDetailTestNumber, value: detail.testNumber!),
            
          if (detail.files.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.download, color: context.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detail.files.first.originalName ?? 'فایل PDF',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => UrlLauncherHelper.openExternal(detail.files.first.url),
                  child: Text(l10n.labTestOpenFile),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? iso, BuildContext context) {
    if (iso == null || iso.isEmpty) return l10n.noData;
    try {
      final dt = DateTime.parse(iso);
      if (Localizations.localeOf(context).languageCode == 'fa') {
        final j = Jalali.fromDateTime(dt);
        return '${j.day} ${j.formatter.mN} ${j.year}';
      }
      return iso;
    } catch (_) {
      return iso;
    }
  }
}

/// یک سطر اطلاعات (برچسب و مقدار)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: context.textSecondaryColor, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// جدول نمایش پارامترهای یک دسته‌بندی
class _CategoryTable extends StatelessWidget {
  final LabTestDetailCategory category;
  final AppLocalizations l10n;

  const _CategoryTable({required this.category, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // هدر دسته‌بندی
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: context.surfaceVariantColor,
            child: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          
          // هدر جدول
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.appDividerColor)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(l10n.parameterNameLabel, style: _headerStyle(context))),
                Expanded(flex: 2, child: Text(l10n.parameterValueLabel, textAlign: TextAlign.center, style: _headerStyle(context))),
                Expanded(flex: 2, child: Text(l10n.parameterUnitLabel, textAlign: TextAlign.center, style: _headerStyle(context))),
                Expanded(flex: 3, child: Text(l10n.normalRangeLabel, textAlign: TextAlign.center, style: _headerStyle(context))),
              ],
            ),
          ),

          // سطرهای پارامترها
          ...category.parameters.map((p) => _ParameterRow(parameter: p, l10n: l10n)),
        ],
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    return TextStyle(fontSize: 12, color: context.textSecondaryColor, fontWeight: FontWeight.bold);
  }
}

/// یک سطر از پارامترها در جدول
class _ParameterRow extends StatelessWidget {
  final LabTestDetailParameter parameter;
  final AppLocalizations l10n;

  const _ParameterRow({required this.parameter, required this.l10n});

  @override
  Widget build(BuildContext context) {
    // اگر مقدار خارج از محدوده بود، رنگ آن را تغییر می‌دهیم
    final isHigh = parameter.flag == 'H';
    final isLow = parameter.flag == 'L';
    final valueColor = isHigh ? AppTheme.error : (isLow ? AppTheme.info : context.textPrimaryColor);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appDividerColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(parameter.name, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              parameter.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valueColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              parameter.unit ?? '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              (parameter.refMin != null || parameter.refMax != null)
                  ? '${parameter.refMin ?? '-'} - ${parameter.refMax ?? '-'}'
                  : '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// بخش توصیه‌های پزشک با آیکون گوشی پزشکی
class _DoctorSuggestionsSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _DoctorSuggestionsSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.push(AppConstants.doctorAdviceRoute),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: context.softTealBg,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services, color: AppTheme.success, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.doctorSuggestions,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          l10n.doctorSuggestionsDescription,
          style: TextStyle(fontSize: 13, height: 1.6, color: context.textSecondaryColor),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => context.push(AppConstants.doctorAdviceRoute),
            child: Text(l10n.viewAllAdvice),
          ),
        ),
      ],
    );
  }
}

/// لینک "بیشتر بخوانید"
class _ReadMoreLink extends StatelessWidget {
  final String text;

  const _ReadMoreLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppConstants.blogListRoute),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.info,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}