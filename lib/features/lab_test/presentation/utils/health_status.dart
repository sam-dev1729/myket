import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Gauge needle position for an overall health status string.
double healthStatusGaugeValue(String? status) {
  switch (status?.toLowerCase()) {
    case 'green':
      return 0.25;
    case 'orange':
      return 0.6;
    case 'red':
      return 0.9;
    default:
      return 0.5;
  }
}

/// Semantic color for an overall health status string.
Color healthStatusColor(BuildContext context, String? status) {
  switch (status?.toLowerCase()) {
    case 'green':
      return AppTheme.gaugeGreen;
    case 'orange':
      return AppTheme.gaugeYellow;
    case 'red':
      return AppTheme.gaugeRed;
    default:
      return context.textTertiaryColor;
  }
}

/// Localized label for an overall health status string.
String healthStatusLabel(String? status, AppLocalizations l10n) {
  switch (status?.toLowerCase()) {
    case 'green':
      return l10n.gaugeStatusHealthy;
    case 'orange':
      return l10n.gaugeStatusWarning;
    case 'red':
      return l10n.gaugeStatusDanger;
    default:
      return l10n.noData;
  }
}

/// Severity rank used to pick the worst status among markers.
int healthStatusSeverity(String? status) {
  switch (status?.toLowerCase()) {
    case 'red':
      return 3;
    case 'orange':
      return 2;
    case 'green':
      return 1;
    default:
      return 0;
  }
}
