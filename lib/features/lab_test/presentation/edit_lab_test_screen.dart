import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/optional.dart';
import '../../../l10n/app_localizations.dart';
import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';
import 'edit_lab_test_controller.dart';
import 'widgets/add_edit_category_dialog.dart';
import 'widgets/add_edit_header_dialog.dart';
import 'widgets/add_edit_parameter_dialog.dart';
import 'widgets/delete_category_dialog.dart';
import 'widgets/delete_parameter_dialog.dart';

/// Screen for editing a saved lab test (header + categories + parameters).
///
/// All CRUD operations are fully wired:
/// - header (test date, doctor, lab, address, test number)
/// - categories (add/edit/delete + reorder via drag-and-drop)
/// - parameters (add/edit/delete, including moving between categories
///   and reordering within a category via drag-and-drop)
class EditLabTestScreen extends ConsumerStatefulWidget {
  /// The id of the lab test to edit.
  final String id;

  const EditLabTestScreen({super.key, required this.id});

  @override
  ConsumerState<EditLabTestScreen> createState() => _EditLabTestScreenState();
}

class _EditLabTestScreenState extends ConsumerState<EditLabTestScreen> {
  @override
  void initState() {
    super.initState();
    // Cannot update provider state during build/initState — defer to the
    // first frame so `ref.read(...).initialize(...)` is safe.
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  /// Loads the detail and pushes it into the controller.
  ///
  /// Used both for initial load and for the AppBar's refresh action and
  /// the pull-to-refresh gesture. On failure:
  /// - if no detail exists yet (initial load), state goes to `error`;
  /// - if a detail already exists (refresh), a snackbar is shown and the
  ///   old data is preserved.
  Future<void> _init() async {
    try {
      final detail = await ref.read(labTestRepositoryProvider).getLabTestDetail(widget.id);
      if (!mounted) return;
      ref.read(editLabTestControllerProvider.notifier).initialize(detail);
    } catch (e) {
      if (!mounted) return;
      final current = ref.read(editLabTestControllerProvider);
      if (current.detail == null) {
        ref.read(editLabTestControllerProvider.notifier).setError(e.toString());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
      }
    }
  }

  /// Shows a success snackbar.
  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.success));
  }

  /// Shows an error snackbar.
  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.error));
  }

  /// Opens the add-category dialog and creates the new category.
  Future<void> _addCategory() async {
    if (ref.read(editLabTestControllerProvider).isMutating) return;
    final l10n = AppLocalizations.of(context)!;

    final name = await AddEditCategoryDialog.show(context);
    if (name == null) return;

    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final ok = await ref.read(editLabTestControllerProvider.notifier).createCategory(trimmed);

    if (!mounted) return;
    if (ok) {
      _showSnack(l10n.labTestUpdatedSuccess);
    } else {
      _showError(l10n.updateError);
    }
  }

  /// Opens the header edit dialog and submits the changes.
  ///
  /// Both [HeaderFormData] and [UpdateLabTestHeaderRequest] use
  /// `Optional<String>` for every field (see PKG-011-001), so this
  /// method is a pure pass-through — the dialog already computed the
  /// absent/of/ofNullable state per field.
  Future<void> _editHeader() async {
    if (ref.read(editLabTestControllerProvider).isMutating) return;
    final l10n = AppLocalizations.of(context)!;

    final detail = ref.read(editLabTestControllerProvider).detail;
    if (detail == null) return;

    final formData = await AddEditHeaderDialog.show(context, initialDetail: detail);
    if (formData == null) return;

    final ok = await ref
        .read(editLabTestControllerProvider.notifier)
        .updateHeader(
          UpdateLabTestHeaderRequest(
            testDate: formData.testDate,
            doctorName: formData.doctorName,
            labName: formData.labName,
            labAddress: formData.labAddress,
            testNumber: formData.testNumber,
          ),
        );

    if (!mounted) return;
    if (ok) {
      _showSnack(l10n.headerUpdatedSuccess);
    } else {
      _showError(l10n.updateError);
    }
  }

  /// Opens the add-parameter sheet and creates a parameter in [categoryId].
  Future<void> _addParameter(String categoryId) async {
    if (ref.read(editLabTestControllerProvider).isMutating) return;
    final l10n = AppLocalizations.of(context)!;

    final detail = ref.read(editLabTestControllerProvider).detail;
    if (detail == null) return;

    final formData = await AddEditParameterDialog.show(
      context,
      categories: detail.categories,
      initialCategoryId: categoryId,
    );
    if (formData == null) return;

    final ok = await ref
        .read(editLabTestControllerProvider.notifier)
        .createParameter(
          CreateLabTestParameterRequest(
            categoryId: formData.categoryId,
            name: formData.name,
            value: formData.value,
            unit: formData.unit.value,
            refMin: formData.refMin.value,
            refMax: formData.refMax.value,
            flag: formData.flag.value,
          ),
        );

    if (!mounted) return;
    if (ok) {
      _showSnack(l10n.parameterCreatedSuccess);
    } else {
      _showError(l10n.updateError);
    }
  }

  /// Opens the edit-parameter sheet and updates the parameter.
  ///
  /// Required fields (categoryId, name, value) are diffed against the
  /// original → [Optional.absent] when unchanged, otherwise
  /// [Optional.of]. Optional fields are pass-through from
  /// [ParameterFormData] (which already computed absent/of/ofNullable
  /// via [AddEditParameterDialog._submit]).
  Future<void> _editParameter(LabTestDetailParameter parameter) async {
    if (ref.read(editLabTestControllerProvider).isMutating) return;
    final l10n = AppLocalizations.of(context)!;

    final detail = ref.read(editLabTestControllerProvider).detail;
    if (detail == null) return;

    final formData = await AddEditParameterDialog.show(
      context,
      categories: detail.categories,
      initialCategoryId: parameter.categoryId,
      initialParameter: parameter,
    );
    if (formData == null) return;

    final ok = await ref
        .read(editLabTestControllerProvider.notifier)
        .updateParameter(
          parameter.id,
          UpdateLabTestParameterRequest(
            categoryId: _diff(formData.categoryId, parameter.categoryId),
            name: _diff(formData.name, parameter.name),
            value: _diff(formData.value, parameter.value),
            unit: formData.unit,
            refMin: formData.refMin,
            refMax: formData.refMax,
            flag: formData.flag,
          ),
        );

    if (!mounted) return;
    if (ok) {
      _showSnack(l10n.parameterUpdatedSuccess);
    } else {
      _showError(l10n.updateError);
    }
  }

  /// Opens the delete-parameter confirmation dialog and deletes on confirm.
  Future<void> _deleteParameter(LabTestDetailParameter parameter) async {
    if (ref.read(editLabTestControllerProvider).isMutating) return;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await DeleteParameterDialog.show(context, parameterName: parameter.name);
    if (!confirmed) return;

    final ok = await ref.read(editLabTestControllerProvider.notifier).deleteParameter(parameter.id);

    if (!mounted) return;
    if (ok) {
      _showSnack(l10n.parameterDeletedSuccess);
    } else {
      _showError(l10n.updateError);
    }
  }

  /// Returns [Optional.absent] if [current] equals [original], otherwise
  /// [Optional.of(current)]. Used for required fields that always have a value.
  Optional<T> _diff<T>(T current, T original) =>
      current == original ? const Optional.absent() : Optional.of(current);

  /// Persists a category drag-and-drop reorder.
  ///
  /// Index 0 in the [ReorderableListView] is the fixed header, so we
  /// subtract 1 to map back to `detail.categories` indices. Two early
  /// returns guard against impossible drops:
  /// - `oldIndex == 0`: the header itself can't be dragged.
  /// - `newIndex == 0`: dropping a category before the header has no
  ///   valid target slot (`n` would become -1).
  Future<void> _onReorderCategory(LabTestDetail detail, int oldIndex, int newIndex) async {
    if (oldIndex == 0) return; // header not reorderable
    if (newIndex == 0) return; // can't drop before header
    if (ref.read(editLabTestControllerProvider).isMutating) return;

    final l10n = AppLocalizations.of(context)!;

    // Convert ReorderableListView indices to category-list indices.
    var o = oldIndex - 1;
    var n = newIndex - 1;
    if (o < n) n -= 1;
    if (o == n) return;

    final items = [...detail.categories];
    final moved = items.removeAt(o);
    items.insert(n, moved);

    // Persist new sort_order for every category whose index changed.
    // Sent sequentially to avoid backend race conditions.
    var ok = true;
    for (var i = 0; i < items.length; i++) {
      final cat = items[i];
      if (cat.sortOrder == i) continue;
      final success = await ref
          .read(editLabTestControllerProvider.notifier)
          .updateCategory(cat.id, sortOrder: i);
      if (!success) {
        ok = false;
        break;
      }
    }

    if (!mounted) return;
    if (ok) {
      _showSnack(l10n.labTestUpdatedSuccess);
    } else {
      _showError(l10n.updateError);
    }
  }

  /// Persists a parameter drag-and-drop reorder within [category].
  ///
  /// Applies the standard [ReorderableListView] index adjustment
  /// (`newIndex > oldIndex` → `newIndex -= 1`) and updates the
  /// `sort_order` of every parameter whose position changed via
  /// [UpdateLabTestParameterRequest.sortOrder].
  Future<void> _onReorderParameter(
    LabTestDetailCategory category,
    int oldIndex,
    int newIndex,
  ) async {
    if (ref.read(editLabTestControllerProvider).isMutating) return;
    if (oldIndex == newIndex) return;

    final l10n = AppLocalizations.of(context)!;

    var n = newIndex;
    if (oldIndex < n) n -= 1;
    if (oldIndex == n) return;

    final items = [...category.parameters];
    final moved = items.removeAt(oldIndex);
    items.insert(n, moved);

    var ok = true;
    for (var i = 0; i < items.length; i++) {
      final p = items[i];
      if (p.sortOrder == i) continue;
      final success = await ref
          .read(editLabTestControllerProvider.notifier)
          .updateParameter(p.id, UpdateLabTestParameterRequest(sortOrder: Optional.of(i)));
      if (!success) {
        ok = false;
        break;
      }
    }

    if (!mounted) return;
    if (ok) {
      _showSnack(l10n.labTestUpdatedSuccess);
    } else {
      _showError(l10n.updateError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(editLabTestControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.editLabTestTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.black),
            onPressed: _init,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.isMutating) const LinearProgressIndicator(),
            Expanded(child: _buildBody(l10n, state)),
          ],
        ),
      ),
      floatingActionButton: state.status == EditLabTestStatus.success && state.detail != null
          ? FloatingActionButton.extended(
              onPressed: state.isMutating ? null : _addCategory,
              icon: const Icon(Icons.add),
              label: Text(l10n.addCategoryButton),
            )
          : null,
    );
  }

  /// Selects the appropriate widget subtree based on [state].
  Widget _buildBody(AppLocalizations l10n, EditLabTestState state) {
    switch (state.status) {
      case EditLabTestStatus.initial:
      case EditLabTestStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case EditLabTestStatus.error:
        // If we already have content (refresh failure with data), keep it;
        // only show the full error view when there's nothing to show.
        if (state.detail != null) {
          return _buildContent(l10n, state.detail!, state.isMutating);
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  '${l10n.genericErrorPrefix}: ${state.errorMessage ?? ''}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                TextButton(onPressed: _init, child: Text(l10n.retry)),
              ],
            ),
          ),
        );
      case EditLabTestStatus.success:
        if (state.detail == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(l10n, state.detail!, state.isMutating);
    }
  }

  /// Renders the header card + a reorderable list of categories.
  ///
  /// Index 0 is the fixed header (not draggable); indices 1..N map to
  /// `detail.categories[0..N-1]`.
  Widget _buildContent(AppLocalizations l10n, LabTestDetail detail, bool isMutating) {
    return RefreshIndicator(
      onRefresh: _init,
      child: ReorderableListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        itemCount: detail.categories.length + 1, // +1 for header
        onReorder: (oldIndex, newIndex) => _onReorderCategory(detail, oldIndex, newIndex),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              key: const ValueKey('header'),
              padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
              child: _HeaderCard(
                detail: detail,
                l10n: l10n,
                isMutating: isMutating,
                onEditTap: _editHeader,
              ),
            );
          }
          final categoryIndex = index - 1;
          final c = detail.categories[categoryIndex];
          return Padding(
            key: ValueKey('category_${c.id}'),
            padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: _CategoryCard(
              category: c,
              l10n: l10n,
              isMutating: isMutating,
              onEditTap: () async {
                final newName = await AddEditCategoryDialog.show(context, initialName: c.name);
                if (newName == null) return;
                final trimmed = newName.trim();
                if (trimmed.isEmpty || trimmed == c.name) return;

                final ok = await ref
                    .read(editLabTestControllerProvider.notifier)
                    .updateCategory(c.id, name: trimmed);

                if (!mounted) return;
                if (ok) {
                  _showSnack(l10n.labTestUpdatedSuccess);
                } else {
                  _showError(l10n.updateError);
                }
              },
              onDeleteTap: () async {
                final confirmed = await DeleteCategoryDialog.show(context, categoryName: c.name);
                if (!confirmed) return;

                final ok = await ref
                    .read(editLabTestControllerProvider.notifier)
                    .deleteCategory(c.id);

                if (!mounted) return;
                if (ok) {
                  _showSnack(l10n.labTestUpdatedSuccess);
                } else {
                  _showError(l10n.updateError);
                }
              },
              onAddParameterTap: () => _addParameter(c.id),
              onEditParameterTap: _editParameter,
              onDeleteParameterTap: _deleteParameter,
              onReorderParameter: (oldIdx, newIdx) => _onReorderParameter(c, oldIdx, newIdx),
            ),
          );
        },
      ),
    );
  }
}

