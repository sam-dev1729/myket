import 'package:flutter/material.dart';

/// A direction-aware trailing arrow that points to the "forward" direction
/// of the current locale:
/// - In **LTR** (English), it points to the **right** (`>`).
/// - In **RTL** (Persian/Arabic), it points to the **left** (`<`).
///
/// ## Why only [Icons.chevron_right]?
///
/// Flutter's Material Icons have a `matchTextDirection` flag. When `true`,
/// the icon is **automatically mirrored** under RTL. In recent Flutter
/// versions this flag is `true` for *all* of these arrows:
///
/// - `arrow_back_ios_new`, `arrow_forward_ios`
/// - `chevron_left`, `chevron_right`
///
/// The naive approach — `isRtl ? chevron_left : chevron_right` — produces
/// a **double-flip** in RTL: `chevron_left` is picked, but Flutter then
/// mirrors it (because `matchTextDirection: true`) and it ends up pointing
/// right (`>`), which is the wrong direction for a trailing arrow in Persian.
///
/// The bulletproof fix is to always use **one** forward-pointing icon and
/// let Flutter handle the mirroring:
///
/// - LTR: `chevron_right` (`>`) → not mirrored → `>` ✅
/// - RTL: `chevron_right` (`>`) → auto-mirrored → `<` ✅
class TrailingArrow extends StatelessWidget {
  /// Size of the arrow icon (defaults to 18).
  final double size;

  /// Color of the arrow icon.
  final Color color;

  /// Creates a [TrailingArrow] instance.
  const TrailingArrow({super.key, this.size = 18, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      // Do not switch based on `Directionality.of(context)` here — Flutter
      // already mirrors this icon under RTL. Adding our own flip would
      // cancel it out and produce the wrong direction.
      Icons.chevron_right,
      size: size,
      color: color,
    );
  }
}
