import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Semicircular health gauge used on the Health Record tab and the
/// health report screen.
///
/// The gauge is purely visual: [value] is a 0..1 position on the arc where
/// 0 means the green (healthy) end and 1 the red (danger) end.
class HealthGauge extends StatelessWidget {
  const HealthGauge({
    super.key,
    required this.value,
    required this.tickColor,
    this.size = AppConstants.healthGaugeSize,
  });

  /// Needle position, clamped to the 0..1 range.
  final double value;

  /// Color of the small tick marks and labels inside the dial.
  final Color tickColor;

  /// Width of the gauge; its height is 75% of this value.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(
        painter: HealthGaugePainter(
          value: value.clamp(0, 1).toDouble(),
          strokeWidth: AppConstants.healthGaugeStrokeWidth,
          tickColor: tickColor,
        ),
      ),
    );
  }
}

/// Paints the gauge arc, ticks and needle.
class HealthGaugePainter extends CustomPainter {
  HealthGaugePainter({
    required this.value,
    required this.strokeWidth,
    required this.tickColor,
  });

  /// Needle position (0..1).
  final double value;

  /// Thickness of the colored arc.
  final double strokeWidth;

  /// Color used for tick marks.
  final Color tickColor;

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
  bool shouldRepaint(covariant HealthGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.tickColor != tickColor;
  }
}
