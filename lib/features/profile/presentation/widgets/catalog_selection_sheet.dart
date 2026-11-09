import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/catalog_repository.dart';
import '../../data/models/catalog_models.dart';
import '../../data/models/catalog_type.dart';
import 'custom_catalog_item_dialog.dart';

/// Result returned by [CatalogSelectionSheet] on submit.
class CatalogSelectionResult {
  final List<CatalogItem> selectedItems;
  final bool iDontHave;

  const CatalogSelectionResult({required this.selectedItems, required this.iDontHave});
}

/// Reusable bottom sheet to select / add medical catalog items
/// (Allergies, Diseases, or Medical Histories).
///
/// **Sprint 14 additions:**
/// - `type` parameter to know which `create*` endpoint to call.
/// - Inline "Add new item" button.
class CatalogSelectionSheet extends ConsumerStatefulWidget {
  final String title;
  final List<CatalogItem> allItems;
  final List<String> selectedItemIds;
  final CatalogType type;

  const CatalogSelectionSheet({
    super.key,
    required this.title,
    required this.allItems,
    required this.selectedItemIds,
    required this.type,
  });

  @override
  ConsumerState<CatalogSelectionSheet> createState() => _CatalogSelectionSheetState();
}

class _CatalogSelectionSheetState extends ConsumerState<CatalogSelectionSheet> {
  late List<CatalogItem> _allItems;
  late List<CatalogItem> _filteredItems;
  final TextEditingController _searchController = TextEditingController();
  late Set<String> _selectedIds;
  bool _iDontHave = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _allItems = [...widget.allItems];
    _filteredItems = _allItems;
    _selectedIds = widget.selectedItemIds.toSet();
    _iDontHave = _selectedIds.isEmpty;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleItem(CatalogItem item, bool? value) {
    setState(() {
      if (value == true) {
        _iDontHave = false;
        _selectedIds.add(item.id);
      } else {
        _selectedIds.remove(item.id);
        if (_selectedIds.isEmpty) _iDontHave = true;
      }
    });
  }

  void _toggleDontHave(bool? value) {
    setState(() {
      _iDontHave = value ?? false;
      if (_iDontHave) _selectedIds.clear();
    });
  }

  /// Opens a dialog for entering a custom name, then calls the matching
  /// `create*` endpoint on [CatalogRepository]. Auto-selects the new item.
  Future<void> _addCustomItem(AppLocalizations l10n) async {
    final name = await CustomCatalogItemDialog.show(
      context,
      title: l10n.addNewItemTitle(widget.title),
    );
    if (name == null) return;

    setState(() => _isAdding = true);
    try {
      final repo = ref.read(catalogRepositoryProvider);
      CatalogItem created;
      switch (widget.type) {
        case CatalogType.allergy:
          created = await repo.createAllergy(name);
          break;
        case CatalogType.disease:
          created = await repo.createDisease(name);
          break;
        case CatalogType.history:
          created = await repo.createHistory(name);
          break;
      }
      setState(() {
        _allItems.add(created);
        _selectedIds.add(created.id);
        _iDontHave = false;
        _onSearchChanged(_searchController.text);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.genericErrorPrefix}: $e'), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * AppConstants.bottomSheetHeightFactor,
      decoration: BoxDecoration(
        color: context.surfaceColor,
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
                color: context.textTertiaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: l10n.addNewItemTooltip,
                  icon: _isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                  onPressed: _isAdding ? null : () => _addCustomItem(l10n),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: context.surfaceVariantColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          CheckboxListTile(
            title: Text(l10n.iDontHaveAny, style: const TextStyle(fontWeight: FontWeight.bold)),
            value: _iDontHave,
            activeColor: AppTheme.primary,
            onChanged: _toggleDontHave,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const Divider(height: 1),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(child: Text(l10n.noItemsFound))
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = _selectedIds.contains(item.id);
                      return CheckboxListTile(
                        title: Text(item.name),
                        value: isSelected,
                        activeColor: AppTheme.primary,
                        onChanged: _iDontHave ? null : (v) => _toggleItem(item, v),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: SizedBox(
              width: double.infinity,
              height: AppConstants.financialButtonHeight,
              child: ElevatedButton(
                onPressed: () {
                  final selectedItems = _allItems
                      .where((e) => _selectedIds.contains(e.id))
                      .toList();
                  Navigator.pop(
                    context,
                    CatalogSelectionResult(selectedItems: selectedItems, iDontHave: _iDontHave),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    color: AppTheme.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
