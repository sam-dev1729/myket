import '../../../features/profile/data/models/user_profile.dart';

/// Returns the seeded allergy catalog items.
List<MedicalCatalogItem> mockSeedAllergies() => const [
  MedicalCatalogItem(id: 'mock-allergy-1', name: 'پنی‌سیلین', isSystem: true),
  MedicalCatalogItem(id: 'mock-allergy-2', name: 'آسپیرین', isSystem: true),
  MedicalCatalogItem(id: 'mock-allergy-3', name: 'بادام‌زمینی', isSystem: true),
  MedicalCatalogItem(id: 'mock-allergy-4', name: 'گرده گل', isSystem: true),
  MedicalCatalogItem(id: 'mock-allergy-5', name: 'شیر', isSystem: true),
  MedicalCatalogItem(id: 'mock-allergy-6', name: 'تخم‌مرغ', isSystem: true),
  MedicalCatalogItem(id: 'mock-allergy-7', name: 'گوشت قرمز', isSystem: true),
  MedicalCatalogItem(id: 'mock-allergy-8', name: 'گرد و غبار', isSystem: true),
];

/// Returns the seeded underlying-disease catalog items.
List<MedicalCatalogItem> mockSeedUnderlyingDiseases() => const [
  MedicalCatalogItem(id: 'mock-disease-1', name: 'دیابت نوع ۲', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-2', name: 'فشار خون بالا', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-3', name: 'آسم', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-4', name: 'کم‌کاری تیروئید', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-5', name: 'چربی خون', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-6', name: 'بیماری قلبی', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-7', name: 'کبد چرب', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-8', name: 'نقرس', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-9', name: 'کم‌خونی', isSystem: true),
  MedicalCatalogItem(id: 'mock-disease-10', name: 'آلزایمر', isSystem: true),
];

/// Returns the seeded medical-history catalog items.
List<MedicalCatalogItem> mockSeedMedicalHistories() => const [
  MedicalCatalogItem(id: 'mock-history-1', name: 'آپاندیسیت', isSystem: true),
  MedicalCatalogItem(id: 'mock-history-2', name: 'سزارین', isSystem: true),
  MedicalCatalogItem(id: 'mock-history-3', name: 'شکستگی استخوان', isSystem: true),
  MedicalCatalogItem(id: 'mock-history-4', name: 'جراحی قلب', isSystem: true),
  MedicalCatalogItem(id: 'mock-history-5', name: 'سنگ کلیه', isSystem: true),
];
