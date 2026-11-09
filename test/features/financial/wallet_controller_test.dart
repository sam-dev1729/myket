import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/financial/data/financial_repository.dart';
import 'package:myket/features/financial/data/models/common_models.dart';
import 'package:myket/features/financial/data/models/wallet_models.dart';
import 'package:myket/features/financial/presentation/wallet_controller.dart';

import '../../helpers/test_channel_mocks.dart';
import 'financial_fake_repo.dart';

void main() {
  // Pure Dart tests — no platform channels touched. Binding is initialized
  // only because TestChannelMocks.installAll() requires it.
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  // ─────────────────────────────────────────────────────────────
  // walletControllerProvider
  // ─────────────────────────────────────────────────────────────

  group('walletControllerProvider', () {
    test('loads balance into AsyncData', () async {
      final fake = FakeFinancialRepository()
        ..wallet = const WalletModel(id: 'w1', userId: 'u1', balance: 2500000);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(walletControllerProvider.future);

      final state = container.read(walletControllerProvider);
      expect(state, isA<AsyncData<WalletModel>>());
      expect(state.value!.balance, 2500000);
    });

    test('refresh re-fetches and updates balance', () async {
      final fake = FakeFinancialRepository()
        ..wallet = const WalletModel(id: 'w1', userId: 'u1', balance: 2500000);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(walletControllerProvider.future);
      expect(container.read(walletControllerProvider).value!.balance, 2500000);

      fake.wallet = const WalletModel(id: 'w1', userId: 'u1', balance: 9999000);
      await container.read(walletControllerProvider.notifier).refresh();

      expect(container.read(walletControllerProvider).value!.balance, 9999000);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // transactionsControllerProvider
  // ─────────────────────────────────────────────────────────────

  group('transactionsControllerProvider', () {
    test('loads first page', () async {
      final fake = FakeFinancialRepository()
        ..transactionsPage1 = _page(
          page: 1,
          total: 25,
          items: List.generate(20, (i) => _tx('t$i')),
        );
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(transactionsControllerProvider.future);

      final state = container.read(transactionsControllerProvider).value!;
      expect(state.data, hasLength(20));
      expect(state.meta.total, 25);
      expect(state.meta.page, 1);
    });

    test('loadMore appends next page', () async {
      final fake = FakeFinancialRepository()
        ..transactionsPage1 = _page(page: 1, total: 25, items: List.generate(20, (i) => _tx('t$i')))
        ..transactionsPage2 = _page(
          page: 2,
          total: 25,
          items: List.generate(5, (i) => _tx('t${20 + i}')),
        );
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(transactionsControllerProvider.future);
      expect(container.read(transactionsControllerProvider).value!.data, hasLength(20));

      await container.read(transactionsControllerProvider.notifier).loadMore();

      final state = container.read(transactionsControllerProvider).value!;
      expect(state.data, hasLength(25));
      expect(state.data.last.id, 't24');
    });

    test('empty state returns empty list', () async {
      final fake = FakeFinancialRepository()
        ..transactionsPage1 = _page(page: 1, total: 0, items: const []);
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(transactionsControllerProvider.future);

      final state = container.read(transactionsControllerProvider).value!;
      expect(state.data, isEmpty);
      expect(state.meta.total, 0);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // topupControllerProvider
  // ─────────────────────────────────────────────────────────────

  group('topupControllerProvider', () {
    test('submit success transitions idle → loading → success', () async {
      final fake = FakeFinancialRepository()
        ..topupResponse = const TopupResponse(
          transactionId: 't1',
          amount: 100000,
          status: 'PENDING',
          gatewayUrl: 'https://gateway.test/topup/t1',
        );
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(topupControllerProvider);
      expect(container.read(topupControllerProvider).status, TopupStatus.idle);

      await container.read(topupControllerProvider.notifier).submit(100000);

      final state = container.read(topupControllerProvider);
      expect(state.status, TopupStatus.success);
      expect(state.response!.transactionId, 't1');
      expect(state.response!.gatewayUrl, isNotNull);
    });

    test('submit error sets errorMessage', () async {
      final fake = FakeFinancialRepository()..throwOnTopup = Exception('network down');
      final container = _container(fake);
      addTearDown(container.dispose);

      container.read(topupControllerProvider);
      await container.read(topupControllerProvider.notifier).submit(100000);

      final state = container.read(topupControllerProvider);
      expect(state.status, TopupStatus.error);
      expect(state.errorMessage, contains('network down'));
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

PaginatedWalletTransactions _page({
  required int page,
  required int total,
  required List<WalletTransactionModel> items,
}) {
  return PaginatedWalletTransactions(
    meta: PaginationMeta(total: total, page: page, limit: 20, totalPage: (total / 20).ceil()),
    data: items,
  );
}

WalletTransactionModel _tx(String id) => WalletTransactionModel(
  id: id,
  type: 'DEPOSIT',
  reason: 'WALLET_TOPUP',
  amount: 100000,
  paymentMethod: 'GATEWAY',
  gatewayProvider: 'ZARINPAL',
  status: 'SUCCESS',
  description: 'topup',
  createdAt: '2026-11-08T10:00:00.000Z',
);
