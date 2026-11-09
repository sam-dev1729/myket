import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'models/user_profile.dart';
import 'profile_api.dart';

/// Repository for managing profile data from the backend.
class ProfileRepository {
  final ProfileApi api;

  ProfileRepository(this.api);

  /// Fetches the profile of the currently authenticated user.
  Future<UserProfile> getProfile() async {
    final response = await api.getProfile();
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Updates the authenticated user's profile.
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    final response = await api.updateProfile(request);
    if (!response.success) throw response.error!;
    return response.body!;
  }

  /// Attaches a Google account to the profile.
  Future<void> attachGoogleAccount(String openId, String email) async {
    final response = await api.attachGoogleAccount({
      'google_open_id': openId,
      'google_email': email,
    });
    if (!response.success) throw response.error!;
  }

  /// Detaches a Google account from the profile using its internal ID.
  Future<void> detachGoogleAccount(String accountId) async {
    final response = await api.detachGoogleAccount({'google_account_id': accountId});
    if (!response.success) throw response.error!;
  }

  /// Links an allergy to the profile.
  Future<void> addAllergy(String allergyId) async {
    final response = await api.addAllergy({'allergy_id': allergyId});
    if (!response.success) throw response.error!;
  }

  /// Removes an allergy from the profile.
  Future<void> removeAllergy(String allergyId) async {
    final response = await api.removeAllergy({'allergy_id': allergyId});
    if (!response.success) throw response.error!;
  }

  /// Links an underlying disease to the profile.
  Future<void> addDisease(String diseaseId) async {
    final response = await api.addDisease({'underlying_disease_id': diseaseId});
    if (!response.success) throw response.error!;
  }

  /// Removes an underlying disease from the profile.
  Future<void> removeDisease(String diseaseId) async {
    final response = await api.removeDisease({'underlying_disease_id': diseaseId});
    if (!response.success) throw response.error!;
  }

  /// Links a medical history item to the profile.
  Future<void> addHistory(String historyId) async {
    final response = await api.addHistory({'medical_history_id': historyId});
    if (!response.success) throw response.error!;
  }

  /// Removes a medical history item from the profile.
  Future<void> removeHistory(String historyId) async {
    final response = await api.removeHistory({'medical_history_id': historyId});
    if (!response.success) throw response.error!;
  }
}

/// Riverpod provider for [ProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final api = ProfileApi(apiClient.dio);
  return ProfileRepository(api);
});
