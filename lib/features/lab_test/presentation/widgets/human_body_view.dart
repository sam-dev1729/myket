import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Health status of a single organ shown on the body map.
enum OrganStatus { normal, attention, abnormal }

/// A tappable organ layer of the body map.
class OrganInfo {
  const OrganInfo(this.id, this.anchors);

  /// Asset file name (without extension) under `assets/body/`.
  final String id;

  /// Anchor points (in the SVG `viewBox` coordinate space) used both for
  /// the status markers and for hit-testing taps.
  final List<Offset> anchors;
}

/// The SVG viewBox that contains the full body illustration.
const kBodyViewBox = Rect.fromLTWH(110, 510, 860, 1550);

/// Every organ layer, in no particular draw order.
const kOrgans = <OrganInfo>[
  OrganInfo('brain', [Offset(541, 598)]),
  OrganInfo('thyroid', [Offset(541, 806)]),
  OrganInfo('lungs', [Offset(445, 975), Offset(637, 975)]),
  OrganInfo('heart', [Offset(560, 985)]),
  OrganInfo('liver', [Offset(470, 1135)]),
  OrganInfo('gallbladder', [Offset(478, 1205)]),
  OrganInfo('stomach', [Offset(625, 1165)]),
  OrganInfo('spleen', [Offset(702, 1168)]),
  OrganInfo('pancreas', [Offset(565, 1276)]),
  OrganInfo('kidneys', [Offset(445, 1340), Offset(637, 1340)]),
  OrganInfo('adrenals', [Offset(452, 1277), Offset(630, 1277)]),
  OrganInfo('small_intestine', [Offset(549, 1348)]),
  OrganInfo('large_intestine', [Offset(686, 1320)]),
  OrganInfo('bladder', [Offset(541, 1514)]),
  OrganInfo('bones', [Offset(409, 1560), Offset(673, 1560)]),
  OrganInfo('nerves', [Offset(325, 970)]),
  OrganInfo('vessels', [Offset(800, 1110)]),
];

/// Draw order for the SVG layers (back to front).
const _layerOrder = <String>[
  'body',
  'bones',
  'large_intestine',
  'pancreas',
  'small_intestine',
  'kidneys',
  'adrenals',
  'spleen',
  'liver',
  'gallbladder',
  'stomach',
  'bladder',
  'lungs',
  'heart',
  'thyroid',
  'nerves',
  'brain',
  'vessels',
];

/// Tap radius (in viewBox units) around an organ anchor.
const double _tapRadius = 70;

/// Diameter of a status marker on the body map.
const double _markerSize = 26;

/// Icon size inside a status marker.
const double _markerIconSize = 15;

/// Border width of a status marker.
const double _markerBorderWidth = 2;

/// Alpha applied to the organ layer when it has an abnormal status.
const double _statusAlpha = 0.5;

/// Diameter of the legend color dot.
const double _legendDotSize = 10;

/// Horizontal gap between the legend dot and its label.
const double _legendDotGap = 6;

/// Horizontal spacing between legend items.
const double _legendSpacing = 18;

/// Vertical spacing between wrapped legend rows.
const double _legendRunSpacing = 8;

/// Localized display name for an organ [id].
String bodyOrganName(AppLocalizations l10n, String id) {
  switch (id) {
    case 'brain':
      return l10n.bodyOrganBrain;
    case 'thyroid':
      return l10n.bodyOrganThyroid;
    case 'lungs':
      return l10n.bodyOrganLungs;
    case 'heart':
      return l10n.bodyOrganHeart;
    case 'liver':
      return l10n.bodyOrganLiver;
    case 'gallbladder':
      return l10n.bodyOrganGallbladder;
    case 'stomach':
      return l10n.bodyOrganStomach;
    case 'spleen':
      return l10n.bodyOrganSpleen;
    case 'pancreas':
      return l10n.bodyOrganPancreas;
    case 'kidneys':
      return l10n.bodyOrganKidneys;
    case 'adrenals':
      return l10n.bodyOrganAdrenals;
    case 'small_intestine':
      return l10n.bodyOrganSmallIntestine;
    case 'large_intestine':
      return l10n.bodyOrganLargeIntestine;
    case 'bladder':
      return l10n.bodyOrganBladder;
    case 'bones':
      return l10n.bodyOrganBones;
    case 'nerves':
      return l10n.bodyOrganNerves;
    case 'vessels':
      return l10n.bodyOrganVessels;
    default:
      return id;
  }
}

