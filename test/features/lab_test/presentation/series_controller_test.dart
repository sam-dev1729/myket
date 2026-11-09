import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/financial/data/models/common_models.dart';
import 'package:myket/features/lab_test/data/lab_test_repository.dart';
import 'package:myket/features/lab_test/data/models/lab_test_models.dart';
import 'package:myket/features/lab_test/presentation/series_controller.dart';

import '../../../helpers/test_channel_mocks.dart';
import '../data/lab_test_fake_repo.dart';


void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  group('userAnalytesControllerProvider', () {
    test('loads first page', () async {
      final fake = FakeLabTestRepository()..analytesPage1 = _analytesPage(1, 25, 20);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(userAnalytesControllerProvider.future);
      final state = container.read(userAnalytesControllerProvider).value!;
      expect(state.items, hasLength(20));
      expect(state.meta.total, 25);
    });

    test('loadMore appends page 2', () async {
      final fake = FakeLabTestRepository()
        ..analytesPage1 = _analytesPage(1, 25, 20)
        ..analytesPage2 = _analytesPage(2, 25, 5);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(userAnalytesControllerProvider.future);
      await container.read(userAnalytesControllerProvider.notifier).loadMore();

      final state = container.read(userAnalytesControllerProvider).value!;
      expect(state.items, hasLength(25));
    });
  });

  group('labSeriesProvider', () {
    test('loads series', () async {
      final fake = FakeLabTestRepository()
        ..seriesResponse = const LabSeriesResponse(
          series: [LabSeries(analyteId: 'a1', analyteName: 'Name', unit: 'mg/dL', points: [])],
        );
      final container = _container(fake);
      addTearDown(container.dispose);

      final ids = ['a1'];
      final result = await container.read(labSeriesProvider(ids).future);
      expect(result.series, hasLength(1));
      expect(result.series.first.analyteId, 'a1');
    });

    test('empty ids → empty response', () async {
      final container = _container(FakeLabTestRepository());
      addTearDown(container.dispose);

      final result = await container.read(labSeriesProvider(const []).future);
      expect(result.series, isEmpty);
    });
  });
}

ProviderContainer _container(FakeLabTestRepository fake) => ProviderContainer(
  overrides: [labTestRepositoryProvider.overrideWithValue(fake)],
  retry: TestChannelMocks.disabledRetry,
);

PaginatedUserAnalytes _analytesPage(int page, int total, int count) {
  return PaginatedUserAnalytes(
    meta: PaginationMeta(total: total, page: page, limit: 20, totalPage: (total / 20).ceil()),
    data: List.generate(
      count,
      (i) => UserAnalyte(
        id: 'a${page}_$i',
        code: 'C$i',
        name: 'N${page}_$i',
        valueType: 'NUMERIC',
        sortOrder: i,
        observationCount: 1,
      ),
    ),
  );
}
