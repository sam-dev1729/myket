import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';
import 'health_overview_provider.dart';
import 'lab_test_list_controller.dart';

/// Riverpod [FutureProvider] that loads a single lab test's detail by id.
///
/// Replaces the old family AsyncNotifier because Riverpod 3 removed
/// `FamilyAsyncNotifier`. Callers get:
/// - `ref.watch(labTestDetailProvider(id))` → `AsyncValue<LabTestDetail>`
/// - `ref.invalidate(labTestDetailProvider(id))` → refresh
/// - [deleteLabTestById] → delete + invalidate downstream providers
final labTestDetailProvider = FutureProvider.family<LabTestDetail, String>((ref, id) async {
  return ref.read(labTestRepositoryProvider).getLabTestDetail(id);
});

/// Deletes the lab test identified by [id] and refreshes every downstream
/// provider that depends on lab-test data.
///
/// Returns `true` on success, `false` if the delete failed. The caller is
/// responsible for showing a Snackbar and popping the detail screen.
Future<bool> deleteLabTestById(WidgetRef ref, String id) async {
  try {
    await ref.read(labTestRepositoryProvider).deleteLabTest(id);
    ref.invalidate(labTestListControllerProvider);
    ref.invalidate(labTestDetailProvider(id));
    ref.invalidate(healthOverviewProvider);
    return true;
  } catch (_) {
    return false;
  }
}