/// Header card showing the lab test's editable header fields.
class _HeaderCard extends StatelessWidget {
  final LabTestDetail detail;
  final AppLocalizations l10n;
  final bool isMutating;
  final VoidCallback onEditTap;

  const _HeaderCard({
    required this.detail,
    required this.l10n,
    required this.isMutating,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.editHeaderTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: isMutating ? null : onEditTap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          _InfoRow(
            icon: Icons.calendar_today,
            label: l10n.testDate,
            value: detail.testDate ?? l10n.noData,
          ),
          _InfoRow(
            icon: Icons.person_outline,
            label: l10n.doctorName,
            value: detail.doctorName ?? l10n.noData,
          ),
          _InfoRow(
            icon: Icons.local_hospital,
            label: l10n.labName,
            value: detail.labName ?? l10n.noData,
          ),
          if (detail.labAddress != null && detail.labAddress!.isNotEmpty)
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: l10n.labTestDetailLabAddress,
              value: detail.labAddress!,
            ),
          if (detail.testNumber != null && detail.testNumber!.isNotEmpty)
            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: l10n.labTestDetailTestNumber,
              value: detail.testNumber!,
            ),
        ],
      ),
    );
  }
}

/// A single labeled row with a leading icon and end-aligned value.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingTiny),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: AppConstants.paddingSmall),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// A category card with expandable parameter list and edit/delete actions.
///
/// Uses [ListTileControlAffinity.leading] so the default expand/collapse
/// chevron sits on the leading side and the `trailing` slot is free for
/// our custom action icons (RTL-safe).
///
/// Parameters are wrapped in a [ReorderableListView] (with
/// `buildDefaultDragHandles: false` and a custom
/// [ReorderableDelayedDragStartListener]) so the user can long-press
/// and drag to reorder them. Each drag reorder triggers
/// [onReorderParameter], which persists the new `sort_order` values
/// via the controller.
class _CategoryCard extends StatelessWidget {
  final LabTestDetailCategory category;
  final AppLocalizations l10n;
  final bool isMutating;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onAddParameterTap;
  final void Function(LabTestDetailParameter) onEditParameterTap;
  final void Function(LabTestDetailParameter) onDeleteParameterTap;
  final void Function(int oldIndex, int newIndex) onReorderParameter;

