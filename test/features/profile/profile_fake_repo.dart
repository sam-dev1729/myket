import 'package:dio/dio.dart';
import 'package:myket/features/profile/data/models/user_profile.dart';
import 'package:myket/features/profile/data/profile_api.dart';
import 'package:myket/features/profile/data/profile_repository.dart';

/// Hand-rolled fake of [ProfileRepository] used by profile controller tests.
///
/// Configurable via public fields; never touches Dio or any platform channel.
class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository() : super(ProfileApi(Dio()));

  /// Response returned by [getProfile] (and [updateProfile] when
  /// [updateResponse] is null).
  UserProfile? profile;

  /// Response returned by [updateProfile] (falls back to [profile]).
  UserProfile? updateResponse;

  // ── Configurable errors ──
  Exception? throwOnGetProfile;
  Exception? throwOnUpdateProfile;
  Exception? throwOnAddAllergy;
  Exception? throwOnRemoveAllergy;
  Exception? throwOnAddDisease;
  Exception? throwOnRemoveDisease;
  Exception? throwOnAddHistory;
  Exception? throwOnRemoveHistory;

  @override
  Future<UserProfile> getProfile() async {
    if (throwOnGetProfile != null) throw throwOnGetProfile!;
    return profile!;
  }

  @override
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    if (throwOnUpdateProfile != null) throw throwOnUpdateProfile!;
    return updateResponse ?? profile!;
  }

  @override
  Future<void> addAllergy(String allergyId) async {
    if (throwOnAddAllergy != null) throw throwOnAddAllergy!;
  }

  @override
  Future<void> removeAllergy(String allergyId) async {
    if (throwOnRemoveAllergy != null) throw throwOnRemoveAllergy!;
  }

  @override
  Future<void> addDisease(String diseaseId) async {
    if (throwOnAddDisease != null) throw throwOnAddDisease!;
  }

  @override
  Future<void> removeDisease(String diseaseId) async {
    if (throwOnRemoveDisease != null) throw throwOnRemoveDisease!;
  }

  @override
  Future<void> addHistory(String historyId) async {
    if (throwOnAddHistory != null) throw throwOnAddHistory!;
  }

  @override
  Future<void> removeHistory(String historyId) async {
    if (throwOnRemoveHistory != null) throw throwOnRemoveHistory!;
  }
}
