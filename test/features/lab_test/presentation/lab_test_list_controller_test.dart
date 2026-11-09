import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/lab_test_list_controller.dart';

// Corrected path: 3 levels up (presentation → lab_test → features → test).
import '../../../helpers/test_channel_mocks.dart';

/// Mock of [LabTestRepository] to isolate the controller from networking.
class MockLabTestRepository extends Mock implements LabTestRepository {}

void main() {
  late MockLabTestRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockLabTestRepository();
    container = ProviderContainer(
      overrides: [labTestRepositoryProvider.overrideWithValue(mockRepository)],
      // Riverpod 3 auto-retries failed AsyncNotifier builds. During the retry
      // window the state is `AsyncLoading(error: ..., retrying: true)` — not
      // `AsyncError` — which breaks the assertion below. Disabling retry makes
      // the state settle deterministically on `AsyncError` after the first
      // failed build.
      retry: TestChannelMocks.disabledRetry,
    );
  });

  tearDown(() => container.dispose());

  group('LabTestListController', () {
    test('should fetch lab tests successfully on build', () async {
      final labTests = [
        const LabTestHeader(id: '1', labName: 'Lab A'),
        const LabTestHeader(id: '2', labName: 'Lab B'),
      ];
      when(() => mockRepository.getLabTests()).thenAnswer((_) async => labTests);

      final state = await container.read(labTestListControllerProvider.future);

      expect(state.length, 2);
      expect(state.first.labName, 'Lab A');
      verify(() => mockRepository.getLabTests()).called(1);
    });

    test('should handle error when fetching lab tests fails', () async {
      when(
        () => mockRepository.getLabTests(),
      ).thenAnswer((_) => Future<List<LabTestHeader>>.error(Exception('Network Error')));

      // A listener + Completer is used to wait until the provider has settled
      // on an error, regardless of whether it takes one or several microtasks.
      final completer = Completer<void>();
      final sub = container.listen(labTestListControllerProvider, (previous, next) {
        if (next.hasError && !completer.isCompleted) {
          completer.complete();
        }
      }, fireImmediately: true);
      addTearDown(sub.close);

      await completer.future.timeout(
        TestChannelConstants.providerSettleTimeout,
        onTimeout: () => fail(
          'Provider did not emit AsyncError in time. '
          'Current state: ${container.read(labTestListControllerProvider)}',
        ),
      );

      final state = container.read(labTestListControllerProvider);
      // With retry disabled, the state must be the terminal `AsyncError`.
      expect(state, isA<AsyncError>());
      expect(state.hasError, isTrue);
    });

    test('should refresh list and update state', () async {
      final initialTests = [const LabTestHeader(id: '1', labName: 'Old Lab')];
      final refreshedTests = [
        const LabTestHeader(id: '1', labName: 'Old Lab'),
        const LabTestHeader(id: '2', labName: 'New Lab'),
      ];

      when(() => mockRepository.getLabTests()).thenAnswer((_) async => initialTests);
      await container.read(labTestListControllerProvider.future);

      when(() => mockRepository.getLabTests()).thenAnswer((_) async => refreshedTests);
      await container.read(labTestListControllerProvider.notifier).refreshList();

      final state = container.read(labTestListControllerProvider);
      expect(state.value?.length, 2);
      expect(state.value?.last.labName, 'New Lab');
      verify(() => mockRepository.getLabTests()).called(2);
    });
  });
}