  const _CategoryCard({
    required this.category,
    required this.l10n,
    required this.isMutating,
    required this.onEditTap,
    required this.onDeleteTap,
    required this.onAddParameterTap,
    required this.onEditParameterTap,
    required this.onDeleteParameterTap,
    required this.onReorderParameter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>('edit_category_${category.id}'),
        initiallyExpanded: true,
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            if (category.sortOrder != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
                child: Text(
                  '${category.sortOrder}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: isMutating ? null : onEditTap,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
              onPressed: isMutating ? null : onDeleteTap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        children: [
          // ReorderableListView is safe inside a shrink-wrapped Column
          // because every child has an intrinsic height (no unbounded
          // vertical constraints issue).
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: category.parameters.length,
            onReorder: onReorderParameter,
            itemBuilder: (context, i) {
              final p = category.parameters[i];
              return ReorderableDelayedDragStartListener(
                key: ValueKey('param_${p.id}'),
                index: i,
                child: _ParameterRow(
                  parameter: p,
                  l10n: l10n,
                  isMutating: isMutating,
                  onEditTap: () => onEditParameterTap(p),
                  onDeleteTap: () => onDeleteParameterTap(p),
                ),
              );
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppConstants.paddingMedium,
                end: AppConstants.paddingMedium,
                bottom: AppConstants.paddingSmall,
              ),
              child: TextButton.icon(
                onPressed: isMutating ? null : onAddParameterTap,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addParameterButton),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single parameter row: name | value(+unit) | flag badge | actions.
class _ParameterRow extends StatelessWidget {
  final LabTestDetailParameter parameter;
  final AppLocalizations l10n;
  final bool isMutating;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const _ParameterRow({
    required this.parameter,
    required this.l10n,
    required this.isMutating,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label) = _flagStyle(parameter.flag, l10n);
    final hasFlag = color != null;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: AppConstants.paddingTiny,
      ),
      decoration: hasFlag
          ? BoxDecoration(
              color: color!.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            )
          : null,
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(parameter.name, style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 2,
            child: Text(
              parameter.value + (parameter.unit != null ? ' ${parameter.unit}' : ''),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color!.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
              ),
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: isMutating ? null : onEditTap,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
            onPressed: isMutating ? null : onDeleteTap,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  /// Returns a (color, label) pair for the H/L flag, or (null, null) when
  /// the parameter is within range.
  (Color?, String?) _flagStyle(String? flag, AppLocalizations l10n) {
    switch (flag) {
      case 'H':
        return (AppTheme.error, l10n.labTestFlagHigh);
      case 'L':
        return (AppTheme.info, l10n.labTestFlagLow);
      default:
        return (null, null);
    }
  }
}
