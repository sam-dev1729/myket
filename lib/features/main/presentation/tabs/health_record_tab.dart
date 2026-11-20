import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../lab_test/data/models/lab_test_models.dart';
import '../../../lab_test/presentation/health_overview_provider.dart';
import '../../../lab_test/presentation/widgets/human_body_view.dart';

// ─────────────────────────────────────────────────────────────
// نگاشت آزمایش ← اندام
// این جدول فقط یک نقطه‌ی شروع است؛ با کدها و نام‌های واقعی آزمایش‌های
// خودتان تطبیق بدهید.
// ─────────────────────────────────────────────────────────────

/// تطبیق دقیق با کد آزمایش (حروف کوچک). برای کدهای کوتاه که با جستجوی
/// «شامل بودن» اشتباه می‌شوند (مثل ast که داخل fasting هم هست).
const _organByCode = <String, String>{
  'alt': 'liver',
  'ast': 'liver',
  'alp': 'liver',
  'ggt': 'liver',
  'sgpt': 'liver',
  'sgot': 'liver',
  'cr': 'kidneys',
  'bun': 'kidneys',
  'egfr': 'kidneys',
  'tsh': 'thyroid',
  't3': 'thyroid',
  't4': 'thyroid',
  'ft3': 'thyroid',
  'ft4': 'thyroid',
  'ldl': 'heart',
  'hdl': 'heart',
  'tg': 'heart',
  'chol': 'heart',
  'ckmb': 'heart',
  'fbs': 'pancreas',
  'hba1c': 'pancreas',
  'a1c': 'pancreas',
  'hb': 'vessels',
  'hgb': 'vessels',
  'hct': 'vessels',
  'wbc': 'vessels',
  'rbc': 'vessels',
  'plt': 'vessels',
  'esr': 'vessels',
  'crp': 'vessels',
};

/// جستجوی «شامل بودن» در نام آزمایش (حروف کوچک). فقط کلمات بلند.
const _organKeywords = <String, List<String>>{
  'liver': ['bilirubin', 'albumin', 'بیلی', 'آلبومین', 'آلانین', 'آسپارتات', 'کبدی'],
  'kidneys': ['creatinine', 'urea', 'uric', 'کراتینین', 'اوره', 'اوریک'],
  'thyroid': ['thyroid', 'تیروئید', 'تیروکسین'],
  'heart': ['cholesterol', 'triglyceride', 'troponin', 'کلسترول', 'گلیسرید', 'تروپونین'],
  'pancreas': ['glucose', 'amylase', 'lipase', 'insulin', 'قند', 'آمیلاز', 'لیپاز', 'انسولین'],
  'bones': ['calcium', 'vitamin d', 'phosph', 'کلسیم', 'ویتامین', 'فسفر'],
  'vessels': ['hemoglobin', 'platelet', 'هموگلوبین', 'پلاکت', 'گلبول'],
  'stomach': ['pylori', 'پیلوری'],
  'adrenals': ['cortisol', 'کورتیزول'],
};

String? _organOf(HealthKeyMarker m) {
  final code = (m.code ?? '').toLowerCase().trim();
  final byCode = _organByCode[code];
  if (byCode != null) return byCode;

  final name = (m.name ?? '').toLowerCase();
  for (final entry in _organKeywords.entries) {
    for (final keyword in entry.value) {
      if (name.contains(keyword)) return entry.key;
    }
  }
  return null;
}

int _severity(String? status) {
  switch (status?.toLowerCase()) {
    case HealthOverviewStatus.red:
      return 3;
    case HealthOverviewStatus.orange:
      return 2;
    case HealthOverviewStatus.green:
      return 1;
    default:
      return 0;
  }
}

/// برای هر اندام بدترین وضعیت بین آزمایش‌های مربوط به آن را برمی‌گرداند.
Map<String, OrganStatus> _organStatuses(List<HealthKeyMarker> markers) {
  final worst = <String, int>{};
  for (final m in markers) {
    final organ = _organOf(m);
    if (organ == null) continue;
    final sev = _severity(m.status);
    if (sev == 0) continue;
    if (sev > (worst[organ] ?? 0)) worst[organ] = sev;
  }
  return {
    for (final e in worst.entries)
      e.key: switch (e.value) {
        3 => OrganStatus.abnormal,
        2 => OrganStatus.attention,
        _ => OrganStatus.normal,
      },
  };
}

