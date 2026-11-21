import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter/material.dart';

/// Formats a backend date (`YYYY-MM-DD`) for display.
///
/// Persian locale renders a Jalali date (`۳۱ اردیبهشت ۱۴۰۳`), other locales
/// keep the ISO date. Returns [fallback] when the value is empty/invalid.
String formatLabTestDate(
  BuildContext context,
  String? iso, {
  String fallback = '-',
}) {
  if (iso == null || iso.isEmpty) return fallback;
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
