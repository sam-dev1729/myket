import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/financial/data/models/common_models.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/lab_overview_provider.dart';

import '../../../helpers/test_channel_mocks.dart';
import '../data/lab_test_fake_repo.dart';


void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  group('labOverviewProvider', () {
    test('loads overview', () async {
      final fake = FakeLabTestRepository()
        ..overview = const LabOverview(overallStatus: 'green', parameters: [], advice: '');
      final container = _container(fake);
      addTearDown(container.dispose);

      final result = await container.read(labOverviewProvider.future);
      expect(result.overallStatus, 'green');
    });

    test('error → Future throws', () async {
      final fake = FakeLabTestRepository()..throwOnGetLabOverview = Exception('boom');
      final container = _container(fake);
      addTearDown(container.dispose);

      await expectLater(container.read(labOverviewProvider.future), throwsA(isA<Exception>()));
    });
  });

  group('labOverviewParametersControllerProvider', () {
    test('loads first page', () async {
      final fake = FakeLabTestRepository()..overviewParametersPage1 = _paramsPage(1, 25, 20);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(labOverviewParametersControllerProvider.future);
      final state = container.read(labOverviewParametersControllerProvider).value!;
      expect(state.items, hasLength(20));
      expect(state.meta.total, 25);
      expect(state.meta.page, 1);
    });

    test('loadMore appends page 2', () async {
      final fake = FakeLabTestRepository()
        ..overviewParametersPage1 = _paramsPage(1, 25, 20)
        ..overviewParametersPage2 = _paramsPage(2, 25, 5);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(labOverviewParametersControllerProvider.future);
      await container.read(labOverviewParametersControllerProvider.notifier).loadMore();

      final state = container.read(labOverviewParametersControllerProvider).value!;
      expect(state.items, hasLength(25));
      expect(state.items.last.name, 'P2_4');
    });
  });
}

ProviderContainer _container(FakeLabTestRepository fake) => ProviderContainer(
  overrides: [labTestRepositoryProvider.overrideWithValue(fake)],
  retry: TestChannelMocks.disabledRetry,
);

PaginatedLabOverviewParameters _paramsPage(int page, int total, int count) {
  return PaginatedLabOverviewParameters(
    meta: PaginationMeta(total: total, page: page, limit: 20, totalPage: (total / 20).ceil()),
    data: List.generate(count, (i) => LabOverviewParameter(name: 'P${page}_$i', value: '${i + 1}')),
    overallStatus: 'green',
  );
}