/// The "Health Record" tab that renders the AI-driven health overview.
class HealthRecordTab extends ConsumerWidget {
  const HealthRecordTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final overviewAsync = ref.watch(healthOverviewProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopIconBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(healthOverviewProvider);
                  await ref.read(healthOverviewProvider.future);
                },
                child: overviewAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      _ErrorView(onRetry: () => ref.invalidate(healthOverviewProvider)),
                  data: (overview) => _OverviewBody(overview: overview, l10n: l10n),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Body of the tab when data is available.
class _OverviewBody extends StatelessWidget {
  final HealthOverview overview;
  final AppLocalizations l10n;

  const _OverviewBody({required this.overview, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (overview.overallStatus == null && overview.keyMarkers.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
        children: [
          const SizedBox(height: AppConstants.paddingXLarge),
          Icon(Icons.monitor_heart_outlined, size: 80, color: context.textTertiaryColor),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            l10n.healthOverviewNoData,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
          ),
        ],
      );
    }

    final status = overview.overallStatus;
    final gaugeValue = _statusToGaugeValue(status);
    final statusColor = _statusToColor(context, status);
    final statusLabel = _statusToLabel(status, l10n);
    final organStatuses = _organStatuses(overview.keyMarkers);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      children: [
        const SizedBox(height: AppConstants.paddingMedium),

        // ─── بخش آدمک تعاملی (Body Map) ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.largeCardRadius),
            border: Border.all(color: context.appDividerColor),
          ),
          child: Column(
            children: [
              Text(
                'نقشه تعاملی بدن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'برای مشاهده وضعیت هر اندام، روی آن کلیک کنید.',
                style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
              ),
              const SizedBox(height: 24),

              // نمایش آدمک (نسبت تصویر را خود HumanBodyView تنظیم می‌کند)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: context.softTealBg,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: SizedBox(
                  height: 520,
                  child: Center(
                    child: HumanBodyView(
                      statuses: organStatuses,
                      onOrganTap: (organ) => _showOrganSheet(context, organ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const HumanBodyLegend(),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),

        // ─── بخش گیج سلامت ───
        _SectionTitle(title: l10n.overallHealth),
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.largeCardRadius),
            border: Border.all(color: context.appDividerColor),
          ),
          child: Column(
            children: [
              SizedBox(
                width: AppConstants.healthGaugeSize,
                height: AppConstants.healthGaugeSize * 0.75,
                child: CustomPaint(
                  painter: _HealthGaugePainter(
                    value: gaugeValue,
                    strokeWidth: AppConstants.healthGaugeStrokeWidth,
                    tickColor: context.textTertiaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                statusLabel,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.paddingMedium),
        SizedBox(
          width: double.infinity,
          height: AppConstants.financialButtonHeight,
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppConstants.labOverviewRoute),
            icon: const Icon(Icons.list_alt, color: AppTheme.info),
            label: Text(
              l10n.labOverviewSeeAllCta,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.info),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.info),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
              ),
            ),
          ),
        ),

        if (overview.keyMarkers.isNotEmpty) ...[
          const SizedBox(height: AppConstants.paddingXLarge),
          _SectionTitle(title: l10n.healthOverviewKeyMarkers),
          const SizedBox(height: AppConstants.paddingMedium),
          ...overview.keyMarkers.map((marker) => _KeyMarkerRow(marker: marker, l10n: l10n)),
        ],

        const SizedBox(height: AppConstants.paddingXLarge),
        _SectionTitle(title: l10n.doctorSuggestions),
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: context.softTealBg,
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.doctorSuggestions,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingTiny),
                    Text(
                      (overview.advice != null && overview.advice!.isNotEmpty)
                          ? overview.advice!
                          : l10n.doctorSuggestionsDescription,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: AppTheme.success,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.paddingXLarge),
      ],
    );
  }

  /// با لمس یک اندام، آزمایش‌های مربوط به آن را نشان می‌دهد.
  void _showOrganSheet(BuildContext context, OrganInfo organ) {
    final related = overview.keyMarkers.where((m) => _organOf(m) == organ.id).toList();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.screenPadding,
            0,
            AppConstants.screenPadding,
            AppConstants.paddingLarge,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bodyOrganName(l10n, organ.id),
                  style: sheetContext.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: sheetContext.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                if (related.isEmpty)
                  Text(
                    l10n.bodyNoTestsForOrgan,
                    style: sheetContext.textTheme.bodySmall?.copyWith(
                      color: sheetContext.textSecondaryColor,
                    ),
                  )
                else
                  ...related.map((m) => _KeyMarkerRow(marker: m, l10n: l10n)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _statusToGaugeValue(String? status) {
    switch (status?.toLowerCase()) {
      case HealthOverviewStatus.green:
        return 0.25;
      case HealthOverviewStatus.orange:
        return 0.6;
      case HealthOverviewStatus.red:
        return 0.9;
      default:
        return 0.5;
    }
  }

  Color _statusToColor(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case HealthOverviewStatus.green:
        return AppTheme.gaugeGreen;
      case HealthOverviewStatus.orange:
        return AppTheme.gaugeYellow;
      case HealthOverviewStatus.red:
        return AppTheme.gaugeRed;
      default:
        return context.textTertiaryColor;
    }
  }

  String _statusToLabel(String? status, AppLocalizations l10n) {
    switch (status?.toLowerCase()) {
      case HealthOverviewStatus.green:
        return l10n.gaugeStatusHealthy;
      case HealthOverviewStatus.orange:
        return l10n.gaugeStatusWarning;
      case HealthOverviewStatus.red:
        return l10n.gaugeStatusDanger;
      default:
        return l10n.noData;
    }
  }
}

