import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/financial/data/financial_repository.dart';
import 'package:myket/features/financial/data/models/package_models.dart';
import 'package:myket/features/financial/data/models/wallet_models.dart';
import 'package:myket/features/financial/presentation/package_controller.dart';

import '../../helpers/test_channel_mocks.dart';
import 'financial_fake_repo.dart';

void main() {
  // Pure Dart tests — no platform channels touched. Binding is initialized
  // only because TestChannelMocks.installAll() requires it.
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  // ─────────────────────────────────────────────────────────────
  // packagesControllerProvider
  // ─────────────────────────────────────────────────────────────

  group('packagesControllerProvider', () {
    test('starts in loading, then resolves to data', () async {
      final fake = FakeFinancialRepository()..packages = [_pkg('p1', 'Basic'), _pkg('p2', 'Pro')];
      final container = _container(fake);
      addTearDown(container.dispose);

      expect(container.read(packagesControllerProvider), isA<AsyncLoading<List<PackageModel>>>());

      await container.read(packagesControllerProvider.future);

      final state = container.read(packagesControllerProvider);
      expect(state, isA<AsyncData<List<PackageModel>>>());
      expect(state.value, hasLength(2));
      expect(state.value!.first.title, 'Basic');
    });

    test('refresh re-fetches and updates state', () async {
      final fake = FakeFinancialRepository()..packages = [_pkg('p1', 'V1')];
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(packagesControllerProvider.future);
      expect(container.read(packagesControllerProvider).value!.first.title, 'V1');

      fake.packages = [_pkg('p1', 'V2'), _pkg('p2', 'V3')];
      await container.read(packagesControllerProvider.notifier).refresh();

      final state = container.read(packagesControllerProvider);
      expect(state.value, hasLength(2));
      expect(state.value!.first.title, 'V2');
    });

    test('exposes AsyncError when repository throws', () async {
      final fake = FakeFinancialRepository()..throwOnGetPackages = Exception('boom');
      final container = _container(fake);
      addTearDown(container.dispose);

      await expectLater(
        container.read(packagesControllerProvider.future),
        throwsA(isA<Exception>()),
      );

      expect(container.read(packagesControllerProvider), isA<AsyncError>());
    });
  });

  // ─────────────────────────────────────────────────────────────
  // buyPackageControllerProvider
  // ─────────────────────────────────────────────────────────────

  group('buyPackageControllerProvider', () {
    test('initial state is idle', () {
      final container = _container(FakeFinancialRepository());
      addTearDown(container.dispose);

      expect(container.read(buyPackageControllerProvider).status, BuyStatus.idle);
    });

    test('submit with useWallet=true → BuyStatus.success', () async {
      final fake = FakeFinancialRepository()
        ..createOrderResponse = const CreateOrderResponse(
          orderId: 'o1',
          discountAmount: 0,
          walletAmount: 500000,
          gatewayAmount: 0,
          status: 'SUCCESS',
        );
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(buyPackageControllerProvider);
      await container
          .read(buyPackageControllerProvider.notifier)
          .submit(packageId: 'p1', useWallet: true);

      final state = container.read(buyPackageControllerProvider);
      expect(state.status, BuyStatus.success);
      expect(state.response!.orderId, 'o1');
      expect(state.response!.gatewayUrl, isNull);
    });

    test('submit with useWallet=false → BuyStatus.pending + gatewayUrl', () async {
      final fake = FakeFinancialRepository()
        ..createOrderResponse = const CreateOrderResponse(
          orderId: 'o2',
          discountAmount: 0,
          walletAmount: 0,
          gatewayAmount: 500000,
          status: 'PENDING',
          gatewayUrl: 'https://gateway.test/pay/o2',
        );
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(buyPackageControllerProvider);
      await container.read(buyPackageControllerProvider.notifier).submit(packageId: 'p1');

      final state = container.read(buyPackageControllerProvider);
      expect(state.status, BuyStatus.pending);
      expect(state.response!.gatewayUrl, 'https://gateway.test/pay/o2');
    });

    test('submit with unknown package → BuyStatus.error', () async {
      // BuyPackageController delegates validation to the backend — there is
      // no local "invalid package ID" no-op. We test the real behavior:
      // the repository throws (PACKAGE_NOT_FOUND) and the controller errors.
      final fake = FakeFinancialRepository()..throwOnCreateOrder = Exception('PACKAGE_NOT_FOUND');
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(buyPackageControllerProvider);
      await container.read(buyPackageControllerProvider.notifier).submit(packageId: 'unknown-id');

      final state = container.read(buyPackageControllerProvider);
      expect(state.status, BuyStatus.error);
      expect(state.errorMessage, contains('PACKAGE_NOT_FOUND'));
    });

    test('reset returns to idle', () async {
      final fake = FakeFinancialRepository()
        ..createOrderResponse = const CreateOrderResponse(
          orderId: 'o1',
          discountAmount: 0,
          walletAmount: 0,
          gatewayAmount: 0,
          status: 'SUCCESS',
        );
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(buyPackageControllerProvider);
      await container.read(buyPackageControllerProvider.notifier).submit(packageId: 'p1');
      expect(container.read(buyPackageControllerProvider).status, BuyStatus.success);

      container.read(buyPackageControllerProvider.notifier).reset();
      expect(container.read(buyPackageControllerProvider).status, BuyStatus.idle);
    });
  });
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

ProviderContainer _container(FakeFinancialRepository fake) {
  return ProviderContainer(
    overrides: [financialRepositoryProvider.overrideWithValue(fake)],
    retry: TestChannelMocks.disabledRetry,
  );
}

PackageModel _pkg(String id, String title) =>
    PackageModel(id: id, title: title, price: 500000, durationDays: 30, type: 'BLOOD');
