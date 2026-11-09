import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/core/utils/optional.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/edit_lab_test_controller.dart';


import '../../../helpers/test_channel_mocks.dart';
import '../data/lab_test_fake_repo.dart';


void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  group('EditLabTestController', () {
    test('initialize sets detail + success status', () {
      final detail = _detail();
      final fake = FakeLabTestRepository()..detail = detail;
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(editLabTestControllerProvider.notifier).initialize(detail);

      final state = container.read(editLabTestControllerProvider);
      expect(state.status, EditLabTestStatus.success);
      expect(state.detail, detail);
      expect(state.isMutating, isFalse);
    });

    test('updateHeader success → success + not mutating', () async {
      final detail = _detail();
      final fake = FakeLabTestRepository()..detail = detail;
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(editLabTestControllerProvider.notifier).initialize(detail);
      final ok = await container
          .read(editLabTestControllerProvider.notifier)
          .updateHeader(const UpdateLabTestHeaderRequest(doctorName: Optional.of('Dr. X')));

      expect(ok, isTrue);
      final state = container.read(editLabTestControllerProvider);
      expect(state.status, EditLabTestStatus.success);
      expect(state.isMutating, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('updateHeader error → error + errorMessage', () async {
      final detail = _detail();
      final fake = FakeLabTestRepository()
        ..detail = detail
        ..throwOnUpdateHeader = Exception('network down');
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(editLabTestControllerProvider.notifier).initialize(detail);
      final ok = await container
          .read(editLabTestControllerProvider.notifier)
          .updateHeader(const UpdateLabTestHeaderRequest(doctorName: Optional.of('Dr. X')));

      expect(ok, isFalse);
      final state = container.read(editLabTestControllerProvider);
      expect(state.status, EditLabTestStatus.error);
      expect(state.isMutating, isFalse);
      expect(state.errorMessage, contains('network down'));
    });

    test('deleteParameter success → success', () async {
      final detail = _detail();
      final fake = FakeLabTestRepository()..detail = detail;
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(editLabTestControllerProvider.notifier).initialize(detail);
      final ok = await container
          .read(editLabTestControllerProvider.notifier)
          .deleteParameter('param-1');

      expect(ok, isTrue);
      expect(container.read(editLabTestControllerProvider).status, EditLabTestStatus.success);
    });

    test('updateCategory with sortOrder → success', () async {
      final detail = _detail();
      final fake = FakeLabTestRepository()..detail = detail;
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(editLabTestControllerProvider.notifier).initialize(detail);
      final ok = await container
          .read(editLabTestControllerProvider.notifier)
          .updateCategory('cat-1', sortOrder: 3);

      expect(ok, isTrue);
      expect(container.read(editLabTestControllerProvider).status, EditLabTestStatus.success);
    });

    test('updateParameter with sortOrder Optional → success', () async {
      final detail = _detail();
      final fake = FakeLabTestRepository()..detail = detail;
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(editLabTestControllerProvider.notifier).initialize(detail);
      final ok = await container
          .read(editLabTestControllerProvider.notifier)
          .updateParameter(
            'param-1',
            const UpdateLabTestParameterRequest(sortOrder: Optional.of(2)),
          );

      expect(ok, isTrue);
      expect(container.read(editLabTestControllerProvider).status, EditLabTestStatus.success);
    });
  });
}

ProviderContainer _container(FakeLabTestRepository fake) => ProviderContainer(
  overrides: [labTestRepositoryProvider.overrideWithValue(fake)],
  retry: TestChannelMocks.disabledRetry,
);

LabTestDetail _detail({String id = 'test-1'}) => LabTestDetail(
  id: id,
  testDate: '2026-11-08',
  doctorName: 'Dr. A',
  labName: 'Lab A',
  files: const [],
  categories: const [],
);