/// A single key-marker row (name + value + range + flag dot).
class _KeyMarkerRow extends StatelessWidget {
  final HealthKeyMarker marker;
  final AppLocalizations l10n;

  const _KeyMarkerRow({required this.marker, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = _markerColor(context, marker.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: context.appDividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              marker.name ?? marker.code ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Text(
            '${marker.value ?? '-'}${marker.unit != null ? ' ${marker.unit}' : ''}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            _rangeLabel(marker.refMin, marker.refMax),
            style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
          ),
        ],
      ),
    );
  }

  Color _markerColor(BuildContext context, String? status) {
    switch (status?.toLowerCase()) {
      case HealthOverviewStatus.green:
        return AppTheme.gaugeGreen;
      case HealthOverviewStatus.orange:
        return AppTheme.gaugeYellow;
      case HealthOverviewStatus.red:
        return AppTheme.gaugeRed;
      default:
        return context.textTertiaryColor;
    }
  }

  String _rangeLabel(String? min, String? max) {
    if (min == null && max == null) return '';
    return '${min ?? '-'} - ${max ?? '-'}';
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: AppConstants.paddingSmall),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}

class _TopIconBar extends StatelessWidget {
  const _TopIconBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
        vertical: AppConstants.paddingMedium,
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.headset_mic_outlined, onTap: () {}),
          const SizedBox(width: AppConstants.paddingSmall),
          _CircleIconButton(
            icon: Icons.settings_outlined,
            onTap: () => context.push(AppConstants.settingsRoute),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          _CircleIconButton(icon: Icons.notifications_none, onTap: () {}, showBadge: true),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  const _CircleIconButton({required this.icon, required this.onTap, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: context.appDividerColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: context.iconColor, size: 20)),
            if (showBadge)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTheme.error, shape: BoxShape.circle),
                ),
              ),
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
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
    );
  }
}

class _HealthGaugePainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color tickColor;

  _HealthGaugePainter({
    required this.value,
    required this.strokeWidth,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) - strokeWidth / 2;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    const segments = [
      (AppTheme.gaugeGreen, 0.0, 0.5),
      (AppTheme.gaugeYellow, 0.5, 0.75),
      (AppTheme.gaugeRed, 0.75, 1.0),
    ];
    for (final (color, start, end) in segments) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + sweepAngle * start,
        sweepAngle * (end - start),
        false,
        paint,
      );
    }

    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2;
    for (int i = 0; i <= 8; i++) {
      final t = i / 8;
      final angle = startAngle + sweepAngle * t;
      final outer = Offset(
        center.dx + (radius - strokeWidth / 2 - 4) * math.cos(angle),
        center.dy + (radius - strokeWidth / 2 - 4) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - strokeWidth / 2 - 12) * math.cos(angle),
        center.dy + (radius - strokeWidth / 2 - 12) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    final needleAngle = startAngle + sweepAngle * value;
    final needleEnd = Offset(
      center.dx + (radius - strokeWidth - 12) * math.cos(needleAngle),
      center.dy + (radius - strokeWidth - 12) * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = AppTheme.gaugeNeedle
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    canvas.drawCircle(center, 6, Paint()..color = AppTheme.gaugeNeedle);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _HealthGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.tickColor != tickColor;
  }
}
