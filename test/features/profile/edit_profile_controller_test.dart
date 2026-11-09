import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/features/profile/data/models/user_profile.dart';
import 'package:myket/features/profile/data/profile_repository.dart';
import 'package:myket/features/profile/presentation/edit_profile_controller.dart';

import '../../helpers/test_channel_mocks.dart';
import 'profile_fake_repo.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  group('EditProfileController.updateProfile', () {
    test('success → status=success + updatedProfile', () async {
      final profile = _profile();
      final fake = FakeProfileRepository()
        ..profile = profile
        ..updateResponse = profile;
      final container = _container(fake);
      addTearDown(container.dispose);

      await container
          .read(editProfileControllerProvider.notifier)
          .updateProfile(const UpdateProfileRequest(firstName: 'New'));

      final state = container.read(editProfileControllerProvider);
      expect(state.status, EditStatus.success);
      expect(state.updatedProfile, isNotNull);
      expect(state.errorMessage, isNull);
    });

    test('error → status=error + errorMessage', () async {
      final fake = FakeProfileRepository()..throwOnUpdateProfile = Exception('network down');
      final container = _container(fake);
      addTearDown(container.dispose);

      await container
          .read(editProfileControllerProvider.notifier)
          .updateProfile(const UpdateProfileRequest(firstName: 'X'));

      final state = container.read(editProfileControllerProvider);
      expect(state.status, EditStatus.error);
      expect(state.errorMessage, contains('network down'));
    });
  });

  group('EditProfileController.toggleAllergy', () {
    test('add success → status=success + refreshed profile', () async {
      final profile = _profile();
      final fake = FakeProfileRepository()..profile = profile;
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(editProfileControllerProvider.notifier).toggleAllergy('allergy-1', true);

      final state = container.read(editProfileControllerProvider);
      expect(state.status, EditStatus.success);
      expect(state.updatedProfile, profile);
    });

    test('remove error → status=error', () async {
      final fake = FakeProfileRepository()
        ..profile = _profile()
        ..throwOnRemoveAllergy = Exception('cannot remove');
      final container = _container(fake);
      addTearDown(container.dispose);

      await container
          .read(editProfileControllerProvider.notifier)
          .toggleAllergy('allergy-1', false);

      final state = container.read(editProfileControllerProvider);
      expect(state.status, EditStatus.error);
      expect(state.errorMessage, contains('cannot remove'));
    });
  });

  group('EditProfileController.toggleDisease / toggleHistory', () {
    test('toggleDisease add success → status=success', () async {
      final profile = _profile();
      final fake = FakeProfileRepository()..profile = profile;
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(editProfileControllerProvider.notifier).toggleDisease('disease-1', true);

      expect(container.read(editProfileControllerProvider).status, EditStatus.success);
    });

    test('toggleHistory add success → status=success', () async {
      final profile = _profile();
      final fake = FakeProfileRepository()..profile = profile;
      final container = _container(fake);
      addTearDown(container.dispose);

      await container.read(editProfileControllerProvider.notifier).toggleHistory('history-1', true);

      expect(container.read(editProfileControllerProvider).status, EditStatus.success);
    });
  });

  test('reset → status=initial', () async {
    final profile = _profile();
    final fake = FakeProfileRepository()..profile = profile;
    final container = _container(fake);
    addTearDown(container.dispose);

    await container
        .read(editProfileControllerProvider.notifier)
        .updateProfile(const UpdateProfileRequest(firstName: 'X'));
    expect(container.read(editProfileControllerProvider).status, EditStatus.success);

    container.read(editProfileControllerProvider.notifier).reset();
    expect(container.read(editProfileControllerProvider).status, EditStatus.initial);
  });
}

ProviderContainer _container(FakeProfileRepository fake) => ProviderContainer(
  overrides: [profileRepositoryProvider.overrideWithValue(fake)],
  retry: TestChannelMocks.disabledRetry,
);

UserProfile _profile({String id = 'user-1'}) => UserProfile(
  id: id,
  role: 'PATIENT',
  mobile: '09123456789',
  firstName: 'Ali',
  lastName: 'Test',
  allergies: const [],
  underlyingDiseases: const [],
  medicalHistories: const [],
  googleAccounts: const [],
);
