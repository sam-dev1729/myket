import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../series_controller.dart';

/// Bottom sheet that lets the user pick one or more analytes to plot.
///
/// Pops with a `List<String>` of analyte ids on submit, or `null` on cancel.
class AnalytePickerSheet extends ConsumerStatefulWidget {
  /// Analyte ids that are already selected (pre-checked on open).
  final List<String> initialSelection;

  const AnalytePickerSheet({super.key, this.initialSelection = const []});

  @override
  ConsumerState<AnalytePickerSheet> createState() => _AnalytePickerSheetState();
}

class _AnalytePickerSheetState extends ConsumerState<AnalytePickerSheet> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelection};
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.infiniteScrollThreshold) {
      ref.read(userAnalytesControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounceDuration, () {
      ref.read(userAnalytesControllerProvider.notifier).search(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(userAnalytesControllerProvider);

    return Container(
      height: MediaQuery.of(context).size.height * AppConstants.bottomSheetHeightFactor,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.largeCardRadius)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Text(
              l10n.analytePickerTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.analytePickerSearchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(userAnalytesControllerProvider),
                  child: Text(l10n.retry),
                ),
              ),
              data: (data) {
                if (data.items.isEmpty) {
                  return Center(child: Text(l10n.analytePickerEmpty));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: data.items.length,
                  itemBuilder: (_, i) {
                    final a = data.items[i];
                    final checked = _selected.contains(a.id);
                    return CheckboxListTile(
                      value: checked,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(a.id);
                          } else {
                            _selected.remove(a.id);
                          }
                        });
                      },
                      title: Text(a.name),
                      subtitle: a.canonicalUnit != null ? Text(a.canonicalUnit!) : null,
                      activeColor: AppTheme.primary,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, AppConstants.financialButtonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () => Navigator.pop(context, _selected.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size(0, AppConstants.financialButtonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                      ),
                    ),
                    child: Text(
                      l10n.analytePickerSubmit,
                      style: const TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
