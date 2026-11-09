import 'package:flutter_riverpod/flutter_riverpod.dart';

import './../profile_controller.dart';

/// Result of the profile-completeness check.
///
/// A user must complete a set of mandatory fields before gated flows (e.g.
/// AI lab-test extraction) become available.
class ProfileCompleteness {
  /// Whether every mandatory field is filled in.
  final bool isComplete;

  /// Human-readable list of mandatory field keys still missing.
  final List<String> missingFields;

  const ProfileCompleteness({required this.isComplete, required this.missingFields});
}

/// Mandatory profile-field keys used by [ProfileCompleteness].
class MandatoryProfileFields {
  const MandatoryProfileFields._();

  static const String birthDate = 'birth_date';
  static const String bloodType = 'blood_type';
  static const String isMale = 'is_male';
}

/// Derives [ProfileCompleteness] from the current [profileControllerProvider].
///
/// Only fields strictly required by the backend + clinical flows are checked:
/// `birth_date`, `blood_type`, and `is_male`.
final profileCompletenessProvider = Provider<ProfileCompleteness>((ref) {
  final profileAsync = ref.watch(profileControllerProvider);
  final profile = profileAsync.asData?.value;

  if (profile == null) {
    return const ProfileCompleteness(
      isComplete: false,
      missingFields: [
        MandatoryProfileFields.birthDate,
        MandatoryProfileFields.bloodType,
        MandatoryProfileFields.isMale,
      ],
    );
  }

  final missing = <String>[];
  if (profile.birthDate == null || profile.birthDate!.isEmpty) {
    missing.add(MandatoryProfileFields.birthDate);
  }
  if (profile.bloodType == null || profile.bloodType!.isEmpty) {
    missing.add(MandatoryProfileFields.bloodType);
  }
  if (profile.isMale == null) {
    missing.add(MandatoryProfileFields.isMale);
  }

  return ProfileCompleteness(isComplete: missing.isEmpty, missingFields: missing);
});
