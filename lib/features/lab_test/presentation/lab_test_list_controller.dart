import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';

/// Controller responsible for fetching and managing the list of lab tests.
class LabTestListController extends AsyncNotifier<List<LabTestHeader>> {
  @override
  Future<List<LabTestHeader>> build() async {
    return _fetchLabTests();
  }

  /// Fetches the list from the repository.
  Future<List<LabTestHeader>> _fetchLabTests() async {
    final repository = ref.read(labTestRepositoryProvider);
    return repository.getLabTests();
  }

  /// Refreshes the list manually (e.g., after adding a new test).
  Future<void> refreshList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchLabTests());
  }
}

/// Riverpod provider for [LabTestListController].
final labTestListControllerProvider =
    AsyncNotifierProvider<LabTestListController, List<LabTestHeader>>(() {
      return LabTestListController();
    });
