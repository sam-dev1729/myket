import '../../../features/profile/data/models/user_profile.dart';

/// Returns a list of seeded mock users for the mock environment.
///
/// These users can log in with any OTP (mock accepts everything).
List<UserProfile> mockSeedUsers() {
  return [
    UserProfile(
      id: 'mock-user-001',
      role: 'PATIENT',
      mobile: '09120000001',
      firstName: 'سام',
      lastName: 'محمدی',
      birthDate: '1990-01-15',
      isMale: true,
      height: 178,
      weight: 75,
      bloodType: 'A_POSITIVE',
      city: const CityInfo(
        id: 'mock-city-tehran',
        name: 'تهران',
        provinceId: 'mock-province-tehran',
      ),
      allergies: [
        LinkedItem(
          id: 'mock-link-1',
          allergy: const MedicalCatalogItem(
            id: 'mock-allergy-1',
            name: 'پنی‌سیلین',
            isSystem: true,
          ),
        ),
      ],
      underlyingDiseases: const [],
      medicalHistories: const [],
      googleAccounts: const [],
    ),
    UserProfile(
      id: 'mock-user-002',
      role: 'PATIENT',
      mobile: '09120000002',
      firstName: 'مریم',
      lastName: 'رضایی',
      birthDate: '1995-06-20',
      isMale: false,
      height: 165,
      weight: 62,
      isPregnant: false,
      bloodType: 'O_POSITIVE',
      city: const CityInfo(
        id: 'mock-city-tehran',
        name: 'تهران',
        provinceId: 'mock-province-tehran',
      ),
      allergies: const [],
      underlyingDiseases: const [],
      medicalHistories: const [],
      googleAccounts: const [],
    ),
  ];
}
