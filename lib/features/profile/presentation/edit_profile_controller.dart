import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../data/models/user_profile.dart';
import '../data/profile_repository.dart';

/// Represents the status of an edit operation.
enum EditStatus { initial, loading, success, error }

/// State model for [EditProfileController].
class EditProfileState {
  final EditStatus status;
  final String? errorMessage;
  final UserProfile? updatedProfile;

  const EditProfileState({
    this.status = EditStatus.initial,
    this.errorMessage,
    this.updatedProfile,
  });

  EditProfileState copyWith({
    EditStatus? status,
    String? errorMessage,
    UserProfile? updatedProfile,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      updatedProfile: updatedProfile ?? this.updatedProfile,
    );
  }
}

/// Controller responsible for editing the profile and managing catalog links.
class EditProfileController extends Notifier<EditProfileState> {
  @override
  EditProfileState build() {
    return const EditProfileState();
  }

  /// Updates the basic profile information (height, weight, etc.).
  Future<void> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(status: EditStatus.loading);
    try {
      final repository = ref.read(profileRepositoryProvider);
      final updated = await repository.updateProfile(request);
      state = state.copyWith(status: EditStatus.success, updatedProfile: updated);
    } on ApiException catch (e) {
      state = state.copyWith(status: EditStatus.error, errorMessage: e.message);
    } on DioException catch (e) {
      final apiError = e.error is ApiException ? e.error as ApiException : null;
      state = state.copyWith(
        status: EditStatus.error,
        errorMessage: apiError?.message ?? e.message,
      );
    } catch (e) {
      state = state.copyWith(status: EditStatus.error, errorMessage: e.toString());
    }
  }

  /// Toggles an allergy link on the profile.
  Future<void> toggleAllergy(String allergyId, bool isAdding) async {
    state = state.copyWith(status: EditStatus.loading);
    try {
      final repository = ref.read(profileRepositoryProvider);
      if (isAdding) {
        await repository.addAllergy(allergyId);
      } else {
        await repository.removeAllergy(allergyId);
      }
      // Refresh the profile data after linking
      final updated = await repository.getProfile();
      state = state.copyWith(status: EditStatus.success, updatedProfile: updated);
    } catch (e) {
      state = state.copyWith(status: EditStatus.error, errorMessage: e.toString());
    }
  }

  /// Toggles an underlying disease link on the profile.
  Future<void> toggleDisease(String diseaseId, bool isAdding) async {
    state = state.copyWith(status: EditStatus.loading);
    try {
      final repository = ref.read(profileRepositoryProvider);
      if (isAdding) {
        await repository.addDisease(diseaseId);
      } else {
        await repository.removeDisease(diseaseId);
      }
      final updated = await repository.getProfile();
      state = state.copyWith(status: EditStatus.success, updatedProfile: updated);
    } catch (e) {
      state = state.copyWith(status: EditStatus.error, errorMessage: e.toString());
    }
  }

  /// Toggles a medical history link on the profile.
  Future<void> toggleHistory(String historyId, bool isAdding) async {
    state = state.copyWith(status: EditStatus.loading);
    try {
      final repository = ref.read(profileRepositoryProvider);
      if (isAdding) {
        await repository.addHistory(historyId);
      } else {
        await repository.removeHistory(historyId);
      }
      final updated = await repository.getProfile();
      state = state.copyWith(status: EditStatus.success, updatedProfile: updated);
    } catch (e) {
      state = state.copyWith(status: EditStatus.error, errorMessage: e.toString());
    }
  }

  /// Resets the state to initial.
  void reset() {
    state = const EditProfileState();
  }
}

/// Riverpod provider for [EditProfileController].
final editProfileControllerProvider = NotifierProvider<EditProfileController, EditProfileState>(() {
  return EditProfileController();
});
