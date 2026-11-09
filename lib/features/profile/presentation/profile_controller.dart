import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';
import '../data/profile_repository.dart';

/// Controller responsible for managing the user's profile state.
class ProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    return _fetchProfile();
  }

  Future<UserProfile> _fetchProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getProfile();
  }

  /// Manually refreshes the profile data.
  Future<void> refreshProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProfile());
  }
}

/// Riverpod provider for [ProfileController].
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile>(() {
  return ProfileController();
});