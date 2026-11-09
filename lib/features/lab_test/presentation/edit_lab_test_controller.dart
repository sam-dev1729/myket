import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';

/// Status enum for edit operations.
enum EditLabTestStatus { initial, loading, success, error }

/// State model for [EditLabTestController].
///
/// Holds the current lab test detail together with mutation status flags
/// so the UI can disable buttons or show progress indicators while a
/// mutation is in flight.
class EditLabTestState {
  /// Current operation status.
  final EditLabTestStatus status;

  /// The current (possibly edited) detail of the lab test.
  final LabTestDetail? detail;

  /// Error message (null unless status == error).
  final String? errorMessage;

  /// Whether a mutation (create/update/delete) is in flight.
  final bool isMutating;

  const EditLabTestState({
    this.status = EditLabTestStatus.initial,
    this.detail,
    this.errorMessage,
    this.isMutating = false,
  });

  /// Returns a new state with the provided fields overridden.
  ///
  /// Pass [clearError] = true to explicitly reset [errorMessage] to null
  /// (needed because `errorMessage ?? this.errorMessage` otherwise keeps
  /// the old value).
  EditLabTestState copyWith({
    EditLabTestStatus? status,
    LabTestDetail? detail,
    String? errorMessage,
    bool? isMutating,
    bool clearError = false,
  }) => EditLabTestState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    isMutating: isMutating ?? this.isMutating,
  );
}

/// Controller responsible for editing a lab test's categories and parameters.
///
/// Call [initialize] with the loaded [LabTestDetail] from the detail screen,
/// then use the CRUD methods. After every successful mutation, [detail] is
/// refreshed from the backend so the UI stays in sync.
class EditLabTestController extends Notifier<EditLabTestState> {
  @override
  EditLabTestState build() => const EditLabTestState();

  /// Sets the initial detail. Called once from the screen's `_init`.
  void initialize(LabTestDetail detail) {
    state = EditLabTestState(status: EditLabTestStatus.success, detail: detail);
  }

  /// Marks the controller as errored when the *initial* fetch fails.
  ///
  /// Used by the screen's `_init` catch block — for refresh failures with
  /// existing data, the screen shows a snackbar and keeps the old detail
  /// instead of calling this method.
  void setError(String message) {
    state = state.copyWith(status: EditLabTestStatus.error, errorMessage: message);
  }

  String? get _id => state.detail?.id;

  /// Reloads the detail from the backend (after any mutation).
  Future<void> _refresh() async {
    final id = _id;
    if (id == null) return;
    final refreshed = await ref.read(labTestRepositoryProvider).getLabTestDetail(id);
    state = state.copyWith(detail: refreshed);
  }

  /// Wraps a mutation with isMutating + error handling + auto-refresh.
  Future<bool> _runMutation(Future<void> Function() action) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await action();
      await _refresh();
      state = state.copyWith(isMutating: false, status: EditLabTestStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        isMutating: false,
        status: EditLabTestStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Updates the header of the test.
  Future<bool> updateHeader(UpdateLabTestHeaderRequest request) async {
    final id = _id;
    if (id == null) return false;
    return _runMutation(() => ref.read(labTestRepositoryProvider).updateLabTestHeader(id, request));
  }

  /// Creates a new empty category.
  Future<bool> createCategory(String name, {int? sortOrder}) async {
    final id = _id;
    if (id == null) return false;
    return _runMutation(
      () => ref
          .read(labTestRepositoryProvider)
          .createCategory(id, CreateLabTestCategoryRequest(name: name, sortOrder: sortOrder)),
    );
  }

  /// Renames a category and/or changes its sort order.
  Future<bool> updateCategory(String categoryId, {String? name, int? sortOrder}) async {
    final id = _id;
    if (id == null) return false;
    return _runMutation(
      () => ref
          .read(labTestRepositoryProvider)
          .updateCategory(
            id,
            categoryId,
            UpdateLabTestCategoryRequest(name: name, sortOrder: sortOrder),
          ),
    );
  }

  /// Deletes a category and all its parameters (cascade).
  Future<bool> deleteCategory(String categoryId) async {
    final id = _id;
    if (id == null) return false;
    return _runMutation(
      () => ref.read(labTestRepositoryProvider).deleteCategory(id, categoryId).then((_) {}),
    );
  }

  /// Creates a new parameter in a category.
  Future<bool> createParameter(CreateLabTestParameterRequest request) async {
    final id = _id;
    if (id == null) return false;
    return _runMutation(
      () => ref.read(labTestRepositoryProvider).createParameter(id, request).then((_) {}),
    );
  }

  /// Updates a parameter (including moving it to another category).
  Future<bool> updateParameter(String parameterId, UpdateLabTestParameterRequest request) async {
    final id = _id;
    if (id == null) return false;
    return _runMutation(
      () => ref
          .read(labTestRepositoryProvider)
          .updateParameter(id, parameterId, request)
          .then((_) {}),
    );
  }

  /// Deletes a single parameter.
  Future<bool> deleteParameter(String parameterId) async {
    final id = _id;
    if (id == null) return false;
    return _runMutation(() => ref.read(labTestRepositoryProvider).deleteParameter(id, parameterId));
  }

  /// Clears the error message (for UI dismissal).
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Riverpod provider for [EditLabTestController].
final editLabTestControllerProvider = NotifierProvider<EditLabTestController, EditLabTestState>(
  EditLabTestController.new,
);
