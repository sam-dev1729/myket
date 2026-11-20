import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

/// Localized display name for [id].
String appThemeName(AppThemeId id, AppLocalizations l10n) {
  switch (id) {
    case AppThemeId.vital:
      return l10n.themeVital;
    case AppThemeId.healing:
      return l10n.themeHealing;
    case AppThemeId.teal:
      return l10n.themeTeal;
    case AppThemeId.classic:
      return l10n.themeClassic;
    case AppThemeId.dark:
      return l10n.themeDark;
  }
}

/// Bottom sheet that lets the user preview and switch between the app themes.
class ThemePickerSheet extends ConsumerWidget {
  const ThemePickerSheet({super.key});

  /// Opens the theme picker as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ThemePickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedThemeProvider);

    void select(AppThemeId id) {
      if (selected == id) {
        Navigator.of(context).pop();
        return;
      }
      HapticFeedback.selectionClick();
      ref.read(appThemeProvider.notifier).setTheme(id);
      Navigator.of(context).pop();
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppConstants.screenPadding,
          0,
          AppConstants.screenPadding,
          AppConstants.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.themeLabel,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.paddingTiny),
            Text(
              l10n.themePickerHint,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _GroupLabel(label: l10n.themeLightGroup),
            const SizedBox(height: AppConstants.paddingSmall),
            for (final palette in AppPalette.lightPalettes)
              _ThemeOption(
                palette: palette,
                name: appThemeName(palette.id, l10n),
                selected: palette.id == selected,
                onTap: () => select(palette.id),
              ),
            const SizedBox(height: AppConstants.paddingSmall),
            _GroupLabel(label: l10n.themeDarkGroup),
            const SizedBox(height: AppConstants.paddingSmall),
            for (final palette in AppPalette.darkPalettes)
              _ThemeOption(
                palette: palette,
                name: appThemeName(palette.id, l10n),
                selected: palette.id == selected,
                onTap: () => select(palette.id),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small section label inside the picker.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.textTertiaryColor,
      ),
    );
  }
}

/// A single selectable theme row with a mini preview and its hex colors.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.palette,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final AppPalette palette;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? palette.primary : palette.divider;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          child: AnimatedContainer(
            duration: AppConstants.themeSelectAnimation,
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              border: Border.all(
                color: borderColor,
                width: selected ? AppConstants.borderWidthFocused : 1,
              ),
            ),
            child: Row(
              children: [
                _MiniPreview(palette: palette),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingTiny),
                      Text(
                        '${_hex(palette.primary)} · ${_hex(palette.secondary)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: context.textTheme.bodySmall?.copyWith(
                          letterSpacing: 0.2,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: palette.primary, size: 22)
                else
                  Icon(Icons.circle_outlined, color: palette.divider, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formats [color] as `#RRGGBB`.
  static String _hex(Color color) {
    final value = color.toARGB32() & 0x00FFFFFF;
    return '#${value.toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }
}

/// Tiny "Aa" swatch that previews the palette's surface, text and accents.
class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.themePreviewWidth,
      height: AppConstants.themePreviewHeight,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.text_fields,
            size: 18,
            color: palette.textPrimary,
          ),
          const SizedBox(height: AppConstants.paddingTiny),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Dot(color: palette.primary),
              const SizedBox(width: 3),
              _Dot(color: palette.secondary),
              const SizedBox(width: 3),
              _Dot(color: palette.accent),
            ],
          ),
        ],
      ),
    );
  }
}

/// A small color dot used inside [_MiniPreview].
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppConstants.themePreviewDotSize,
      height: AppConstants.themePreviewDotSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