/// Localized label for a health [status].
String bodyStatusName(AppLocalizations l10n, OrganStatus status) {
  switch (status) {
    case OrganStatus.normal:
      return l10n.bodyStatusNormal;
    case OrganStatus.attention:
      return l10n.bodyStatusAttention;
    case OrganStatus.abnormal:
      return l10n.bodyStatusAbnormal;
  }
}

/// Renders the layered SVG body map and overlays status markers.
///
/// Only organs present in [statuses] are highlighted and tappable; the rest
/// are rendered as normal anatomy. [onOrganTap] receives the tapped organ.
class HumanBodyView extends StatelessWidget {
  const HumanBodyView({
    super.key,
    this.statuses = const {},
    this.onOrganTap,
    this.assetDir = 'assets/body',
  });

  /// Organ id to status, e.g. `{'liver': OrganStatus.abnormal}`.
  final Map<String, OrganStatus> statuses;

  /// Called when the user taps an organ anchor.
  final void Function(OrganInfo organ)? onOrganTap;

  /// Directory containing the per-organ SVG assets.
  final String assetDir;

  /// Theme color used for [status].
  static Color colorOf(OrganStatus status) => switch (status) {
    OrganStatus.normal => AppTheme.success,
    OrganStatus.attention => AppTheme.warning,
    OrganStatus.abnormal => AppTheme.error,
  };

  /// Theme icon used for [status].
  static IconData iconOf(OrganStatus status) => switch (status) {
    OrganStatus.normal => Icons.check_rounded,
    OrganStatus.attention => Icons.priority_high_rounded,
    OrganStatus.abnormal => Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kBodyViewBox.width / kBodyViewBox.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / kBodyViewBox.width;

          Offset toLocal(Offset anchor) => Offset(
            (anchor.dx - kBodyViewBox.left) * scale,
            (anchor.dy - kBodyViewBox.top) * scale,
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              if (onOrganTap == null) return;
              OrganInfo? best;
              var bestDistance = _tapRadius;
              final point = Offset(
                details.localPosition.dx / scale + kBodyViewBox.left,
                details.localPosition.dy / scale + kBodyViewBox.top,
              );
              for (final organ in kOrgans) {
                for (final anchor in organ.anchors) {
                  final distance = (anchor - point).distance;
                  if (distance < bestDistance) {
                    bestDistance = distance;
                    best = organ;
                  }
                }
              }
              if (best != null) onOrganTap!(best);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (final id in _layerOrder)
                  SvgPicture.asset(
                    '$assetDir/$id.svg',
                    fit: BoxFit.fill,
                    colorFilter: switch (statuses[id]) {
                      null || OrganStatus.normal => null,
                      final status => ColorFilter.mode(
                        colorOf(status).withValues(alpha: _statusAlpha),
                        BlendMode.srcATop,
                      ),
                    },
                  ),
                for (final organ in kOrgans)
                  if (statuses[organ.id] != null)
                    for (final anchor in organ.anchors)
                      Positioned(
                        left: toLocal(anchor).dx - _markerSize / 2,
                        top: toLocal(anchor).dy - _markerSize / 2,
                        width: _markerSize,
                        height: _markerSize,
                        child: IgnorePointer(
                          child: _Marker(status: statuses[organ.id]!),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A colored status dot rendered on top of an organ anchor.
class _Marker extends StatelessWidget {
  const _Marker({required this.status});

  final OrganStatus status;

  @override
  Widget build(BuildContext context) {
    final color = HumanBodyView.colorOf(status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: _markerBorderWidth),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Icon(
        HumanBodyView.iconOf(status),
        size: _markerIconSize,
        color: Colors.white,
      ),
    );
  }
}

/// Color legend displayed below the body map.
class HumanBodyLegend extends StatelessWidget {
  const HumanBodyLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: _legendSpacing,
      runSpacing: _legendRunSpacing,
      children: [
        for (final status in OrganStatus.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _legendDotSize,
                height: _legendDotSize,
                decoration: BoxDecoration(
                  color: HumanBodyView.colorOf(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: _legendDotGap),
              Text(
                bodyStatusName(l10n, status),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
