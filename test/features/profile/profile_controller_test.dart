import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/profile/data/models/user_profile.dart';
import 'package:myket/features/profile/data/profile_repository.dart';
import 'package:myket/features/profile/presentation/profile_controller.dart';

import '../../helpers/test_channel_mocks.dart';
import 'profile_fake_repo.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  group('profileControllerProvider', () {
    test('build loads profile', () async {
      final fake = FakeProfileRepository()..profile = _profile(firstName: 'V1');
      final container = _container(fake);
      addTearDown(container.dispose);

      final result = await container.read(profileControllerProvider.future);
      expect(result.firstName, 'V1');
    });

    test('refreshProfile re-fetches and updates', () async {
      final fake = FakeProfileRepository()..profile = _profile(firstName: 'V1');
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(profileControllerProvider.future);
      expect(container.read(profileControllerProvider).value!.firstName, 'V1');

      fake.profile = _profile(firstName: 'V2');
      await container.read(profileControllerProvider.notifier).refreshProfile();

      expect(container.read(profileControllerProvider).value!.firstName, 'V2');
    });

    test('build throws → AsyncError', () async {
      final fake = FakeProfileRepository()..throwOnGetProfile = Exception('boom');
      final container = _container(fake);
      addTearDown(container.dispose);

      await expectLater(
        container.read(profileControllerProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(profileControllerProvider), isA<AsyncError>());
    });
  });
}

ProviderContainer _container(FakeProfileRepository fake) => ProviderContainer(
  overrides: [profileRepositoryProvider.overrideWithValue(fake)],
  retry: TestChannelMocks.disabledRetry,
);

UserProfile _profile({String firstName = 'Ali'}) => UserProfile(
  id: 'user-1',
  role: 'PATIENT',
  mobile: '09123456789',
  firstName: firstName,
  lastName: 'Test',
  allergies: const [],
  underlyingDiseases: const [],
  medicalHistories: const [],
  googleAccounts: const [],
);
